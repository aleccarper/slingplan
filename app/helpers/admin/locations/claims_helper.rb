module Admin::Locations::ClaimsHelper

  def location_claim(claim)
    content_tag :li, class: 'location' do
      concat content_tag(:span, location_link(claim.location), class: 'location')
      concat ' claimed by '
      concat content_tag(:span, vendor_link(claim.vendor), class: 'vendor')
      concat link_to('Approve', "/admin/locations/claims/#{claim.id}/approve", class: 'btn btn-default btn-success')
      concat link_to('Deny', "/admin/locations/claims/#{claim.id}/deny", class: 'btn btn-default btn-danger')
    end
  end

  def location_link(l)
    link_to(l.name, location_path(l.id))
  end

  def vendor_link(v)
    link_to(v.email, vendor_path(v.id))
  end

end
