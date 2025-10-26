Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Authentication routes
  get    "/signup",           to: "sessions#new_signup",         as: :signup
  post   "/signup",           to: "sessions#create_signup",      as: :create_signup
  post   "/signup/verify",    to: "sessions#handle_registration", as: :verify_signup
  get    "/signin",           to: "sessions#new_signin",         as: :signin
  post   "/signin",           to: "sessions#create_signin",      as: :create_signin
  post   "/signin/verify",    to: "sessions#handle_authentication", as: :verify_signin
  delete "/logout",           to: "sessions#destroy",            as: :logout

  # Programs routes
  resources :programs

  # Defines the root path route ("/")
  root "home#index"
end
