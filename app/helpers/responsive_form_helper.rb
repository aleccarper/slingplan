module ResponsiveFormHelper

  def responsive_form_for(name, *args, &block)
    options = args.extract_options!
    options[:class] = 'vertical' if options[:class].nil?
    options[:validate] = true if options[:validate].nil?
    model = name.class == Symbol ? name.to_s.titleize : name.class.name

    unless options[:validate_submit].nil?
      validate_submit = 'validate_submit'
      options[:class] << ' invalid'
    else
      validate_submit = ''
    end

    html = {class: "#{options[:class]} #{valid_form_class(flash)} #{validate_submit}" }
    if options[:html]
      if options[:html].include? :class
        html[:class] = html[:class].merge options[:html][:class]
      end
      if options[:html].include? :method
        html[:method] = options[:html][:method]
      end
      if options[:html].include? :id
        html[:id] = options[:html][:id]
      end
    end
    args << options.merge(
      builder: ResponsiveFormBuilder,
      flash: flash,
      data: { validate: options[:validate], model: model },
      html: html
    )
    form_for(name, *args, &block)
  end

  def valid_form_class(flash)
    return 'valid' if flash[:errors].nil? && flash[:valid]
    return 'invalid' if flash[:errors] && !flash[:valid]
  end

end
