Rails.application.routes.draw do
  resource :builds, only: :create

  mount ActionCable.server => '/cable'

  resources :builds

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
