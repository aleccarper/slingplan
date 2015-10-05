class Planners::Admin::Inquiries::NegotiationsController < Planners::Admin::InquiriesController
  def show
    @negotiation = current_planner.negotiations.find_by_id(params[:id])
    @vendor_rfp = @negotiation.vendor_rfp
    @service_rfp = @vendor_rfp.service_rfp
    @event = @negotiation.vendor_rfp.service_rfp.event
  end
end
