ConnectingLight::Application.routes.draw do
  resources :messages, except: [:edit, :update]
end
