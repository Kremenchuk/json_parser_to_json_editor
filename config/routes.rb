Rails.application.routes.draw do
  root 'home#index'
  get 'parser' => 'home#parser'
  get 'save_json' => 'home#save_json'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
