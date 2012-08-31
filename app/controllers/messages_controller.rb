require 'csv'
require 'ipaddr'
require 'digi_fi'

class MessagesController < ApplicationController
  respond_to :html, :json

  skip_before_filter :verify_authenticity_token

  caches_action :index, expires_in: 1.seconds , cache_path: Proc.new { |controller|
    cache_path = "messages.#{controller.params[:format]}?count=#{params[:count] || '1000'}"
    cache_path << "since_id=#{params[:since_id]}" if params[:since_id]
    cache_path << "since_time=#{params[:since_time]}" if params[:since_time]
    cache_path << "from_location=#{params[:from_location]}" if params[:from_location]
    cache_path << "to_location=#{params[:to_location]}" if params[:to_location]
    cache_path << "page=#{params[:page]}" if params[:page]
    cache_path
  }

  def index
    @messages = Message.order("id DESC")
    if params[:page]
      @messages = @messages.page(params[:page])
    else
      if params[:count] =~ /\A\d+\Z/
        @messages = @messages.limit(params[:count])
      else
        @messages = @messages.limit(1000)
      end
    end

    if params[:since_id]
      @messages = @messages.where('id >= ?', params[:since_id].to_i)
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

  caches_action :hadrians_mapbox

  def hadrians_mapbox
    @messages = Message.order("id DESC").limit(500)

    @messages = @messages.where("latitude <= :north AND latitude >= :south AND longitude >= :west AND longitude <= :east", params[:map_box])
    @messages = @messages.where('created_at >= ?', 5.seconds.ago)
    render json: {messages: @messages.as_json(methods: [:post_time, :rgb, :closest_wall_point])}
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
    if @message.valid?
      @message.update_animation_data! if @message[:animation_data].blank?
      @message.save
      expire_action :action => :index
      expire_action :action => :hadrians_mapbox, format: :json
      digi_fi_client.send_message(@message)
    end
    respond_with @message
  end

  PHONE_TO_LAT_LONG = {}
  CSV.foreach(Rails.root.join("data","connecting-light.csv"), headers: true) do |row|
    PHONE_TO_LAT_LONG[row["number"]] = [row["latitude"].to_f,row["longitude"].to_f]
  end

  def sms
    latitude, longitude = PHONE_TO_LAT_LONG[params[:To]] || [0,0]
    @message = Message.new(
      red: 255,
      green: 0,
      blue: 234,
      latitude: latitude,
      longitude: longitude,
      animation_data: "/wF//wH/////g+AAf/4AAAAAAAAAAAAAB///////6ABAAAAA",
      message: params[:Body]
    )

    if @message.save
      expire_action :action => :index
      digi_fi_client.send_message(@message)
    end

    render nothing: true
  end
end
