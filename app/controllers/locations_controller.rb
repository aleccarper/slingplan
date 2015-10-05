class LocationsController < ApplicationController
  #layout 'map'

  def show
    @location = Location.find(params[:id])
    @vendor = @location.vendor
    @services = @location.services.map(&:name)
  end

  def available_services
    locations = Location
      .active
      .account_valid
      .includes(:services)
      .joins(:services)

    if params[:bounds]
      locations = locations.within_bounding_box(get_bounding_box)
    end

    visible = locations.map { |l| l.services.map(&:id) }.flatten.uniq

    render json: {
      all: Service.all.sort_by(&:name),
      visible: visible,
      any_staffers: Staffer.all.within_bounding_box(get_bounding_box).any?
    }
  end

  def states_with_locations
    states = Rails.cache.fetch('states_with_locations') do
      Location.includes(:claims).includes(:services).joins(:services).account_valid.active.map { |loc| loc.state }.uniq
    end

    render json: {
      states: states
    }
  end
end
