Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'
  get "/dashboard", to: 'pages#dashboard'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
resources :companies, only: [:index, :show]
resources :recruitments, only: [:index, :show]
resources :categories, only: [:index, :show]
resources :events, only: [:index, :show]
resources :events_categories, only: [:index, :show] do
  resources :subscriptions
end


end
