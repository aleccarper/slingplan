class Planners::Admin::Inquiries::BugReportsController < Planners::Admin::InquiriesController
  before_action :set_title

  def index
  end

  def new
    @bug_report = current_planner.inquiries.new
  end

  def show
    @bug_report = current_planner.inquiries.find(params[:id])
  end

  def create
    @bug_report = current_planner.inquiries.new(params_for_inquiry.merge({
      type: 'bug_report'
    }))
    if @bug_report.valid?
      @bug_report.save
      flash[:notice] = 'Bug report submitted.'
      SlackModule::API::notify_inquiry_created(current_planner, @bug_report, with_host_url(@bug_report.admin_path))
      return redirect_to planners_admin_inquiries_path
    end
    render :new
  end

  private

  def set_title
    set_meta_tags :title => 'Report'
  end
end
