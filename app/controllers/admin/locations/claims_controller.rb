class Admin::Locations::ClaimsController < ApplicationController
  layout 'admin'

  def index
    @claims = Claim.where(status: 'pending')
  end

  def approve
    @claim = Claim.find(params[:id])
    @claim.approve

    redirect_to admin_locations_claims_path, {
      notice: "Successfully transferred ownership of #{@claim.location.name} to #{@claim.vendor.email}."
    }
  end

  def deny
    @claim = Claim.find(params[:id])
    @claim.deny

    redirect_to admin_locations_claims_path, {
      notice: "Successfully denied #{@claim.vendor.email} ownership of #{@claim.location.name}."
    }
  end
end
