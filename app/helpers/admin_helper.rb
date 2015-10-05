module AdminHelper
  def admin_tab(name, text=nil)
    path = "admin/#{name}"

    content_tag :li, class: "tab #{nav_link_class(path)}" do
      link_to (text || name).titleize, "/#{path}", class: "nav-#{name}"
    end
  end
end
