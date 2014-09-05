Cashbox::Application.routes.draw do
  devise_for :users
  # You can have the root of your site routed with "root"
  root 'home#show'

  resources :organizations do
    member do
      put :switch
    end
  end
  resources :bank_accounts, except: [:show, :index]
  resources :categories
  resources :transactions,  only: [:create, :edit, :update, :destroy]
  resources :members, only: [:index, :edit, :update]
end
