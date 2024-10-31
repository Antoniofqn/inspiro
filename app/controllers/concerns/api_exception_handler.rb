module ApiExceptionHandler
  extend ActiveSupport::Concern
  included do
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
    rescue_from ActionController::ParameterMissing, with: :bad_request
    rescue_from Pundit::NotAuthorizedError do |exception|
      begin
        message = JSON.parse(exception.message)
      rescue JSON::ParserError => e
        message = []
      end
      forbidden(message || [])
    end
  end

  private

  # 404 - Record not found
  def record_not_found(error)
    render json: { error: error.message }, status: :not_found
  end

  # 422 - Validation or business logic errors
  def unprocessable_entity(error)
    render json: { error: error.record.errors.full_messages }, status: :unprocessable_entity
  end

  # 400 - Bad request
  def bad_request(error)
    render json: { error: error.message }, status: :bad_request
  end

  # 403 - Forbidden
  def forbidden(*errors)
    @errors = (errors.flatten.present? ? errors : [I18n.t('api.errors.forbidden')]).flatten.uniq
    render json: { error: @errors }, status: :forbidden
  end
end
