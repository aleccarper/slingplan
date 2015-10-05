class ActionController::Base

  # Place model validation errors and values into flash for postback-based validation
  def flash_errors(model)
    flash.now[:errors] = format_model_validation_errors(model)
    flash.now[:values] = params
  end

  # Trigger a valid form submission on postback
  def flash_success
    flash.now[:valid] = true
  end

  # Humanize model validation error messages
  def format_model_validation_errors(model)
    errors = model.errors.to_hash
    errors.each do |k, v|
      errors[k] = v.map { |error| "...#{error}" }
    end
  end

  # Turn a form control name into model, attribute
  def get_model_info(input_name)
    if input_name =~ /^(\w+)\[(\w+)\]$/
      return $1, $2
    else
      return false, false
    end
  end

end
