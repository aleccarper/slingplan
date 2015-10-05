class ResponsiveFormBuilder < ActionView::Helpers::FormBuilder

  def text_field(attribute, args={})
    field_wrapper(attribute, args) do
      super(attribute, args.merge(data: { validate: args[:validate] }))
    end
  end

  def number_field(attribute, args={})
    field_wrapper(attribute, args) do
      super(attribute, args.merge(data: { validate: args[:validate] }))
    end
  end

  def text_area(attribute, args={})
    field_wrapper(attribute, args) do
      super(attribute, args.merge(data: { validate: args[:validate] }))
    end
  end

  def email_field(attribute, args={})
    field_wrapper(attribute, args) do
      super(attribute, args.merge(data: { validate: args[:validate] }))
    end
  end

  def password_field(attribute, args={})
    field_wrapper(attribute, args) do
      super(attribute, args.merge(data: { validate: args[:validate] }))
    end
  end

  def telephone_field(attribute, args={})
    field_wrapper(attribute, args) do
      super(attribute, args.merge(data: { validate: args[:validate] }))
    end
  end

  def select(attribute, args={})
    field_wrapper(attribute, args) do
      @template.content_tag(:div, class: 'select-dropdown') do
        opts = {}
        unless args[:prompt] == false
          opts[:prompt] = 'Select'
        end
        super(attribute, args[:collection], opts, { data: { validate: args[:validate] } })
      end
    end
  end

  def state_select(attribute, args={})
    field_wrapper(attribute, args) do
      @template.content_tag(:div, class: 'select-dropdown') do
        opts = {}
        opts[:prompt] = 'Select State'
        select(attribute, args[:collection], opts, data: { validate: args[:validate] })
      end
    end
  end

  def hidden_field(attribute, args={})
    super(attribute, args)
  end

  def service_selection(attribute, services, args={}, &block)
    field_wrapper(attribute, args) do
      collection_check_boxes(attribute, services, :id, :name, args, data: { validate: args[:validate] }, &block)
    end
  end

  def country_select(attribute, args={})
    field_wrapper(attribute, args) do
      super(attribute, args, data: { validate: args[:validate] })
    end
  end

  def time_zone_select(attribute, zones, args={})
    field_wrapper(attribute, args) do
      super(attribute, zones, args.merge(data: { validate: args[:validate] }))
    end
  end

  def file_field(attribute, args={})
    field_wrapper(attribute, args) do
      super(attribute, args.merge(data: { validate: args[:validate] }))
    end
  end

  def submit(value)
    @template.content_tag(:div, class: 'submit') do
      super(value)
    end
  end



  private

  # Set up @errors and @values
  def initialize(object_name, object, template, options, block=nil)
    @errors = options[:flash][:errors] if options[:flash][:errors]
    @values = options[:flash][:values][object_name.to_s] if options[:flash][:values]
    super(object_name, object, template, options)
  end

  # Parse symbol or array of triggers into a data-triggers attribute value
  def parse_triggers(triggers)
    case
    when triggers.class == Symbol
      triggers.to_s
    when triggers.class == Array
      triggers.join(' ')
    else nil
    end
  end

  # Wraps a standard field in validation markup
  def field_wrapper(attribute, args, &block)
    cls = @errors && @errors[attribute] && @errors[attribute].length > 0 ? 'error' : 'valid' if @values
    triggers = args.delete(:triggers) if args[:triggers]
    args[:validate] = true if args[:validate].nil? # Default validate to true

    required_cls = ' required' if args[:required]

    @template.content_tag(:div, {
      class: "field #{cls} #{required_cls}",
      id: "js-field-#{attribute}",
      'data-triggers' => parse_triggers(triggers)
    }) do
      label_wrapper(attribute, args) do
        errors_list(attribute) +
        @template.content_tag(:div, class: 'field-wrapper') do
          @template.content_tag(:div, '', class: 'indicator') +
          block.call
        end
      end
    end
  end

  # Turns errors for an attribute into a ul
  def errors_list(attribute)
    @template.content_tag(:ul, class: 'errorlist') do
      if @errors and @errors[attribute]
        items = ''
        @errors[attribute].each do |error|
          items += @template.content_tag(:li, error)
        end
        items.html_safe
      end
    end
  end

  # Wraps the field in a label
  def label_wrapper(attribute, args, &block)
    if args[:label] == false
      block.call
    else
      @template.content_tag(:label) do
        @template.content_tag(:span, get_label_from_attribute(attribute, args)) +
        block.call
      end
    end
  end

  # Tries to grab a suitable label string from the field
  def get_label_from_attribute(attribute, args)
    if args[:label].class == String
      args[:label]
    else
      args[:placeholder] || attribute.to_s.humanize.titlecase
    end
  end

end
