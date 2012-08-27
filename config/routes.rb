ConnectingLight::Application.routes.draw do
  resources :admin_settings do
    collection do
      post :send_hello_world_ping
      post :reload_json_settings
      post :send_admin_settings
    end
  end

  root to: "application#welcome"
  get "time" => "application#time"
  resources :messages, except: [:edit, :update] do
    collection do
      post :sms
    end
  end
end
