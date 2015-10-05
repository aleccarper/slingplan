class Planners::Admin::EventsController < Planners::AdminController
  include StripeToolbox

  before_action :convert_date, only: :update
  before_action :set_stripe
  before_action :set_stripe_values
  before_action :update_totals

  def index
    @max_active_allowed = get_max_allowed_events(planner_subscription)
    set_meta_tags :title => 'Events'
  end

  def page_unconfirmed
    render_pagination current_planner.events.unconfirmed.get_pages
  end

  def page_future
    render_pagination current_planner.events.confirmed.future.get_pages
  end

  def page_today
    render_pagination current_planner.events.confirmed.today.get_pages
  end

  def page_past
    render_pagination current_planner.events.confirmed.past.get_pages
  end

  def page_service_rfp
    render_pagination ServiceRfp.find_by_id(params[:service_rfp_id]).vendor_rfps.by_responses.get_pages, 'planners/admin/events/page_service_rfp'
  end

  def show_service_rfp
    @event = current_planner.events.find_by_id(params[:id])

    if params[:service_rfp_id].blank?
      first = @event.service_rfps.first
      return redirect_to "/planners/admin/events/#{@event.id}/service_rfp/#{first.id}"
    end

    @service_rfp = @event.service_rfps.find_by_id(params[:service_rfp_id])
  end

  def new
    if has_max_active_events?(current_planner)
      return redirect_to '/planners/admin/events', {
        alert: "Sorry - you currently have the maximum number of active Events supported by your subscription."
      }
    end

    @event = current_planner.events.new
    set_meta_tags :title => 'New Event'
  end

  def clone
    if has_max_active_events?(current_planner)
      return redirect_to '/planners/admin/events', {
        alert: "Sorry - you currently have the maximum number of active Events supported by your subscription."
      }
    end

    @event = current_planner.events.find_by_id(params[:id])

    @dup = @event.clone
    @dup.save

    redirect_to edit_planners_admin_event_path(@dup)
  end

  def edit
    @event = current_planner.events.find_by_id(params[:id])

    if params[:page].blank?
      return redirect_to edit_planners_admin_event_path(@event) << '/location'
    end

    case params[:page]
      when 'location' then set_meta_tags :title => 'Event Location'
      when 'contact' then set_meta_tags :title => 'Event Contact'
      when 'date' then set_meta_tags :title => 'Event Date'
      when 'services' then set_meta_tags :title => 'Event Services'
      when 'service_rfp' then set_meta_tags :title => 'Event RFPs'
    end
    
    if params[:page] == 'service_rfp'
      redirect_to edit_planners_admin_event_path(@event) << '/service_rfp'
    end

    @page = params[:page]
  end

  def edit_service_rfp
    @event = current_planner.events.find_by_id(params[:id])

    if params[:service_rfp_id].blank?
      if @event.services.blank?
        return redirect_to edit_planners_admin_event_path(@event) << '/services', {
          alert: 'You must first choose services.'
        }
      end

      first = @event.service_rfps.first
      return redirect_to edit_planners_admin_event_path(@event) << "/service_rfp/#{first.id}"
    end

    @service_rfp = @event.service_rfps.find_by_id(params[:service_rfp_id])
    @service_rfp_locations_in_maximum_range = @service_rfp.eligible_locations(mile_radius: 200)
  end

  def create
    @event = current_planner.events.new(event_params)
    @referrer_path = request.referrer.match(/\/(\w+)$/)[1]

    @next_page = case event_action
    when 'save' then edit_event_page[0]
    when 'next' then edit_event_page[1]
    end

    if @event.save
      return redirect_to(edit_planners_admin_event_path(@event) << "/#{@next_page}", {
        notice: 'Event successfully created.'
      })
    end

    flash_errors(@event)

    render :new
  end

  def update
    @event = current_planner.events.find_by_id(params[:id])
    @referrer_path = request.referrer.match(/\/(\w+)$/)[1]

    if params[:next_page].blank?
      @next_page = "#{edit_planners_admin_event_path(@event)}/" << case event_action
      when 'back' then edit_event_page[edit_event_page.index(@referrer_path) - 1]
      when 'save' then edit_event_page[edit_event_page.index(@referrer_path)]
      when 'next' then edit_event_page[edit_event_page.index(@referrer_path) + 1]
      end
    else
      @next_page = params[:next_page]
    end

    attributes = event_params
    if @referrer_path == 'contact'
      hidden = params.select { |p| !p.match(/^hidden_contact_info_(.*+)$/).nil? }
      hidden = Event.potentially_hidden_contact_info.select do |a|
        not hidden.keys.include? "hidden_contact_info_#{a.to_s}"
      end
      @event.hidden_contact_info = hidden
    end

    @event.update(event_params)
    @event.save

    redirect_to @next_page
  end

  def update_service_rfp
    @event = current_planner.events.find_by_id(params[:id])
    @service_rfp = @event.service_rfps.find_by_id(params[:service_rfp_id])
    @referrer_path = request.referrer.match(/\/(\w+)$/)[1]

    if params[:next_page].blank?
      @next_page = case event_action
      when 'back' then edit_planners_admin_event_path(@event) << "/#{edit_event_page[-2]}"
      when 'save' then edit_planners_admin_event_path(@event) << "/service_rfp/#{@service_rfp.id}"
      when 'confirm' then "#{planners_admin_events_path}/#{@event.id}/service_rfp"
      end
    else
      @next_page = params[:next_page]
    end

    @service_rfp.update(service_rfp_params)
    @service_rfp.save

    if event_action == 'confirm'
      if has_max_active_events?(current_planner)
        return redirect_to(edit_planners_admin_event_path(@event) << "/service_rfp/#{@service_rfp.id}", {
          alert: "Sorry - you currently have the maximum number of active Events supported by your subscription."
        })
      end
      @event.service_rfps.each(&:generate_vendor_rfps)
      @event.update_attribute(:confirmed, true)
    end

    redirect_to @next_page
  end

  def destroy
    @event = current_planner.events.find_by_id(params[:id])

    @event.destroy

    redirect_to planners_admin_events_path
  end

  def page_service_rfp_locations
    @event = current_planner.events.find_by_id(params[:event_id])
    @service_rfp = @event.service_rfps.find_by_id(params[:service_rfp_id])

    render_pagination @service_rfp.eligible_locations(mile_radius: params[:mile_radius]).get_pages
  end

  def make_outside_arrangements
    @event = current_planner.events.find_by_id(params[:id])
    @service_rfp = @event.service_rfps.find_by_id(params[:service_rfp_id])

    @service_rfp.make_outside_arrangements!

    render json: {
      success: @service_rfp.reload.outside_arrangements == true
    }
  end

  def cancel_outside_arrangements
    @event = current_planner.events.find_by_id(params[:id])
    @service_rfp = @event.service_rfps.find_by_id(params[:service_rfp_id])

    @service_rfp.cancel_outside_arrangements!

    render json: {
      success: @service_rfp.reload.outside_arrangements == false
    }
  end

  def print_friendly_event
    @event = current_planner.events.find_by_id(params[:id])

    render({
      template: '/planners/admin/events/print_friendly_event',
      layout: false,
      locals: {
        event: @event
      }
    })
  end

  def print_friendly_service_rfp
    @event = current_planner.events.find_by_id(params[:id])
    @service_rfp = @event.service_rfps.find_by_id(params[:service_rfp_id])

    render({
      template:'/planners/admin/events/print_friendly_service_rfp',
      layout: false,
      locals: {
        event: @event,
        service_rfp: @service_rfp
      }
    })
  end

  def hide_vendor_rfp_from_service_rfp
    srfp = ServiceRfp.find(params[:service_rfp_id])
    vrfp = VendorRfp.find(params[:vendor_rfp_id])
    if srfp and vrfp
      srfp.vendor_rfps.delete(vrfp)

      render json: {
        vendor_rfp_ids: srfp.vendor_rfps.map(&:id)
      }
    end
  end

  def hide_location_from_service_rfp
    service_rfp = ServiceRfp.find(params[:service_rfp_id])
    location = Location.find(params[:location_id])

    service_rfp.hide_location(location)

    render json: {
      hidden_location_id: location.id
    }
  end

  def undo_hide_location_from_service_rfp
    service_rfp = ServiceRfp.find(params[:service_rfp_id])
    location = Location.find(params[:location_id])

    service_rfp.unhide_location(location)

    render json: {
      hidden_location_id: location.id
    }
  end

  def update_status
    @event = Event.find(params[:event_id])

    if !@event || @event.planner.id != current_planner.id
      return
    end

    @event.status = params[:status]
    @event.save

    tier_id = planner_subscription
    current = (current_planner.events.where status: 'active').length
    max = get_max_allowed_events(tier_id)

    render json: {
      event: Event.find(params[:event_id]),
      current: current,
      max: max,
      percentage: ((current.to_f / max) * 100).to_i
    }
  end



  private

  def event_action
    [:back, :save, :next, :confirm].map { |s|
      if params.include? s then s.to_s else nil end
    }.compact.first
  end

  def edit_event_page
    ['location', 'contact', 'date', 'services', 'service_rfp']
  end

  def convert_date
    unless (date = params[:event][:start_date]).blank?
      params[:event][:start_date] = date_dmy(DateTime.strptime(date, "%m/%d/%Y"))
    end
    unless (date = params[:event][:end_date]).blank?
      params[:event][:end_date] = date_dmy(DateTime.strptime(date, "%m/%d/%Y"))
    end
  end

  def update_totals
    @total_events = current_planner.events.length
  end

  def get_full_address(event)
    return [
      event.address1,
      event.address2,
      event.city,
      event.state,
      event.zip.to_s
    ].join(' ')
  end

  def set_full_address
    if @event.valid?
      @event.update_attribute(:full_address, get_full_address(@event))
    end
  end

  def event_params
    params.require(:event).permit(
      :name,
      :country_code,
      :start_date,
      :end_date,
      :address1,
      :address2,
      :city,
      :state,
      :zip,
      :phone_number,
      :latitude,
      :longitude,
      :planner_id,
      :tentative,
      :contracted_by,
      service_ids: []
    )
  end

  def service_rfp_params
    params.require(:service_rfp).permit(
      :notes,
      :budget,
      :radius,
      :outside_arrangements
    )
  end
end
