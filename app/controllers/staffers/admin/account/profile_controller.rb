class Vendors::Admin::Account::ProfileController < Vendors::Admin::AccountController

  def index
    set_meta_tags :title => 'Profile'
    
    @vendor = current_vendor
    render :edit
  end

  def edit
    @vendor = current_vendor
  end

  def update
    @vendor = Vendor.find(params[:id])
    return if @vendor.id != current_vendor.id

    @vendor.update(vendor_params)

    redirect_to vendors_admin_account_profile_index_path, {
      notice: 'Successfully updated profile.'
    }
  end



  private

  def vendor_params
    params.require(:vendor).permit([
      :name,
      :description,
      :country_code,
      :time_zone,
      :logo_image,
      :primary_phone_number,
      :primary_email,
      :primary_website
    ])
  end
end
