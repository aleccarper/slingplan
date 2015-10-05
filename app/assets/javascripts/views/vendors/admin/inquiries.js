var Vendors = (function($, m) {

  var init = function() {
    $(document).on('click', '#new_negotiation_message input[type=submit][name=bid]', function(e) {
      if($('#negotiation_message_bid').val() === '') {
        e.preventDefault();
        alert("Please supply a bid if you'd like to place one.");
        return false;
      }
    });
  };

  m.Admin.Inquiries = {
    init: init
  };

  return m;
}(jQuery, Vendors || {}));


