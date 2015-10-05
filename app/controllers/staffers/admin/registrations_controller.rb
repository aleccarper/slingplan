class Staffers::Admin::RegistrationsController < Devise::RegistrationsController
  protected :after_sign_up_path_for

  @@staffer_params = [
    :email,
    :password,
    :password_confirmation,
    :name,
    :address1,
    :address2,
    :city,
    :state,
    :zip,
    :description,
    :country_code,
    :current_password,
    :primary_phone_number,
    :primary_email,
    :primary_website,
    :time_zone,
    :logo_image,
    :resume,
    :accepted_terms_of_service
  ]

  def new
    set_meta_tags :title => 'Staffer Registration',
                  :keywords => "slingplan, register, account, staffer, staff, staffing, meeting planners, free, map, plan, event, services",
                  :description => "Advertise your services and get in direct contact with meeting planners by signing up with a Staffer account."
    super
  end

  def after_sign_up_path_for(resource)
    SlackModule::API::notify_staffer_created(resource, Staffer.count)
    staffers_admin_sign_up_plan_path
  end

  def plan
    set_stripe
    @plans = restructure_plans_for_view(:staffer, @stripe_toolbox.get_all_plans)
    @cvc_value = ''
    @month_value = ''
    @year_value = ''

    do_debug_values = false
    if do_debug_values
      @credit_card_value = [
        '4242', '4242', '4242', '4242' # ['4000', '0000', '0000', '0341']
      ]
      @cvc_value = '321'
      @month_value = '12'
      @year_value = '2015'
    end

    set_meta_tags :title => 'Select A Plan'
  end

  def subscribe
    # Get the credit card details submitted by the form
    response = { success: true }
    coupon = params[:coupon_code]
    token = params[:stripeToken]
    plan = "s#{params[:plan]}"

    set_stripe

    @customer = staffer_customer
    @staffer = current_staffer

    if response[:success]
      response = @stripe_toolbox.create_card(@customer, token)
    end

    if response[:success]
      response = @stripe_toolbox.create_subscription(@customer, plan)
    end

    if response[:success]
      @staffer.subscribed = true
      @staffer.subscription_id = plan
      @staffer.billing_status = 'active'
      @staffer.sign_up_step = 'completed'
      @staffer.save

      SlackModule::API::notify_staffer_subscription_created(@staffer, plan, total_staffers_subscribed)

      flash[:notice] = 'Successfully subscribed.'

      StafferMailer.staffer_welcome_email(@staffer).deliver
    end

    render json: response
  end



  private

  def sign_up_params
    params.require(:staffer).permit(@@staffer_params)
  end

  def account_update_params
    params.require(:staffer).permit(@@staffer_params)
  end
end
