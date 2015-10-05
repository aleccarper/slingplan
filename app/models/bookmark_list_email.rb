class BookmarkListEmail
  # tableless model:
  # http://stackoverflow.com/questions/14389105/rails-model-without-a-table

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :email

  validates :email,
    presence: true,
    format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }

  def initialize(attributes = {})
    attributes.each { |n, v| send("#{n}=", v) }
  end

  def persisted?
    false
  end
end
