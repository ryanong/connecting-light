class AddJobIdToMessages < ActiveRecord::Migration
  def up
    add_column :messages, :job_id, :integer
    execute("UPDATE messages SET job_id = 0")
  end

  def down
    remove_column :messages, :job_id
  end
end
