class Api::ApiController < ApplicationController
  include Pundit::Authorization
  before_action :authenticate_user!
end
