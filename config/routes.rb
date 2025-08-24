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

  root to: "pages#home"

  get "map", to: "events#map_landing"
  get "events/map", to: "events#map"

  resources :venues do
    get :search, on: :collection
    member do
      get :upcoming_events
      get :check_ownership
    end
  end

  get "events/landing", to: "events#landing"

  resources :events do
    collection do
      #get :nearby
      get :map
      get :landing
      get :time_options_ajax
      get :end_time_options_ajax
      get :date_options_ajax
    end
  end

  resources :artists, only: [:show] do
    get :events, on: :member
    get :promo_flyer, on: :member
    get :promo_flyer_print, on: :member
    get :search, on: :collection
  end

  resources :artist_follows, only: [:create, :destroy]

  resources :venue_follows, only: [:create, :destroy]

  # new venue requests (public)
  resources :venue_requests, only: [:index, :new, :create] do
    get :claim, on: :collection
    get :receipt, on: :member
  end

  # admin-only
  namespace :admin do
    resources :venue_requests do
      member do
        patch :approve
        patch :reject
        patch :update_coordinates
      end
    end
  end

  resources :configurations, only: [] do
    get :ios_v1, on: :collection
  end

  resources :notification_tokens, only: :create

  #misc routes
  # User-specific routes (no ID needed - uses current_user/current_owner/current_artist)
  get "/owner/dashboard", to: "owners#dashboard", as: :owner_dashboard
  get "/user/dashboard", to: "users#dashboard", as: :user_dashboard
  get "/artist/dashboard", to: "artists#dashboard", as: :artist_dashboard
  get "/owner/venue_requests", to: "owners#venue_requests", as: "owner_venue_requests"
  get "/artist/venue_requests", to: "artists#venue_requests", as: "artist_venue_requests"
  get "/about", to: "pages#about"
  get "/owners_about", to: "pages#owners_about"
  get "/artists_about", to: "pages#artists_about"
  get "/menu", to: "pages#menu", as: :menu
  get "/users/:id/landing", to: "users#landing", as: :user_landing
  get "/artists/:id/landing", to: "artists#landing", as: :artist_landing
  get "/owners/:id/landing", to: "owners#landing", as: :owner_landing
  # Admin routes
  get "/admin", to: "admin#dashboard", as: "admin_dashboard"
  #get "/admin/venue_requests", to: "admin#venue_requests", as: "admin_venue_requests"

  get "/test_email", to: "test_email#send_ping"

  #for autocomplete search
  get "/artists/search", to: "artists#search"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  #render rake tasks

  get("/rake_tasks", { :controller => "rake_tasks", :action => "show" })
  get("/run_task", { :controller => "rake_tasks", :action => "run_task" })
end
