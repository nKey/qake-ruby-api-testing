# Base class for all controllers. Includes common modules to handle output format, exception handling and documentation
class ApplicationController < ActionController::API
  include Response
  include ExceptionHandler
  include Swagger::Blocks
end
