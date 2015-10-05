class Admin::Inquiries::SuggestionsController < Admin::InquiriesController

  def index
    @open = Inquiry.suggestions.open
    @closed = Inquiry.suggestions.closed
  end

  def show
    @suggestion = Inquiry.find(params[:id])
  end
end
