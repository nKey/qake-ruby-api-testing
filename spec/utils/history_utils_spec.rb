# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HistoryUtils, type: :model do
  describe 'aggregate_scores' do
    let!(:now) { Time.now }
    let!(:scores) do
      [
        Score.new(player: 'A', score: 5, time: now.prev_day(1)),
        Score.new(player: 'A', score: 8, time: now.prev_day(3)),
        Score.new(player: 'A', score: 6, time: now.prev_day(3)),
        Score.new(player: 'A', score: 10, time: now.prev_day(5)),
        Score.new(player: 'A', score: 10, time: now),
        Score.new(player: 'A', score: 5, time: now)
      ]
    end

    context 'when aggregating a list of scores' do
      let!(:aggregate) { HistoryUtils.aggregate_scores(scores) }
      it 'finds the first max score' do
        expect(aggregate[:high_score]).to eq({ score: scores[3].score, time: scores[3].time })
      end

      it 'finds the first min score' do
        expect(aggregate[:low_score]).to eq({ score: scores[0].score, time: scores[0].time })
      end

      it 'calculates the average to the second decimal' do
        expect(aggregate[:avg_score]).to eq(7.33)
      end

      it 'returns the list of scores without player name' do
        expect(aggregate[:scores]).to eq(scores.map { |s| { score: s.score, time: s.time } })
      end
    end
  end
end