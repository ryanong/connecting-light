ConnectingLight::Application.routes.draw do
  root to: "application#welcome"
  get "time" => "application#time"
  resources :messages, except: [:edit, :update]
end
