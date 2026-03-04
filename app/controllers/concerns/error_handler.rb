module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity_error
    rescue_from Pundit::NotAuthorizedError, with: :forbidden
    rescue_from ActionController::ParameterMissing, with: :bad_request
    rescue_from AASM::InvalidTransition, with: :unprocessable_transition
    rescue_from ActiveRecord::InvalidForeignKey, with: :invalid_foreign_key
  end

  private

  def not_found(_exception)
    render json: { error: "Record not found" }, status: :not_found
  end

  def unprocessable_entity_error(exception)
    render json: { error: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def forbidden(_exception)
    render json: { error: "Not authorized" }, status: :forbidden
  end

  def bad_request(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def unprocessable_transition(exception)
    render json: { error: exception.message }, status: :unprocessable_entity
  end

  def invalid_foreign_key(_exception)
    render json: { error: "Referenced record does not exist" }, status: :unprocessable_entity
  end
end
