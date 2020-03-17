Rails.application.routes.draw do
  devise_for :users
  require 'sidekiq/web'
  require 'sidekiq-status/web'
  mount Sidekiq::Web => '/sidekiq'

  post '/examples/find'
  get '/examples/find', to: 'main#search'
  get '/examples/:id/add_example_facts', to: 'examples#add_example_facts',
                                         as: 'add_example_facts'
  post '/examples/:id/update_example_facts',
       to: 'examples#update_example_facts',
       as: 'update_example_facts'
  resources :examples

  match 'search', as: 'main_search', via: :get, to: 'main#search'

  resources :structures
  get '/properties/:id/add_example_facts', to: 'properties#add_example_facts',
                                           as: 'add_example_facts_to_property'
  post '/properties/:id/update_example_facts',
       to: 'properties#update_example_facts',
       as: 'update_example_facts_to_property'
  resources :properties
  resources :building_blocks
  resources :implications
  resources :axioms
  resources :example_facts

  namespace :api do
    namespace :v1 do
      get 'examples/:id', to: 'examples#show'
      get 'find', to: 'examples#find'
      get 'search', to: 'examples#search'
      get 'properties/:id', to: 'properties#show'
      get 'properties/:id/view_info', to: 'properties#view_info'
      get 'structures/:id', to: 'structures#show'
      get 'structures', to: 'structures#index'
      get 'structures/:id/view_info', to: 'structures#view_info'
    end
  end

  get '/' => 'structures#index'
  root to: 'structures#index'
end
