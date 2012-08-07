class Message < ActiveRecord::Base
  attr_accessible :ip_address, :latitude, :longitude, :message, :status
  
  def self.latest
    where(state: 'approved').limit(200)
  end
end
