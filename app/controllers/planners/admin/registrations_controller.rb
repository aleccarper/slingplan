class Planners::Admin::RegistrationsController < Devise::RegistrationsController
  protected :after_sign_up_path_for

  @@planner_params = [
    :email,
    :password,
    :password_confirmation,
    :time_zone,
    :logo_image,
    :first_name,
    :last_name,
    :company_name,
    :primary_phone_number,
    :primary_email,
    :primary_website,
    :accepted_terms_of_service
  ]

  def new
    set_meta_tags :title => 'Planner Registration', 
                  :keywords => "slingplan, register, account, planner, vendor, plan, event",
                  :description => "Register a planner account to easily seek out and communicate directly with the vendors you need to make your event a success."
    super
  end

  def after_sign_up_path_for(resource)
    SlackModule::API::notify_planner_created(resource, Planner.count)
    planners_admin_events_path
  end

  private

  def sign_up_params
    params.require(:planner).permit(@@planner_params)
  end

  def account_update_params
    params.require(:planner).permit(@@planner_params)
  end
end
