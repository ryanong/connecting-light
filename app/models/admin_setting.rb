class AdminSetting < ActiveRecord::Base
  attr_accessible :max, :min, :name, :value

  validate :value_within_range_if_minmax_is_set

  after_save :reset_settings_cache

  def pair
    [name, value]
  end

  def reset_settings_cache
    Rails.cache.write("admin-settings", self.class.get)
  end

  def numeric?
    !!(min || max)
  end

  def value
    if numeric?
      super.to_f
    else
      super
    end
  end

  def step
    (max - min) / 100
  end

  def value_within_range_if_minmax_is_set
    if min && value < min
      errors.add(:value, "can't be smaller than #{min}")
    elsif max && value > max
      errors.add(:value, "can't be larger than #{max}")
    end
  end

  def self.get
    Hash[self.all.map(&:pair)]
  end

  def self.fetch
    Rails.cache.
      fetch("admin-settings") { self.get }.
      merge(time: Time.now.to_i)
  end
end
