require 'spec_helper'
include Warden::Test::Helpers

module RequestHelpers

  def login_planner(planner)
    login_as planner, scope: :planner, run_callbacks: false
  end

  def login_vendor(vendor)
    login_as vendor, scope: :vendor, run_callbacks: false
  end

  def create_logged_in_planner
    planner = FactoryGirl.create(:planner)
    login_planner(planner)
    planner
  end

  def create_logged_in_vendor
    vendor = FactoryGirl.create(:vendor)
    login_vendor(vendor)
    vendor
  end

end
