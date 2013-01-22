Making::Application.routes.draw do
  root to: 'home#index'

  devise_for :users, skip: [:sessions]
  as :user do
    get 'signin' => 'devise/sessions#new', as: :new_user_session
    post 'signin' => 'devise/sessions#create', as: :user_session
    delete 'signout' => 'devise/sessions#destroy', as: :destroy_user_session
  end
  resources :users, only: [:show]

  resources :things do
    resources :reviews
  end

  resources :photos, only: [:create, :destroy, :show]
  resources :review_photos, only: [:create]

  get '/search', to: 'home#search', as: :search
  get '/sandbox', to: 'home#sandbox'

  match "/404", :to => "home#not_found"
  match "/403", :to => "home#forbidden"
end
