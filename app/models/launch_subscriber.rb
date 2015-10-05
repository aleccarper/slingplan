class LaunchSubscriber < ActiveRecord::Base
  include SlackModule

  validates :email,
    presence: true,
    format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }

  after_commit :after_commit



  private

  def after_commit
    SlackModule::API::notify_launch_subscriber_created(self.email, LaunchSubscriber.count)
  end
end
