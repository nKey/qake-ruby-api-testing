require 'rails_helper'

RSpec.describe ScoresController, type: :request do
  describe 'GET /scores/:id' do
    let!(:score) { Score.create(player: 'player', score: 10, time: Time.now) }
    let!(:score_id) { score.id }
    before { get "/scores/#{score_id}" }

    context 'when the score exists' do
      it 'it returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'it returns the right response body' do
        expect(json['id']).to eq(score_id)
        expect(json['player']).to eq(score.player)
        expect(json['score']).to eq(score.score)
        expect(json['time']).to eq(score.time.iso8601(3))
      end
    end

    context 'when the score does not exists' do
      let!(:score_id) { 1000 }
      it 'it returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'it returns the correct error message' do
        expect(json['message']).to eq("Couldn't find Score with 'id'=#{score_id}")
      end
    end
  end

  describe 'POST /scores' do
    context 'when the request is valid' do
      let(:valid_request) { { player: 'new player', score: 1, time: Time.now.iso8601 } }

      before { post '/scores', params: valid_request }
      it 'it returns status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'it returns the correct body' do
        expect(json['id']).to be_a Integer
        expect(json['player']).to eq(valid_request[:player])
        expect(json['score']).to eq(valid_request[:score])
        expect(DateTime.iso8601(json['time'])).to eq(valid_request[:time])
      end
    end

    context 'when the date is invalid' do
      let(:invalid_date_format) { { player: 'new player', score: 1, time: Time.now } }

      before { post '/scores', params: invalid_date_format }
      it 'it returns status code 400' do
        expect(response).to have_http_status(400)
      end

      it 'it returns the correct error message' do
        expect(json['message']).to eq('Validation failed: invalid or missing time, use iso8601 DateTime format')
      end
    end

    context 'when the player is missing' do
      let(:missing_player) { { score: 1, time: Time.now.iso8601 } }

      before { post '/scores', params: missing_player }
      it 'it returns status code 400' do
        expect(response).to have_http_status(400)
      end

      it 'it returns the correct error message' do
        expect(json['message']).to eq('Validation failed: Player can\'t be blank')
      end
    end

    context 'when the time is missing' do
      let(:missing_time) { { player: 'new player', score: 1 } }

      before { post '/scores', params: missing_time }
      it 'it returns status code 400' do
        expect(response).to have_http_status(400)
      end

      it 'it returns the correct error message' do
        expect(json['message']).to eq('Validation failed: invalid or missing time, use iso8601 DateTime format')
      end
    end

    context 'when the score is missing' do
      let(:missing_score) { { player: 'new player', time: Time.now.iso8601 } }

      before { post '/scores', params: missing_score }
      it 'it returns status code 400' do
        expect(response).to have_http_status(400)
      end

      it 'it returns the correct error message' do
        expect(json['message']).to eq('Validation failed: Score can\'t be blank, Score is not a number')
      end
    end

    context 'when the score is negative' do
      let(:negative_score) { { player: 'new player', score: -1, time: Time.now.iso8601 } }

      before { post '/scores', params: negative_score }
      it 'it returns status code 400' do
        expect(response).to have_http_status(400)
      end

      it 'it returns the correct error message' do
        expect(json['message']).to eq('Validation failed: Score must be greater than 0')
      end
    end
  end

  describe 'DELETE /scores/:id' do
    let!(:score) { Score.create(player: 'player', score: 10, time: Time.now) }
    let!(:score_id) { score.id }
    before { delete "/scores/#{score_id}" }

    context 'when the score exists' do
      it 'it returns status code 204' do
        expect(response).to have_http_status(204)
      end

      it 'it returns an empty response body' do
        expect(response.body).to eq('')
      end
    end

    context 'when the score does not exists' do
      let!(:score_id) { 1000 }
      it 'it returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'it returns the correct error message' do
        expect(json['message']).to eq("Couldn't find Score with 'id'=#{score_id}")
      end
    end
  end

  describe 'GET /scores' do
    before do
      Score.create(player: 'A', score: 8, time: DateTime.now.prev_day(1))
      Score.create(player: 'B', score: 9, time: DateTime.now.prev_day(3))
      Score.create(player: 'C', score: 10, time: DateTime.now.prev_day(5))
      Score.create(player: 'A', score: 10, time: DateTime.now.prev_day(1))
    end

    context 'when searching without filter' do
      before { get '/scores' }

      it 'it returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'it returns the first page of results' do
        expect(json['page']).to eq(1)
      end

      it 'it returns the size of the current result set' do
        expect(json['size']).to eq(4)
      end

      it 'it returns the scores in the descending score order' do
        @scores = json['list']
        expect(@scores.map { |s| s['score'] }).to eq([10, 10, 9, 8])
        expect(@scores.map { |s| s['player'] }).to eq(['A', 'C', 'B', 'A'])
      end
    end

    context 'when searching with pagination and size' do
      context 'when getting the first page of 2 results' do
        before { get '/scores', params: { size: 2 } }

        it 'it returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'it returns the first page of results' do
          expect(json['page']).to eq(1)
        end

        it 'it returns the size of the current result set' do
          expect(json['size']).to eq(2)
        end

        it 'it returns the scores in the descending score order' do
          @scores = json['list']
          expect(@scores.map { |s| s['score'] }).to eq([10, 10])
          expect(@scores.map { |s| s['player'] }).to eq(['A', 'C'])
        end
      end

      context 'when getting the second page of 2 results' do
        before { get '/scores', params: { page: 2, size: 2 } }

        it 'it returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'it returns the second page of results' do
          expect(json['page']).to eq(2)
        end

        it 'it returns the size of the current result set' do
          expect(json['size']).to eq(2)
        end

        it 'it returns the second page of scores in the descending score order' do
          @scores = json['list']
          expect(@scores.map { |s| s['score'] }).to eq([9, 8])
          expect(@scores.map { |s| s['player'] }).to eq(['B', 'A'])
        end
      end

      context 'when getting the third page' do
        before { get '/scores', params: { page: 3, size: 2 } }
        it 'it returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'it returns the third page of results' do
          expect(json['page']).to eq(3)
        end

        it 'it returns a size of 0 results' do
          expect(json['size']).to eq(0)
        end
      end
    end

    context 'when searching for scores for existing users' do
      before { get '/scores', params: { players: 'A,B' } }

      it 'it returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'it returns the scores for those users' do
        @scores = json['list']
        expect(@scores.map { |s| s['score'] }).to eq([10, 9, 8])
        expect(@scores.map { |s| s['player'] }).to eq(['A', 'B', 'A'])
      end
    end

    context 'when searching for scores after a date' do
      before { get '/scores', params: { after: DateTime.now.prev_day(2).iso8601 } }

      it 'it returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'it returns the scores after that date' do
        @scores = json['list']
        expect(@scores.map { |s| s['score'] }).to eq([10, 8])
        expect(@scores.map { |s| s['player'] }).to eq(['A', 'A'])
      end
    end

    context 'when searching for scores before a date' do
      before { get '/scores', params: { before: DateTime.now.prev_day(2).iso8601 } }

      it 'it returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'it returns the scores after that date' do
        @scores = json['list']
        expect(@scores.map { |s| s['score'] }).to eq([10, 9])
        expect(@scores.map { |s| s['player'] }).to eq(['C', 'B'])
      end
    end

    context 'when searching for scores with all filters' do
      let!(:params) {
        {
          players: 'A,B',
          before: DateTime.now.prev_day(2).iso8601,
          after: DateTime.now.prev_day(6).iso8601
        }
      }
      before { get '/scores', params: params }

      it 'it returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'it returns the scores after that date' do
        @scores = json['list']
        expect(@scores.map { |s| s['score'] }).to eq([9])
        expect(@scores.map { |s| s['player'] }).to eq(['B'])
      end
    end
  end
end
