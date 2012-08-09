class AdminMessagesController < ApplicationController
  respond_to :html, :json

  def index
    @messages = Message.all
    respond_with @messages
  end

  def approve
    @messages = Message.where(id: params[:ids])
    @messages.update_all(status: "approved")

    redirect_to :index
  end

  def show
    @message = Message.find(params[:id])

    respond_with @message
  end

  def destroy
    @message = Message.find(params[:id])

    @message.destroy
    respond_with @message
  end
end
