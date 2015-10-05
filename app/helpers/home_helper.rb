module HomeHelper

  def service_result(location, bookmark_list, for_bookmarks, vendor_profile, &block)
    content = capture(&block)
    cls = 'location-list-item'
    cls << ' for_bookmarks' if for_bookmarks
    cls << ' vendor_profile' if vendor_profile
    cls << ' admin_owned' if location.vendor_id.nil?
    if bookmark_list.nil?
      cls << ' bookmarked' if get_cookie_bookmarks.include? location.id
    else
      cls << ' bookmarked' if bookmark_list.bookmarks.map(&:location_id).include? location.id
    end

    content_tag :div, content, class: cls, data: { 'location-id' => location.id }
  end

  def staffer_result(staffer, &block)
    content_tag :div, capture(&block), class: 'location-list-item', data: { 'staffer-id' => staffer.id }
  end

  def result_tree_level(expanded, service_id, i_level, level_class, state, city=nil, &block)
    cls = "tree-level tree-level-#{i_level} #{level_class}"
    key = "#{full_state_name_from_abbreviation(state).split(' ').join('_')}"
    key += "-#{city.split(' ').join('_')}" if i_level == 1

    if expanded.blank?
      cls << ' tree-collapsed' if i_level == 1
    else
      unless expanded.include? key
        cls << ' tree-collapsed'
      end
    end

    content_tag :div, capture(&block), class: cls, data: {
      'i-level' => i_level,
      'level-type' => level_class,
      'key' => key
    }
  end

end
