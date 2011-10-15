Gottodo::Application.routes.draw do

  resource :evernote
  resource :main
  resource :login
  resources :user
  
  root :to => 'mains#show'
end
