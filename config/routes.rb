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
        end
        resources :orders do
          get :customer
          get :adjustments
          get :payments
          get :returns
          put :approve
          put :cancel
        end
      end
    end
    resources :products
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
    resources :addresses 
    resources :payment_histories
    resources :wishlists
    #Applications routes
    resources :shop , :only => [:index,:show]
    resources :orders do 
      put :ready_to_pick
      put :cancel
    end
    resources :payment_preferences

    #Api routes
    namespace :api do 
      namespace :v1 do 

        resources :products do 
          post :rate_and_comment
        end

        concern :order_routes do
          member do
            put :approve
            put :cancel
            put :empty
            put :apply_coupon_code
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


        resources :merchant_stores do 
          put :update_location
          post :rate
        end
        resources :registrations 
        resources :sessions
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
        end
        resources :orders, concerns: :order_routes

      end
    end

    #Admin routes
    namespace :admin do 
      resources :sellers do 
        resources :payment_preferences
        get :stores
        resources :payment_histories
        get :store_orders
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
