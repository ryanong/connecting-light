class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :status
      t.string :message
      t.float :latitude
      t.float :longitude
      t.integer :red
      t.integer :green
      t.integer :blue
      t.integer :ip_address, limit: 8

      t.timestamps
    end
  end
end
