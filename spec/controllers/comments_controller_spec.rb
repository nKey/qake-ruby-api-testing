require 'rails_helper'

RSpec.describe CommentsController, type: :request do
  describe 'GET /comments' do    
    context 'when the request is valid' do
      before { get '/comments' }

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

  describe 'POST /comments' do    
    context 'when the request is valid' do
      before { post '/comments' }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it "return json" do
        expected = '{
          "postId":"1",
          "id":501,
          "name":"Teste",
          "email":"douglas.queiroz@nkey.com.br",
          "body": "Teste 1\nteste 2\nteste3\nteste4"
        }'
        puts "EXPECTED", JSON.parse(expected)
        puts "ACTUAL", json
        expect(json).to eq(JSON.parse(expected))
      end
    end
  end

  describe 'PUT /comments' do    
    context 'when the request is valid' do
      before { put '/comments/:id' }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it "return json" do
        expected = '{
          "postId":"2",
          "id":5,
          "name":"Teste Atualizado",
          "email":"douglas.queiroz+atualizado@nkey.com.br",
          "body": "Teste 1\nteste 2\nteste3\nteste4"
        }'
        puts "EXPECTED", JSON.parse(expected)
        puts "ACTUAL", json
        expect(json).to eq(JSON.parse(expected))
      end
    end
  end
end
