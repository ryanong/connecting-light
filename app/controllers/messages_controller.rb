require 'ipaddr'
require 'digi_fi'

class MessagesController < ApplicationController
  respond_to :html, :json

  skip_before_filter :verify_authenticity_token

  caches_action :index, expires_in: 10.seconds , cache_path: Proc.new { |controller|
    cache_path = "messages.#{controller.params[:format]}?limit=#{params[:count] || '1000'}"
    cache_path << "since_id=#{params[:since_id]}" if params[:since_id]
    cache_path << "since_time=#{params[:since_time]}" if params[:since_time]
    cache_path << "from_location=#{params[:from_location]}" if params[:from_location]
    cache_path << "to_location=#{params[:to_location]}" if params[:to_location]
    cache_path
  }

  def index
    @messages = Message.order("id DESC").limit(1000)

    if params[:count].is_a?(Numeric)
      @messages = @messages.limit(params[:count])
    end

    if params[:since_id]
      @messages = @messages.where('id >= ?', params[:since_id])
    end

    if params[:since_time]
      @messages = @messages.where('created_at >= ?', Time.at(params[:since_time].to_i))
    end

    if params[:from_location]
      @messages = @messages.where('location_on_wall >= ?', params[:from_location].to_f)
    end

    if params[:to_location]
      @messages = @messages.where('location_on_wall <= ?', params[:to_location].to_f)
    end

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
      @message.update_animation_data! if @message[:animation_data].blank?
      digi_fi_client.send_message(@message)
    end
    respond_with @message
  end

  def sms
    @message = Message.new(
      red: 255,
      green: 0,
      blue: 234,
      latitude: 70,
      longitude: 40,
      location_on_wall: 0,
      animation_data: "/wF//wH/////g+AAf/4AAAAAAAAAAAAAB///////6ABAAAAA",
      message: params[:Body]
    )

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
