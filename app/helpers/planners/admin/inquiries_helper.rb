module Planners::Admin::InquiriesHelper

  def back_to_planner_inquiries
    link_to("<i class='left fa fa-arrow-left'></i>Back".html_safe, planners_admin_inquiries_path, class: 'btn btn-default')
  end

  def suggestions_link
    content_tag :div, class: 'inquiries-suggestions-button' do
      concat link_to('Suggestions', '/planners/admin/inquiries/suggestions', class: 'btn btn-default')
      if current_planner.inquiries.suggestions.open.count > 0
        concat content_tag(:div, current_planner.inquiries.suggestions.open.count, class: 'inquiries-count')
      end
    end
  end

  def questions_link
    content_tag :div, class: 'inquiries-questions-button' do
      concat link_to('Questions', '/planners/admin/inquiries/questions', class: 'btn btn-default')
      if current_planner.inquiries.questions.open.count > 0
        concat content_tag(:div, current_planner.inquiries.questions.open.count, class: 'inquiries-count')
      end
    end
  end

  def bug_reports_link
    content_tag :div, class: 'inquiries-bug-reports-button' do
      concat link_to('Bug Reports', '/planners/admin/inquiries/bug_reports', class: 'btn btn-default')
      if current_planner.inquiries.bug_reports.open.count > 0
        concat content_tag(:div, current_planner.inquiries.bug_reports.open.count, class: 'inquiries-count')
      end
    end
  end

  def classes_for_inquiry(inquiry)
    "inquiry #{inquiry.type.gsub(/_/, '-')} #{inquiry.status}"
  end

  def time_for_inquiry(inquiry)
    zone = !current_planner.nil? ? current_planner.time_zone : 'Central Time (US & Canada)'
    inquiry.created_at.in_time_zone(zone)
           .strftime("%a %b #{inquiry.created_at.in_time_zone(zone).day.ordinalize} at %l:%M%P")
  end
end
