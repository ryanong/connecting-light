require 'matrix'

class Message < ActiveRecord::Base
  attr_accessible :latitude, :longitude, :message, :status
  serialize :closest_point, Vector

  before_save :calculate!

  def self.latest
    where(status: 'approved').limit(200)
  end

  WALLSEND = Vector[54.9913,-1.5290]
  BOWNESS = Vector[54.9532, -3.2146]

  def percent_of_wall
    distance_to_segment
  end

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

  def calculate!
    dx = WALLSEND[0] - BOWNESS[0]
    dy = WALLSEND[1] - BOWNESS[1]
    # Calculate the t that minimizes the distance.
    t = ((pt[0] - BOWNESS[0]) * dx + (pt[1] - BOWNESS[1]) * dy) / (dx^2 + dy^2)

    # See if this represents one of the segment's
    # end points or a point in the middle.
    if (t < 0)
      self.closest_point = BOWNESS
      dx = pt[0] - BOWNESS[0]
      dy = pt[1] - BOWNESS[1]
    elsif (t > 1)
      self.closest_point = WALLSEND
      dx = pt[0] - WALLSEND[0]
      dy = pt[1] - WALLSEND[1]
    else
      self.closest_point = Vector[BOWNESS[0] + t * dx, BOWNESS[1] + t * dy]
      dx = pt[0] - closest[0]
      dy = pt[1] - closest[1]
    end

    self.distance=Math.sqrt(dx * dx + dy * dy);
  end
end
