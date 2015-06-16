Rails.application.routes.draw do
  get 'users_sessions/destroy'

  root 'users#users'
  post 'playlist' => 'playlist#new'
  get 'playlist' => 'playlist#playlist'
  post 'play' => 'playlist#play'
  get 'login' => 'spotify#login'
  get 'login/:id' => 'spotify#login', as: :login_user
  get 'auth/spotify/callback' => 'spotify#callback'
  get 'auth/failure' => 'spotify#failure'
  get 'stats' => 'admin#stats'
  get 'percentage' => 'playlist#percentage'

  resources :users_sessions, only: [:destroy]
  resources :last_fm_users, only: [:create, :update], controller: 'last_fm'

  # resources :sessions, :only => [] do
  #   member do
  #     post "user" => 'user_sessions#create'
  #     delete "user/:id" => 'user_sessions#destroy'
  #   end
  # end

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
