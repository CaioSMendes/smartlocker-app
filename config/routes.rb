Rails.application.routes.draw do
  get 'static_pages/inadimplente'
  root 'welcome#index'
  get 'admin', to: 'admin#index'
  get 'dadosuser', to: 'admin#dadosuser'
  get '/manager_users', to: 'manager_users#index', as: 'manager_users_index'
  get 'inadimplente', to: 'static_pages#inadimplente'
  resources :employees
  devise_for :users
  resources :keylockers 

  resources :employees do
    member do
      patch 'toggle_and_save_status'
      put 'reset_pin'
    end
  end

  resources :keylockers do
    member do
      patch 'toggle_and_save_status'
    end
  end

  patch 'manager_users/:id/toggle_finance', to: 'manager_users#toggle_finance', as: :toggle_finance
  patch 'manager_users/:id/toggle_role', to: 'manager_users#toggle_role', as: :toggle_role

  resources :manager_users do
    member do
      delete :destroy
    end
  end

  get '/history_entries', to: 'history_entries#index'

  resources :addresses, only: [:new, :create, :edit, :update, :destroy]

  resources :history_entries, only: [:index, :show, :new, :create, :destroy]


  # config/routes.rb
  resources :user_lockers do
    member do
      post 'assign_keylocker'
      delete 'remove_keylocker/:keylocker_id', to: 'user_lockers#remove_keylocker', as: 'remove_keylocker'
    end
  end

  

  #resources :keylockers, defaults: { format: 'json' }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :api do
    namespace :v1 do
      resources :employees
      get '/employees', to: 'employees#index'
      get '/employees/:employee_id/belongs_to_keylocker/:keylocker_id', to: 'employees#belongs_to_keylocker'
      post '/esp8288params', to: 'employees#esp8288params', via: :post
      post 'check_user', to: 'employees#check_user'
      post 'count_and_track_spaces', to: 'employees#count_and_track_spaces'
      post 'return_key', to: 'employees#return_key'
      post 'key_locker_history', to: 'employees#key_locker_history'
      get '/outro_metodo', to: 'employees#outro_metodo'
      resources :keylockers  # Ajuste para o novo nome do controlador
      #post '/auth/sign_in', to: 'authentication#sign_in'
      devise_for :users, skip: [:registrations], controllers: {
        sessions: 'api/v1/auth/sessions'
      }
    end
  end
end


