Making::Application.routes.draw do
  use_doorkeeper
  root to: 'home#index'
  get 'welcome', to: 'home#welcome'
  get '/page/:page', to: "home#index"
  get 'qr_entry', to: 'home#qr_entry'

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
      resource :notification_settings
    end
    resources :authentications, only: [:destroy]
  end

  resources :users, only: [:show] do
    collection do
      post 'share'
      get 'fuzzy'
    end

    member do
      get 'fancies'
      get 'owns'
      get 'reviews'
      get 'things'
      get 'groups'
      get 'topics'
      get 'activities'
      get 'followings'
      get 'followers'
      post 'followings', to: :follow
      delete 'followings', to: :unfollow
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

  resource :profile, only: [] do
    get 'fancies'
    get 'owns'
    get 'things'
    get 'reviews'
    get 'followings'
    get 'followers'
    get 'groups'
    get 'topics'
    get 'recommend_users'
    post 'follow_recommends'
  end

  namespace :hell do
    resources :activities, only: [:index]
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

    resources :thing_rebate_coupons, only: [:show, :index, :new, :create, :update] do
      member do
        post 'generate_code'
        post 'batch_bind'
      end
    end

    resources :landing_covers, except: [:show]
    resources :promotions, except: [:show]
    resources :things, only: [:index, :update, :edit] do
      collection do
        get 'resort'
      end

      member do
        get 'send_stock_notification'
      end
    end

    resources :users, only: [:index, :update, :show]

    resources :reviews, only: [:index]

    resources :comments, only: [:index, :destroy]

    resources :rewards do
      member do
        patch 'award'
      end
    end

    resources :categories, only: [:index, :edit, :update]
  end

  resources :things do
    collection do
      get 'random'
      get 'category/:category', action: :index, as: :category
    end

    member do
      post 'fancy'
      post 'own'
      get 'buy'
      get 'comments'
      get 'related'
      get 'groups'
      post 'group_fancy'
    end

    resources :reviews do
      member { post 'vote' }
    end
    resources :stories
  end

  resources :posts, only: [] do
    resources :comments
  end

  resources :categories, only: [:index] do
    collection do
      get 'all'
    end
  end

  resources :groups do
    collection do
      get 'all'
      get 'fuzzy'
      get 'page/:page', action: :index
    end

    member do
      get 'page/:page', action: :show
      get 'join'
      delete 'leave'
      post 'invite'
      get 'members'
      get 'fancies'
    end

    resources :topics do
      member { post 'vote' }
    end
  end

  resources :photos, only: [:create, :destroy, :show]
  resources :review_photos, only: [:create]

  resources :notifications, only: [:index] do
    collection do
      post 'mark'
    end
  end

  resources :dialogs, except: [:new, :edit, :update] do
    resources :private_messages, only: [:destroy]
  end

  resources :lotteries do
    get 'page/:page', action: :index, on: :collection
  end

  resources :rewards, only: [:index]

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

  get 'jobs', to: 'home#jobs'
  get 'valentine', to: 'specials#valentine'
  get 'womensday', to: 'specials#womensday'

  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      get 'search', to: 'search#index'

      resources :things, only: [:index, :show] do
        resources :reviews, only: [:index, :show] do
          resources :comments, controller: :review_comments, only: [:index, :show, :create, :destroy]
        end
        resources :comments, controller: :thing_comments, only: [:index, :show, :create, :destroy]
      end

      resources :categories, only: [:index, :show] do
        resources :things, only: [:index]
      end

      resources :users, only: [:index, :show] do
        member do
          get 'fancies'
          get 'owns'
          get 'reviews'
          get 'things'
          get 'groups'
          get 'followings'
          get 'followers'
          get 'activities'
        end
      end

      resources :groups, only: [:index, :show] do
        resources :members, controller: :group_members, only: [:index, :show, :create, :destroy]

        resources :topics, except: [:new, :edit] do
          resources :comments, controller: :topic_comments, only: [:index, :show, :create, :destroy]
        end
      end

      resource :account, only: [:show] do
        resources :fancies, only: [:show, :update, :destroy]
        resources :owns, only: [:show, :update, :destroy]
        resources :followings, only: [:show, :update, :destroy]
      end

      resources :notifications, only: [:index] do
        collection do
          post 'mark'
        end
      end

      scope module: 'official' do
        resource :cart, only: [:show] do
          resources :items, controller: :cart_items, only: [:index, :show, :create, :update, :destroy]
        end
        resources :orders, only: [:index, :show, :create] do
          member do
            patch 'cancel'
            get 'tenpay_callback'
            get 'alipay_callback'
          end
        end
        resources :coupons, only: [:index, :update]
        resources :addresses, except: [:new, :edit, :show]
      end

      get 'oauth/default_callback', to: 'oauth#default_callback'
      post 'oauth/exchange_access_token', to: 'oauth#exchange_access_token'
    end
  end
end
