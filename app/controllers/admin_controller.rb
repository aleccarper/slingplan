class AdminController < ApplicationController
  layout 'admin'

  include StripeToolbox

  before_action :set_stripe
  before_action :set_coupon

  def index
  end



  private

  def set_stripe
    stripe_wrapper = StripeToolbox::Wrapper.new
    stripe_toolbox = StripeToolbox::Toolbox.new
    stripe_toolbox.init_stripe
  end

  def set_coupon
    @coupons = Stripe::Coupon.all['data']
  end
end
