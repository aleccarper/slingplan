class Vendors::Admin::Account::SettingsController < Vendors::Admin::AccountController
  def index
    @settings = current_vendor.settings

    set_meta_tags :title => 'Settings'
  end

  def update
    s = current_vendor.settings
    s.assign_attributes(params_for_settings)
    s.save

    redirect_to planners_admin_account_settings_path
  end



  private

  def params_for_settings
    params.require(:settings).permit([
      :email_frequency
    ])
  end
end
