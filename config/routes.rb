Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :notes, only: %i[index create]
    end
  end
end
