require 'rails_helper'

RSpec.describe Score, type: :model do
  describe 'validation' do
    it 'is is valid with all the properties' do
      expect(Score.new(player: 'player', score: 5, time: DateTime.now)).to be_valid
    end

    it 'is is not valid without player' do
      expect(Score.new(score: 5, time: DateTime.now)).to_not be_valid
    end

    it 'is is not valid without time' do
      expect(Score.new(player: 'player', score: 5)).to_not be_valid
    end

    it 'is is not valid with negative score' do
      expect(Score.new(player: 'player', score: -5, time: DateTime.now)).to_not be_valid
    end

    it 'is is not valid with 0 score' do
      expect(Score.new(player: 'player', score: 0, time: DateTime.now)).to_not be_valid
    end
  end

  describe 'query filters' do
    before do
      Score.create(player: 'A', score: 8, time: DateTime.now.prev_day(1))
      Score.create(player: 'B', score: 9, time: DateTime.now.prev_day(3))
      Score.create(player: 'C', score: 10, time: DateTime.now.prev_day(5))
    end

    context 'when filtering by players' do
      let!(:result) { Score.by_players(['a', 'c']) }
      it 'returns the right number scores' do
        expect(result.length).to be(2)
      end
      it 'returns the scores for the selected players' do
        expect(result.map(&:player)).to contain_exactly('A', 'C')
      end
    end

    context 'when filtering by player' do
      let!(:result) { Score.by_players('a') }
      it 'returns the right number scores' do
        expect(result.length).to be(1)
      end
      it 'returns the scores for the selected players' do
        expect(result.map(&:player)).to contain_exactly('A')
      end
    end

    context 'when filtering by players = nil' do
      let!(:result) { Score.by_players(nil) }
      it 'returns all the scores' do
        expect(result.length).to be(3)
      end
      it 'returns the scores for all the players' do
        expect(result.map(&:player)).to contain_exactly('A', 'B', 'C')
      end
    end

    context 'when filtering by players = \'\'' do
      let!(:result) { Score.by_players('') }
      it 'returns all the scores' do
        expect(result.length).to be(3)
      end
      it 'returns the scores for all the players' do
        expect(result.map(&:player)).to contain_exactly('A', 'B', 'C')
      end
    end

    context 'when filtering by players empty' do
      let!(:result) { Score.by_players([]) }
      it 'returns all the scores' do
        expect(result.length).to be(3)
      end
      it 'returns the scores for all the players' do
        expect(result.map(&:player)).to contain_exactly('A', 'B', 'C')
      end
    end

    context 'when filtering by unknown players' do
      let!(:result) { Score.by_players(['f', 'd']) }
      it 'returns no scores' do
        expect(result.length).to be(0)
      end
    end

    context 'when filtering by DateTime before' do
      let!(:result) { Score.before(DateTime.now.prev_day(2)) }
      it 'returns the right number scores' do
        expect(result.length).to be(2)
      end
      it 'returns the scores until the selected DateTime' do
        expect(result.map(&:player)).to contain_exactly('B', 'C')
      end
    end

    context 'when filtering by DateTime after' do
      let!(:result) { Score.after(DateTime.now.prev_day(2)) }
      it 'returns the right number scores' do
        expect(result.length).to be(1)
      end
      it 'returns the scores since the selected DateTime' do
        expect(result.map(&:player)).to contain_exactly('A')
      end
    end

    context 'when filtering by DateTime interval' do
      let!(:result) { Score.after(DateTime.now.prev_day(4)).before(DateTime.now.prev_day(2)) }
      it 'returns the right number scores' do
        expect(result.length).to be(1)
      end
      it 'returns the scores in the selected interval' do
        expect(result.map(&:player)).to contain_exactly('B')
      end
    end

    context 'when filtering by DateTime interval using Time objects' do
      let!(:result) { Score.after(Time.now.prev_day(4)).before(Time.now.prev_day(2)) }
      it 'returns the right number scores' do
        expect(result.length).to be(1)
      end
      it 'returns the scores in the selected interval' do
        expect(result.map(&:player)).to contain_exactly('B')
      end
    end

    context 'when the DateTime filter does not match anything' do
      let!(:result) { Score.after(DateTime.now.prev_day(10)).before(DateTime.now.prev_day(6)) }

      it 'returns no scores' do
        expect(result.length).to be(0)
      end
    end

    context 'when the filter is not a DateTime or Time object' do
      let!(:result) { Score.after(DateTime.now.iso8601) }

      it 'returns all scores' do
        expect(result.length).to be(3)
      end
    end

    context 'when using all filters' do
      let!(:result) { Score.after(DateTime.now.prev_day(4)).before(DateTime.now).by_players(['a']) }

      it 'returns the right number scores' do
        expect(result.length).to be(1)
      end
      it 'returns the scores in the selected interval' do
        expect(result.map(&:player)).to contain_exactly('A')
      end
    end
  end
end
