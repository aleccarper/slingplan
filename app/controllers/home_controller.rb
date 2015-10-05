class HomeController < ApplicationController

  layout -> {
    if not anyone_signed_in?
      'home'
    end
    # elsif planner_signed_in?
    #   'planner_admin'
    # else vendor_signed_in?
    #   'vendor_admin'
    # end
  }

  def index
    if not anyone_signed_in?
      render template: '/home/index'
    end
    # elsif planner_signed_in?
    #   render template: '/map/index'
    # else vendor_signed_in?
    #   render template: '/map/index'
    # end
  end

  def robots
    render 'home/robots.txt.erb'
  end

end
