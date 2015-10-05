require 'bcrypt'

class BetaTester < ActiveRecord::Base
  include BCrypt
  include SlackModule

  attr_accessor :password

  after_create :after_create

  validates :email,
    presence: true,
    uniqueness: true,
    format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }

  validates :password_digest,
    presence: true

  def authenticate(candidate)
    password == candidate
  end

  def password
    @password ||= Password.new(password_digest)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_digest = @password
  end



  private

  def after_create
    SlackModule::API::notify_beta_tester_created(self.email, self.password)
  end
end
