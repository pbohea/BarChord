Rails.application.routes.draw do
  devise_for :users, controllers: {
                       sessions: "users/sessions",
                       registrations: "users/registrations",
                       passwords: "users/passwords",
                       confirmations: "users/confirmations",
                       unlocks: "users/unlocks",
                     }

  devise_for :owners, controllers: {
                        sessions: "owners/sessions",
                        registrations: "owners/registrations",
                        passwords: "owners/passwords",
                        confirmations: "owners/confirmations",
                        unlocks: "owners/unlocks",
                      }

  devise_for :artists, controllers: {
                         sessions: "artists/sessions",
                         registrations: "artists/registrations",
                         passwords: "artists/passwords",
                         confirmations: "artists/confirmations",
                         unlocks: "artists/unlocks",
                       }

  root to: "events#index"

  get "events/map", to: "events#map", defaults: { format: :json }
  #model routes
  resources :venues
  resources :events

  resources :artists, only: [:show] do
    get :events, on: :member
  end

  resources :artist_follows, only: [:create, :destroy]

  resources :venue_follows, only: [:create, :destroy]

  resources :configurations, only: [] do
    get :ios_v1, on: :collection
  end

  #session management
  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"

  #misc routes
  get "/owners/:id/dashboard", to: "owners#dashboard", as: :owner_dashboard
  get "/users/:id/dashboard", to: "users#dashboard", as: :user_dashboard

  #for autocomplete search
  get "/artists/search", to: "artists#search"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

end
