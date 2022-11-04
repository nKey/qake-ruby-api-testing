require "faraday"
require "json"

class CommentsController < ApplicationController
    def index
        url = "https://jsonplaceholder.typicode.com/comments?name=alias odio sit"
        data = Faraday.get(url).body
        render json: data
    end

    # POST /comment
    def create
        data = Faraday.new(url: 'https://jsonplaceholder.typicode.com').post('/comments', {
            "postId": 1,
            "name": "Teste",
            "email": "douglas.queiroz@nkey.com.br",
            "body": "Teste 1\nteste 2\nteste3\nteste4"
          }).body
        render json: data
    end
    # PUT /comment
    def update
        data = Faraday.new(url: 'https://jsonplaceholder.typicode.com').put('/comments/5', {
            "postId": 2,
            "name": "Teste Atualizado",
            "email": "douglas.queiroz+atualizado@nkey.com.br",
            "body": "Teste 1\nteste 2\nteste3\nteste4"
          }).body
        render json: data
    end
end