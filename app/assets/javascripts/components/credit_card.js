var CreditCard = (function($, m) {

  var current;
  var on_changed_callback;

  var init = function() {
    $('.credit-card.front input, .credit-card.front  select').on('focus', front_focus);
    $('.credit-card.back input').on('focus', back_focus);

    $('.credit-card.front input, .credit-card.back input').on('input', card_changed);
    $('.credit-card.front select').on('input', card_changed);

    set_current();
  };

  var card_changed = function() {
    if(typeof on_changed_callback !== 'undefined') {
      on_changed_callback();
      set_stripe_values();
    }
  };

  var on_changed = function(func) {
    on_changed_callback = function() {
      func(current, get_selected());
    };
  };

  var get_selected = function() {
    selected = '';
    selected += $('#stripe_number').val();
    selected += $('#exp_month').val();
    selected += $('#exp_year').val();
    selected += $('#stripe_cvc').val();
    return selected;
  };

  var set_current = function() {
    current = get_selected();
  };

  var set_stripe_values = function() {
    $('#stripe_number_value').attr('value', $('#stripe_number').val());
  };

  var front_focus = function() {
    $('.credit-card.back').addClass('unfocused');
    $(this).closest('.credit-card').removeClass('unfocused');
  };

  var back_focus = function() {
    $('.credit-card.front').addClass('unfocused');
    $(this).closest('.credit-card').removeClass('unfocused');
  };

  return {
    init: init,
    on_changed: on_changed
  }

}(jQuery, CreditCard || {}));
