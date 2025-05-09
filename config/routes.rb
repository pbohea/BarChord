Rails.application.routes.draw do
  devise_for :owners, controllers: { registrations: "owners/registrations" }
  devise_for :users,  controllers: { registrations: "users/registrations" }
  devise_for :artists, controllers: { registrations: "artists/registrations" } 

  root to: "events#active"


  resources :venues
  resources :events

  get  "/login",  to: "sessions#new"
  post "/login",  to: "sessions#create"

  get "/owners/:id/dashboard", to: "owners#dashboard", as: :owner_dashboard

  #for autocomplete search
  get "/artists/search", to: "artists#search"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
