module PaginationHelper
  include ActionView::Context
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::FormTagHelper
  include FontAwesome::Sass::Rails::ViewHelpers

  def paginate(el_id, source, data={})
    render partial: '/partials/paginate', locals: {
      id: el_id,
      source: source,
      data: data
    }
  end

  def render_pagination(pages, partial=nil, data={})
    pages_for request.path.match(/\w+$/), pages, params[:page].to_i, partial || request.path, data
  end

  def pages_for(el_id, pages, i_page, partial, data)
    content = if pages.blank?
      content_tag :div, 'Nothing Here!', class: 'nothing-here'
    else
      content_tag :div, id: el_id, class: 'pagination' do
        concat hidden_field_tag :pagination_last_page, pages.count - 1

        if pages.length > 1
          first_class = "pagination-first #{i_page > 0 ? '' :  'disabled'}"
          prev_class = "pagination-prev #{i_page > 0 ? '' :  'disabled'}"
          concat link_to("#{icon('angle-double-left')}<span class='text'>First</span>".html_safe, '', class: first_class)
          concat link_to("#{icon('angle-left')}<span class='text'>Prev</span>".html_safe, '', class: prev_class)

          if pages.count > 4
            if i_page < 2
              range = [0, 4]
            elsif i_page > pages.count - 3
              range = [i_page - 2, pages.count - 1]
            else
              range = [i_page - 2, i_page + 2]
            end
          else
            range = [0, pages.count - 1]
          end

          page_range = pages[range[0]..range[1]]

          concat (range[0]..range[1]).to_a.map { |i|
            cls = 'pagination-page'
            cls << ' pagination-current-page' if i == i_page
            link_to(i + 1, '#', class: cls, data: { page: i })
          }.join('').html_safe

          next_class = "pagination-next #{i_page < pages.count - 1 ? '' : 'disabled'}"
          last_class = "pagination-last #{i_page < pages.count - 1 ? '' :  'disabled'}"
          concat link_to("<span class='text'>Next</span> #{icon('angle-right')}".html_safe, '', class: next_class)
          concat link_to("<span class='text'>Last</span> #{icon('angle-double-right')}".html_safe, '', class: last_class)
        end

        concat pagination_contents(pages, i_page, partial, data)
      end
    end

    render json: {
      view: content
    }
  end

  def pagination_contents(pages, i_page, partial, data)
    locals = { page: pages[i_page] }
    locals.merge! data unless data.empty?

    content_tag :div, class: 'pagination-contents' do
      render_to_string({
        partial: partial.gsub(/\/\d+/, ''),
        formats: [:html],
        locals: locals
      }).html_safe
    end
  end

end
