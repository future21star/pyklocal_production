Pyklocal::Application.routes.draw do 


  
  namespace :merchant do
    get "stores/amazon/fetch", to: "amazon_products#fetch", as: "store_amazon_product"
    get "/", to: "home#index"
    get "stores/products/:product_id/variants", to: "variants#index", as: "stores_products_variants"
    get "stores/products/:product_id/variants/new", to: "variants#new", as: "stores_products_variants_new"
    get "stores/:store_id/orders", to: "orders#index", as: :store_orders
    
    resources :stores do
      collection do
        resources :amazon_products do
          collection do
            post :import_collection
          end
        end 
        resources :products do
          resources :images
          resources :variants
          resources :product_properties
          get :stock
          collection do
            post :bulk_upload
            get :sample_csv
          end
        end
        resources :orders do
          get :customer
          get :adjustments
          get :payments
          get :approve
          put :cancel
          post :return_item_accept_reject
          collection do 
            get :returns
          end
        end
      end
    end
    resources :products
    resources :return_authorization_reasons
  end

  resources :email_tokens do
    collection do
      get :edit_store
    end
  end

  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being the default of "spree"
  mount Spree::Core::Engine, at: '/'

  Spree::Core::Engine.routes.draw do 
    get "new_store_application", to: "home#new_store_application"
    get "orders" => "home#orders"
    get "order_placed/:id", to: "orders#order_placed", as: "order_placed"
    resources :addresses 
    resources :payment_histories
    resources :wishlists 
    resources :users_feedbacks
    #Applications routes
    resources :shop , :only => [:index,:show]
    resources :orders do 
      put :ready_to_pick
      put :cancel
      put :apply_coupon_code
      # resources :return_authorizations
      resources :customer_return_items do
        collection do 
          post :return_multiple_item
          get :eligible_item
        end
      end
      
    end
    resources :return_authorizations
    resources :payment_preferences
    resources :customer_returns, only: [:index, :new, :edit, :create, :update] do
        member do
          put :refund
        end
      end
    
    #Api routes
    namespace :api do 
      namespace :v1 do

        resources :home
        resources :pages, only: [:index]
        resources :client_tokens, only: [:show]
        resources :user_addresses, only: [:show, :update, :create, :destroy]
        resources :wishlists , :only => [:index, :destroy, :create]

        resources :search do 
          get :filters, on: :collection
        end

        resources :categories

        resources :store_sessions
        resources :users_feedbacks

        resources :ratings_reviews, only: [:index, :create]

        resources :products do 
          post :rate_and_comment
          get :related_product
        end

        concern :order_routes do
          member do
            put :approve
            put :cancel
            put :empty
            put :apply_coupon_code
            post :add_to_cart
            get :refresh_order_summary
            put :cancel_coupon
            post :populate
            put :cancel_coupon_code
            get :get_adjustments
          end

          
          resources :line_items
          resources :payments do
            member do
              put :authorize
              put :capture
              put :purchase
              put :void
              put :credit
            end
          end

          resources :addresses, only: [:show, :update]

          resources :return_authorizations do
            member do
              put :add
              put :cancel
              put :receive
            end
          end
        end

        resources :countries do 
          member do
            get :states
          end
        end

        resources :merchant_stores do 
          put :update_location
          post :rate
        end
        resources :registrations, only: [:create]
        resources :sessions
        resources :password do
          post :change_password, on: :collection
        end
        resources :users do
          post :user_devices
          get :my_pickup_list
          put :update_location
          put :pickup
          put :add_to_cart
          get :my_cart
          put :remove_from_cart
          put :mark_as_deliver
          get :my_delivery_list
          get :profile
          get :get_cart
          get :get_orders
        end
        resources :orders, concerns: :order_routes

      end
    end

    #Admin routes
    namespace :admin do 
      resources :commissions
      resources :feedbacks
      resources :carousel_images
      resources :static_images
      resources :cancel_orders

      resources :sellers do 
        resources :payment_preferences
        get :stores
        resources :payment_histories
        get :store_orders
        delete :delete_store
      end
      resources :reports, only: [:index] do
        collection do
          get :products_sale_report
          post :products_sale_report
          get :store_details_report
          post :store_details_report
        end
      end
    end

  end
          # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
