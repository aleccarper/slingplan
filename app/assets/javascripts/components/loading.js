var Loading = (function(jQuery, m) {

  var init = function() {
    // init is already called on document ready
    // and page:load, so just call it here
    hide('body');

    init_page_change_overlay();
  };

  var show = function(selector, spinner_font_size) {
    var el = $(selector);
    // turbolinks calls page:before-change once for each page
    // that has been navigated to via turbolinks since a full
    // reload, so check to ensure only 1 is added
    if(el.find('.loading-overlay').length !== 0) {
      return;
    }

    el.append(HandlebarsTemplates['common/overlay']());


    var css = get_css_for_spinner(spinner_font_size);
    el.find('.loading-overlay .spinner').css(css);

    // hack to make sure the transition in takes place.  for
    // some reason, without the setTimeout, the loading overlay
    // shows instantly with no transition
    setTimeout(function() {
      el.addClass('loading');
    }, 1);
  };

  var hide = function(selector) {
    var el = $(selector);
    el.removeClass('loading');
    setTimeout(function() {
      el.find('.loading-overlay').remove();
    }, 500)
  };

  var get_css_for_spinner = function(font_size) {
    var wh = font_size * 0.9875;
    return {
      'font-size': font_size + 'px',
      'height': wh + 'px',
      'width': wh + 'px'
    }
  };

  var init_page_change_overlay = function() {
    window.onbeforeunload = function() {
      show('body');
    };
    $(document).on('page:before-change', function() {
      show('body');
    });
  };



  return {
    init: init,
    show: show,
    hide: hide
  }
}(jQuery, Loading || {}));


