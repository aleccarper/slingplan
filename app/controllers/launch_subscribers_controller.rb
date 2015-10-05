class LaunchSubscribersController < ApplicationController
  def create
    @ls = LaunchSubscriber.new(params_for_launch_subscriber)

    if @ls.save
      set_cookie('launch_subscribed_email', @ls.email)

      LaunchSubscribersMailer.delay_for(15.seconds).new_launch_subscriber_email

      flash[:just_subscribed] = true
    end

    redirect_to '/'
  end

  def params_for_launch_subscriber
    params.require(:launch_subscriber).permit(:email)
  end
end
