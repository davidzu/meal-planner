Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "weeks#show"

  resources :weeks, only: [:show, :update] do
    member do
      post :copy
      post :clear
      post :shopping_list, to: "shopping_lists#create"
    end
    resources :days, only: [] do
      resources :menu_days, only: [:new, :create, :update, :destroy]
    end
  end

  resources :recipes do
    collection { get :search }
  end

  resources :shopping_lists, only: [:index, :show] do
    member { patch :toggle_item }
  end

  get "settings", to: "settings#index", as: :settings
  resources :households, only: [:update]
  resources :users, only: [:new, :create, :edit, :update, :destroy]
end
