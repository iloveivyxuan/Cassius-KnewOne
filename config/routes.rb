Making::Application.routes.draw do
  root to: 'home#index'
  get '/page/:page', to: "home#index"

  devise_for :users, controllers: {omniauth_callbacks: "omniauth_callbacks", :registrations => "registrations"} do
    put 'profile', :to => 'profiles#update'
  end
  resources :users, only: [:show, :index] do
    collection do
      post 'share'
      get 'bind'
    end
  end

  resources :things do
    collection do
      get 'admin'
    end

    member do
      post 'fancy'
      post 'own'
      get 'buy'
      get 'buy_package'
      get 'comments'
      get 'pro_edit'
      put 'pro_update'
      get 'wechat_qr'
    end

    resources :reviews do
      member { post 'vote' }
    end

    resources :updates
  end
  get '/reviews_admin', to: "reviews#admin", as: :reviews_admin

  resources :posts, only: [] do
    resources :comments
  end

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

  resources :guests do
    collection do
      get "activate/:token", action: :activate, as: :activate
      get "limits"
    end
  end

  resources :suppliers

  get '/search', to: 'home#search', as: :search
  get '/sandbox', to: 'home#sandbox'

  get "/404", :to => "home#not_found"
  get "/403", :to => "home#forbidden"
end
