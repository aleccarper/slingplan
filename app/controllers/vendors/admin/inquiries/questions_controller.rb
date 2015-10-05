class Vendors::Admin::Inquiries::QuestionsController < Vendors::Admin::InquiriesController
  before_action :set_title

  def index
  end

  def new
    @question = current_vendor.inquiries.new
  end

  def show
    @question = current_vendor.inquiries.find(params[:id])
  end

  def create
    @question = current_vendor.inquiries.new(params_for_inquiry.merge({
      type: 'question'
    }))
    if @question.valid?
      @question.save
      flash[:notice] = 'Question submitted.'
      SlackModule::API::notify_inquiry_created(current_vendor, @question, with_host_url(@question.admin_path))
      return redirect_to vendors_admin_inquiries_path
    end
    render :new
  end

  private

  def set_title
    set_meta_tags :title => 'Question'
  end
end
