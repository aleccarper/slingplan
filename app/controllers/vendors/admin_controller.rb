class Vendors::AdminController < ApplicationController
  include Vendors::AdminHelper

  layout 'vendor_admin'

  before_action :sign_up_redirect

  def index
  end



  private

  def sign_up_redirect
    if current_vendor.sign_up_step == 'card_plan'
      redirect_to vendors_admin_sign_up_plan_path
    end
  end

  def set_stripe_values
    @customer = vendor_customer
    #@upcoming_invoice = Stripe::Invoice.upcoming(:customer => @customer.id);
    @locations = current_vendor.locations
    @active_location_count = (@locations.where status: 'active').length
    @charges = Stripe::Charge.all( :customer => current_vendor.stripe_id )
  end
end
