class Admin::Inquiries::QuestionsController < Admin::InquiriesController

  def index
    @open = Inquiry.questions.open
    @closed = Inquiry.questions.closed
  end

  def show
    @question = Inquiry.find(params[:id])
  end
end
