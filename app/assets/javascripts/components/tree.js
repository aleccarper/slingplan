var Tree = (function($, m) {

  var callback = null;

  var init = function() {
    $('body').off().on('click', '.tree-header', level_click);
  };

  var level_click = function(e) {
    var el = $(this).closest('.tree-level');
    if(el.hasClass('tree-collapsed')) {
      el.removeClass('tree-collapsed');
    } else {
      el.addClass('tree-collapsed');
    }

    if(callback !== null) {
      callback(el);
    }

    e.stopPropagation();
  };

  var expand_collapse_callback = function(func) {
    callback = func;
  };

  return {
    init: init,
    expand_collapse_callback: expand_collapse_callback
  }
}(jQuery, Tree || {}));
