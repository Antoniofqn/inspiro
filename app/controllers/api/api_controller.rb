class Api::ApiController < ApplicationController
  include Pundit::Authorization
  include ApiExceptionHandler
  before_action :authenticate_user!

  ##
  # creates serializer meta information (pagination and extras)
  #
  def serializer_meta(object, query, extra_params = {})
  { total_pages: object.total_pages,
    current_page: object.current_page,
    count: query.count }.merge(extra_params)
  end
end
