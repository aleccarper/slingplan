var MapHistory = (function(jQuery, m) {

  var history = [];
  var history_index = -1;
  var skip_history_record = true;

  var init = function() {
    $('body').on('click', '.btn-map-back', on_map_back_button_click);
    $('body').on('click', '.btn-map-forward', on_map_forward_click);
    $('body').on('click', '.btn-map-home', on_map_home_button_click);

    hide_back_button();
    hide_forward_button();
    hide_reset_button();
  };

  var record = function() {
    if(!skip_history_record) {
      history.splice(history_index, history.length - 1);

      var current = {};
      current.center = Map.map.getCenter();
      current.zoom = Map.map.getZoom();
      current.mapTypeId = Map.map.getMapTypeId();
      history.push(current);
      history_index = history.length - 1;

      hide_forward_button();
      if(history_index > -1) {
        show_back_button();
        show_reset_button();
      }
    }

    skip_history_record = false;
  };

  var back = function() {
    history_index--;
    skip_history_record = true;
    if(history_index <= -1) {
      hide_back_button();
      hide_reset_button();
      Map.reset_map();
    } else {
      Map.map.setOptions(history[history_index]);
    }
    show_forward_button();
  };

  var forward = function() {
    history_index++;
    skip_history_record = true;
    if(history_index == history.length) {
      hide_forward_button();
    }
    show_back_button();
    show_reset_button();
    Map.map.setOptions(history[history_index]);
  };

  var hide_forward_button = function() {
    $('.map-forward').addClass('disabled');
  };

  var show_forward_button = function() {
    $('.map-forward').removeClass('disabled');
  };

  var hide_back_button = function() {
    $('.map-back').addClass('disabled');
  };

  var show_back_button = function() {
    $('.map-back').removeClass('disabled');
  };

  var hide_reset_button = function() {
    $('.map-home').addClass('disabled');
  };

  var show_reset_button = function() {
    $('.map-home').removeClass('disabled');
  };

  var on_map_back_button_click = function(e) {
    e.preventDefault();
    back();
    return false;
  };

  var on_map_forward_click = function(e) {
    e.preventDefault();
    forward();
    return false;
  };

  var on_map_home_button_click = function(e) {
    e.preventDefault();
    Map.reset_map();
    clear();
    return false;
  };

  var clear = function() {
    skip_history_record = true;
    history = [];
    history_index = -1;
    hide_back_button();
    hide_forward_button();
    hide_reset_button();
  };

  return {
    init: init,
    record: record
  }
}(jQuery, MapHistory || {}));


