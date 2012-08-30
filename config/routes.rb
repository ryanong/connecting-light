ConnectingLight::Application.routes.draw do
  get "viz/map"

  resources :admin_settings do
    collection do
      post :send_hello_world_ping
      post :reload_json_settings
      post :send_admin_settings
      post :do_clear_messages
    end
  end

  root to: "application#welcome"
  get "time" => "application#time"
  resources :messages, except: [:edit, :update] do
    collection do
      post :sms
      get :hadrians_mapbox
    end
  end
end
