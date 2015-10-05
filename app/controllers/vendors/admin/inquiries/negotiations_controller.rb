class Vendors::Admin::Inquiries::NegotiationsController < Vendors::Admin::InquiriesController
  def show
    vrfps = VendorRfp.where('location_id IN (?)', current_vendor.locations.map(&:id)).map(&:id)
    @negotiation = Negotiation.where('vendor_rfp_id IN (?)', vrfps).find(params[:id])
    @vendor_rfp = @negotiation.vendor_rfp
    @event = @negotiation.vendor_rfp.service_rfp.event
    @location = @vendor_rfp.location
  end
end
