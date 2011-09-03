Gottodo::Application.routes.draw do
  
  resources :oauth_consumers do
    member do
      get :callback
      get :callback2
      match 'client/*endpoint' => 'oauth_consumers#client'
    end
  end

  resource :main
  resource :login
  
  root :to => 'main#index'
end
