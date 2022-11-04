# This Controller serves the Swagger UI for the API Documentation
class ApidocsController < ApplicationController
  swagger_root do
    key :swagger, '2.0'
    info do
      key :version, '1.0.0'
      key :title, 'TopScoreRankingApi'
      key :description, 'A sample API that provides CRUD operations for Scores and basic history functionality'
      contact do
        key :name, 'Wordnik API Team'
      end
    end
    key :basePath, '/'
    key :consumes, ['application/json']
    key :produces, ['application/json']
  end

  # A list of all classes that have swagger_* declarations.
  SWAGGERED_CLASSES = [
    HistoriesController,
    ScoresController,
    HistoryUtils,
    Score,
    ExceptionHandler,
    self,
  ].freeze

  def index
    render json: Swagger::Blocks.build_root_json(SWAGGERED_CLASSES)
  end
end