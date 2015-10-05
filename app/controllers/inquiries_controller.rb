class InquiriesController < ApplicationController

  # Inquiries

  def create_inquiry_message
    @msg = InquiryMessage.new(params_for_inquiry_message.merge({
      "#{current_authenticated_role.to_s}_id" => authenticated_instance.id,
      action: inquiry_message_action
    }))
    @inquiry = @msg.inquiry

    @msg.save

    respond_to do |f|
      f.js
    end
  end

  def read_inquiry_messages
    if current = current_vendor || current_planner || current_staffer || current_admin
      unless params[:ids].blank?
        messages = InquiryMessage.where('id IN (?)', params[:ids])
        messages.each(&:read!)
        render json: {
          read_ids: params[:ids]
        }
      end
    end
  end



  # Negotiations

  def create_negotiation_message
    @msg = NegotiationMessage.create(build_negotiation_message_attrs)
    @inquiry = @msg.negotiation

    if request.format.to_s == 'text/html'
      return redirect_to request.referrer
    end

    respond_to do |f|
      f.js
    end
  end

  def create_negotiation_message_bid
    @msg = NegotiationMessage.create(build_negotiation_message_attrs)
    @inquiry = @msg.negotiation

    respond_to do |f|
      f.js
    end
  end

  def read_negotiation_messages
    if current = (current_vendor or current_planner or current_admin)
      unless params[:ids].blank?
        messages = NegotiationMessage.where('id IN (?)', params[:ids])
        messages.each(&:read!)
        render json: {
          read_ids: params[:ids]
        }
      end
    end
  end

  def download_attachment
    msg = NegotiationMessage.find_by_id(params[:id])
    if Rails.env.development?
      file_path = "#{Rails.root}/public#{msg.file_attachment.url}".gsub(/(\?\d+)/, '')
    else
      file_path = msg.file_attachment.url.gsub(/(\?\d+)/, '')
    end
    if [msg.negotiation.planner, msg.negotiation.vendor].include? authenticated_instance
      send_file(URI.decode(file_path), {
        filename: msg.file_attachment_file_name,
        type: msg.file_attachment_content_type
      })
    end
  end



  private

  def inquiry_message_action
    [:reply, :closed, :open].map { |s|
      if params.include? s then s.to_s else nil end
    }.compact.first
  end

  def params_for_inquiry
    params.require(:inquiry).permit(
      :planner_id,
      :vendor_id,
      :staffer_id,
      :action,
      :subject,
      :body
    )
  end

  def params_for_inquiry_message
    params.require(:inquiry_message).permit(
      :admin_id,
      :planner_id,
      :vendor_id,
      :staffer_id,
      :action,
      :inquiry_id,
      :content,
      :file_attachment
    )
  end

  def params_for_negotiation_message
    params.require(:negotiation_message).permit(
      :planner_id,
      :vendor_id,
      :negotiation_id,
      :inquiry_id,
      :action,
      :bid,
      :content,
      :file_attachment
    )
  end

  def build_negotiation_message_attrs
    attrs = case current_authenticated_role
    when :admin then { admin_id: current_admin.id }
    when :vendor then { vendor_id: current_vendor.id }
    when :planner then { planner_id: current_planner.id }
    when :staffer then { staffer_id: current_staffer.id }
    end

    params_for_negotiation_message.merge(attrs)
  end
end
