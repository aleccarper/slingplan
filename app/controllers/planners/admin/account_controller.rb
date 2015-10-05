class Planners::Admin::AccountController < Planners::AdminController
  before_action :set_planner

  def index
    redirect_to planners_admin_account_profile_index_path
  end



  private

  def set_planner
    @planner = current_planner
  end

end
