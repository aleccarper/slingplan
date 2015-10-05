var Coupon = (function($, m) {

  var init = function() {
    $('.coupon-code').on('input', debounced_validate_coupon_code);

    $('.activate-coupon').submit(function(e) {
      if($('#coupon_code').val().trim().length === 0) {
        e.preventDefault();
        $('#coupon_code').closest('.field').addClass('error');
        alert('No coupon code.')
        return false;
      }
    });
  };

  var validate_coupon_code = function() {
    $.ajax({
      method: 'POST',
      url: '/validate_coupon',
      data: {
        code: $(this).val()
      }
    })
    .done(function(data) {
      if(data.success) {
        $('.coupon-entered').html(data.view).show();

        $('.activate-coupon .submit').removeClass('disabled');

        // scroll to bottom of page
        $('html, body').animate({
          scrollTop: $(document).height()
        }, 250);
      } else {
        $('.coupon-entered').html('');
        //$('.activate-coupon .submit').addClass('disabled');
      }
    });
  };

  var debounced_validate_coupon_code = _.debounce(validate_coupon_code, 500);

  return {
    init: init
  };
}(jQuery, Coupon || {}));


