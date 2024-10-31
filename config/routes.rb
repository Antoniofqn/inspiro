Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  get "up" => "rails/health#show", as: :rails_health_check
  post '/webhooks/stripe', to: 'webhooks#stripe'

  namespace :api do
    namespace :v1 do
      post 'payments/create_checkout_session', to: 'payments#create_checkout_session'
      post 'payments/create_portal_session', to: 'payments#create_portal_session'
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
