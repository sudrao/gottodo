Gottodo::Application.routes.draw do

  resource :evernote
  resource :main
  resource :login
  resources :users
  
  root :to => 'mains#show'
end
