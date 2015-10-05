module Admin::LocationsHelper
  def admin_location_claims_link
    link_to('Claims', '/admin/locations/claims', class: 'right btn btn-claims')
  end
end
