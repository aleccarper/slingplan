var Slider = (function($, m) {

  var working = false;

  var init = function(opts) {
    m.slider_class = opts.slider_class;
    m.callback = opts.callback;
    m.ensure = opts.ensure;
    m.false_class = opts.false_class;

    $(document).on('mousedown', m.slider_class, on_click);
  };

  var on_click = function(e) {
    var that = $(this);

    if(typeof m.ensure !== 'undefined') {
      if(!m.ensure(that)) return;
    }

    // ensure left mouse
    if(e.which !== 1) return;

    working = true;

    // toggle the slider false_class
    if(that.hasClass(m.false_class)) {
      that.removeClass(m.false_class);
    } else {
      that.addClass(m.false_class);
    }
    // ensure callback was passed and call it.  When logic completes,
    // the callback should call finished() to open Slider up for new calls
    if(typeof m.callback !== 'undefined') {
      m.callback(that, !that.hasClass(m.false_class));
    }
  };

  // manually set slider state
  var set_state = function(that, bool) {
    if(bool) {
      that.removeClass(m.false_class);
    } else {
      that.addClass(m.false_class);
    }
  };

  // Unblock Slider events
  var finished = function() {
    working = false;
  };

  return {
    init: init,
    set_state: set_state,
    finished: finished
  };
}(jQuery, Slider || {}));
