class VendorsController < ApplicationController
  def index
  end

  def show
    @vendor = Vendor.find_by_id(params[:id])
  end

  def page_state
    @vendor = Vendor.find_by_id(params[:id])
    @pages = @vendor.locations
      .confirmed
      .active
      .account_valid
      .where(state: params[:state])
      .order(city: :desc)
      .get_pages

    @i_page = params[:page].to_i

    render json: {
      view: render_to_string({
        partial: '/vendors/page_state',
        formats: [:html],
        locals: {
          i_page: @i_page,
          pages: @pages,
          state: params[:state],
          locations: @pages[@i_page] || []
        }
      })
    }
  end
end
