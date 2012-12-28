Making::Application.routes.draw do
  root to: 'home#index'

  devise_for :users, skip: [:sessions]
  as :user do
    get 'signin' => 'devise/sessions#new', as: :new_user_session
    post 'signin' => 'devise/sessions#create', as: :user_session
    delete 'signout' => 'devise/sessions#destroy', as: :destroy_user_session
  end
  resources :users, only: [:show]

  resources :guides do
    resources :steps
  end

  resources :photos, only: [:new, :create, :destroy]

  match "/404", :to => "home#not_found"
  match "/403", :to => "home#forbidden"
end
