require 'ipaddr'
require 'digi_fi'

class MessagesController < ApplicationController
  respond_to :html, :json

  caches_action :index
  def index
    @messages = Message.latest

    respond_with @messages do |format|
      format.json {
        render json: @messages.as_json(
          except: [:created_at, :updated_at, :status, :ip_address],
          methods: [:post_time]
        )
      }
    end
  end

  def show
    @message = Message.find(params[:id])

    respond_with @message do |format|
      format.json {
        render json: @message.as_json(
          except: [:created_at, :updated_at, :status, :ip_address],
          methods: [:post_time]
        )
      }
    end
  end

  def new
    @message = Message.new

    respond_with @message
  end

  def create
    @message = Message.new(params[:message])
    @message.ip_address = IPAddr.new(request.remote_ip).to_i
    @message.status = "approved"
    if @message.save
      expire_action :action => :index
      digi_fi_client.send_message(@message)
    end
    respond_with @message
  end

  def digi_fi_client
    @digi_fi_client ||= DigiFi.new
  end
end
