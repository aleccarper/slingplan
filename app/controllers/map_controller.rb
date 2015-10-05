require 'ostruct'

class MapController < ApplicationController
  layout 'map'

  def index
    set_meta_tags :title => 'Map',
                  :keywords => "map, bookmark, event, vendors, services, planner, #{Service.all.map { |s| s.name.downcase }.join(', ')}",
                  :description => "A map for easily finding vendors by service and location. Bookmark lists of vendors to use at your next event."
  end

  def get_state_outlines; render 'map/states.json' end

  def route_filter
    @country, @state, @city, @vendor_name = normalized_route_filter_params
    if @vendor_name
      @vendor = Vendor
        .where("lower(name) = ?", @vendor_name.downcase)
        .first

      if @vendor.nil?
        return render '/vendors/not_found'
      end

      @locations_outside_area = @vendor.locations
        .where('(state != ? AND lower(city) != ?)', @state, @city)

      @locations = @vendor.locations
        .where(country_code: @country)
        .where(state: @state)
        .where("lower(city) = ?", @city)

    elsif @city
      @locations = Location
        .where(country_code: @country)
        .where(state: @state)
        .where("lower(city) = ?", @city)

    elsif @state
      @locations = Location
        .where(country_code: @country)
        .where(state: @state)

    elsif @country
      @locations = Location
        .where(country_code: @country)
    end

    render '/vendors/index'
  end

  def render_view_state
    case params[:state]
    when 'search'
      return render json: {
        view: render_to_string({
          partial: 'map/search',
          formats: [:html]
        })
      }
    when 'results'
      locals = case params[:model].classify
      when 'Service'
        service = Service.find_by_id(params[:id])
        {
          title: service.name,
          cls: service.name.parameterize
        }
      when 'Staffer'
        {
          title: 'Staffers',
          cls: 'staffers'
        }
      end
      return render json: {
        view: render_to_string({
          partial: 'map/results',
          formats: [:html],
          locals: locals
        })
      }
    when 'vendor'
      vendor = Vendor.find(params[:id])
      return render json: {
        view: render_to_string({
          partial: 'map/vendor',
          formats: [:html],
          locals: {
            vendor: vendor,
            states: vendor.locations.by_state_and_city
          }
        })
      }
    when 'bookmarks'
      unless params[:bookmark_list_id].blank?
        bookmark_list = BookmarkList.find(params[:bookmark_list_id])
      end
      return render json: {
        view: render_to_string({
          partial: 'bookmarks/bookmarks',
          formats: [:html],
          locals: {
            bookmark_list: bookmark_list || nil
          }
        })
      }
    when 'export'
      unless params[:bookmark_list_id].blank?
        bookmark_list = BookmarkList.find(params[:bookmark_list_id])
      end
      return render json: {
        view: render_to_string({
          partial: 'bookmarks/export',
          formats: [:html],
          locals: {
            bookmark_list: bookmark_list || nil
          }
        })
      }
    when 'email'
      unless params[:bookmark_list_id].blank?
        bookmark_list = BookmarkList.find(params[:bookmark_list_id])
      end
      return render json: {
        view: render_to_string({
          partial: 'bookmarks/email',
          formats: [:html],
          locals: {
            bookmark_list: bookmark_list || nil
          }
        })
      }
    when 'email_success'
      unless params[:bookmark_list_id].blank?
        bookmark_list = BookmarkList.find(params[:bookmark_list_id])
      end
      @email = params[:email]
      return render json: {
        view: render_to_string({
          partial: 'bookmarks/email_success',
          formats: [:html],
          locals: {
            bookmark_list: bookmark_list || nil
          }
        })
      }
    end
  end

  def service_results

    locals = case params[:model].classify
    when 'Service'
      results, locations = locations_by_bounds_and_service

      unless params[:bookmark_list_id].blank?
        bookmark_list = BookmarkList.find(params[:bookmark_list_id])
      end
      {
        service_id: params[:service_id],
        results: results,
        expanded: params[:expanded_service_results],
        bookmark_list: bookmark_list || nil
      }
    when 'Staffer'
      results, staffers = staffers_by_bounds
      {
        results: results,
        expanded: params[:expanded_staffer_results]
      }
    end
    return render json: {
      view: render_to_string({
        partial: "map/#{params[:model]}_results",
        formats: [:html],
        locals: locals
      }),
      locations: locations || [],
      staffers: staffers || []
    }
  end

  private

  def locations_by_bounds_and_service
    locations = Service.find(params[:service_id])
      .locations
      .active
      .account_valid

    if params[:bounds]
      locations = locations.within_bounding_box(get_bounding_box)
    end

    [locations.by_state_and_city, locations]
  end

  def staffers_by_bounds
    staffer = Staffer.all.where(subscribed: true)

    if params[:bounds]
      staffer = staffer.within_bounding_box(get_bounding_box)
    end

    [staffer.by_state_and_city, staffer]
  end

  def normalized_route_filter_params
    country, state, city, vendor_name = params[:filter].split('/').map(&:downcase)
    [
      normalize_country(country),
      normalize_state(state),
      normalize_city(city),
      normalize_vendor_name(vendor_name)
    ]
  end

  def normalize_country(c)
    if c.nil?
      return
    end
    c.upcase
  end

  def normalize_state(s)
    if s.nil?
      return
    end
    if state_abbreviations.include? s
      return state_abbreviations[s]
    end
    s
  end

  def normalize_city(c)
    if c.nil?
      return
    end
    c
  end

  def normalize_vendor_name(v)
    if v.nil?
      return
    end
    v.gsub(/-/, ' ')
  end

end
