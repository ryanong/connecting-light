ConnectingLight::Application.routes.draw do
  root to: "application#welcome"
  resources :messages, except: [:edit, :update]
end
