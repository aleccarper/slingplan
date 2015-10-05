class ClaimsController < ApplicationController
  def create
    @claim = Claim.new
    @claim.vendor = current_vendor
    @claim.location = Location.find(params[:id])
    @claim.save
    render json: @claim
  end

  def destroy
    current_vendor.claims.find_by(location_id: params[:id]).destroy
    head :ok
  end
end
