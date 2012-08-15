class RemoveStatusFromMessages < ActiveRecord::Migration
  def up
    remove_column :messages, :status
  end

  def down
    add_column :messages, :status, :string
  end
end
