class Staffers::Admin::AccountController < Staffers::AdminController
  before_action :set_staffer

  def index
    redirect_to staffers_admin_account_billing_index_path
  end



  private

  def set_staffer
    @staffer = current_staffer
  end

end
