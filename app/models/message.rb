require 'matrix'

class Message < ActiveRecord::Base
  attr_accessible :latitude, :longitude, :message, :red, :green, :blue
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
    where(status: 'approved').limit(200).order("id DESC")
  end

  WALLSEND = Vector[54.9913,-1.5290]
  BOWNESS = Vector[54.9532, -3.2146]

  def point
    Vector[latitude,longitude]
  end

  def self.distance( point1, point2 )
    xs = point2[0] - point1[0];
    xs = xs * xs;

    ys = point2[1] - point1[1];
    ys = ys * ys;

    return Math.sqrt( xs + ys );
  end

  HADRIANS_DISTANCE = distance(WALLSEND, BOWNESS)

  def calculate_location_on_wall!
    return set_random_location! if latitude.blank? || longitude.blank?
    dx = WALLSEND[0] - BOWNESS[0]
    dy = WALLSEND[1] - BOWNESS[1]
    # Calculate the t that minimizes the distance.
    t = ((point[0] - BOWNESS[0]) * dx + (point[1] - BOWNESS[1]) * dy) / (dx**2 + dy**2)

    # See if this represents one of the segment's
    # end points or a point in the middle.
    if (t < 0)
      closest_point = BOWNESS
      dx = point[0] - BOWNESS[0]
      dy = point[1] - BOWNESS[1]
    elsif (t > 1)
      closest_point = WALLSEND
      dx = point[0] - WALLSEND[0]
      dy = point[1] - WALLSEND[1]
    else
      closest_point = Vector[BOWNESS[0] + t * dx, BOWNESS[1] + t * dy]
      dx = point[0] - closest[0]
      dy = point[1] - closest[1]
    end

    distance_to_wall=Math.sqrt(dx * dx + dy * dy);

    if distance_to_wall > 3.0
      self.set_random_location!
    else
      self.location_on_wall = self.class.distance(closest_point, BOWNESS)
    end
  end

  def set_random_location!
    self.location_on_wall = rand(0.0..100.0)
  end
end
