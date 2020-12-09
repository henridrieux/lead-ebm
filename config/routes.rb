Rails.application.routes.draw do
  # Sidekiq Web UI, only for admins.
  # authenticate :user, ->(user) { user.admin? } do
  #   mount Sidekiq::Web => '/sidekiq'
  # end
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
  root to: 'pages#home'
  get "/about", to: 'pages#about'
  get "/dashboard", to: 'pages#dashboard'
  get "/cpps", to: 'pages#cpps'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :companies, only: [:index, :show]
  resources :recruitments, only: [:index, :show]
  resources :categories, only: [:index, :show]
  resources :events, only: [:index, :show]
  resources :event_categories, only: [:index, :show] do
    resources :subscriptions
  end
end
