class ApplicationController < ActionController::Base
  protect_from_forgery

  def welcome

  end

  def time
    respond_to do |format|
      format.html { render text: Time.now.to_i }
      format.json { render json: { time: Time.now.to_i } }
    end
  end
end
