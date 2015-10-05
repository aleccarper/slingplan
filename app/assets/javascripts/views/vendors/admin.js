var Vendors = (function($, m) {

  var init = function() {
    m.Admin.Locations.init();
    m.Admin.Account.init();
    m.Admin.Inquiries.init();
  };

  m.Admin = {
    init: init
  };

  return m;
}(jQuery, Vendors || {}));
