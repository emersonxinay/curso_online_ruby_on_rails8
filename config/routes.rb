Rails.application.routes.draw do
  get "home/index"
  get "courses/new"
  get "courses/create"
  get "courses/edit"
  get "courses/update"
  root to: "home#index"
  devise_for :users
  authenticate :user, ->(u) { u.admin? } do
    namespace :admin do
      get 'dashboard', to: 'dashboard#index'
    end
  end
  
  authenticate :user, ->(u) { u.instructor? } do
    resources :courses, only: [:new, :create, :edit, :update]
  end

end
