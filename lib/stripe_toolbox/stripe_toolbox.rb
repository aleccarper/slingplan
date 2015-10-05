module StripeToolbox
  class Wrapper
    def execute(object, function_name, params)
      results = object.send function_name, params
      response = results
      response
    end
  end

  class Toolbox
    def init_stripe
      Stripe.api_key = Rails.application.secrets['stripe']['secret']
    end

    def pay_invoice(customer)
      init_stripe
      response = {}

      begin
       invoice = Stripe::Invoice.create(customer: customer.id,
          description: 'Plan change - Prorated')

        invoice.forgiven = true
        invoice.closed = true
        invoice.save

        response[:success] = true
      rescue Exception => e
        response[:success] = false;
        response[:message] = e.message
      end

      return response
    end

    def get_upcoming_invoice(customer)
      init_stripe
      response = {success: true}
      begin
        invoice = Stripe::Invoice.upcoming(customer: customer.id)
        response[:invoice] = invoice
      rescue Exception => e
        response = {success: false, message: e.message};
      end
      return response
    end

    def create_card(customer, token)
      init_stripe

      purge_response = purge_cards(customer)
      return purge_response if !purge_response[:success]

      response = {success: true}
      begin
        customer.sources.create({source: token})
      rescue Exception => e
        response = {success: false, message: e.message};
      end
      return response
    end

    def purge_cards(customer)
      init_stripe
      response = {success: true}
      begin
        cards = customer.sources.all(limit: 99, object: 'card')
        cards.each do |card|
          card.delete
        end
      rescue Exception => e
        response = {success: false, message: e.message};
      end
      return response
    end

    def create_subscription(customer, plan)
      init_stripe
      response = {success: true}
      begin
        if customer.subscriptions['total_count'] > 0
          response = {success: false, message: 'Subscription already exists'}
        else
          customer.subscriptions.create(plan: plan)
        end
      rescue Exception => e
        response = {success: false, message: e.message};
      end
      return response
    end

    def get_subscriptions(customer)
      init_stripe
      response = {success: true}
      begin
        response[:subscriptions] = customer.subscriptions.all
      rescue Exception => e
        response = {success: false, message: e.message};
      end
      return response
    end

    def change_plan(customer, new_plan)
      init_stripe
      response = {success: true}
      begin
        if customer.subscriptions['total_count'] == 0
          response = create_subscription(customer, new_plan)
        else
          subscriptions = customer.subscriptions.all
          subscription = subscriptions[:data][0]
          subscription.plan = new_plan
          subscription.prorate = false
          subscription.save
          pi_response = pay_invoice(customer)
        end

        customer = Stripe::Customer.retrieve(customer.id)
        if customer.account_balance < 0
          customer.account_balance = 0
        end
        customer.save
        
      rescue Exception => e
        response = {success: false, message: e.message};
      end
      return response
    end

    def update_card(customer, token)
      init_stripe
      response = {success: true}
      begin
        response = create_card(customer, token)
      rescue Exception => e
        response = {success: false, message: e.message};
      end
      return response
    end

    def consume_coupon(customer, coupon)
      init_stripe
      response = {}
      customer.coupon = coupon

      begin
        customer.save
        response = {success: true, message: 'Coupon activated'}
      rescue Exception => e
        response = {success: false, message: e.message }
      end

      response
    end

    def get_customer_card(customer) 
      init_stripe
      response = {success: true}
      begin
        cards = customer.sources.all(limit: 1, object: 'card')

        if cards['data'] || cards['data'].count > 0
          response[:card] = cards['data'][0]
        end
      rescue Exception => e
        response = {success: false, message: e.message};
      end
      return response
    end

    def get_current_subscription(customer)
      init_stripe
      response = {success: true}
      begin
        subscriptions = customer.subscriptions.all
        subscription = subscriptions[:data][0]
        response[:subscription] = subscription
      rescue Exception => e
        response = {success: false, message: e.message};
      end
      return response
    end

    def get_customer_from_vendor(vendor)
      init_stripe
      return Stripe::Customer.retrieve(vendor.stripe_id)
    end

    def cancel_subscription(customer)
      init_stripe
      response = {success: true}
      begin
        subscriptions = customer.subscriptions.all
        subscription = subscriptions[:data][0]
        subscription.delete(at_period_end: true)
        response[:cancelation_date] = subscription[:current_period_end]
      rescue Exception => e
        response = {success: false, message: e.message};
      end
      return response
    end

    def delete_subscription(customer)
      init_stripe
      response = {success: true}
      begin
        subscriptions = customer.subscriptions.all
        subscription = subscriptions[:data][0]
        subscription.delete(at_period_end: false)
      rescue Exception => e
        response = {success: false, message: e.message};
      end
      return response
    end

    def cancel_subscription_cancelation(customer)
      init_stripe
      response = {success: true}
      begin
        subscriptions = customer.subscriptions.all
        subscription = subscriptions[:data][0]
        subscription.plan = subscription[:plan]
        subscription.save
      rescue Exception => e
        response = {success: false, message: e.message};
      end
      return response
    end

    def get_subscription_cancelation(customer)
      init_stripe
      response = {success: true}
      begin
        subscriptions = customer.subscriptions.all
        subscription = subscriptions[:data][0]
        response[:set_to_cancel] = subscription[:cancel_at_period_end]
      rescue Exception => e
        response = {success: false, message: e.message};
      end
      return response
    end

    def get_all_plans
      init_stripe
      response = {}
      begin
        response[:plans] = Stripe::Plan.all(count: 100)
        response[:success] = true
      rescue Exception => e
        response[:message] = e.message
        response[:success] = false
      end
      return response
    end

  end
end

