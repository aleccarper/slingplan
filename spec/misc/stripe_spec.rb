require 'rails_helper'
require 'stripe_mock'

describe 'slingplan stripe' do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before { StripeMock.start }
  after { StripeMock.stop }

  describe 'stripe_toolbox' do
    let(:toolbox) { include StripeToolbox; StripeToolbox::Toolbox.new }
    
    describe 'init_stripe' do
      it 'sets the api key' do
        Rails.application.secrets['stripe']['secret'] = 'test'
        toolbox.init_stripe
        expect(Stripe.api_key).to eq('test')
      end
    end


    describe 'pay_invoice' do
      before {
        @customer = Stripe::Customer.create({
          email: 'johnny@appleseed.com',
          source: stripe_helper.generate_card_token
        })

        test_plan = stripe_helper.create_plan(:id => 'test_plan', :amount => 1500)
        @customer.subscriptions.create(:plan => 'test_plan')
      }

      context 'used a valid customer' do
        it 'should return success is true' do
          response = toolbox.pay_invoice(@customer)
          expect(response[:success]).to eq(true)
        end
      end

      context 'using an invalid customer' do
        it 'should return an error message' do
          response = toolbox.pay_invoice(nil)
          expect(response[:message]).not_to eq(nil)
        end

        it 'should return success is false' do
          response = toolbox.pay_invoice(nil)
          expect(response[:success]).to_not eq(true)
        end
      end
    end


    describe 'get_upcoming_invoice' do
      before {
        @customer = Stripe::Customer.create({
          email: 'johnny@appleseed.com',
          source: stripe_helper.generate_card_token
        })

        test_plan = stripe_helper.create_plan(:id => 'test_plan', :amount => 1500)
        @customer.subscriptions.create(:plan => 'test_plan')
      }

      context 'used a valid customer for test' do
        it 'should return the upcoming invoice' do
          response = toolbox.get_upcoming_invoice(@customer)
          expect(response[:invoice]).not_to eq(nil)
        end

        it 'should return success is true' do
          response = toolbox.get_upcoming_invoice(@customer)
          expect(response[:success]).to eq(true)
        end
      end

      context 'using an invalid customer test' do
        it 'should return an error message' do
          response = toolbox.get_upcoming_invoice(nil)
          expect(response[:message]).not_to eq(nil)
        end

        it 'should return success is false' do
          response = toolbox.get_upcoming_invoice(nil)
          expect(response[:success]).to_not eq(true)
        end
      end
    end

    describe 'create_card' do
      before {
        @customer = Stripe::Customer.create({
          email: 'johnny@appleseed.com'
        })

        @token = stripe_helper.generate_card_token
      }

      context 'used a valid customer and token' do
        it 'should return success true' do
          response = toolbox.create_card(@customer, @token)
          expect(response[:success]).to eq(true)
        end
      end

      context 'using an invalid customer or token' do
        it 'should return success false' do
          response = toolbox.create_card(nil, nil)
          expect(response[:success]).to_not eq(true)
        end

        it 'should return an error message' do
          response = toolbox.create_card(nil, nil)
          expect(response[:message]).not_to eq(nil);
        end
      end
    end

    describe 'purge_cards' do
      before {
        @customer = Stripe::Customer.create({
          email: 'johnny@appleseed.com'
        })
      }

      context 'used a valid customer and token' do
        it 'should return success true' do
          response = toolbox.purge_cards(@customer)
          byebug
          expect(response[:success]).to eq(true)
        end
      end

      context 'using an invalid customer or token' do
        it 'should return success false' do
          response = toolbox.purge_cards(nil)
          expect(response[:success]).to_not eq(true)
        end

        it 'should return an error message' do
          response = toolbox.purge_cards(nil)
          expect(response[:message]).not_to eq(nil)
        end
      end
    end

    describe 'create_subscription' do
      before {
        @customer = Stripe::Customer.create({
          email: 'johnny@appleseed.com'
        })

        toolbox.create_card(@customer, stripe_helper.generate_card_token)
        stripe_helper.create_plan(:id => 'test_plan', :amount => 1500)
      }

      context 'used a valid customer and plan' do
        it 'should return success true' do
          response = toolbox.create_subscription(@customer, 'test_plan')
          expect(response[:success]).to eq(true)
        end
      end

      context 'using an invalid customer or plan' do
        it 'should return success false' do
          response = toolbox.create_subscription(nil, 'not_a_plan')
          expect(response[:success]).to_not eq(true)
        end

        it 'should return an error message' do
          response = toolbox.create_subscription(nil, 'not_a_plan')
          expect(response[:message]).not_to eq(nil)
        end
      end
    end

    describe 'get_subscriptions' do
      before {
        @customer = Stripe::Customer.create({
          email: 'johnny@appleseed.com',
          source: stripe_helper.generate_card_token
        })

        test_plan = stripe_helper.create_plan(:id => 'test_plan', :amount => 1500)
        @customer.subscriptions.create(:plan => 'test_plan')
      }

      context 'used a valid customer' do
        it 'should return success true' do
          response = toolbox.get_subscriptions(@customer)
          expect(response[:success]).to eq(true)
        end

        it 'should return subscriptions' do
          response = toolbox.get_subscriptions(@customer)
          expect(response[:subscriptions]).to_not eq(nil)
        end
      end

      context 'using an invalid customer' do
        it 'should return success false' do
          response = toolbox.get_subscriptions(nil)
          expect(response[:success]).to_not eq(true)
        end

        it 'should return an error message' do
          response = toolbox.get_subscriptions(nil)
          expect(response[:message]).not_to eq(nil)
        end
      end
    end

    describe 'change_plan' do
      before {
        @customer = Stripe::Customer.create({
          email: 'johnny@appleseed.com',
          source: stripe_helper.generate_card_token
        })

        test_plan = stripe_helper.create_plan(:id => 'test_plan', :amount => 1500)
        test_plan2 = stripe_helper.create_plan(:id => 'test_plan2', :amount => 1600)
        @customer.subscriptions.create(:plan => 'test_plan')
      }

      context 'used a valid customer' do
        it 'should return success true' do
          response = toolbox.change_plan(@customer, 'test_plan2')
          expect(response[:success]).to eq(true)
        end
      end

      context 'using an invalid customer' do
        it 'should return success false' do
          response = toolbox.change_plan(nil, nil)
          expect(response[:success]).to_not eq(true)
        end

        it 'should return an error message' do
          response = toolbox.change_plan(nil, nil)
          expect(response[:message]).not_to eq(nil)
        end
      end
    end

    describe 'update_card' do
      before {
        @customer = Stripe::Customer.create({
          email: 'johnny@appleseed.com'
        })

        @token = stripe_helper.generate_card_token
      }

      context 'used a valid customer and token' do
        it 'should return success true' do
          response = toolbox.update_card(@customer, @token)
          expect(response[:success]).to eq(true)
        end
      end

      context 'using an invalid customer or token' do
        it 'should return success false' do
          response = toolbox.update_card(nil, nil)
          expect(response[:success]).to_not eq(true)
        end

        it 'should return an error message' do
          response = toolbox.update_card(nil, nil)
          expect(response[:message]).not_to eq(nil)
        end
      end
    end

    describe 'consume_coupon' do
      before {
        @customer = Stripe::Customer.create({
          email: 'johnny@appleseed.com'
        })

        Stripe::Coupon.create(
          :percent_off => 25,
          :duration => 'repeating',
          :duration_in_months => 3,
          :id => 'test_coupon'
        )
      }

      context 'used a valid customer and token' do
        it 'should return success true' do
          response = toolbox.consume_coupon(@customer, 'test_coupon')
          expect(response[:success]).to eq(true)
        end

        it 'should return a success message' do
          response = toolbox.consume_coupon(@customer, 'test_coupon')
          expect(response[:message]).not_to eq(nil)
        end
      end
    end

    describe 'get_current_subscription' do
      before {
        @customer = Stripe::Customer.create({
          email: 'johnny@appleseed.com',
          source: stripe_helper.generate_card_token
        })

        test_plan = stripe_helper.create_plan(:id => 'test_plan', :amount => 1500)
        @customer.subscriptions.create(:plan => 'test_plan')

        @customer_no_subscription = Stripe::Customer.create({
          email: 'johnny@appleseed.com',
          source: stripe_helper.generate_card_token
        })
      }

      context 'used a valid customer' do
        it 'should return success true' do
          response = toolbox.get_current_subscription(@customer)
          expect(response[:success]).to eq(true)
        end

        it 'should return a subscription' do
          response = toolbox.get_current_subscription(@customer)
          expect(response[:subscription]).to_not eq(nil)
        end
      end

      context 'using a customer without a subscription' do
        it 'should not return a subscription' do
          response = toolbox.get_current_subscription(@customer_no_subscription)
          expect(response[:subscription]).to eq(nil)
        end
      end
    end

    describe 'cancel_subscription' do
      before {
        @customer = Stripe::Customer.create({
          email: 'johnny@appleseed.com',
          source: stripe_helper.generate_card_token
        })

        test_plan = stripe_helper.create_plan(:id => 'test_plan', :amount => 1500)
        @customer.subscriptions.create(:plan => 'test_plan')
      }

      context 'used a valid customer and token' do
        it 'should return success true' do
          response = toolbox.cancel_subscription(@customer)
          expect(response[:success]).to eq(true)
        end

        it 'should return a cancelation date' do
          response = toolbox.cancel_subscription(@customer)
          expect(response[:cancelation_date]).to_not eq(nil)
        end
      end

      context 'using an invalid customer' do
        it 'should return success false' do
          response = toolbox.cancel_subscription(nil)
          expect(response[:success]).to_not eq(true)
        end

        it 'should return an error message' do
          response = toolbox.cancel_subscription(nil)
          expect(response[:message]).not_to eq(nil)
        end
      end
    end

    describe 'delete_subscription' do
      before {
        @customer = Stripe::Customer.create({
          email: 'johnny@appleseed.com',
          source: stripe_helper.generate_card_token
        })

        test_plan = stripe_helper.create_plan(:id => 'test_plan', :amount => 1500)
        @customer.subscriptions.create(:plan => 'test_plan')
      }

      context 'used a valid customer and token' do
        it 'should return success true' do
          response = toolbox.delete_subscription(@customer)
          expect(response[:success]).to eq(true)
        end
      end

      context 'using an invalid customer' do
        it 'should return success false' do
          response = toolbox.delete_subscription(nil)
          expect(response[:success]).to_not eq(true)
        end

        it 'should return an error message' do
          response = toolbox.delete_subscription(nil)
          expect(response[:message]).not_to eq(nil)
        end
      end
    end

    describe 'cancel_subscription_cancelation' do
      before {
        @customer = Stripe::Customer.create({
          email: 'johnny@appleseed.com',
          source: stripe_helper.generate_card_token
        })

        test_plan = stripe_helper.create_plan(:id => 'test_plan', :amount => 1500)
        @customer.subscriptions.create(:plan => 'test_plan')

        toolbox.cancel_subscription(@customer)
      }

      context 'used a valid customer' do
        it 'should return success true' do
          toolbox.cancel_subscription(@customer)
          response = toolbox.cancel_subscription_cancelation(@customer)
          expect(response[:success]).to eq(true)
        end
      end

      context 'using an invalid customer' do
        it 'should return success false' do
          toolbox.cancel_subscription(@customer)
          response = toolbox.cancel_subscription_cancelation(nil)
          expect(response[:success]).to_not eq(true)
        end

        it 'should return an error message' do
          toolbox.cancel_subscription(@customer)
          response = toolbox.cancel_subscription_cancelation(nil)
          expect(response[:message]).not_to eq(nil)
        end
      end
    end

    describe 'get_subscription_cancelation' do
      before {
        @customer = Stripe::Customer.create({
          email: 'johnny@appleseed.com',
          source: stripe_helper.generate_card_token
        })

        test_plan = stripe_helper.create_plan(:id => 'test_plan', :amount => 1500)
        @customer.subscriptions.create(:plan => 'test_plan')

        toolbox.cancel_subscription(@customer)
      }

      context 'used a valid customer' do
        it 'should return success true' do
          response = toolbox.get_subscription_cancelation(@customer)
          expect(response[:success]).to eq(true)
        end

        it 'should return success true' do
          response = toolbox.get_subscription_cancelation(@customer)
          expect(response[:set_to_cancel]).to eq(true)
        end
      end

      context 'using an invalid customer' do
        it 'should return success false' do
          response = toolbox.get_subscription_cancelation(nil)
          expect(response[:success]).to_not eq(true)
        end

        it 'should return an error message' do
          response = toolbox.get_subscription_cancelation(nil)
          expect(response[:message]).not_to eq(nil)
        end
      end
    end

    describe 'get_all_plans' do
      before {

      }


      it 'should return success true' do
        response = toolbox.get_all_plans()
        expect(response[:success]).to eq(true)
      end

      it 'should return plans' do
        response = toolbox.get_all_plans()
        expect(response[:plans]).to_not eq(nil)
      end

    end
  end
end
