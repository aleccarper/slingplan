var Tabs = (function($, m) {

  var init = function() {
    $('.tabs-expand-collapse').on('click', toggle_tabs_or_go_home)
  };

  var toggle_tabs_or_go_home = function(e) {
    var width = $(window).width();

    if(width < 920 && $('.tabs').length !== 0) {
      e.preventDefault();
      $('body').toggleClass('tabs-collapsed', !$('body').hasClass('tabs-collapsed'));
    }
  };

  return {
    init: init
  };
}(jQuery, Tabs || {}));
