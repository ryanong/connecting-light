require 'csv'

class HadriansWall
  class << self
    def closest_ballon(point)
      minimum_distance = nil
      closest = nil
      BALLOONS.each do |balloon|
        distance = euclidean_distance(point, balloon)
        if minimum_distance.nil? || minimum_distance > distance
          minimum_distance = distance
          closest = balloon
        end
      end
      closest
    end

    def closest_wall_point(point)
      distance_on_wall = nil

      minimum_distance = nil
      closest_point = nil
      last_wall_point = BALLOON_POINTS.first

      BALLOON_POINTS.each do |wall_point|
        closest_point_to_line, distance = closest_point_and_distance(point, last_wall_point, wall_point)
        if minimum_distance.nil? || minimum_distance > distance
          minimum_distance = distance
          closest_point = closest_point_to_line
          distance_on_wall = LENGTHS[last_wall_point] + euclidean_distance(last_wall_point, closest_point)
        end
        last_wall_point = wall_point
      end
      [closest_point, distance_on_wall]
    end

    def percent_along_the_wall(point)
      _ , distance = closest_wall_point(point)
      distance / LENGTH
    end

    def euclidean_distance(vector1, vector2)
      sum = 0.0
      return sum if vector1 == vector2
      vector1.zip(vector2).each do |v1, v2|
        component = (v1 - v2)**2
        sum += component
      end
      Math.sqrt(sum)
    end

    def closest_point_and_distance(point, start, finish)
      if(start == finish)
        return [start, euclidean_distance(point, start)]
      end

      l2 = distance_squared(start, finish);
      t = ((point[0] - start[0]) * (finish[0] - start[0]) + (point[1] - start[1]) * (finish[1] - start[1])) / l2;

      if(t < 0)
        return [start, euclidean_distance(point, start)];
      end

      if(t > 1)
        return [finish, euclidean_distance(point, finish)];
      end

      closest_point = [start[0] + t * (finish[0] - start[0]),
                       start[1] + t * (finish[1] - start[1])]
      return [closest_point, euclidean_distance(point, closest_point)];
    end

    def distance_squared(v,w)
      (v[0] - w[0])**2 + (v[1] - w[1])**2
    end

  end

  POINTS = []
  CSV.foreach(Rails.root.join("data", "hadrians_wall.csv"), headers:true) do |row|
    POINTS << [row["longitude"].to_f, row["latitude"].to_f]
  end

  BALLOON_POINTS = []
  CSV.foreach(Rails.root.join("data", "balloon_wall.csv"), headers:true) do |row|
    BALLOON_POINTS << [row["longitude"].to_f, row["latitude"].to_f]
  end

  distance = 0.0
  last_wall_point = BALLOON_POINTS.first
  LENGTHS = Hash[BALLOON_POINTS.map do |wall_point|
    distance += euclidean_distance(last_wall_point, wall_point)
    last_wall_point = wall_point
    [wall_point, distance]
  end]

  LENGTH = distance

  BALLOONS = []
  BALLOON_MAPPING = {}

  CSV.foreach(Rails.root.join("data", "balloons.csv"), headers:true) do |row|
    point = [row["longitude"].to_f, row["latitude"].to_f]
    BALLOONS << point
    BALLOON_MAPPING[row["id"]] = self.percent_along_the_wall(point)
  end
end
