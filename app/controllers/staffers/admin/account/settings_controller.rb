class Staffers::Admin::Account::SettingsController < Staffers::Admin::AccountController
  def index
    @settings = current_staffer.settings

    set_meta_tags :title => 'Settings'
  end

  def update
    s = current_staffer.settings
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
