class Vendors::Admin::PasswordsController < Devise::PasswordsController
  protected :after_resetting_password_path_for



  protected

  def after_resetting_password_path_for(resource)
    '/vendors/admin/locations'
  end
end
