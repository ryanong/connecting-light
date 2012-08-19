class AdminSetting < ActiveRecord::Base
  attr_accessible :max, :min, :name, :value

  after_save :reset_settings_cache

  def pair
    [name, value]
  end

  def reset_settings_cache
    Rails.cache.write("admin-settings", self.class.get)
  end

  def value
    if min || max
      super.to_f
    else
      super
    end
  end

  def self.get
    Hash[self.all.map(&:pair)]
  end

  def self.fetch
    Rails.cache.fetch("admin-settings") do
      self.get
    end
  end
end
