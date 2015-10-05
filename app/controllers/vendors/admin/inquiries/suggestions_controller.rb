class Vendors::Admin::Inquiries::SuggestionsController < Vendors::Admin::InquiriesController
  before_action :set_title

  def index
  end

  def new
    @suggestion = current_vendor.inquiries.new
  end

  def show
    @suggestion = current_vendor.inquiries.find(params[:id])
  end

  def create
    @suggestion = current_vendor.inquiries.new(params_for_inquiry.merge({
      type: 'suggestion'
    }))
    if @suggestion.valid?
      @suggestion.save
      flash[:notice] = 'Suggestion submitted.'
      SlackModule::API::notify_inquiry_created(current_vendor, @suggestion, with_host_url(@suggestion.admin_path))
      return redirect_to vendors_admin_inquiries_path
    end
    render :new
  end

  private

  def set_title
    set_meta_tags :title => 'Suggestion'
  end
end
