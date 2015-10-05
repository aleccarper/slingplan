class Coupon
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming

  attr_accessor :id
  attr_accessor :amount_off
  attr_accessor :max_redemptions
  attr_accessor :duration
  attr_accessor :currency

  validates :id,
    presence: true

  validates :amount_off,
    presence: true

  validates :max_redemptions,
    presence: true

  validates :duration,
    presence: true

  validates :currency,
    presence: true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end

end
