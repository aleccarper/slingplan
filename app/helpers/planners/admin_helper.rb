module Planners::AdminHelper

  def planner_admin_tab(name, text=nil, &block)
    path = name == 'overview' ? '/' : "/planners/admin/#{name}"
    tab_name = (text || name.titleize)
    cls = "tab #{nav_link_class(path)}"

    unless block.nil?
      cls << ' has-subtabs'
    end

    content = content_tag(:li, class: cls) do
      link_to(tab_name, path, class: "nav-#{name}")
    end

    content << capture(&block) unless block.nil?
    content
  end

  def planner_admin_account_tab(name, text=nil)
    path = "planners/admin/account/#{name}"
    content_tag :li, class: "subtab #{subnav_link_class(path)}" do
      link_to (text || name.titleize), "/#{path}", class: "nav-#{name}"
    end
  end

  def unsubscribed_alert
    content_tag :div do
      concat content_tag(:span, "Activating locations will be enabled only after you subscribe ")
      concat link_to('here', '/planners/admin/account/billing', class: 'btn btn-default')
      concat '.'
    end
  end
end
