Making::Application.routes.draw do
  use_doorkeeper
  root to: 'home#index'
  get '/page/:page', to: "home#index"
  get 'qr_entry', to: "home#qr_entry"

  get 'join_alpha', to: 'home#join_alpha'
  get 'leave_alpha', to: 'home#leave_alpha'

  devise_for :users, controllers: {
      omniauth_callbacks: "omniauth_callbacks",
      registrations: "registrations",
      confirmations: "confirmations",
      sessions: "sessions",
      passwords: "passwords"
  }

  scope 'settings' do
    root to: 'profiles#edit', as: 'setting_root'
    scope path_names: {edit: ''}, only: [:edit, :update] do
      resource :profile, path_prefix: 'admin'
      resource :account do
        patch 'email'
      end
      resources :addresses, except: [:show]
      resources :invoices, except: [:show]
      resources :balances, only: [:index]
      resources :coupons, only: [:index] do
        collection do
          post 'bind'
        end
      end
    end
    resources :authentications, only: [:destroy]
  end

  resources :users, only: [:show, :index] do
    collection do
      post 'share'
      patch 'bind'
      get 'binding'
      get 'fuzzy'
    end
  end

  resources :cart_items, only: [:index, :create, :update, :destroy]

  resources :orders, only: [:index, :show, :create, :new] do
    member do
      patch 'confirm_free'
      patch 'cancel'
      get 'tenpay'
      get 'tenpay_wechat'
      get 'tenpay_notify'
      get 'tenpay_callback'
      get 'alipay'
      post 'alipay_notify'
      get 'alipay_callback'
      get 'deliver_bill'
    end
  end

  namespace :haven do
    resources :orders, only: [:index, :show, :update] do
      member do
        patch 'ship'
        patch 'close'
        patch 'refund'
        patch 'refund_to_balance'
        patch 'refunded_balance_to_platform'
        get 'generate_waybill'
      end
    end

    resources :abatement_coupons, only: [:show, :index, :new, :create, :update] do
      member do
        post 'generate_code'
        post 'batch_bind'
      end
    end

    resources :landing_pages
    resources :things, only: [:index, :update, :edit] do
      collection do
        get 'resort'
      end
    end

    resources :users, only: [:index, :update, :show]
  end

  resources :things do
    collection do
      get 'admin'
      get 'resort'
    end

    member do
      post 'fancy'
      post 'own'
      get 'buy'
      get 'comments'
      get 'related'
    end

    resources :reviews do
      member { post 'vote' }
    end
    resources :stories
    resources :investors do
      collection do
        get 'admin'
      end
    end
  end

  get '/reviews', to: "reviews#admin", as: :reviews_admin

  resources :posts, only: [] do
    resources :comments
  end

  resources :categories, only: [:show, :index]

  resources :groups do
    resources :topics
    get 'date/:date', action: :show, on: :member
  end

  resources :photos, only: [:create, :destroy, :show]
  resources :review_photos, only: [:create]

  resources :messages, only: [:index] do
    get 'page/:page', action: :index, on: :collection
    collection do
      post 'readall'
    end
  end

  resources :lotteries do
    get 'page/:page', action: :index, on: :collection
  end

  resources :suppliers

  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.role?(:admin) } do
    mount Sidekiq::Web => '/haven/sidekiq'
  end

  get '/search', to: 'home#search', as: :search
  get '/sandbox', to: 'home#sandbox'

  get "/404", :to => "home#not_found"
  get "/403", :to => "home#forbidden"
  get "/500", :to => "home#error"

  get 'valentine', to: 'specials#valentine'

  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      resources :things, only: [:index, :show] do
        resources :reviews, only: [:index, :show]
        resources :comments, only: [:index]
      end
      resources :users, only: [:index, :show] do
        member do
          get 'fancies'
          get 'owns'
          get 'reviews'
          get 'things'
        end
      end
    end
  end
end
