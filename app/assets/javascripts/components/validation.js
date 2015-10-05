var Validation = (function($, m) {

  var bypass = false;

  var init = function() {
    $('form .field').each(function() {
      bind_validate($(this));
    });

    $(document).on('click', 'form input[type=submit]', function() {
      $('input[type=submit]', $(this).parents('form')).removeAttr('clicked');
      $(this).attr('clicked', 'true');
    });

    $('form.validate_submit').on('submit', on_submit);
  };

  var on_submit = function(e) {
    if(bypass) {
      bypass = false;
      return;
    }

    var form = $(this);
    var controls = [];
    var included_attrs = [];
    var clicked_submit_name = $('input[type=submit][clicked=true]').attr('name');
    var clicked_submit_value = $('input[type=submit][clicked=true]').val();
    if(clicked_submit_name) {
      var submit_button_attrs = $("<input type='hidden' name='" + clicked_submit_name + "' value='" + clicked_submit_value + "' />");
      form.append(submit_button_attrs);
    }

    $.each(form.find('.field').find('input, select, textarea'), function(i, o) {
      var el = $(o);
      if(validation_enabled(el)) {
        controls.push(el);
        included_attrs.push(get_model_info(el.attr('name')).attribute);
      }
    });

    $.post('/validate_all', {
      model: form.data('model'),
      attributes: form.serializeObject(),
      included_attrs: included_attrs
    },
    function(errors) {
      if(Object.keys(errors).length === 0) {
        form.unbind('submit').submit();
        return;
      };
      $.each(controls, function(i, o) {
        var model_info = get_model_info(o.attr('name'));
        if(errors[model_info.attribute]) {
          show_validation(model_info.attribute, o.closest('.field'), o.find('ul.errorlist'), errors);
        }
      });

      var scrolled = $('body').scrollTop();
      var control_offset = $('.field.error:first').offset().top;
      var pos = scrolled + control_offset;
      var scrollTop = pos - ($(window).height() / 2);
      $('body').animate({
        scrollTop: scrollTop
      }, 250);
    });

    return false;
  };

  // Gets model and attributes from input name
  var get_model_info = function(input_name) {
    var matches = input_name.match(/^(\w+)\[(\w+)\]$/);
    return { model: matches[1], attribute: matches[2] };
  };

  // Parses a data-triggers attribute into an array of control names
  var get_control_triggers = function(model, field) {
    var data_triggers = field.attr('data-triggers');
    if(data_triggers) {
      var triggers = [];
      $.each(data_triggers.split(' '), function(i, trigger) {
        triggers.push("{0}[{1}]".format(model, trigger));
      });
      return triggers;
    } else {
      return null;
    }
  };

  // Find parent form based on control and returns serialized form data
  var get_form_values = function(control) {
    var form = control.closest('form');
    return form.serializeArray();
  };

  // Show validation display on form field
  var show_validation = function(attribute, field, errorlist, errors) {
    var errors = errors[attribute];

    errorlist.empty();
    errorlist.append(HandlebarsTemplates['validation/errors'](errors));

    if(!!errors && errors.length > 0) {
      field.removeClass('valid').addClass('error');
    } else {
      field.removeClass('error').addClass('valid');
    }

    var errors = field.closest('form').find('.field.error').length !== 0;
    field.closest('form').toggleClass('invalid', errors);
  };

  // Triggers validation display on other fields
  var trigger_validation = function(triggers, errors) {
    var results = [];
    for (var k in triggers) {
      results.push($("[name='" + triggers[k] + "']").trigger('input', errors));
    }
    return results;
  };

  // Check to see if validation is enabled on the form
  var validation_enabled = function(control) {
    // Check to see if validation is enabled at the control level
    if(control.attr('data-validate') == 'true') {
      if(control.closest('form').attr('data-validate') == 'true') {
        return true;
      }
    }
    return false;
  };

  // Causes validation display on field, optinally doing postback if needed
  var validate = function(form_action, model, attribute, field, control, errorlist, triggers, errors) {
    if(!errors) {
      $.post('/validate', {
        form_action: form_action,
        model: model,
        attribute: attribute,
        values: get_form_values(control),
        triggers: triggers
      },
      function(errors) {
        show_validation(attribute, field, errorlist, errors);

        // Since this was a postback, trigger validations
        trigger_validation(triggers, errors);
      });
    } else {
      show_validation(attribute, field, errorlist, errors);
    }
  };

  // Selects appropriate elements and binds validate() to field input
  var bind_validate = function(field) {
    var control = field.find('input, select, textarea');
    if(validation_enabled(control)) {
      var model_info = get_model_info(control.attr('name'));
      var errorlist = field.find('ul.errorlist');
      var triggers = get_control_triggers(model_info.model, field);
      var form_action = control.closest('form').attr('action');

      var timeout = null;
      control.on('input change', function(event, errors) {
        clearTimeout(timeout);
        timeout = setTimeout(function() {
          validate(form_action, model_info.model, model_info.attribute, field, control, errorlist, triggers, errors);
        }, 1000);
      });
    }
  };

  return {
    init: init
  }
}(jQuery, Validation || {}));

