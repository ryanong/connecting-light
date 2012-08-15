require 'matrix'

class Message < ActiveRecord::Base
  attr_accessible :latitude, :longitude, :message, :red, :green, :blue, :animation_data, :location_on_wall
  before_save :calculate_location_on_wall!

  validates :message, :red, :green, :blue,
    presence: true

  validates :latitude, :longitude,
    numericality: {
      greater_than_or_equal_to: -180,
      less_than_or_equal_to: 180,
      allow_nil: true
    }

  def self.latest
    order("id DESC")
  end

  def calculate_location_on_wall!
    return true if location_on_wall
    return set_random_location! if latitude.blank? || longitude.blank?

    self.location_on_wall = HadriansWall.percent_along_the_wall([longitude, latitude])
  end

  def post_time
    created_at.to_i
  end

  def set_random_location!
    self.location_on_wall = rand(0.0..100.0)
  end
end
