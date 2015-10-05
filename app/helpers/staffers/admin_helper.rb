module Staffers::AdminHelper
  def staffer_admin_tab(name, text=nil, &block)
    path = name == 'overview' ? '/' : "/staffers/admin/#{name}"
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

  def staffer_admin_account_tab(name, text=nil)
    path = "staffers/admin/account/#{name}"
    content_tag :li, class: "subtab #{subnav_link_class(path)}" do
      link_to (text || name.titleize), "/#{path}", class: "nav-#{name}"
    end
  end

end
