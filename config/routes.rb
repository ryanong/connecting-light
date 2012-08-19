ConnectingLight::Application.routes.draw do
  resources :admin_settings

  root to: "application#welcome"
  get "time" => "application#time"
  resources :messages, except: [:edit, :update]
end
