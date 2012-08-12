class Message < ActiveRecord::Base
end

class AddAnimationDataToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :animation_data, :text
    Message.reset_column_information
    Message.update_all(animation_data: "MjM0OTAgdWRoO2NudiA5MDIzdTQgOTAzIGg0MjNsayA=")
  end
end
