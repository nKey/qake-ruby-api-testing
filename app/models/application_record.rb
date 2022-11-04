# This abstract class is the base class for all ActiveRecords models.
# It's used to include common functionality for all models, like swagger blocks to define schemas.
class ApplicationRecord < ActiveRecord::Base
  include Swagger::Blocks

  self.abstract_class = true
end
