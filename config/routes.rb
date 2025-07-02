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

  root to: "events#landing"

  get "map", to: "events#map_landing"
  get "events/map", to: "events#map"

  resources :venues do
    get :search, on: :collection
    member do
      get :upcoming_events
    end
  end

  get "events/landing", to: "events#landing"

  resources :events do
    collection do
      #get :nearby
      get :map
      get :landing
    end
  end

  resources :artists, only: [:show] do
    get :events, on: :member
    get :promo_flyer, on: :member
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
  get "/owners/:id/dashboard", to: "owners#dashboard", as: :owner_dashboard
  get 'owners/:id/venue_requests', to: 'owners#venue_requests', as: 'owner_venue_requests'
  get "/users/:id/dashboard", to: "users#dashboard", as: :user_dashboard
  get "/artists/:id/dashboard", to: "artists#dashboard", as: :artist_dashboard
  get 'artists/:id/venue_requests', to: 'artists#venue_requests', as: 'artist_venue_requests'
  get "/about", to: "pages#about"
  get "/owners_about", to: "pages#owners_about"
  get "/artists_about", to: "pages#artists_about"
  get "/menu", to: "pages#menu", as: :menu
  # Admin routes
  get "/admin", to: "admin#dashboard", as: "admin_dashboard"
  #get "/admin/venue_requests", to: "admin#venue_requests", as: "admin_venue_requests"

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
