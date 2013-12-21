AdminWebapp::Application.routes.draw do  
  resources :users
  resources :patients
  resources :medications
  resources :sessions, only: [:new , :create, :destroy]
  resources :appusers
  resources :password_resets
  resources :charities
  resources :serials

  root to: 'sessions#new'

  match '/home', to: 'static_pages#home'

  resources :users do
    member do
      get "change_password"
    end
  end

  match '/signin',  to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete

  resources :appusers do
    member do
      get "change_password"
    end
  end

  ############################################
  ############### Api posts ##################

  #auth
  match '/auth/access_token' => 'auth#access_token', :via => [:post];
  match '/auth/user_token' => 'auth#user_token', :via => [:post];
  
  #Users
  match '/api/Users' => 'api#users', :via => [:post]
  match '/api/update_user' => 'api#update_user', :via => [:post]
  
  #patients
  match '/api/Patients' => 'api#patients', :via => [:post]
  match '/api/update_patient' => 'api#update_patient', :via => [:post]
  match '/api/upload_patient_image' => 'api#upload_patient_image', :via => [:post]
  
  #visits
  match '/api/Visitations' => 'api#visits', :via => [:post]
  match '/api/update_visit' => 'api#update_visit', :via => [:post]
  
  #prescriptions
  match '/api/Prescriptions' => 'api#prescriptions', :via => [:post]
  match '/api/update_prescription' => 'api#update_prescription', :via => [:post]
  
  #medications
  match '/api/Medication' => 'api#medications', :via => [:post]
  
  ############################################
end
