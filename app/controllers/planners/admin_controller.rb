class Planners::AdminController < ApplicationController
  include Planners::AdminHelper

  layout 'planner_admin'


  def index
  end

  private

  def set_stripe_values
    @customer = planner_customer
    @charges = Stripe::Charge.all(:customer => current_planner.stripe_id)
  end
end

