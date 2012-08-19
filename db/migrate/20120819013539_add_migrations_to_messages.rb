class AddMigrationsToMessages < ActiveRecord::Migration
  def change
    add_index :messages, :ip_address
    add_index :messages, :created_at
    add_index :messages, :location_on_wall
  end
end
