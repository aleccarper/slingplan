class Staffers::Admin::Account::BillingController < Staffers::Admin::AccountController
  include StripeToolbox
  before_action :set_stripe
  before_action :set_stripe_values

  def index
    @plans = restructure_plans_for_view(:staffer, @stripe_toolbox.get_all_plans)

    @selected_plan = staffer_subscription
    @plan_name = @selected_plan

    response = @stripe_toolbox.get_subscription_cancelation(@customer)
    @can_revert_cancelation = (staffer_customer_subscribed? && response[:set_to_cancel])

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

    @model = current_staffer

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
    if current_staffer.billing_status == 'cancellation_pending'
      @stripe_toolbox.cancel_subscription_cancelation(@customer)
    end

    plan = 's'+params[:plan]
    response = @stripe_toolbox.change_plan(@customer, plan)

    if(response[:success])
      current_staffer.subscribed = true
      current_staffer.billing_status = 'active'
      current_staffer.subscription_id = plan
      current_staffer.save
      flash! :update_plan_success
    else
      flash! :card_declined
    end

    response = @stripe_toolbox.get_all_plans
    @plans = response[:plans]

    redirect_to staffers_admin_account_billing_index_path
  end

  def cancel_subscription
    debug = false

    if debug
      response = @stripe_toolbox.delete_subscription(@customer)
    else
      response = @stripe_toolbox.cancel_subscription(@customer)
    end

    if response[:success]
      plan = staffer_subscription
      SlackModule::API::notify_staffer_subscription_cancelled(current_staffer, plan, total_staffers_subscribed)

      if(!debug)
        Notifier::Manager.notify(current_staffer, 'Pending Cancelation', 'Your subscription been set to cancel at the end of the current billing period.', '/staffers/admin/account/billing', 2)
        current_staffer.billing_status = 'cancellation_pending'
        current_staffer.cancelation_date = response[:cancelation_date]
        current_staffer.save

        flash! :subscription_set_to_cancel
      end
    end

    redirect_to staffers_admin_account_billing_index_path
  end

  def reactivate_subscription
    response = @stripe_toolbox.cancel_subscription_cancelation(@customer)

    current_staffer.billing_status = 'active'
    current_staffer.save

    Notifier::Manager.notify(current_staffer, 'Pending Cancelation Reverted', 'Your subscription will continue.', '/staffers/admin/account/billing', 1)

    flash! :subscription_cancelation_reverted

    redirect_to staffers_admin_account_billing_index_path
  end

  def cancel_trial
    Notifier::Manager.notify(current_staffer, 'Subscription Canceled', 'Your subscription has been canceled.', '/staffers/admin/account/billing', 3)
    current_staffer.subscribed = false
    current_staffer.subscription_id = nil
    current_staffer.billing_status = 'inactive'
    current_staffer.save

    redirect_to staffers_admin_account_billing_index_path
  end

  def create_subscription
    set_stripe
    response = {success: true}
    plan = 's'+params[:plan]

    @customer = staffer_customer

    if response[:success]
      response = @stripe_toolbox.create_subscription(@customer, plan)
    end

    if response[:success]
      current_staffer.subscribed = true
      current_staffer.subscription_id = plan
      current_staffer.billing_status = 'active'
      current_staffer.save

      SlackModule::API::notify_staffer_subscription_created(current_staffer, plan, total_staffers_subscribed)

      flash! :subscription_activated

      Notifier::Manager.notify(current_staffer, 'Annnd We\'re back!', 'Your subscription has been created! Be sure to make sure your profile is up to date.', '/staffers/admin/locations', 1)

      flash.discard(:alert)
    else
      flash! :card_declined
    end

    redirect_to staffers_admin_account_billing_index_path
  end

  def activate_coupon
    response = @stripe_toolbox.consume_coupon(@customer, params[:coupon_code]);

    if response[:success]
      flash[:notice] = 'Coupon redeemed!'
    else
      flash[:alert] = response[:message]
    end

    redirect_to staffers_admin_account_billing_index_path
  end
end
