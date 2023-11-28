Rails.application.routes.draw do
  root 'welcome#index'
  get 'admin', to: 'admin#index'
  resources :employees
  devise_for :users
  resources :keylockers 
  get '/historicos', to: 'historicos#index'
  resources :addresses, only: [:new, :create, :edit, :update, :destroy]
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
      get '/outro_metodo', to: 'employees#outro_metodo'
      resources :keylockers  # Ajuste para o novo nome do controlador
      #post '/auth/sign_in', to: 'authentication#sign_in'
      devise_for :users, skip: [:registrations], controllers: {
        sessions: 'api/v1/auth/sessions'
      }
    end
  end
end


