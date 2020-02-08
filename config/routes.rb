Rails.application.routes.draw do
  require 'sidekiq/web'

  mount Sidekiq::Web => '/sidekiq'

  root to: redirect('/de')
  scope '/:locale', locale: /#{I18n.available_locales.join('|')}/ do
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
    get '/' => 'structures#index'
  end
end
