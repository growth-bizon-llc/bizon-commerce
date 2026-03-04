class ApplicationController < ActionController::API
  include ErrorHandler

  respond_to :json
end
