Rails.application.routes.draw do
  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs' if Rails.env.development?

  get "up" => "rails/health#show", as: :rails_health_check

  # Devise at root level so scope stays :user (authenticate_user!, current_user)
  devise_for :users, path: 'api/v1/admin/auth', controllers: {
    sessions: 'api/v1/admin/sessions'
  }, defaults: { format: :json }

  namespace :api do
    namespace :v1 do
      # Admin / Backoffice
      namespace :admin do
        resource :store, only: [:show, :update]
        resource :dashboard, only: [:show]
        resources :categories
        resources :products do
          resources :variants, controller: 'variants'
          resources :images, controller: 'product_images', only: [:index, :create, :update, :destroy]
        end
        resources :orders, only: [:index, :show, :update]
        resources :customers, only: [:index, :show]
      end

      # Storefront (public)
      namespace :storefront do
        resources :products, only: [:index, :show], param: :slug
        resources :categories, only: [:index, :show], param: :slug

        resource :cart, only: [:show] do
          post :add_item
          patch :update_item
          delete :remove_item
          delete :clear
        end

        resource :store, only: [:show]

        resources :orders, only: [:create, :show], param: :order_number do
          patch :accept_terms, on: :member
        end
        resource :session, only: [:create]
        resources :customers, only: [:create, :show, :destroy] do
          get :export_data, on: :member
        end

        resource :checkout, only: [] do
          post 'sessions', to: 'checkout_sessions#create'
          get 'sessions/:id/status', to: 'checkout_sessions#status', as: :session_status
        end
      end
    end
  end

  post '/webhooks/stripe', to: 'webhooks/stripe#create'
end
