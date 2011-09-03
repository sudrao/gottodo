Gottodo::Application.routes.draw do

  resource :evernote
  resource :main
  resource :login
  
  root :to => 'main#index'
end
