Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Session routes
  get "sign-in", to: "sessions#new", as: :sign_in
  post "sign-in", to: "sessions#create"
  get "sign-out", to: "sessions#destroy", as: :sign_out

  resources :entries do
    collection do
      get :income
      get :expense
      get :budget
    end
  end
  resources :buckets, except: [ :destroy ]

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "buckets#index"
end
