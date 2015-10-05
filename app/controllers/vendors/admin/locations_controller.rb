class Vendors::Admin::LocationsController < Vendors::AdminController
  include StripeToolbox

  before_action :set_stripe
  before_action :set_stripe_values
  before_action :update_totals

  def index
    @claims = current_vendor.claims.where(status: 'pending')
    @max_active_allowed = current_vendor.get_max_allowed_locations(vendor_subscription)

    set_meta_tags :title => 'Locations'
  end

  def new
    @location = current_vendor.locations.new

    set_meta_tags :title => 'New Location'
  end

  def show
    @location = current_vendor.locations.find_by_id(params[:id])
    @page = 'manage-location'
  end

  def confirm
    @location = current_vendor.locations.find_by_id(params[:id])
    @location.confirm!

    redirect_to vendors_admin_locations_path, {
      notice: 'Location successfully created.'
    }
  end

  def complete
    @location = current_vendor.locations.find_by_id(params[:id])
    redirect_to edit_vendors_admin_location_path(@location) << '/finalize'
  end

  def edit
    @location = current_vendor.locations.find_by_id(params[:id])

    if params[:page].blank?
      return redirect_to edit_vendors_admin_location_path(@location) << '/location'
    elsif params[:page] == 'finalize'
      validate_possible_claimables
    end

    case params[:page]
      when 'location' then set_meta_tags :title => 'Location'
      when 'services' then set_meta_tags :title => 'Location Services'
      when 'finalize' then set_meta_tags :title => 'Finalize Location'
    end

    @page = params[:page]
  end

  def create
    @location = current_vendor.locations.new(location_params)
    @referrer_path = request.referrer.match(/\/(\w+)$/)[1]

    @next_page = case location_action
    when 'save' then edit_location_page[0]
    when 'next' then edit_location_page[1]
    end

    if @location.save
      return redirect_to(edit_vendors_admin_location_path(@location) << "/#{@next_page}", {
        notice: 'Location successfully created.'
      })
    end

    flash_errors(@location)

    render :new
  end

  def update
    @location = current_vendor.locations.find_by_id(params[:id])
    @referrer_path = request.referrer.match(/\/(\w+)$/)[1]

    if params[:next_page].blank?
      @next_page = "#{edit_vendors_admin_location_path(@location)}/" << case location_action
      when 'back' then edit_location_page[edit_location_page.index(@referrer_path) - 1]
      when 'save' then edit_location_page[edit_location_page.index(@referrer_path)]
      when 'next' then edit_location_page[edit_location_page.index(@referrer_path) + 1]
      end
    else
      @next_page = params[:next_page]
    end

    @location.update(location_params)
    @location.save

    redirect_to @next_page
  end

  def claim
    @created = Location.find(params[:created_id])
    @claimed = Location.find(params[:claimed_id])

    @claim = Claim.new(vendor: current_vendor, location: @claimed)

    if success = @claim.save
      @created.destroy!
      SlackModule::API::notify_claim_created(@claim, vendor_url(@claim.vendor.id), @claimed, location_url(@claimed.id))
    end

    render json: { success: success }
  end

  def claimed
  end

  def update_status
    @location = Location.find(params[:location_id])

    if(!@location || @location.vendor.id != current_vendor.id)
      return
    end

    @location.status = params[:status]
    @location.save

    tier_id = vendor_subscription
    current = current_vendor.locations.where(status: 'active').length
    max = current_vendor.get_max_allowed_locations(tier_id)

    render json: {
      location: Location.find(params[:location_id]),
      current: current,
      max: max,
      percentage: max == 'Unlimited' ? 0 : ((current.to_f / max) * 100).to_i
    }
  end

  def destroy
    @location = Location.find(params[:id]).destroy
    redirect_to vendors_admin_locations_path
  end

  def page_negotiating
    ids = Location.negotiating(current_vendor.id).map(&:first)
    render_pagination current_vendor.locations.where('id IN (?)', ids).get_pages
  end

  def page_unconfirmed
    render_pagination current_vendor.locations.unconfirmed.order(city: :desc).get_pages
  end

  def page_state
    render_pagination current_vendor.locations.confirmed.where(state: params[:state]).order(city: :desc).get_pages
  end



  private

  def location_action
    [:back, :save, :next, :confirm].map { |s|
      if params.include? s then s.to_s else nil end
    }.compact.first
  end

  def edit_location_page
    ['location', 'services', 'finalize']
  end

  def validate_possible_claimables
    full_address = @location.get_full_address
    geocoded = Geocoder.search(full_address)

    lat = geocoded[0].data['geometry']['location']['lat']
    lng = geocoded[0].data['geometry']['location']['lng']

    @claimables = Location.where("vendor_id IS null AND name ILIKE ?", @location.name).near([lat, lng], 3)
  end

  def update_totals
    @locations = current_vendor.locations
    @active_location_count = (@locations.where status: 'active').length
    @total_active_locations = @active_location_count
  end

  def location_params
    params.require(:location).permit(
      :name,
      :email,
      :website,
      :country_code,
      :address1,
      :address2,
      :city,
      :state,
      :zip,
      :phone_number,
      :latitude,
      :longitude,
      :vendor_id,
      :service_ids => []
    )
  end
end
