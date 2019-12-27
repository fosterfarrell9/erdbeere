Rails.application.routes.draw do
  root to: redirect('/de')
  scope '/:locale', locale: /#{I18n.available_locales.join('|')}/ do
    post '/examples/find'
    get '/examples/find', to: 'main#search'
    resources :examples

    match 'search', as: 'main_search', via: :get, to: 'main#search'

    resources :structures
    resources :properties
    resources :building_blocks
    resources :implications
    get '/' => 'structures#index'
  end
end
