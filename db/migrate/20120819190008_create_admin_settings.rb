class CreateAdminSettings < ActiveRecord::Migration
  def change
    create_table :admin_settings do |t|
      t.string :name
      t.float :min
      t.float :max
      t.string :value

      t.timestamps
    end
  end
end
