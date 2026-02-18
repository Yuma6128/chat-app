Rails.application.routes.draw do
  devise_for :users
  root to: "events#dashboard"

  get  '/dashboard', to: 'events#dashboard', as: :dashboard
  get  '/rooms',     to: 'rooms#index',      as: :rooms

  resources :users, only: [:edit, :update]
  resources :rooms, only: [:new, :create, :destroy]

  resources :events do
    resources :tasks, only: [:create, :edit, :update, :destroy] do
      member do
        patch :toggle_status
      end
    end
  end

  resources :rooms, only: [] do
    resources :messages, only: [:index, :create]
  end
end
