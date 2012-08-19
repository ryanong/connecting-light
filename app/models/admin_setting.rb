class AdminSetting < ActiveRecord::Base
  attr_accessible :max, :min, :name, :value
end
