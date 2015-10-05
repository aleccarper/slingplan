class Vendors::Admin::RegistrationsController < Devise::RegistrationsController
  protected :after_sign_up_path_for

  @@vendor_params = [
    :email,
    :password,
    :password_confirmation,
    :name,
    :description,
    :country_code,
    :current_password,
    :primary_phone_number,
    :primary_email,
    :primary_website,
    :time_zone,
    :logo_image,
    :accepted_terms_of_service
  ]

  def new
    set_meta_tags :title => 'Vendor Registration',
                  :keywords => "slingplan, register, account, vendor, meeting planners, free, map, plan, event, services",
                  :description => "Advertise your services and get in direct contact with meeting planners by signing up with a Vendor account."
    super
  end

  def after_sign_up_path_for(resource)
    SlackModule::API::notify_vendor_created(resource, vendor_url(resource.id), Vendor.count)
    vendors_admin_sign_up_plan_path
  end

  def plan
    set_stripe
    @plans = restructure_plans_for_view(:vendor, @stripe_toolbox.get_all_plans)
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
    plan = "v#{params[:plan]}"

    set_stripe

    @customer = vendor_customer
    @vendor = current_vendor

    #if coupon != ''
    #  response = @stripe_toolbox.consume_coupon(@customer, coupon)
    #end

    if response[:success]
      response = @stripe_toolbox.create_card(@customer, token)
    end

    if response[:success]
      @vendor.subscribed = true
      @vendor.subscription_id = plan
      @vendor.billing_status = 'trial'
      @vendor.sign_up_step = 'completed'
      @vendor.save

      Notifier::Manager.notify(current_vendor, 'Welcome!', 'Get started by adding your locations. You\'re on your way to doing more business!', '/vendors/admin/locations', 1)
      SlackModule::API::notify_vendor_subscription_created(@vendor, vendor_url(@vendor.id), plan, Vendor.where('billing_status=? OR billing_status=?', 'active', 'trial').count)

      flash[:notice] = 'Successfully subscribed.'

      flash.discard(:alert)
    end

    render json: response
  end



  private

  def sign_up_params
    params.require(:vendor).permit(@@vendor_params)
  end

  def account_update_params
    params.require(:vendor).permit(@@vendor_params)
  end
end
