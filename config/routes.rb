Making::Application.routes.draw do

  %w(things reviews topics groups categories entries stories).each do |a|
    get "maps/#{a}"
    get "maps/#{a}/page/:page", to: "maps##{a}"
  end

  use_doorkeeper

  authenticated :user do
    root to: 'home#index'
    get 'page/:page', to: "home#index"
  end

  root to: 'home#landing', as: :landing

  get 'hits/(page/:page)', to: 'home#hits', as: :hits
  get 'embed', to: 'home#embed', as: :embed
  get 'welcome', to: 'home#welcome'
  get 'jobs', to: 'home#jobs'
  get 'user_agreement', to: 'home#user_agreement'
  get 'sale_terms', to: 'home#sale_terms'
  get 'qr_entry', to: 'home#qr_entry'
  get "404", to: "home#not_found"
  get "403", to: "home#forbidden"
  get "500", to: "home#error"
  get 'blocked', to: 'home#blocked'

  get 'shop(/page/:page)', to: 'things#shop', as: :shop

  # bong
  get 'bong', to: 'bong#index'
  post 'bong/consume_point', to: 'bong#consume_point'
  get 'bong/available_point', to: 'bong#available_point'

  get 'explore', to: 'explore#index'
  %w(talks lists reviews features specials events).each do |a|
    get "explore/#{a}", to: "explore##{a}", as: "explore_#{a}"
  end
  resources :entries, only: [:show] do
    member do
      get 'wechat'
      get 'photos'
    end
  end

  devise_for :users, controllers: {
    omniauth_callbacks: "omniauth_callbacks",
    registrations: "registrations",
    confirmations: "confirmations",
    sessions: "sessions",
    passwords: "passwords"
  }

  devise_scope :user do
    get 'users/quick_start', to: 'registrations#quick_start', as: :quick_start
  end

  scope 'settings' do
    root to: 'profiles#edit', as: 'setting_root'

    get 'drafts', to: 'profiles#drafts', as: 'setting_drafts'

    scope path_names: {edit: ''}, only: [:edit, :update] do
      resource :profile, path_prefix: 'admin'
      resource :account do
        patch 'email'
      end
      resources :interests, only: [:update]
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

  scope :search, controller: :search, as: :search do
    root action: :index
    get 'suggestions'
    get 'things'
    get 'lists'
    get 'users'
    get 'topics'
  end

  resources :users, only: [:show] do
    collection do
      post 'share'
      get 'fuzzy'
    end

    member do
      get 'fancies'
      get 'desires'
      get 'owns'
      get 'lists'
      get 'reviews'
      get 'feelings'
      get 'things'
      get 'groups'
      get 'topics'
      get 'activities'
      get 'followings'
      post 'followings', action: :batch_follow
      get 'followers'
      post 'followers', action: :follow
      delete 'followers', action: :unfollow
      get 'profile'
    end
  end

  resources :tags do
    collection do
      get 'fuzzy'
    end
  end

  resources :prizes, only: [:index]

  resources :thing_lists, path: 'lists', except: [:new, :edit] do
    resources :thing_list_items, path: 'items', only: [:create, :update, :destroy]
    resources :comments, only: [:index, :create, :destroy]

    member do
      post 'fancy'
      post 'unfancy'
      post 'sort'
    end
  end

  resources :cart_items, only: [:index, :create, :update, :destroy]

  resources :orders, only: [:index, :show, :create, :new] do
    collection do
      get 'wxpay'
    end

    member do
      patch 'confirm_free'
      patch 'cancel'
      patch 'request_refund'
      patch 'cancel_request_refund'
      get 'tenpay'
      get 'tenpay_wechat'
      get 'tenpay_notify'
      get 'tenpay_callback'
      get 'alipay'
      get 'alipay_wap'
      post 'alipay_notify'
      get 'alipay_callback'
      post 'alipay_wap_notify'
      get 'alipay_wap_callback'
      get 'wxpay_callback'
      post 'wxpay_notify'
      get 'deliver_bill'
    end
  end

  resources :adoptions, only: [:index, :create]

  resource :profile, only: [] do
    get 'recommend_users'
    post 'follow_recommends'
  end

  resources :merchants, only: [:show] do
    member do
      post 'set_description'
    end
  end

  resources :things do
    collection do
      post 'create_by_extractor'
      get 'extract_url'
      get 'categories/*categories', to: 'things#index'
      get 'brand/:brand', action: :index, as: :brand
      get 'brand/:brand/categories/:categories', action: :index
      post 'modify_brand'
      post 'create_by_user'
    end

    member do
      get 'activities'
      get 'lists'
      post 'fancy'
      post 'own'
      get 'buy'
      get 'coupon'
    end

    resources :reviews do
      collection do
        match 'invite', via: [:get, :post]
      end

      member do
        post 'vote'
        post 'unvote'
      end
    end

    resources :feelings, except: [:new, :edit] do
      member do
        post 'vote'
        post 'unvote'
      end
    end

    resource :impression, only: [:show, :update, :destroy]

    resources :stories
  end

  resources :posts, only: [] do
    resources :comments, only: [:index, :create, :destroy]
  end

  resources :articles, only: [] do
    member do
      post 'vote'
      post 'unvote'
    end
  end

  resources :specials, only: [] do
    member do
      post 'vote'
      post 'unvote'
    end
  end

  resources :categories, only: [:index] do
    member do
      post 'subscribe_toggle', action: :subscribe_toggle
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
    end

    resources :topics do
      member do
        post 'vote'
        post 'unvote'
      end
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
    collection {post 'readall'}
  end

  resources :drafts, only: [:index, :show, :update, :destroy]

  resources :suppliers

  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.role?(:admin) } do
    mount Sidekiq::Web => '/haven/sidekiq'
  end

  resource :styleguide, path: 'ediugelyts', only: [:show] do
    get 'coding'
    get 'scaffolds'
    get 'components'
    get 'tips'
  end

  namespace :haven do
    resources :activities, only: [:index]

    resources :orders, only: [:index, :show, :update] do
      member do
        patch 'ship'
        patch 'close'
        patch 'refund'
        patch 'transit'
        patch 'refund_to_balance'
        patch 'refund_bong_point'
        patch 'refunded_balance_to_platform'
        get 'generate_waybill'
      end
      collection do
        get 'stock'
        get 'batch_ship'
        post 'batch_ship'
        get 'batch_update'
        post 'batch_update'
      end
    end

    resources :adoptions, only: [:index] do
      member do
        post 'approve'
        post 'deny'
        post 'one_click_deny'
      end
    end

    resources :abatement_coupons, only: [:show, :index, :new, :create, :update] do
      member do
        post 'generate_code'
        post 'batch_bind'
      end
    end

    resources :stats, only: [:index, :update, :edit]

    resources :merchants

    resources :thing_rebate_coupons, only: [:show, :index, :new, :create, :update] do
      member do
        post 'generate_code'
        post 'batch_bind'
        get 'download'
      end
    end

    resources :coupon_codes, only: [:destroy]

    resources :promotions, except: [:show] do
      collection do
        post 'sort'
      end
    end
    resources :jumptrons
    resources :things, only: [:index, :update, :edit] do
      member do
        get 'send_stock_notification'
      end

      collection do
        get 'batch_edit'
        patch 'batch_update'
        post 'send_hits_message'
        get 'approved_status'
        post 'part_time_list'
      end
    end

    resources :groups do
      collection do
        get 'index'
        post 'approve'
        post 'invisible'
      end
    end

    resources :blacklists, only: [:index, :create, :destroy]

    resources :articles, except: [:show]

    resources :specials, except: [:show] do
      resources :special_subjects, except: [:show, :index]
    end

    resources :entries, except: [:show]

    resources :weeklies, except: [:show] do
      member do
        post 'deliver'
        post 'edm'
      end
    end

    resources :users, only: [:index, :update, :show] do
      collection do
        post 'confirm_email'
        post 'reset_password'
        post 'fuck_you'
        get 'recharge'
        post 'recharge'
        post 'change_balance'
      end
    end

    resources :thing_lists, only: [:index] do
      member do
        get 'export'
      end
    end
    resources :thing_list_backgrounds, only: [:index, :edit, :create, :update, :destroy]

    resources :reviews, only: [:index]

    resources :feelings, only: [:index]

    resources :comments, only: [:index, :destroy]

    resources :categories

    resources :tags

    resources :brands, only: [:index, :edit, :update, :destroy] do
      collection do
        get 'clear'
      end
    end

    resources :prizes do
      collection do
        get 'santa'
      end
    end

    resources :resources

    resources :staffs do
      get 'role', to: 'staffs#role'
    end
  end

  namespace :hell, defaults: {format: :json} do
    resources :activities, only: [:index]

    get 'stats/contents_product', to: 'stats#contents_product'
  end

  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      post 'bong_connect', to: 'bong_connect#create'

      get 'search', to: 'search#index'
      get 'extract_url', to: 'utils#extract_url'
      get 'find_similar', to: 'utils#find_similar'
      get 'test_name', to: 'utils#test_name'
      get 'test_email', to: 'utils#test_email'

      get 'explore/features', to: 'explore#features'

      resources :entries, only: [:show]

      resources :articles, only: [] do
        resources :comments, controller: :article_comments, only: [:index, :show, :create, :destroy]
        resource :vote, only: [:create, :destroy, :show]
      end

      resources :things, only: [:index, :show, :create] do
        resources :reviews, only: [:index, :show] do
          resources :comments, controller: :review_comments, only: [:index, :show, :create, :destroy]
          resource :vote, only: [:create, :destroy, :show]
        end
        resources :feelings, only: [:index, :show, :create] do
          resources :comments, controller: :feeling_comments, only: [:index, :show, :create, :destroy]
          resource :vote, only: [:create, :destroy, :show]
        end
        resources :comments, controller: :thing_comments, only: [:index, :show, :create, :destroy]

        resource :vote, only: [:create, :destroy, :show]

        collection do
          get 'random'
          get 'recommends'
        end
      end

      resources :categories, only: [:index, :show] do
        resources :things, only: [:index]
      end

      resources :friends, only: [] do
        collection do
          get 'weibo'
          get 'recommends'
          post 'batch_follow'
        end
      end

      resources :users, only: [:index, :show, :create] do
        member do
          get 'fancies'
          get 'owns'
          get 'reviews'
          get 'feelings'
          get 'things'
          get 'groups'
          get 'followings'
          get 'followers'
          get 'activities'
        end

        collection do
          post 'password'
        end
      end

      resources :groups, only: [:index, :show] do
        resources :members, controller: :group_members, only: [:index, :show, :create, :destroy]

        resources :topics, except: [:new, :edit] do
          resources :comments, controller: :topic_comments, only: [:index, :show, :create, :destroy]
          resource :vote, only: [:create, :destroy, :show]
        end
      end

      resource :account, only: [:show, :update] do
        resources :fancies, only: [:show, :update, :destroy]
        resources :owns, only: [:show, :update, :destroy]
        resources :followings, only: [:show, :update, :destroy]

        member do
          get 'feeds'
          put 'apple_device_token'
        end
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
        resources :orders, only: [:index, :show, :create, :new] do
          member do
            patch 'cancel'
            get 'alipay'
          end
        end
        resources :coupons, only: [:index, :update]
        resources :addresses, except: [:new, :edit, :show]
        resource :balance, only: [:show]
      end

      get 'oauth/default_callback', to: 'oauth#default_callback'
      get 'oauth/default_callback_2', to: 'oauth#default_callback_2'
      post 'oauth/exchange_access_token', to: 'oauth#exchange_access_token'
    end
  end

  mount ChinaCity::Engine => '/china_city'
end
