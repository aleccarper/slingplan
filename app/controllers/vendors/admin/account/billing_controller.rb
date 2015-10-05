class Vendors::Admin::Account::BillingController < Vendors::Admin::AccountController
  include StripeToolbox
  before_action :set_stripe
  before_action :set_stripe_values

  def index
    @plans = restructure_plans_for_view(:vendor, @stripe_toolbox.get_all_plans)

    @selected_plan = vendor_subscription
    @plan_name = @selected_plan

    response = @stripe_toolbox.get_subscription_cancelation(@customer)
    @can_revert_cancelation = (vendor_customer_subscribed? && response[:set_to_cancel])

    response = @stripe_toolbox.get_customer_card(@customer)
    if response[:success] && response[:card]
      card = response[:card]

      @credit_card_value = ['****', '****', '****', card['last4']]
      @cc_brand = card['brand']
      @cc_last_4 = card['last4']
      @cc_exp_month = card['exp_month']

      if @cc_exp_month < 10
        @cc_exp_month = '0'+@cc_exp_month.to_s
      end

      @cc_exp_year = card['exp_year']
    end

    response = @stripe_toolbox.get_upcoming_invoice(@customer)
    if response[:success] && response[:invoice]
      @upcoming_invoice = response[:invoice]
    end

    response = @stripe_toolbox.get_subscriptions(@customer)
    if response[:success]
       @plan =response[:subscriptions][:data][0]
    end

    @model = current_vendor

    set_meta_tags :title => 'Billing'

    render :index
  end

  def update_billing
    token = params[:stripeToken]
    response = @stripe_toolbox.update_card(@customer, token)

    if response[:success]
      flash! :card_updated_successfully
    end

    render json: response
  end

  def change_plan
    if current_vendor.billing_status == 'cancellation_pending'
      @stripe_toolbox.cancel_subscription_cancelation(@customer)
    end
    
    plan = 'v'+params[:plan]
    response = @stripe_toolbox.change_plan(@customer, plan)

    if(response[:success])
      current_vendor.subscribed = true
      current_vendor.billing_status = 'active'
      current_vendor.subscription_id = plan
      current_vendor.save
      flash! :update_plan_success
    else
      flash! :card_declined
    end

    response = @stripe_toolbox.get_all_plans
    @plans = response[:plans]

    redirect_to vendors_admin_account_billing_index_path
  end

  def cancel_subscription
    debug = false

    if debug
      response = @stripe_toolbox.delete_subscription(@customer)
    else
      response = @stripe_toolbox.cancel_subscription(@customer)
    end

    if response[:success]
      plan = vendor_subscription
      SlackModule::API::notify_vendor_subscription_cancelled(current_vendor, vendor_url(current_vendor.id), plan, total_vendors_subscribed)

      if(!debug)
        Notifier::Manager.notify(current_vendor, 'Pending Cancelation', 'Your subscription been set to cancel at the end of the current billing period. :(', '/vendors/admin/account/billing', 2)
        current_vendor.billing_status = 'cancellation_pending'
        current_vendor.cancelation_date = response[:cancelation_date]
        current_vendor.save

        flash! :subscription_set_to_cancel
      end
    end

    

    redirect_to vendors_admin_account_billing_index_path
  end

  def reactivate_subscription
    response = @stripe_toolbox.cancel_subscription_cancelation(@customer)

    current_vendor.billing_status = 'active'
    current_vendor.save

    Notifier::Manager.notify(current_vendor, 'Pending Cancelation Reverted', 'Your subscription will continue.', '/vendors/admin/account/billing', 1)

    flash! :subscription_cancelation_reverted

    redirect_to vendors_admin_account_billing_index_path
  end

  def cancel_trial
    Notifier::Manager.notify(current_vendor, 'Subscription Canceled', 'Your subscription has been canceled. :(', '/vendors/admin/account/billing', 3)
    current_vendor.subscribed = false
    current_vendor.subscription_id = nil
    current_vendor.billing_status = 'inactive'
    current_vendor.save

    current_vendor.archive_locations

    redirect_to vendors_admin_account_billing_index_path
  end

  def create_subscription
    set_stripe
    response = {success: true}
    plan = 'v'+params[:plan]

    @customer = vendor_customer

    if response[:success]
      response = @stripe_toolbox.create_subscription(@customer, plan)
    end

    if response[:success]
      current_vendor.subscribed = true
      current_vendor.subscription_id = plan
      current_vendor.billing_status = 'active'
      current_vendor.save

      current_vendor.unarchive_locations

      SlackModule::API::notify_vendor_subscription_created(current_vendor, vendor_url(current_vendor.id), plan, total_vendors_subscribed)

      flash! :subscription_activated

      Notifier::Manager.notify(current_vendor, 'Annnd We\'re back!', 'Your subscription has been created! Be sure to make sure your locations are up to date.', '/vendors/admin/locations', 1)

      flash.discard(:alert)
    else
      flash! :card_declined
    end

    redirect_to vendors_admin_account_billing_index_path
  end

  def activate_coupon
    response = @stripe_toolbox.consume_coupon(@customer, params[:coupon_code]);

    if response[:success]
      flash[:notice] = 'Coupon redeemed!'
    else
      flash[:alert] = response[:message]
    end

    redirect_to vendors_admin_account_billing_index_path
  end
end
