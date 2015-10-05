Stripe.api_key = Rails.application.secrets['stripe']['secret']

StripeEvent.configure do |events|
  #event.class       #=> Stripe::Event
  #event.type        #=> "charge.failed"
  #event.data.object #=> #<Stripe::Charge:0x3fcb34c115f8>


  #events.subscribe 'invoice.payment_failed' do |event|
  #  vendor = Vendor.find_by_stripe_id(event.data.object.customer)
  #  if vendor
  #    vendor.billing_status = 'inactive'
  #    vendor.save
  #    VendorMailer.vendor_payment_failed_email(vendor, event.data.object).deliver
  #  end
  #end

  events.subscribe 'charge.succeeded' do |event|
    model = Vendor.find_by_stripe_id(event.data.object.customer) || 
            Planner.find_by_stripe_id(event.data.object.customer) || 
            Staffer.find_by_stripe_id(event.data.object.customer)
    
    if model
      model.billing_status = 'active'
      model.save

      case model.class.name.downcase.to_sym
        when :vendor
          VendorMailer.vendor_payment_email(model, event.data.object).deliver
        when :planner
          PlannerMailer.planner_payment_email(model, event.data.object).deliver
        when :staffer
          StafferMailer.staffer_payment_email(model, event.data.object).deliver
      end
    end
  end

  events.subscribe 'customer.subscription.delete' do |event|
    model = Vendor.find_by_stripe_id(event.data.object.customer) || 
            Planner.find_by_stripe_id(event.data.object.customer) || 
            Staffer.find_by_stripe_id(event.data.object.customer)

    if model
      url = ''

      case model.class.name.downcase.to_sym
        when :vendor
          url = '/vendors/admin/account/billing'
        when :planner
          url = '/planners/admin/account/billing'
        when :staffer
          url = '/staffers/admin/account/billing'
      end


      model.subscription_ended


      if url != ''
        Notifier::Manager.notify(model, 'Subscription Canceled', 'Your subscription has been canceled.', url, 3)
      end
    end
  end

  events.all do |event|
    #add logging here
  end
end
