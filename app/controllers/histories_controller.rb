# frozen_string_literal: true

# This controller provides the API to retrieve the score history of a given player
#
# For more details on the JSON Api checkout the Swagger documentation at http://localhost:3000/swagger/index.html#/History
class HistoriesController < ApplicationController
  before_action :set_player

  swagger_path '/players/{id}/history' do
    operation :get do
      key :summary, 'Get History for Player'
      key :description, 'Returns the scores for the given player, with high, low and average scores'
      key :operationId, 'GetHistoryById'
      key :tags, [
        'History'
      ]
      parameter do
        key :name, :id
        key :in, :path
        key :description, 'Id of the player'
        key :type, :string
      end
      response 200 do
        key :description, 'History Response'
        schema do
          key :'$ref', :HistorySchema
        end
      end
    end
  end
  def show
    @scores = Score.by_players(@player)
    json_response(HistoryUtils.aggregate_scores(@scores))
  end

  private

  def set_player
    @player = params.require('player_id')
  end

end
