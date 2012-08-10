class AddPointsToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :closest_point, :string
    add_column :messages, :distance, :float
  end
end
