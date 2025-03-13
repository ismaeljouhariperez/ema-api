Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  
  # Solid Queue Web UI
  mount SolidQueue::Engine => '/solid_queue', as: :solid_queue
  
  # API routes
  namespace :api do
    namespace :v1 do
      resources :adventures do
        collection do
          get :search
        end
      end
      
      # Routes utilisateurs
      get 'profile', to: 'users#profile'
      resources :users, only: [] do
        member do
          get :adventures
        end
      end
      
      # Routes IA
      namespace :ai_adventures do
        post :generate
        get :search_similar
        get 'status/:job_id', to: 'ai_adventures#status', as: :status
      end
    end
  end
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end