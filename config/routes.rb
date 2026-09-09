Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Week Planner — default screen (sitemap: App → Week Planner)
  root "weeks#show"
  resources :weeks, only: [:show, :update] do
    member do
      get  "copy/:source_week_id", to: "weeks#copy", as: :copy
      post "shopping_list", to: "shopping_lists#create", as: :shopping_list
    end

    resources :days, only: [] do
      resources :menu_days, only: [:new, :create, :destroy]
    end
  end

  # Recipes — Library (sitemap: App → Recipes)
  resources :recipes do
    collection do
      get "search", to: "recipes#search", as: :search
    end
  end

  # Shopping Lists — current week + archive (sitemap: App → Shopping Lists)
  resources :shopping_lists, only: [:show, :index] do
    member do
      patch "toggle_item/:item_id", to: "shopping_lists#toggle_item", as: :toggle_item
    end
  end

  # Settings — household members (sitemap: App → Settings)
  resources :settings, only: [:index]
  resources :households, only: [:show, :edit, :update]
  resources :users, only: [:new, :create, :edit, :update, :destroy]
end