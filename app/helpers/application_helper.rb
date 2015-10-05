module ApplicationHelper

  def included(base)
    base.class_eval do
      include AbstractController::Rendering
      include AbstractController::Layouts
      include AbstractController::Helpers
      include AbstractController::Translation
      include AbstractController::AssetPaths
      include ActionController::UrlWriter
    end
  end

  def section_wrap_full(opts, &block)
    cls = 'section-wrap-full '
    cls << opts[:class] if opts.has_key? :class

    content = content_tag :div, class: cls do
      section = content_tag(:section) do
        title = content_tag(:h1, opts[:title])
        title << content_tag(:div, class: 'section-subtitle') do
          content_tag(:div, opts[:subtitle])
        end
      end
      section << content_tag(:div, class: 'section-wrap-bottom') do
        content_tag(:div, capture(&block))
      end
    end
    content
  end

  def section_wrap_mini(opts, &block)
    cls = 'section-wrap-full mini '
    cls << opts[:class] if opts.has_key? :class

    content = content_tag :div, class: cls do
      section = content_tag(:section) do
        title = content_tag(:h1, opts[:title])
      end
    end
    content
  end

  def sign_in_call_to_action
    content = content_tag(:p, "Don't yet have an account on SlingPlan?  Get started now.")
    content << link_to("Planner Sign Up", new_registration_path(:planner), class: 'btn sign-up')
    content << '&nbsp;&nbsp;'.html_safe
    content << link_to("Vendor Sign Up", new_registration_path(:vendor), class: 'btn sign-up')
    content << '&nbsp;&nbsp;'.html_safe
    content << link_to("Staffer Sign Up", new_registration_path(:staffer), class: 'btn sign-up')
    content
  end

  def feedback_prompt
    section_wrap_between('feedback-prompt') do
      concat content_tag(:span, "Share your ideas with us.")
      if current_vendor
        concat link_to('submit feedback', new_vendors_admin_inquiries_suggestion_path, class: 'btn btn-submit-feedback')
      end

      if current_planner
        concat link_to('submit feedback', new_planners_admin_inquiries_suggestion_path, class: 'btn btn-submit-feedback')
      end
    end
  end

  def section_wrap_between(cls='', &block)
    content_tag :div, class: "section-wrap-between #{cls}" do
      content_tag :div, capture(&block)
    end
  end

  def date_mdy(date)
    if date.nil?
      ""
    else
      date.strftime("%-m/%-d/%Y")
    end
  end

  def date_dmy(date)
    if date.nil?
      ""
    else
      date.strftime("%d/%m/%Y")
    end
  end

  def host_url
    'https://www.slingplan.com'
  end

  def with_host_url(relative_path)
    path = relative_path[0] == '/' ? relative_path : "/#{relative_path}"
    host_url + path
  end

  def markdown(text)
    renderer = Redcarpet::Render::HTML.new({
      link_attributes: { rel: 'nofollow', target: "_blank" },
      space_after_headers: true,
      fenced_code_blocks: true,
      filter_html: true,
      hard_wrap: true
    })
    markdown = Redcarpet::Markdown.new(renderer, {
      disable_indented_code_blocks: true,
      superscript: true,
      autolink: true
    })
    content_tag :div, markdown.render(text).html_safe, class: 'markdown'
  end

  def overlay
    content_tag :div, "<i class='spinner fa fa-cog fa-spin fa-6'></i>".html_safe, class: 'loading-overlay'
  end

  def help_icon
    content_tag(:div, class: 'header-help') do
      concat icon('question fa-2x')
      concat icon('question-circle fa-2x')
    end
  end

  def help_box
    content_tag(:div, class: 'help') do
      concat content_tag(:div, 'Have a problem or suggestion?', class: 'help-title')
      concat link_to('Suggestion', new_vendors_admin_account_inquiries_suggestion_path, class: 'btn btn-success')
      concat link_to('Question', new_vendors_admin_account_inquiries_question_path, class: 'btn btn-info')
      concat link_to('Bug Report', new_vendors_admin_account_inquiries_bug_report_path, class: 'btn btn-danger')
    end
  end

  def body_tag(&block)
    cls = params[:controller].gsub(/\//, '-')

    if ENV['HOLDING'] == 'true' || ENV['MAINTENANCE'] == 'true' || (ENV['BETA'] == 'true' and get_cookie('beta_tester_email').blank?)
      cls << ' holding'
    end

    # for css overriding
    if params[:controller] == 'home'
      if vendor_signed_in?
        cls << ' vendor-signed-in'
      elsif planner_signed_in?
        cls << ' planner-signed-in'
      elsif admin_signed_in?
        cls << ' admin-signed-in'
      end
    end

    body_content = if params[:controller].index('/map') == 0
      content_tag(:div, capture(&block), class: 'map-wrapper')
    else
      capture(&block)
    end
    content_tag :body, body_content, class: "#{cls} loading tabs-collapsed", data: { controller: cls }
  end

  def stripe_durations
    [
      ['Once', 'once'],
      ['Forever', 'forever'],
      ['Repeating', 'repeating'],
    ]
  end

  def location_list_item(location, &block)
    content = capture(&block)

    cls = 'location-list-item'
    if not location.confirmed
      cls << ' unconfirmed'
    end
    if location.active?
      cls << ' active'
    end

    content_tag :li, content, id: "location-#{location.id}", class: cls, data: { 'location-id' => location.id }
  end

  def location_list_address(location)
    content_tag :div, class: 'location-address' do
      concat content_tag(:div, location.address1, class: 'location-address1')
      if location.address2
        concat content_tag(:div, location.address2, class: 'location-address2')
      end
      concat content_tag(:span, "#{location.city}, ", class: 'location-city')
      concat content_tag(:span, "#{location.state} ", class: 'location-state')
      concat content_tag(:span, location.zip, class: 'location-zip')
    end
  end

  def hex_color_between(from, to, percentage)
    (0..5).to_a.in_groups_of(2).map { |a|
      f = from[a[0]..a[1]].to_i(16) * percentage
      t = to[a[0]..a[1]].to_i(16) * (1 - percentage)
      (h = (f + t).ceil.to_s(16)).length == 1 ? '0' + h : h
    }.join('')
  end

	def us_states
	[
	  ['Alabama', 'AL'],
	  ['Alaska', 'AK'],
	  ['Arizona', 'AZ'],
	  ['Arkansas', 'AR'],
	  ['California', 'CA'],
	  ['Colorado', 'CO'],
	  ['Connecticut', 'CT'],
	  ['Delaware', 'DE'],
	  ['District of Columbia', 'DC'],
	  ['Florida', 'FL'],
	  ['Georgia', 'GA'],
	  ['Hawaii', 'HI'],
	  ['Idaho', 'ID'],
	  ['Illinois', 'IL'],
	  ['Indiana', 'IN'],
	  ['Iowa', 'IA'],
	  ['Kansas', 'KS'],
	  ['Kentucky', 'KY'],
	  ['Louisiana', 'LA'],
	  ['Maine', 'ME'],
	  ['Maryland', 'MD'],
	  ['Massachusetts', 'MA'],
	  ['Michigan', 'MI'],
	  ['Minnesota', 'MN'],
	  ['Mississippi', 'MS'],
	  ['Missouri', 'MO'],
	  ['Montana', 'MT'],
	  ['Nebraska', 'NE'],
	  ['Nevada', 'NV'],
	  ['New Hampshire', 'NH'],
	  ['New Jersey', 'NJ'],
	  ['New Mexico', 'NM'],
	  ['New York', 'NY'],
	  ['North Carolina', 'NC'],
	  ['North Dakota', 'ND'],
	  ['Ohio', 'OH'],
	  ['Oklahoma', 'OK'],
	  ['Oregon', 'OR'],
	  ['Pennsylvania', 'PA'],
	  ['Puerto Rico', 'PR'],
	  ['Rhode Island', 'RI'],
	  ['South Carolina', 'SC'],
	  ['South Dakota', 'SD'],
	  ['Tennessee', 'TN'],
	  ['Texas', 'TX'],
	  ['Utah', 'UT'],
	  ['Vermont', 'VT'],
	  ['Virginia', 'VA'],
	  ['Washington', 'WA'],
	  ['West Virginia', 'WV'],
	  ['Wisconsin', 'WI'],
	  ['Wyoming', 'WY']
	]
	end

	def social_media_block(url = nil, text = nil)
		link = url || request.url
		t = text || 'Check this out'
		html_block = "
		<div class='social-media-share-page-block'>
			<div class='social-media-share-button-wrap'>
				<a href='https://twitter.com/share' class='twitter-share-button' data-url='"+link+"' data-text='"+t+"' data-count='none'>Tweet</a>
				<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>
			</div>
			<div class='social-media-share-button-wrap'>
				<div class='fb-share-button' data-href="+link+" data-type='button'></div>
			</div>

			<div class='social-media-share-button-wrap'>
				<div class='g-plus' data-action='share' data-annotation='none' data-href="+link+"></div>
			</div>
		</div>
		"
		html_block.html_safe
	end
end
