var SignIn = (function($, m) {

  var init = function() {
    $('.role').on('click', function() {
      var role = $(this).data('role');
      $('.sign-in-area')
        .removeClass('vendor planner staffer')
        .addClass(role);
      $('.sign-in-form-wrapper').removeClass('selected');
      $('.sign-in-form-wrapper[data-role=' + role + ']').addClass('selected');
      window.scrollTo(0, document.body.scrollHeight);
    });
  };

  return {
    init: init
  };
}(jQuery, SignIn || {}));

