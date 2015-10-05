class Planners::Admin::Account::ProfileController < Planners::Admin::AccountController

  def index
    set_meta_tags :title => 'Profile'
    
    @planner = current_planner
    render :edit
  end

  def edit
    @planner = current_planner
  end

  def update
    @planner = Planner.find(params[:id])
    return if @planner.id != current_planner.id

    @planner.update(planner_params)

    redirect_to planners_admin_account_profile_index_path, {
      notice: 'Successfully updated profile.'
    }
  end



  private

  def planner_params
    params.require(:planner).permit([
      :first_name,
      :last_name,
      :company_name,
      :country_code,
      :time_zone,
      :primary_phone_number,
      :primary_email,
      :primary_website,
      :logo_image,
    ])
  end
end
