var Plans = (function($, m) {

  var selected_plan = -1;
  var template_id = '#plan-template';
  var current;
  var completed_callback;

  var init = function() {
    $('.plan').on('click', on_plan_click);
    $('.plan .price').on('click', on_price_click);

    var val = $('input[name=plan]').val()
    if(val != null) {
      selected_plan = parseInt(val[4]) - 1;
    }

    current = $('.plans #plan').val();
  };

  var on_completed = function(func) {
    completed_callback = function() {
      var selected = $('.price.selected').data('id');
      func(current, selected);
    };
  };

  var on_plan_click = function() {
    var selected = $('.plan-' + selected_plan);
    if(!selected.is($(this))) {
      deselect_plan();
    } else {
      selected.removeClass('selected')
        .parent()
        .removeClass('selected')
        .find('.price')
        .removeClass('selected');
    }

    selected_plan = $('.plan').index($(this));

    $(this).addClass('selected')
      .parent()
      .addClass('selected');

    if(!$('.plans').hasClass('plan-selected')) {
      $('.plans').addClass('plan-selected');
    }
  };

  var deselect_plan = function() {
    $('.plan').removeClass('selected')
      .parent()
      .removeClass('selected complete')
      .find('.price')
      .removeClass('selected');

    $('.plans').removeClass('plan-selected');
  };

  var on_price_click = function() {
    deselect_plan();

    $('.price').removeClass('selected');

    $(this).addClass('selected');

    $(this).closest('.plan')
      .addClass('selected')
      .parent()
      .addClass('selected complete');

    $('input[name=plan]').val($(this).data('id'));

    $(this).closest('.plan-wrapper').addClass('complete');

    selected_plan = $('.plan').index($(this).closest('.plan'));

    if(!$('.plans').hasClass('plan-selected')) {
      $('.plans').addClass('plan-selected');
    }

    if(typeof completed_callback !== 'undefined') {
      completed_callback();
    }

    // on planner page
    if($('body').is('.planners-admin-registrations')) {
      if(selected_plan === 0) {
        $('.card-info').parent().fadeOut();
      } else {
        $('.card-info').parent().fadeIn();
      }
    } else {
      $('.card-info').parent().fadeIn();
    }

    return false;
  };

  return {
    init: init,
    on_completed: on_completed
  };

}(jQuery, Plans || {}));
