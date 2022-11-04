# frozen_string_literal: true

# Utility class that calculates aggregate results from a list of scores.
# Scores of multiple players can be passed, but the player value will be ignored and stripped away from the scores.
# It is up to the caller to decide if it should aggregate scores for multiple players or for a single player.
# Returns an object with:
# * high_score => the first top score from the list in order
# * low_score => the first lowest score from the list in order
# * avg_score => the average score, up to 2 decimals
# * scores => the list of scores
#
# ==== Examples
# HistoryUtils.aggregate_scores([
#   Score.new(player: 'A', score: 6, time: now.prev_day(1)),
#   Score.new(player: 'A', score: 8, time: now.prev_day(3))
# ])
# # =>
# {
#   high_score: { score: 8, time: now.prev_day(3) },
#   low_score: { score: 6, time: now.prev_day(1) },
#   avg_score: 7,
#   scores: [{ score: 6, time: now.prev_day(1) }, { score: 8, time: now.prev_day(3) }]
# }
class HistoryUtils
  include Swagger::Blocks

  swagger_schema :HistorySchema do
    property :high_score do
      key :description, 'Highest score for the player'
      key :type, :object
      property :score do
        key :type, :integer
        key :format, :int32
      end
      property :time do
        key :type, :string
        key :description, 'DateTime in ISO8601 format'
      end
    end
    property :low_score do
      key :description, 'Lowest score for the player'
      key :type, :object
      property :score do
        key :type, :integer
        key :format, :int32
      end
      property :time do
        key :type, :string
        key :description, 'DateTime in ISO8601 format'
      end
    end
    property :avg_score do
      key :type, :number
      key :format, :float
      key :description, 'Average score for the player'
    end
    property :scores do
      key :type, :array
      items do
        property :score do
          key :type, :integer
          key :format, :int32
        end
        property :time do
          key :type, :string
          key :description, 'DateTime in ISO8601 format'
        end
      end
    end
  end
  def self.aggregate_scores(scores)
    scores = scores.map { |s| { score: s.score, time: s.time } }
    max_score, min_score, total_score = calculate_max_min_total(scores)
    {
      high_score: max_score,
      low_score: min_score,
      avg_score: (total_score.to_f / scores.length).round(2),
      scores: scores
    }
  end

  class << self
    private

    def calculate_max_min_total(scores)
      max_score = min_score = scores.first
      total_score = 0
      scores.each do |s|
        if s[:score] > max_score[:score]
          max_score = s
        elsif s[:score] < min_score[:score]
          min_score = s
        end
        total_score += s[:score]
      end
      [max_score, min_score, total_score]
    end
  end
end
