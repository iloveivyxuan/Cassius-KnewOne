Making::Application.routes.draw do
  root to: 'home#index'

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
    resources :reviews, except: [:index] do
      member {post 'vote'}
    end
    collection {get 'admin'}
    member {post 'fancy'}
    member {post 'own'}
    get 'date/:date', action: :index, on: :collection
  end

  resources :reviews, only: [:index] do
    get 'page/:page', action: :index, on: :collection
  end

  resources :posts, only: [] do
    resources :comments
  end

  resources :photos, only: [:create, :destroy, :show]
  resources :review_photos, only: [:create]

  resources :messages, only: [:index] do
    get 'page/:page', action: :index, on: :collection
    collection do
      post 'readall'
    end
  end

  get '/search', to: 'home#search', as: :search
  get '/sandbox', to: 'home#sandbox'

  match "/404", :to => "home#not_found"
  match "/403", :to => "home#forbidden"
end
