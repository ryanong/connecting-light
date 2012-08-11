require 'ipaddr'

class MessagesController < ApplicationController
  respond_to :html, :json

  caches_action :index
  def index
    Message.latest

    respond_with @messages
  end

  def show
    @message = Message.find(params[:id])

    respond_with @message
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
    end
    respond_with @message
  end
end
