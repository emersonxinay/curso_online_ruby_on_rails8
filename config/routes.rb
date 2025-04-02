Rails.application.routes.draw do
  root 'home#index'
  
  devise_for :users
  
  resources :courses do
    resources :sections, except: [:index, :show] do
      resources :lessons, except: [:index] do
        member do
          post :complete
        end
      end
    end
    resources :enrollments, only: [:create] do
      resources :payments, only: [:new, :create] do
        member do
          get :bank_transfer_instructions
        end
      end
    end
  end
  
  # Payment webhooks
  post 'stripe/webhook', to: 'payments#stripe_webhook'
  post 'paypal/webhook', to: 'payments#paypal_webhook'
  
  # Payment success/cancel routes
  get 'payments/:id/success', to: 'payments#success', as: :payment_success
  get 'payments/:id/cancel', to: 'payments#cancel', as: :payment_cancel
  get 'payments/:id/paypal/success', to: 'payments#paypal_success', as: :paypal_success
  get 'payments/:id/paypal/cancel', to: 'payments#paypal_cancel', as: :paypal_cancel
  
  get 'dashboard/student', to: 'dashboard#student'
  get 'dashboard/instructor', to: 'dashboard#instructor'
  get 'dashboard/admin', to: 'dashboard#admin'
end