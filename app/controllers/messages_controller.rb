require 'ipaddr'
require 'digi_fi'

class MessagesController < ApplicationController
  respond_to :html, :json

  caches_action :index
  def index
    if params[:count].is_a?(Numeric)
      @messages = Messages.limit(params[:count])
    else
      @messages = Messages.limit(1000)
    end

    if params[:since_id]
      @messages = @messages.where('id > ?', params[:since_id])
    end

    if params[:since_time]
      @messages = @messages.where('created_at > ?', params[:since_time])
    end

    respond_with @messages do |format|
      format.json {
        render json: @messages.as_json(
          except: [:created_at, :updated_at, :ip_address],
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
          except: [:created_at, :updated_at, :ip_address],
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
