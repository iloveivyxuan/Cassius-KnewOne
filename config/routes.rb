Making::Application.routes.draw do
  root to: 'home#index'
  get '/page/:page', to: "home#index"

  devise_for :users, skip: [:sessions],
  controllers:  {omniauth_callbacks: "omniauth_callbacks"}

  as :user do
    get 'signin' => 'devise/sessions#new', as: :new_user_session
    delete 'signout' => 'devise/sessions#destroy', as: :destroy_user_session
  end
  resources :users, only: [:show, :index] do
    member {post 'share'}
  end

  resources :things do
    collection {get 'admin'}
    member {post 'fancy'}
    member {post 'own'}
    member {get 'buy'}
    member {get 'buy_package'}
    get 'date/:date', action: :index, on: :collection

    resources :reviews do
      member {post 'vote'}
    end

    resources :links do
      member {post 'digg'}
    end
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

  match "/404", :to => "home#not_found"
  match "/403", :to => "home#forbidden"
end
