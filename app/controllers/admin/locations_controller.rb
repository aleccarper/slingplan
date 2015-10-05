require 'roo'

class Admin::LocationsController < ApplicationController
  layout 'admin'

  before_action :set_claims
  before_action :set_location, only: [:update, :destroy]

  def index
  end

  def new
    @location = Location.new
  end

  def edit
    @location = Location.find(params[:id])
  end

  def create
    @location = current_admin.locations.new(location_params)

    set_full_address(@location)

    if @location.valid?
      @location.status = 'active'
      @location.save

      SlackModule::API::notify_admin_location_created(current_admin, @location, location_url(@location.id), current_admin.locations.count)

      return redirect_to admin_locations_path
    end

    flash_errors(@location)
    render :new
  end

  def update
    if @location.admin.id == current_admin.id
      @location.update(location_params)
    end

    set_full_address(@location)

    @location.save

    redirect_to admin_locations_path
  end

  def update_status
    @location = Location.find(params[:location_id])

    if !@location || @location.admin.id != current_admin.id
      return
    end

    original_active_count = get_active_location_count(current_admin)
    original_location_status = @location.status

    @location.status = params[:status]
    @location.save

    updated_active_count = get_active_location_count(current_admin)

    if response[:success] == false #revert
      @location.status = original_location_status
      @location.save
    end

    render json: { location: @location }
  end

  def destroy
    @location_id = @location.id

    if current_admin && @location.admin.id == current_admin.id
      @location.destroy
    end
    redirect_to admin_locations_path
  end

  def seed
    @seed_upload = SeedUpload.new(admin: current_admin)
  end

  def seed_upload
    if $redis.get('parsing_seed_file') == 'true'
      flash[:notice] = 'Someone is already parsing a seed file.'
      return redirect_to admin_locations_path
    end

    $redis.set('parsing_seed_file', true)

    @seed_upload = SeedUpload.new(seed_upload_params.merge({
      admin: current_admin
    }))

    if !@seed_upload.valid?
      $redis.set('parsing_seed_file', false)
      SlackModule::API.notify(@seed_upload.errors.to_json)
      return
    end

    @seed_upload.save
    id = @seed_upload.id

    SeedWorker.perform_async(id)

    flash[:notice] = 'Your seed file is uploading.  Check back in a while.'
    redirect_to admin_locations_path
  end

  def page_state
    state = params[:state].upcase
    pages = Location.admin_owned.where(state: state).order(city: :desc).get_pages
    render_pagination(pages, '/admin/locations/page_state', nil, "page_state_#{state}")
  end



  private



  def set_claims
    @claims = Claim.where(status: 'pending')
  end

  def set_location
    @location = current_admin.locations.find_by_id(params[:id])
  end

  def set_full_address(location)
    if location.valid?
      location.update_attribute(:full_address, [
        location.address1,
        location.address2,
        location.city,
        location.state,
        location.zip.to_s
      ].join(' '))
    end
  end

  def seed_upload_params
    params.require(:seed_upload).permit(
      :file
    )
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
      :admin_id,
      :service_ids => []
    )
  end
end
