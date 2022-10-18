require "faraday"
require "json"

module Api
  module V1external
    class CommentsController < ApplicationController
      def index
        url = "https://jsonplaceholder.typicode.com/comments?name=alias odio sit"
        data = Faraday.get(url).body
        render json: data
      end

      # def comment_params
      #   params.permit(:name)
      # end
    end
  end
end
