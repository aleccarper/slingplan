class Vendors::Admin::Locations::ClaimsController < Vendors::Admin::LocationsController
  def index
    @claims = current_vendor.claims.where(status: 'pending')
  end

  def cancel
    @claim = current_vendor.claims.find(params[:id])
    @claim.cancel

    redirect_to vendors_admin_locations_claims_path, {
      notice: "Successfully cancelled claim for #{@claim.location.name}."
    }
  end
end
