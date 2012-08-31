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
    }, unless: :location_on_wall?

  validate :one_message_per_5_seconds, on: :create

  def self.latest
    order("id DESC")
  end

  def closest_wall_point
    HadriansWall.closest_wall_point([longitude, latitude])
  end

  def calculate_location_on_wall!(force = false)
    return true if !self.location_on_wall.nil? && !force
    return set_random_location! if latitude.blank? || longitude.blank?

    self.location_on_wall = HadriansWall.percent_along_the_wall([longitude, latitude])
  end

  def post_time
    created_at.to_i
  end

  def set_random_location!
    self.location_on_wall = rand(0.0..1.0)
  end

  def animation_data
    super || "/wF/ZAA4Ycf5hh8P4YAABIMOAwAAAAAAAAAAAAwAAAAAAAAA"
  end

  def rgb
    [red,green,blue]
  end

  def as_json(args = {})
    super({except: [:created_at, :updated_at, :ip_address],
      methods: [:post_time, :rgb]}.merge(args))
  end

  def one_message_per_5_seconds
    if self.class.where(ip_address: ip_address).where("created_at >= ?", 5.seconds.ago).count > 0
      errors.add(:base, "you can only post one message every 5 seconds")
    end
  end

  def update_animation_data!
    response = Typhoeus::Request.get(
      "http://198.101.204.58/tts.of",
      params: {
        text: message,
        type: "base64"
      }
    )
    if response.success?
      self.animation_data = response.body
      return true
    elsif response.timed_out?
      Rails.logger.error("got a time out")
    elsif response.code == 0
      Rails.logger.error(response.curl_error_message)
    else
      Rails.logger.error("HTTP request failed: " + response.code.to_s)
    end
    false
  end
end
