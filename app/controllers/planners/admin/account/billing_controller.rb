class Planners::Admin::Account::BillingController < Planners::Admin::AccountController
  include StripeToolbox
  before_action :set_stripe
  before_action :set_stripe_values

  def index
    @plans = restructure_plans_for_view(:planner, @stripe_toolbox.get_all_plans)
    @selected_plan = planner_subscription

    response = @stripe_toolbox.get_customer_card(@customer)
    if response[:success] && response[:card]
      card = response[:card]

      response = @stripe_toolbox.get_subscription_cancelation(@customer)
      @can_revert_cancelation = (planner_customer_subscribed? && response[:set_to_cancel])

      @credit_card_value = ['****', '****', '****', card['last4']]
      @cc_brand = card['brand']
      @cc_last_4 = card['last4']
      @cc_exp_month = card['exp_month']

      if @cc_exp_month < 10
        @cc_exp_month = '0'+@cc_exp_month.to_s
      end
      
      @cc_exp_year = card['exp_year']
    else
      @credit_card_value = ['','','','']
    end

    response = @stripe_toolbox.get_upcoming_invoice(@customer)
    if response[:success] && response[:invoice]
      @upcoming_invoice = response[:invoice]
    end

    response = @stripe_toolbox.get_subscriptions(@customer)
    if response[:success]
       @plan =response[:subscriptions][:data][0]
    end

    @model = current_planner

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
    if @planner.billing_status == 'cancellation_pending'
      @stripe_toolbox.cancel_subscription_cancelation(@customer)
    end

    plan = 'p'+params[:plan]
    response = @stripe_toolbox.change_plan(@customer, plan)

    if response[:success]
      current_planner.subscribed = true
      current_planner.billing_status = 'active'
      current_planner.subscription_id = plan
      current_planner.save
      flash! :update_plan_success
    else
      flash! :card_declined
    end
    
    response = @stripe_toolbox.get_all_plans
    @plans = response[:plans]

    redirect_to planners_admin_account_billing_index_path
  end

  def cancel_subscription
    response = @stripe_toolbox.get_all_plans
    @plans = response[:plans]

    debug = false

    if debug
      response = @stripe_toolbox.delete_subscription(@customer)
    else
      response = @stripe_toolbox.cancel_subscription(@customer)
    end

    if response[:success]
      plan = planner_subscription

      SlackModule::API::notify_planner_subscription_cancelled(@planner, plan, total_planners_subscribed)

      if !debug
        Notifier::Manager.notify(@planner, 'Pending Cancelation', 'Your subscription been set to cancel at the end of the current billing period. :(', '/planners/admin/account/billing', 2)
        @planner.billing_status = 'cancellation_pending'
        @planner.cancelation_date = response[:cancelation_date]
        @planner.save

        flash! :subscription_set_to_cancel
      end
    end

    redirect_to planners_admin_account_billing_index_path
  end

  def reactivate_subscription
    response = @stripe_toolbox.cancel_subscription_cancelation(@customer)

    @planner.billing_status = 'active'
    @planner.save

    Notifier::Manager.notify(@planner, 'Pending Cancelation Reverted', 'Your subscription will continue.', '/planners/admin/account/billing', 1)

    flash! :subscription_cancelation_reverted

    redirect_to planners_admin_account_billing_index_path
  end

  def create_subscription
    set_stripe
    response = {success: true}
    plan = 'p'+params[:plan]

    @customer = planner_customer
    @planner = current_planner


    response = @stripe_toolbox.create_subscription(@customer, plan)

    if response[:success]
      @planner.subscribed = true
      @planner.subscription_id = plan
      @planner.billing_status = 'active'
      @planner.save

      SlackModule::API::notify_planner_subscription_created(@planner, plan, total_planners_subscribed)

      flash! :subscription_activated

      Notifier::Manager.notify(@planner, 'Annnd We\'re back!', 'Your subscription has been created! Be sure to make sure your locations are up to date.', '/planners/admin/locations', 1)
    else
      flash! :card_declined
    end

    flash.discard(:alert)

    redirect_to planners_admin_account_billing_index_path
  end

  def activate_coupon
    response = @stripe_toolbox.consume_coupon(@customer, params[:coupon_code]);

    if response[:success]
      flash[:notice] = 'Coupon redeemed!'
    else
      flash[:alert] = response[:message]
    end

    redirect_to planners_admin_account_billing_index_path
  end
end
