Making::Application.routes.draw do
  root to: 'home#index'

  devise_for :users, skip: [:sessions],
  controllers:  {omniauth_callbacks: "omniauth_callbacks"}

  as :user do
    get 'signin' => 'devise/sessions#new', as: :new_user_session
    delete 'signout' => 'devise/sessions#destroy', as: :destroy_user_session
  end
  resources :users, only: [:show]

  resources :things do
    resources :reviews
    collection {get 'admin'}
  end

  resources :photos, only: [:create, :destroy, :show]
  resources :review_photos, only: [:create]

  get '/search', to: 'home#search', as: :search
  get '/sandbox', to: 'home#sandbox'

  match "/404", :to => "home#not_found"
  match "/403", :to => "home#forbidden"
end
