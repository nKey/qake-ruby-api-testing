# frozen_string_literal: true

# Represents a score for the game, achieved by a specific player at the specified time
# All attributes are mandatory.
# The score value must be greater than 0
#
# ==== Examples
#
# Score.create(player: "John Doe", score: 10, time: Time.now).valid? # => true
# Score.create(player: "John Doe", score: -10, time: Time.now).valid? # => false
# Score.create(score: 10, time: Time.now).valid? # => false
# Score.create(player: "John Doe", time: Time.now).valid? # => false
# Score.create(player: "John Doe", score: -10).valid? # => false
class Score < ApplicationRecord
  validates :player, presence: true
  validates :time, presence: true
  validates :score, presence: true, numericality: { greater_than: 0 }

  swagger_schema :ScoreSchema do
    key :required, [:player, :time, :score]
    property :player do
      key :type, :string
      key :description, 'Player id, case insensitive'
    end
    property :time do
      key :type, :string
      key :description, "DateTime in ISO8601 format, like: #{DateTime.now.iso8601}"
    end
    property :score do
      key :type, :integer
      key :description, 'Score as a strictly positive integer'
    end
  end

  # Returns an ActiveRecord::Relation that filters the scores by the given `players`.
  # `players` can be a string representing a single player, or an array of strings representing multiple players.
  # When an array is passed, it will filter scores for all the given players.
  # When an empty array, or empty string is passed, it will not filter by player, so all scores are returned.
  #
  # === Examples
  #
  # Score.by_players('A') => will filter scores for player A
  # Score.by_players(['A','B']) => will filter scores for both players A and B
  # Score.by_players([]) => will filter scores for all players
  # Score.by_players('') => will filter scores for all players
  # Score.by_players(nil) => will filter scores for all players
  def self.by_players(players)
    return where(nil) unless players.present?

    where(player: players)
  end

  # Returns an ActiveRecord::Relation that filters the scores before the given `date`.
  # A DateTime object should be passed as argument.
  # When nil is passed, it returns all scores.
  #
  # === Examples
  #
  # Score.before(DateTime.now.prev_day(1)) => will exclude scores of the last 24 hours
  # Score.before(nil) => will return all scores
  def self.before(date)
    return where(nil) unless date_filter_is_valid(date)

    where('time <= ?', date)
  end

  # Returns an ActiveRecord::Relation that filters the scores after the given `date`.
  # A DateTime object should be passed as argument.
  # When nil is passed, it returns all scores.
  #
  # === Examples
  #
  # Score.after(Time.now.prev_day(1)) => will include scores of the last 24 hours
  # Score.after(nil) => will return all scores
  def self.after(date)
    return where(nil) unless date_filter_is_valid(date)

    where('time >= ?', date)
  end

  class << self
    private

    def date_filter_is_valid(date)
      date.present? && (date.is_a?(DateTime) || date.is_a?(Time))
    end
  end
end
