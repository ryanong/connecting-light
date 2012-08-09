class MessagesController < ApplicationController
  respond_to :html, :json

  def index
    @messages = Rails.cache.fetch('latest-messages') do
      Message.latest
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

    respond_with @message
  end
end
