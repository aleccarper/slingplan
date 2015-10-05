class Vendors::Admin::AccountController < Vendors::AdminController
  before_action :set_vendor

  def index
    redirect_to vendors_admin_account_profile_index_path
  end



  private

  def set_vendor
    @vendor = current_vendor
  end

end
