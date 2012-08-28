class VizController < ApplicationController
  def map
    @hadrians_wall = HadriansWall::POINTS
  end
end
