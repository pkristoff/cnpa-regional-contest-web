Rails.application.routes.draw do

  root 'home#index'

  match '/assets/javascripts/directives/images/images-template' => 'home#file_list_template', via: :get
  match '/views/partials/chooseContest' => 'home#choose_contest', via: :get
  match '/views/partials/contestFiles' => 'home#contest_files', via: :get
  match '/views/partials/busyModal' => 'home#busyModal', via: :get
  match 'rename-file-template' => 'home#rename_file_template', via: :get


  match '/addFiles' => 'home#add_files', via: :post
  match '/contest' => 'home#contest', via: :get
  match '/createContest' => 'home#create_contest', via: :post
  match '/deleteFile' => 'home#delete_file', via: :post
  match '/directory' => 'home#directory', via: :get
  match '/email_contest' => 'home#email_contest', via: :post
  match '/generateContest' => 'home#generate_contest', via: :post
  match '/getContests' => 'home#get_contests', via: :post
  match '/home_css.css' => 'home#home_css', via: :post
  match '/regenerateContest' => 'home#regenerate_contest', via: :post
  match '/rename_file' => 'home#rename_file', via: :post
  match '/saveConfigInfo' => 'home#save_config_info', via: :post
  match '/setCopyright' => 'home#set_copyright', via: :post

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with 'rake routes'.

  # You can have the root of your site routed with 'root'
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
