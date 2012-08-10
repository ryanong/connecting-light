class AddPointsToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :location_on_wall, :float
  end
end
