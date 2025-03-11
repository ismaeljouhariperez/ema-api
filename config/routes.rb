Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  
  # API routes
  namespace :api do
    namespace :v1 do
      resources :adventures do
        collection do
          get :search
        end
      end
      
      # Route pour obtenir les informations de l'utilisateur actuel
      get 'profile', to: 'users#profile'
    end
  end
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
