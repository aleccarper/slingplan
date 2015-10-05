module Vendors::Admin::Account::BillingHelper

  def plan_info
    plan = vendor_subscription[:plan]
    content_tag :div do
      content_tag(:span, plan[:name] + ' - ', class: 'strong') +
      content_tag(:span, @active_location_count.to_s + ' of ' + current_vendor.get_max_allowed_locations(vendor_subscription).to_s + ' active locations', class: 'billing-plan-locations-used')
    end
  end

  def card_info
    card = @customer[:cards]['data'][0]
    credit_card_value = '**** **** **** ' + card['last4']
    content_tag :div, class: 'card-wrap' do
      content_tag(:span, card[:brand] + ' ', class: 'strong') +
      content_tag(:span, credit_card_value, class: 'strong') +
      content_tag(:span, ' Expeiration: ') +
      content_tag(:span, card['exp_month'].to_s + '/'+card['exp_year'].to_s, class: 'strong')
    end
  end

  def next_payment_date
    content_tag :div, class: 'next-payment-date-wrap' do
      content_tag(:span, 'Next payment due: ') +
      content_tag(:span, prettify_date(@upcoming_invoice[:period_end].to_s), class: 'strong')
    end
  end

  def invoice_subtotal
    content_tag :div, class: 'subtotal' do
      concat content_tag(:span, 'Subtotal: ')
      concat content_tag(:span, '$' + prettify_amount(@upcoming_invoice[:subtotal]), class: 'strong')
    end
  end

  def invoice_starting_balance
    content_tag :div, class: 'starting-balance' do
      concat content_tag(:span, 'Starting Balance: ')
      concat content_tag(:span, '$' + prettify_amount(@upcoming_invoice[:starting_balance]), class: 'strong')
    end
  end

  def invoice_total
    content_tag :div, class: 'total' do
      concat content_tag(:span, 'Amount: ')
      concat content_tag(:span, '$' + prettify_amount(@upcoming_invoice[:amount_due]), class: 'strong')
    end
  end

  def next_payment_amount
    content_tag :div, class: 'next-payment-date-wrap' do
      #concat invoice_subtotal
      #concat invoice_starting_balance
      concat invoice_total
    end
  end

  def coupon_info
    content_tag :div, class: 'next-payment-date-wrap' do
      if @upcoming_invoice[:discount]
        content_tag(:span, 'Amount Off: ') +
        content_tag(:span, '$' + prettify_amount(@upcoming_invoice[:discount][:coupon][:amount_off]), class: 'strong')
      else
         content_tag(:span, "You don't have an active coupon");
      end
    end
  end

  def billing_status_info
    content_tag(:span, "Your account status is: #{@vendor.billing_status}");
  end

  def billing_status_valid?
    return true
  end

  def billing_status_canceled?
    return false
  end

  def build_charge(charge)
    content_tag :div, class: 'charge-item' do
      concat content_tag(:span, "$#{prettify_amount(charge[:amount])}", class: 'amount')
      concat content_tag(:span, "**** **** **** #{charge[:source][:last4]}", class: 'card')
      concat content_tag(:span, "<i class='fa #{charge[:paid] ? 'fa-check' : 'fa fa-times'}'></i>".html_safe, class: "paid #{charge[:paid]}")
      concat content_tag(:span, "#{prettify_date(charge[:created].to_s)}", class: 'date')
      concat content_tag(:span, "#{prettify_date_short(charge[:created].to_s)}", class: 'date-shorthand')
    end
  end

  def tier_checked(which)
    if !@customer.subscriptions.all[:data][0] then return false; end

    return (@customer.subscriptions.all[:data][0][:plan][:id] == which)
  end


  # plans should have .plan-selected if any plan is selected
  def plans_classes
    cls = 'plans'
    if @selected_plan
      cls << ' plan-selected'
    end
    cls
  end

  def this_plan_is_selected?(plan)
    @selected_plan and "#{current_authenticated_role.to_s[0]}#{plan[:id]}" == @selected_plan[0..-2]
  end

  def this_price_is_selected?(plan, m_or_y)
    @selected_plan and "#{current_authenticated_role.to_s[0]}#{plan[:id]}#{m_or_y}" == @selected_plan
  end

  def plan_wrapper_classes(plan)
    cls = 'plan-wrapper'
    if this_plan_is_selected?(plan)
      cls << ' selected complete'
    end
    if plan[:primary]
      cls << ' primary'
    end
    cls
  end

  def plan_classes(plan, i)
    cls = "plan plan-#{i}"
    if this_plan_is_selected?(plan)
      cls << ' selected'
    end
    if plan[:primary]
      cls << ' primary'
    end
    cls
  end

  def price_classes(plan, price, m_or_y)
    cls = 'price'
    if this_price_is_selected?(plan, m_or_y)
      cls << ' selected'
    end
    cls
  end
end
