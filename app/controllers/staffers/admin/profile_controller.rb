class Staffers::Admin::ProfileController < Staffers::AdminController
  def index
    set_meta_tags :title => 'Profile'

    @staffer = current_staffer
    render :edit
  end

  def edit
    @staffer = current_staffer
  end

  def update
    @staffer = Staffer.find(params[:id])
    return if @staffer.id != current_staffer.id

    @staffer.update(staffer_params)

    redirect_to staffers_admin_profile_index_path, {
      notice: 'Successfully updated profile.'
    }
  end



  private

  def staffer_params
    params.require(:staffer).permit([
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
    ])
  end
end
