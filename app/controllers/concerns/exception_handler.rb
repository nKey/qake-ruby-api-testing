# Provides common exception handling for all api controllers
module ExceptionHandler
  # provides the more graceful `included` method
  extend ActiveSupport::Concern
  include Swagger::Blocks

  swagger_schema :ErrorSchema do
    property :message do
      key :description, 'Error Message'
      key :type, :string
    end
  end

  included do
    rescue_from Exception do |e|
      json_response({ message: e.message }, :internal_server_error)
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      json_response({ message: e.message }, :not_found)
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      json_response({ message: e.message }, :bad_request)
    end

    rescue_from ActionController::ParameterMissing do |e|
      json_response({ message: e.message[/.*/] }, :bad_request)
    end

    rescue_from Date::Error do |e|
      json_response({ message: 'Validation failed: invalid or missing time, use iso8601 DateTime format' },
                    :bad_request)
    end
  end
end
