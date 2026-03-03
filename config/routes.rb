Rails.application.routes.draw do
  # TODO: Funcionalidades - API
  namespace :api do
    namespace :v1 do
      resources :messages, only: [:create, :show]
      resources :reactions, only: [:create]
      resources :communities, only: [] do
        member do
          get :top_messages, path: "messages/top"
        end
      end
      get "analytics/suspicious_ips", to: "analytics#suspicious_ips"
    end
  end

  # TODO: Funcionalidades - Frontend
  resources :communities, only: [:index, :show] do
    resources :messages, only: [:create, :show]
  end
  resources :reactions, only: [:create]

  root "communities#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
