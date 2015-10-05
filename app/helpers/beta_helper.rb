module BetaHelper

  def beta_nav
    content_tag :div, class: 'beta-nav' do
      concat content_tag(:div, 'Vendors', class: "btn btn-medium btn-dark vendors", data: { page: 'vendors' })
      concat content_tag(:div, 'General Overview', class: "btn btn-medium btn-dark overview", data: { page: 'overview' })
      concat content_tag(:div, 'Planners', class: "btn btn-medium btn-dark planners", data: { page: 'planners' })
    end
  end

end
