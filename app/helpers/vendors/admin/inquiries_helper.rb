module Vendors::Admin::InquiriesHelper

  def back_to_vendor_inquiries
    link_to("<i class='left fa fa-arrow-left'></i>Back".html_safe, vendors_admin_inquiries_path, class: 'btn btn-default')
  end

  def suggestions_link
    content_tag :div, class: 'inquiries-suggestions-button' do
      concat link_to('Suggestions', '/vendors/admin/inquiries/suggestions', class: 'btn btn-large')
      if current_vendor.inquiries.suggestions.open.count > 0
        concat content_tag(:div, current_vendor.inquiries.suggestions.open.count, class: 'inquiries-count')
      end
    end
  end

  def questions_link
    content_tag :div, class: 'inquiries-questions-button' do
      concat link_to('Questions', '/vendors/admin/inquiries/questions', class: 'btn btn-large')
      if current_vendor.inquiries.questions.open.count > 0
        concat content_tag(:div, current_vendor.inquiries.questions.open.count, class: 'inquiries-count')
      end
    end
  end

  def bug_reports_link
    content_tag :div, class: 'inquiries-bug-reports-button' do
      concat link_to('Bug Reports', '/vendors/admin/inquiries/bug_reports', class: 'btn btn-large')
      if current_vendor.inquiries.bug_reports.open.count > 0
        concat content_tag(:div, current_vendor.inquiries.bug_reports.open.count, class: 'inquiries-count')
      end
    end
  end

  def classes_for_inquiry(inquiry)
    "inquiry #{inquiry.type.gsub(/_/, '-')} #{inquiry.status}"
  end

  def classes_for_vendor_rfp(rfp)
    cls = ['vendor-rfp']
    if rfp.current_bid.nil?
      cls << 'pending-bid'
    elsif not rfp.bid_approved?
      cls << 'pending-bid-approval'
    else
      cls << 'bid-approved'
    end
    cls.join(' ')
  end

  def time_for_inquiry(inquiry)
    zone = !current_vendor.nil? ? current_vendor.time_zone : 'Central Time (US & Canada)'
    inquiry.created_at.in_time_zone(zone)
           .strftime("%a %b #{inquiry.created_at.in_time_zone(zone).day.ordinalize} at %l:%M%P")
  end

  def date_for_event(event)
    zone = !current_vendor.nil? ? current_vendor.time_zone : 'Central Time (US & Canada)'
    event.start_date.in_time_zone(zone)
           .strftime("%a %b #{event.start_date.in_time_zone(zone).day.ordinalize}")
  end
end
