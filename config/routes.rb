Rails.application.routes.draw do
  root 'home#index'
  
  devise_for :users
  
  resources :courses do
    member do
      get :setup
    end
    resources :sections, except: [:index, :show] do
      resources :lessons, except: [:index] do
        member do
          post :complete
          post :mark_as_completed
        end
      end
    end
    resources :enrollments, only: [:create] do
      resources :payments, only: [:new, :create] do
        member do
          get :bank_transfer_instructions
          get :paypal_success
          get :paypal_cancel
          patch :upload_receipt
        end
      end
    end
  end
  
  # Certificates routes
  resources :certificates, only: [:index, :show] do
    member do
      get :download
    end
  end
  
  # Enrolled courses for current user
  get 'my-courses', to: 'enrollments#index', as: :enrolled_courses
  
  # Payment webhooks
  post 'stripe/webhook', to: 'payments#stripe_webhook'
  post 'paypal/webhook', to: 'payments#paypal_webhook'
  
  # Payment success/cancel routes
  get 'payments/:id/success', to: 'payments#success', as: :payment_success
  get 'payments/:id/cancel', to: 'payments#cancel', as: :payment_cancel
  
  # Dashboard routes
  get 'dashboard/student', to: 'dashboard#student'
  get 'dashboard/instructor', to: 'dashboard#instructor'
  get 'dashboard/admin', to: 'dashboard#admin'
  
  # Static pages
  get 'about', to: 'home#about'
  get 'privacy', to: 'home#privacy'
  get 'terms', to: 'home#terms'
  get 'contact', to: 'home#contact'
  
  # Notifications
  resources :notifications, only: [:index, :show, :update]
  
  # Admin routes
  namespace :admin do
    resources :users
    resources :courses
    resources :payments do
      member do
        patch :approve
        patch :reject
      end
    end
    resources :enrollments
    resources :certificates
    root to: 'dashboard#index'
  end
end