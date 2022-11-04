# frozen_string_literal: true

# This controller provides the CRUD api functionality for the Score resource.
#
# For more details on the JSON Api checkout the Swagger documentation at http://localhost:3000/swagger/index.html#/Score
class ScoresController < ApplicationController
  before_action :set_score, only: [:show, :destroy]
  before_action :set_list_params, only: [:index]

  DEFAULT_PAGE = 1
  DEFAULT_PAGE_SIZE = 20

  swagger_path '/scores' do
    operation :post do
      key :summary, 'Submit a Score'
      key :description, 'Saves the submitted Score'
      key :operationId, 'SubmitScore'
      key :tags, [
        'Score'
      ]
      parameter do
        key :name, :body
        key :in, :body
        key :description, 'Score'
        schema do
          key :'$ref', :ScoreSchema
        end
      end
      response 200 do
        key :description, 'Score Response'
        schema do
          key :'$ref', :ScoreSchema
        end
      end
      response 400 do
        key :description, 'Failed validation'
        schema do
          key :'$ref', :ErrorSchema
        end
      end
    end
  end

  def create
    @score = Score.create!(
      player: params[:player],
      score: params[:score],
      time: DateTime.iso8601(params[:time])
    )
    json_response(@score, :created)
  end

  swagger_path '/scores' do
    operation :get do
      key :summary, 'Find Scores'
      key :description, 'Returns the scores filtered by page, players and dates'
      key :operationId, 'FindScores'
      key :tags, [
        'Score'
      ]
      parameter do
        key :name, :players
        key :in, :query
        key :description, 'Comma separated list of player ids'
        key :type, :string
      end
      parameter do
        key :name, :before
        key :in, :query
        key :description, "DateTime in ISO8601 format, like: #{DateTime.now.iso8601}"
        key :type, :string
      end
      parameter do
        key :name, :after
        key :in, :query
        key :description, "DateTime in ISO8601 format, like: #{DateTime.now.iso8601}"
        key :type, :string
      end
      parameter do
        key :name, :page
        key :in, :query
        key :description, "1-based Page number to retrieve, defaults to #{DEFAULT_PAGE}"
        key :type, :integer
      end
      parameter do
        key :name, :size
        key :in, :query
        key :description, "Number of results per page, defaults to #{DEFAULT_PAGE_SIZE}"
        key :type, :integer
      end
      response 200 do
        key :description, 'Score Response'
        schema do
          property :page do
            key :type, :integer
            key :format, :int32
            key :description, '1-based Page number'
          end
          property :size do
            key :type, :integer
            key :format, :int32
            key :description, 'Count of returned scores'
          end
          property :list do
            key :type, :array
            items do
              key :'$ref', :ScoreSchema
            end
          end
        end
      end
    end
  end

  def index
    @scores = Score.by_players(@players)
                   .after(@after)
                   .before(@before)
                   .page(@page)
                   .per(@size)
                   .order(score: :desc, time: :desc)
    json_response({ list: @scores, page: @page, size: @scores.length }, :ok)
  end

  swagger_path '/scores/{id}' do
    operation :get do
      key :summary, 'Get Score by ID'
      key :description, 'Returns the selected Score'
      key :operationId, 'GetScoreById'
      key :tags, [
        'Score'
      ]
      parameter do
        key :name, :id
        key :in, :path
        key :description, 'Id of the score'
        key :type, :string
      end
      response 200 do
        key :description, 'Score Response'
        schema do
          key :'$ref', :ScoreSchema
        end
      end
      response 404 do
        key :description, 'Score Not Found'
        schema do
          key :'$ref', :ErrorSchema
        end
      end
    end
  end

  def show
    json_response(@score)
  end

  swagger_path '/scores/{id}' do
    operation :delete do
      key :summary, 'Delete Score by ID'
      key :description, 'Deletes the selected Score'
      key :operationId, 'DeleteScoreById'
      key :tags, [
        'Score'
      ]
      parameter do
        key :name, :id
        key :in, :path
        key :description, 'Id of the score'
        key :type, :string
      end
      response 204 do
        key :description, 'No Content'
      end
      response 404 do
        key :description, 'Score Not Found'
        schema do
          key :'$ref', :ErrorSchema
        end
      end
    end
  end

  def destroy
    @score.destroy
    head :no_content
  end

  private

  def set_list_params
    @page = params[:page].present? ? params[:page].to_i : DEFAULT_PAGE
    @size = params[:size].present? ? params[:size].to_i : DEFAULT_PAGE_SIZE
    @players = params[:players].present? ? params[:players].split(',').map(&:strip) : nil
    @before = params[:before].present? ? DateTime.iso8601(params[:before]) : nil
    @after = params[:after].present? ? DateTime.iso8601(params[:after]) : nil
  end

  def set_score
    @score = Score.find(params[:id])
  end
end
