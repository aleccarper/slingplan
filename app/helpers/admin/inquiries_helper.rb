module Admin::InquiriesHelper

  def back_to_admin_inquiries
    link_to("<i class='left fa fa-arrow-left'></i>Back".html_safe, admin_inquiries_path, class: 'btn btn-default')
  end

  def admin_suggestions_link
    content_tag :div, class: 'inquiries-suggestions-button' do
      concat link_to('Suggestions', '/admin/inquiries/suggestions', class: 'btn btn-default')
      if Inquiry.suggestions.open.count > 0
        concat content_tag(:div, Inquiry.suggestions.open.count, class: 'inquiries-count')
      end
    end
  end

  def admin_questions_link
    content_tag :div, class: 'inquiries-questions-button' do
      concat link_to('Questions', '/admin/inquiries/questions', class: 'btn btn-default')
      if Inquiry.questions.open.count > 0
        concat content_tag(:div, Inquiry.questions.open.count, class: 'inquiries-count')
      end
    end
  end

  def admin_bug_reports_link
    content_tag :div, class: 'inquiries-bug-reports-button' do
      concat link_to('Bug Reports', '/admin/inquiries/bug_reports', class: 'btn btn-default')
      if Inquiry.bug_reports.open.count > 0
        concat content_tag(:div, Inquiry.bug_reports.open.count, class: 'inquiries-count')
      end
    end
  end

  def classes_for_inquiry(inquiry)
    "inquiry #{inquiry.type.gsub(/_/, '-')} #{inquiry.status}"
  end

  def time_for_inquiry(inquiry)
    zone = !current_vendor.nil? ? current_vendor.time_zone : 'Central Time (US & Canada)'
    inquiry.created_at.in_time_zone(zone)
           .strftime("%a %b #{inquiry.created_at.in_time_zone(zone).day.ordinalize} at %l:%M%P")
  end

end
