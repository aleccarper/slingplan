class Staffers::Admin::PasswordsController < Devise::PasswordsController
  protected :after_resetting_password_path_for



  protected

  def after_resetting_password_path_for(resource)
    '/staffers/admin/events'
  end
end
