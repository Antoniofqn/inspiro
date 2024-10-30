Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      resources :notes do
        collection do
          post :associate_tags
        end
      end
      resources :tags
      resources :clusters do
        member do
          post :add_notes
          delete :remove_notes
        end
      end
    end
  end
end
