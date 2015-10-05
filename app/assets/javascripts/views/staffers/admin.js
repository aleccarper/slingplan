var Staffers = (function($, m) {

  var init = function() {
    m.Admin.Account.init();
  };

  m.Admin = {
    init: init
  };

  return m;
}(jQuery, Staffers || {}));
