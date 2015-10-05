var Planners = (function($, m) {

  var init = function() {
    m.Admin.Events.init();

    $("#planner_primary_phone_number").mask("(999) 999-9999");
  };

  m.Admin = {
    init: init
  };

  return m;
}(jQuery, Planners || {}));
