class ApplicationController < ActionController::Base
  include SlackModule
  include Notifier
  include ActionView::Context
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper
  include PaginationHelper

  before_filter :beta_auth
  before_filter :set_timezone
  before_filter :set_seo

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :beta_auth
  def beta_auth
    return if [root_path, '/beta', '/validate', '/launch_subscriber/create', '/launch_subscriber/success'].include? request.path
    return if ENV['BETA'] != 'true'
    return unless get_cookie('beta_tester_email').blank?
    redirect_to root_path
  end

  helper_method :set_seo
  def set_seo
    set_meta_tags :site => 'SlingPlan',
                  :title => 'Search, Schedule, Done',
                  :keywords => "slingplan, sourcing, scheduling, vednors, event, planning, service, planner, sling plan, map, bookmarks",
                  :description => "SlingPlan - A modern, efficient, and simple solution to sourcing, scheduling, and negotiating with vendors for your meeting and event needs.",
                  :twitter => {
                    :card => "summary",
                    :site => "@slingplan",
                    :title => 'SlingPlan | Search, Schedule, Done.  The next level of Event Planning.',
                    :description => 'A modern, efficient, and simple solution to sourcing, scheduling, and negotiating with vendors for your meeting and event needs.'
                  },
                  :og => {
                    :url => 'slingplan.com',
                    :title => 'Search, Schedule, Done.',
                    :description => 'A modern, efficient, and simple solution to sourcing, scheduling, and negotiating with vendors for your meeting and event needs.',
                    :site_name => 'SlingPlan',
                    :type => 'website'
                  }
  end

  # render a javascript tag pointing to your local
  # machine at the port livereload listens to
  helper_method :livereload_tag
  def livereload_tag
    # get your ip on your local network
    local_ip = Socket.ip_address_list.detect { |intf|
      intf.ipv4_private?
    }.ip_address
    # livereload listen port
    port = '35729'
    javascript_include_tag "http://#{local_ip}:#{port}/livereload.js?snipver=1"
  end

  def after_sign_in_path_for(resource)
    if vendor_signed_in?
      session['vendor_return_to'] or '/vendors/admin/locations'
    elsif planner_signed_in?
      session['planner_return_to'] or '/planners/admin/events'
    elsif staffer_signed_in?
      session['staffer_return_to'] or '/staffers/admin/profile'
    elsif admin_signed_in?
      session['admin_return_to'] or '/admin/locations'
    end
  end

  helper_method :flash!
  def flash!(which)
    flash[:flash_background] = which
  end

  helper_method :set_cookie
  def set_cookie(k, v)
    cookies[k] = v
  end

  helper_method :get_cookie
  def get_cookie(k)
    cookies[k]
  end

  helper_method :get_cookie_bookmarks
  def get_cookie_bookmarks
    cookies[:bookmarks] ||= ''
    cookies[:bookmarks].split('&').map(&:to_i)
  end

  helper_method :set_cookie_bookmarks
  def set_cookie_bookmarks(ids)
    cookies[:bookmarks] = (ids.class == Array) ? ids.join('&') : ''
  end

  helper_method :all_bookmark_ids
  def all_bookmark_ids
    bookmarks = get_cookie_bookmarks
    if planner_signed_in?
      return bookmarks + current_planner.bookmark_lists.map(&:bookmarks).flatten.map(&:location).map(&:id)
    end
    bookmarks
  end

  helper_method :nav_link_class
  def nav_link_class(for_link)
    if request.path.include?('inquiries/negotiations')
      if planner_signed_in? && for_link.include?('admin/events')
        return 'active'
      elsif vendor_signed_in? && for_link.include?('admin/locations')
        return 'active'
      else
        return ''
      end
    else
      path = request.path
    end
    if path == for_link and for_link == '/'
      'active'
    elsif path.include? for_link and for_link != '/'
      'active'
    end
  end

  helper_method :subnav_link_class
  def subnav_link_class(for_link)
    if request.path.include? for_link
      'active'
    end
  end

  helper_method :current_controller
  def current_controller
    "#{params[:controller]}"
  end


  # planners
  helper_method :total_planners_subscribed
  def total_planners_subscribed
    Planner.where(subscribed: true).count
  end

  helper_method :planner_customer
  def planner_customer
    @customer = StripeToolbox::Wrapper.new.execute(Stripe::Customer, 'retrieve', current_planner.stripe_id)
  end

  helper_method :planner_customer_has_card
  def planner_customer_has_card
    !@customer[:cards]['data'][0].nil?
  end

  helper_method :planner_customer_subscribed?
  def planner_customer_subscribed?
    planner_customer.subscriptions['total_count'] > 0
  end

  helper_method :planner_subscription
  def planner_subscription
    return current_planner.subscription_id
  end

  helper_method :recently_changed?
  def recently_changed? last
    last.created_at > 5.seconds.ago or last.updated_at > 5.seconds.ago
  end


  # vendors
  helper_method :total_vendors_subscribed
  def total_vendors_subscribed
    Vendor.where(subscribed: true).count
  end

  helper_method :vendor_customer
  def vendor_customer
    @customer = StripeToolbox::Wrapper.new.execute(Stripe::Customer, 'retrieve', current_vendor.stripe_id)
  end

  helper_method :vendor_customer_has_card
  def vendor_customer_has_card
    !@customer[:cards]['data'][0].nil?
  end

  helper_method :vendor_customer_subscribed?
  def vendor_customer_subscribed?
    vendor_customer.subscriptions['total_count'] > 0
  end

  helper_method :vendor_subscription
  def vendor_subscription
    return current_vendor.subscription_id
  end


  # staffers
  helper_method :total_staffers_subscribed
  def total_staffers_subscribed
    Staffer.where(subscribed: true).count
  end

  helper_method :staffer_customer
  def staffer_customer
    @customer = StripeToolbox::Wrapper.new.execute(Stripe::Customer, 'retrieve', current_staffer.stripe_id)
  end

  helper_method :staffer_customer_has_card
  def staffer_customer_has_card
    !@customer[:cards]['data'][0].nil?
  end

  helper_method :staffer_customer_subscribed?
  def staffer_customer_subscribed?
    staffer_customer.subscriptions['total_count'] > 0
  end

  helper_method :staffer_subscription
  def staffer_subscription
    return current_staffer.subscription_id
  end



  helper_method :has_max_active_events?
  def has_max_active_events?(planner)
    if (max = get_max_allowed_events(planner.subscription_id)) != 'Unlimited'
      if planner.events.confirmed.active.length >= max
        return true
      end
    end
    false
  end

  helper_method :get_active_location_count
  def get_active_location_count(vendor_or_admin)
    count = 0
    vendor_or_admin.locations.each do |loc|
      if loc.status == 'active'
        count = count + 1
      end
    end
    return count
  end

  helper_method :get_max_allowed_events
  def get_max_allowed_events(plan)
    if !plan
      return 99
    end
    plan = plan[1..-1] if plan[0] != 't'
    allowed = 0
    case plan[0..4]
      when 'tier1' then allowed = 3
      when 'tier2' then allowed = 10
      when 'tier3' then allowed = 'Unlimited'
      when 'tier4' then allowed = 20
      when 'tier5' then allowed = 40
    end
    return 'Unlimited'#allowed
  end

  helper_method :restructure_plans_for_view
  def restructure_plans_for_view(model, stripe_plans)
    r = {}
    plans = stripe_plans[:plans][:data].select { |p| p[:id][0] == model.to_s[0] }.reverse
    product = case model
    when :planner then 'Event'
    when :vendor then 'Location'
    end

    plans.each_with_index do |p, i|
      tier, m_or_y = p.id[1..5], p.id[6..-1]
      unless r.has_key? tier
        case model
        when :planner
          max = get_max_allowed_events(p.id)
          feature_msg = " at once"
        when :vendor
          max = current_vendor.get_max_allowed_locations(p.id)
        end

        r[tier] = {}
        r[tier][:name] = p.name
        r[tier][:prices] = {}
        if model == :staffer
          r[tier][:feature] = nil
        else
          if max == 1
            r[tier][:feature] = "#{max} #{product}"
          else
            r[tier][:feature] = ("#{max} #{product}s" << (max == 'Unlimited' ? '' : feature_msg || ''))
          end
          r[tier][:primary] = tier == 'tier3'
        end
      end
      r[tier][:prices][m_or_y.to_sym] = prettify_amount(p.amount.to_s)
    end
    r = r.map { |h| {id: h[0]}.merge(h[1]) }
    r.sort { |a,b| a[:id][5].to_i <=> b[:id][5].to_i }
  end

  helper_method :prettify_date
  def prettify_date(str)
    DateTime.strptime(str.to_s, '%s').strftime("%B %d, %Y")
  end

  helper_method :prettify_date_short
  def prettify_date_short(str)
    DateTime.strptime(str.to_s, '%s').strftime("%m/%d/%y")
  end

  helper_method :prettify_amount
  def prettify_amount(amount)
    number_with_delimiter('%.2f' % [amount.to_f / 100], delimiter: ',')
  end

  helper_method :prettify_amount_without_cents
  def prettify_amount_without_cents(amount)
    if amount.to_s.length > 2
      amount.to_s[0, amount.to_s.length-2]
    else
      '0'
    end
    #'%.0f' % [amount.to_f / 100]
  end

  helper_method :prettify_amount_just_cents
  def prettify_amount_just_cents(amount)
    amount.to_s[-2, 2]
  end


  helper_method :set_stripe
  def set_stripe
    @stripe_toolbox = StripeToolbox::Toolbox.new
    @stripe_toolbox.init_stripe
  end

  helper_method :class_exists?
  def class_exists?(name)
    c = Module.const_get(name)
    c.is_a?(Class)
  rescue NameError
    false
  end

  helper_method :full_state_name_from_abbreviation
  def full_state_name_from_abbreviation(abbreviation)
    state_abbreviations.invert[abbreviation.upcase].titlecase
  end

  helper_method :truncate_with_ellipsis
  def truncate_with_ellipsis(s, len)
    if s.length > len then "#{(s[0..len-1]).strip}..." else s end
  end

  helper_method :state_abbreviations
  def state_abbreviations
    {
      'alabama' => 'AL',
      'alaska' => 'AK',
      'arizona' => 'AZ',
      'arkansas' => 'AR',
      'california' => 'CA',
      'colorado' => 'CO',
      'connecticut' => 'CT',
      'delaware' => 'DE',
      'district of columbia' => 'DC',
      'florida' => 'FL',
      'georgia' => 'GA',
      'hawaii' => 'HI',
      'idaho' => 'ID',
      'illinois' => 'IL',
      'indiana' => 'IN',
      'iowa' => 'IA',
      'kansas' => 'KS',
      'kentucky' => 'KY',
      'louisiana' => 'LA',
      'maine' => 'ME',
      'maryland' => 'MD',
      'massachusetts' => 'MA',
      'michigan' => 'MI',
      'minnesota' => 'MN',
      'mississippi' => 'MS',
      'missouri' => 'MO',
      'montana' => 'MT',
      'nebraska' => 'NE',
      'nevada' => 'NV',
      'new hampshire' => 'NH',
      'new jersey' => 'NJ',
      'new mexico' => 'NM',
      'new york' => 'NY',
      'north carolina' => 'NC',
      'north dakota' => 'ND',
      'ohio' => 'OH',
      'oklahoma' => 'OK',
      'oregon' => 'OR',
      'pennsylvania' => 'PA',
      'rhode island' => 'RI',
      'south carolina' => 'SC',
      'south dakota' => 'SD',
      'tennessee' => 'TN',
      'texas' => 'TX',
      'utah' => 'UT',
      'vermont' => 'VT',
      'virginia' => 'VA',
      'washington' => 'WA',
      'west virginia' => 'WV',
      'wisconsin' => 'WI',
      'wyoming' => 'WY'
    }
  end

  helper_method :anyone_signed_in?
  def anyone_signed_in?
    planner_signed_in? || vendor_signed_in? || staffer_signed_in? || admin_signed_in?
  end

  helper_method :non_admin_signed_in?
  def non_admin_signed_in?
    planner_signed_in? || vendor_signed_in? || staffer_signed_in?
  end

  helper_method :current_sign_out_path
  def current_sign_out_path
    return case current_authenticated_role
    when :admin then destroy_admin_session_path
    when :vendor then destroy_vendor_session_path
    when :planner then destroy_planner_session_path
    when :staffer then destroy_staffer_session_path
    end
  end

  helper_method :current_manage_account_path
  def current_manage_account_path
    return case current_authenticated_role
    when :admin then admin_locations_path
    when :vendor then vendors_admin_locations_path
    when :planner then planners_admin_events_path
    when :staffer then '/staffers/admin/profile'
    end
  end

  helper_method :authenticated_instance
  def authenticated_instance
    return case current_authenticated_role
    when :admin then current_admin
    when :vendor then current_vendor
    when :planner then current_planner
    when :staffer then current_staffer
    end
  end

  helper_method :current_authenticated_role
  def current_authenticated_role
    if vendor_signed_in? then Vendor.name.downcase.to_sym
    elsif planner_signed_in? then Planner.name.downcase.to_sym
    elsif admin_signed_in? then Admin.name.downcase.to_sym
    elsif staffer_signed_in? then Staffer.name.downcase.to_sym
    end
  end

  helper_method :get_bounding_box
  def get_bounding_box
    ne = [
      params[:bounds][:ne_lat],
      params[:bounds][:ne_lng]
    ]
    sw = [
      params[:bounds][:sw_lat],
      params[:bounds][:sw_lng]
    ]
    center_point = [
      params[:bounds][:center_lat],
      params[:bounds][:center_lng]
    ]

    distance = Geocoder::Calculations.distance_between(ne, sw)
    Geocoder::Calculations.bounding_box(center_point, distance * 0.35)
  end



  private

  def set_timezone
    Time.zone =
      if defined? current_vendor
        current_vendor.time_zone if vendor_signed_in?
      elsif defined? current_planner
        current_planner.time_zone if planner_signed_in?
      elsif defined? current_staffer
        current_staffer.time_zone if staffer_signed_in?
      elsif defined? current_admin
        current_admin.time_zone if admin_signed_in?
      end
  end

end
