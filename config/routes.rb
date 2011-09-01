Gottodo::Application.routes.draw do
  
  resource :main
  resource :login
  
  root :to => 'main#index'
end
