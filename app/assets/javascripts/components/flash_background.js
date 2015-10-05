var FlashBackground = (function($, m) {

  var el;

  var init = function() {
    el = $('.flash-background');

    el.find('.expand').on('click', expand);
    el.find('.collapse').on('click', collapse);
    el.find('.hide').on('click', hide);
  };

  var expand = function() {
    el.addClass('expanded');
  };

  var collapse = function() {
    el.removeClass('expanded');
  };

  var show = function(message) {
    if(message) {
      var alert = $("<div class='alert'>" + message + "</div>")
      el.html(alert);
    }
    el.addClass('shown');
  };

  var hide = function() {
    el.removeClass('shown');
    setTimeout(function() {
      el.html('');
    }, 250);
  };

  var notice = function(inner_html) {
    var html = $("<div class='notice'></div>");
    html.append(inner_html);
    el.html(html);
    show();
    init();
  };

  var alert = function(inner_html) {
    var html = $("<div class='alert'></div>");
    html.append(inner_html);
    el.html(html);
    show();
    init();
  };

  return {
    init: init,
    show: show,
    hide: hide,
    notice: notice,
    alert: alert
  }
}(jQuery, FlashBackground || {}));
