class VizController < ApplicationController
  MAP_BOX = {
    east: -1.2657,
    north: 55.2594,
    south: 54.6989,
    west: -3.235
  }

  def map
    @map_box = MAP_BOX
  end
end
