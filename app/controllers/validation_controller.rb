class ValidationController < ApplicationController
  skip_before_action :verify_authenticity_token
  respond_to :json

  def validate_all
    # If the model doesn't exist, don't return anything
    model = params[:model].classify
    if not class_exists?(model)
      redirect_to root_path
      return
    end

    model = Kernel.const_get(model)

    i = model.new

    attributes = params[:attributes][params[:model].tableize.singularize.to_sym].each do |k, v|
      if v.class != Array
        i[k] = v
      end
    end

    i.valid?

    errors = format_model_validation_errors(i)

    included = params[:included_attrs].blank? ? [] : params[:included_attrs].map(&:to_sym)
    errors = errors.delete_if { |k, v| !included.include? k }

    respond_to do |format|
      format.json { render json: errors }
    end
  end

  def validate
    # If the model doesn't exist, don't return anything
    model = params[:model].classify
    if not class_exists?(model)
      redirect_to root_path
      return
    end

    model = Kernel.const_get(model)
    attribute = params[:attribute].to_sym

    # Clean up incoming form values into attribute: value hash
    values = {}
    params[:values].each do |k, v|
      m, a = get_model_info(v['name'])
      if m and a and m == params[:model]
        values[a.to_sym] = v['value']
      end
    end

    # Clean up incoming triggers into :trigger array
    triggers = []
    if params[:triggers].class == Array
      params[:triggers].each do |v|
        m, a = get_model_info(v)
        triggers << a.to_sym
      end
    end

    i = model.new(values)
    i.valid?

    errors = format_model_validation_errors(i)

    respond_to do |format|
      case

      # If an attribute was specified, only pass back errors for that attribute
      when attribute && triggers.empty?
        format.json { render json: errors.select { |k, v| k == attribute } }

      # If an array of triggers was specified, pass back errors for the attribute and the triggers
      when attribute && triggers.any?
        format.json { render json: errors.select { |k, v| k == attribute or triggers.include? k } }

      else
        format.json { render json: errors }
      end
    end
  end

end
