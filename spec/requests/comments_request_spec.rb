require 'rails_helper'

RSpec.describe 'Comments', type: :request do
  describe 'GET /comments' do    
    context 'when the request is valid' do
      before { get '/api/v1external/comments' }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it "return json" do
        expected = '[
            {
              "postId":1,
              "id":4,
              "name":"alias odio sit",
              "email":"Lew@alysha.tv",
              "body": "non et atque\noccaecati deserunt quas accusantium unde odit nobis qui voluptatem\nquia voluptas consequuntur itaque dolor\net qui rerum deleniti ut occaecati"
            }
        ]'
        puts "EXPECTED", JSON.parse(expected)
        puts "ACTUAL", json
        expect(json).to eq(JSON.parse(expected))
      end
    end
  end
end