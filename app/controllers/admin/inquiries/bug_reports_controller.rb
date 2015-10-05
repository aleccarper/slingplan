class Admin::Inquiries::BugReportsController < Admin::InquiriesController

  def index
    @open = Inquiry.bug_reports.open
    @closed = Inquiry.bug_reports.closed
  end

  def show
    @bug_report = Inquiry.find(params[:id])
  end
end
