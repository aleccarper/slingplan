class Staffers::AdminController < ApplicationController
  layout 'staffer_admin'

  before_action :sign_up_redirect

  def index
  end



  private

  def sign_up_redirect
    if current_staffer.sign_up_step == 'card_plan'
      redirect_to staffers_admin_sign_up_plan_path
    end
  end

  def set_stripe_values
    @customer = staffer_customer
    #@upcoming_invoice = Stripe::Invoice.upcoming(:customer => @customer.id);
    @charges = Stripe::Charge.all( :customer => current_staffer.stripe_id )
  end
end
