AdminWebapp::Application.routes.draw do  
  resources :users
  resources :patients
  resources :medications
  resources :sessions, only: [:new , :create, :destroy]
  resources :appusers
  resources :password_resets
  resources :charities

  root to: 'sessions#new'

  match '/home', to: 'static_pages#home'

  match '/createuser', to: 'users#new'
  match '/users',  to: 'users#index'
  resources :users do
    member do
      get "change_password"
    end
  end

  match '/signin',  to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete

  match '/appusers', to: 'appusers#index'
  match '/createappuser', to: 'appusers#new'
  resources :appusers do
    member do
      get "change_password"
    end
  end

  match '/patients', to: 'patients#index'

  ############################################
  ############### Api posts ##################

  #auth
  match '/auth/access_token' => 'auth#access_token', :via => [:post];
  match '/auth/user_token' => 'auth#user_token', :via => [:post];
  
  #Users
  match '/api/Users' => 'api#users', :via => [:post]
  match '/api/user_by_id' => 'api#user_for_id', :via => [:post]
  match '/api/update_user' => 'api#update_user', :via => [:post]
  match '/api/deactivate_user' => 'api#deactivate_user', :via => [:post]
  
  #patients
  match '/api/Patients' => 'api#patients', :via => [:post]
  match '/api/patient_for_id' => 'api#patient_for_id', :via => [:post]
  match '/api/update_patient' => 'api#update_patient', :via => [:post]
  match '/api/upload_patient_image' => 'api#upload_patient_image', :via => [:post]
  
  #visits
  match '/api/Visitations' => 'api#visits', :via => [:post]
  match '/api/visits_for_id' => 'api#visits_for_id', :via => [:post]
  match '/api/visits_for_patient' => 'api#visits_for_patient', :via => [:post]
  match '/api/update_visit' => 'api#update_visit', :via => [:post]
 # match '/api/edit_visit' => 'api#edit_visit', :via => [:post]
  
  #prescriptions
  match '/api/Prescriptions' => 'api#prescriptions', :via => [:post]
  match '/api/prescriptions_for_id' => 'api#prescriptions_for_id', :via => [:post]
  match '/api/prescriptions_for_visit' => 'api#prescriptions_for_visit', :via => [:post]
  match '/api/update_prescription' => 'api#update_prescription', :via => [:post]
  #match '/api/edit_prescription' => 'api#edit_prescription', :via => [:post]
  
  #medications
  match '/api/Medications' => 'api#medications', :via => [:post]
  match '/api/medications_for_id' => 'api#medications_for_id', :via => [:post]
  match '/api/update_medication' => 'api#update_medication', :via => [:post]
 # match '/api/edit_medication' => 'api#edit_medication', :via => [:post]
  
  
  ############################################

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
