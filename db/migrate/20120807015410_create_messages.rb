class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :status
      t.string :message
      t.float :latitude
      t.flost :longitude
      t.integer :ip_address, limit: 8

      t.timestamps
    end
  end
end
