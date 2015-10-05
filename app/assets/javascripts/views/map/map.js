var Map = (function($, m) {
  //properties
  m.states_with_locations = [];
  m.pins = {};

  m.locations = []
  m.staffers = []
  m.selected_service = 0;
  m.expanded_service_results = [];
  m.expanded_staffer_results = [];
  m.xhr = [];

  m.mapOptions = {
    center: new google.maps.LatLng(38.850033, -95.6500523),
    zoom: 5,
    styles: map_styles,
    disableDefaultUI: true
  };

  m.infowindow = new google.maps.InfoWindow({
    content: ''
  });

  m.mapClusterOptions = {
    gridSize: 150,
    maxZoom: 8
  };

  m.search_data;
  m.view_state;
  m.responsive_width = 600;


  //init
  var init = function() {
    init_map();
    init_claims();
    init_searching();

    m.view_state = ViewStates.init({
      parent: '.sidebar.left',
      endpoint: '/map/render_view_state',
      states: [
        {
          initial: true,
          name: 'search',
          events: {
            'next': 'results'
          }
        },
        {
          name: 'results',
          events: {
            'back': 'search',
            'next': 'vendor'
          }
        },
        {
          name: 'vendor',
          events: {
            'back': 'results'
          }
        }
      ],
      after_init: function(that) {
        that.get_parent().find('.sidebar-controls .back').on('click', function() {
          that.back();

          clear_locations_results();

          setTimeout(function(){
            $('.sidebar .view-states-wrapper .current').perfectScrollbar();
          }, 100);

        });
      },
      before_back: function(that) {
        if(that.get() === 'results') {
          Map.clear_locations();
        }
      }
    });
  };

  var refresh_service_results = function(initial) {
    if(initial) {
      m.expanded_service_results = [];
      m.expanded_staffing_results = [];
      m.locations = [];
    } else {
      if(m.xhr && m.xhr.readyState != 4) {
        m.xhr.abort();
      }
      m.xhr = null;
    }

    var parent = $('.sidebar.left .results');
    m.xhr = $.ajax({
      method: 'POST',
      url: '/map/service_results',
      data: {
        model: $('#selected_model').val(),
        bounds: get_bounds(),
        service_id: $('#selected_service').val(),
        bookmark_list_id: $('#bookmark_list_id').val(),
        expanded_service_results: m.expanded_service_results,
        expanded_staffer_results: m.expanded_staffer_results
      }
    }).done(function(data) {
      var placeholder = parent.find('.placeholder');
      if(placeholder.length === 0) {
        parent.find('.tree-level.state').remove();
      } else {
        placeholder.remove();
      }
      parent.append(data.view);

      parent.toggleClass('empty', data.view.length === 0);

      m.locations = data.locations;
      m.staffers = data.staffers;

      refresh_map();
    });
  };



  /*
  *
  *********MAP********
  *
  */

  m.state_polys = [];
  m.state_hover_stroke_weight = 1.5;
  m.state_normal_stroke_weight = 1;

  var polygon_mouse_over_state = function(){
    this.setOptions({strokeWeight: m.state_hover_stroke_weight});
  };

  var polygon_mouse_out_state = function(){
    this.setOptions({strokeWeight: m.state_normal_stroke_weight});
  };

  m.selected_state_polygon;
  m.selected_zoom_level;
  var polygon_click = function(){
    m.map.panTo(this.center);
    m.map.fitBounds(this.bounds);
    this.setMap(null);
    var current_poly = this;
    $.each(m.state_polys, function(key, value){
      if(value != current_poly){
        value.setMap(m.map);
      }
    });
    m.selected_zoom_level = m.map.getZoom();
    m.selected_state_polygon = current_poly;
  };

  var on_mouse_enter_location_list_item = function(){
    var pin = m.pins[parseInt($(this).attr('data-location-id'))];
    if(pin) {
      pin.marker.setTitle('currently_selected');
    }

    //var marker_element = get_pin_dom_element_by_title('currently_selected');
    //console.log('on_mouse_enter_location_list_item');
  };

  var on_mouse_leave_location_list_item = function(){
    //console.log('on_mouse_out_location_list_item');
  };

  var refresh_polygons = function(){
    var map_bounds = m.map.getBounds();
    $.each(m.state_polys, function(key, value){
      if(value.bounds.intersects(map_bounds) && m.map.getZoom() > 6) {
        value.setMap(null);
      } else {
        if(value !== m.selected_state_polygon || m.selected_zoom_level > m.map.getZoom()){
          value.setMap(m.map);
        }
      }
    });
  };

  var map_first_loaded = function(){
    $('#map').animate({'opacity' : '1'}, 1500);
  };

  var init_map = function() {
    $('#map').css({'opacity' : '0'});
    m.map = new google.maps.Map(document.getElementById('map'), m.mapOptions);
    google.maps.event.addListener(m.map, 'idle', MapHistory.record);
    google.maps.event.addListener(m.map, 'idle', refresh_polygons);
    google.maps.event.addListenerOnce(m.map, 'idle', map_first_loaded);


    $('body').on('click', '.btn-map-around-me', on_around_me_click);
    $('body').on('mouseenter', '.location-list-item', on_mouse_enter_location_list_item);
    $('body').on('mouseleave', '.location-list-item', on_mouse_leave_location_list_item);

    var request = $.ajax({
      url : '/locations/states_with_locations',
      type : 'GET',
      dataType : 'JSON',
      contentTyp : 'text/plain'
    });

    request.done(function(data){
      m.states_with_locations = data.states;
      build_map_visuals();
    });
  };


  var build_map_visuals = function(){
    $.each(state_outlines_json.states.state, function(key, value) {
      if($.inArray(value.name, m.states_with_locations) != -1) {
        var pts = [];
        var min_lat, min_lng, max_lat, max_lng;
        var latlngbounds = new google.maps.LatLngBounds();
        var set_mins_maxes = true;

        $.each(value.point, function(point_key, point_value){
          var lat = point_value['lat'];
          var lng = point_value['lng'];

          if(set_mins_maxes){
            set_mins_maxes = false;
            min_lat = lat;
            max_lat = lat;
            min_lng = lng;
            max_lng = lng;
          } else {
            min_lat = Math.min(min_lat, lat);
            min_lng = Math.min(min_lng, lng);
            max_lat = Math.max(max_lat, lat);
            max_lng = Math.max(max_lng, lng);
          }

          var latLngObj = new google.maps.LatLng(lat, lng);
          latlngbounds.extend(latLngObj);
          pts.push(latLngObj);
        });

        var poly = new google.maps.Polygon({
          paths: pts,
          strokeColor: '#168746',
          strokeOpacity: 1,
          strokeWeight: m.state_normal_stroke_weight,
          fillColor: '#168746',
          fillOpacity: 0
        });

        poly.center = new google.maps.LatLng(min_lat + ((max_lat - min_lat)/2), min_lng + ((max_lng - min_lng)/2));
        poly.bounds = latlngbounds;

        google.maps.event.addListener(poly,"mouseover", polygon_mouse_over_state);
        google.maps.event.addListener(poly,"mouseout",polygon_mouse_out_state);
        google.maps.event.addListener(poly, 'click', polygon_click);

        m.state_polys.push(poly);
        poly.setMap(m.map);
      }
    });
  };




  var on_around_me_click = function(e) {
    e.preventDefault();

    navigator.geolocation.getCurrentPosition(function(position) {
      var latLng = new google.maps.LatLng(
        position.coords.latitude, position.coords.longitude);
      m.map.panTo(latLng);
      m.map.setZoom(10);
    });

    return false;
  };

  var reset_map = function() {
    m.map.setCenter(m.mapOptions.center);
    m.map.setZoom(m.mapOptions.zoom);
  };

  var on_around_me_button_click = function (e) {
    e.preventDefault();
    move_map_to_my_location();
    return false;
  };

  var get_search_data = function() {
    m.search_data = {
      id: $('#selected_service').val(),
      model: $('#selected_model').val(),
      bookmark_list_id: $('#bookmark_list_id').val(),
      location: $('.tbx-search-by-location').val(),
      bounds: get_bounds()
    };
    return m.search_data;
  };

  var get_previous_search_data = function() {
    return m.search_data;
  };

  var move_map_to_my_location = function() {
    navigator.geolocation.getCurrentPosition(function (position) {
      var latLng = new google.maps.LatLng(
          position.coords.latitude, position.coords.longitude);

      m.map.panTo(latLng);
      m.map.setZoom(10);
    });
  };

  var get_bounds = function() {
    var bounds = m.map.getBounds();
    map_bounds = null;

    if(bounds) {
      var ne = bounds.getNorthEast();
      var sw = bounds.getSouthWest();
      var center = bounds.getCenter();

      map_bounds = {};
      map_bounds.ne_lat = ne.lat();
      map_bounds.ne_lng = ne.lng();

      map_bounds.sw_lat = sw.lat();
      map_bounds.sw_lng = sw.lng();

      map_bounds.center_lat = center.lat();
      map_bounds.center_lng = center.lng();
    }

    return map_bounds;
  };

  var refresh_map = function() {
    var new_ids = {};

    $.each(m.locations, function(key, value) {
      new_ids[value.id] = true;
      if(m.pins[value.id] == null) {
        add_pin(value, 'location');
      }
    });
    $.each(m.staffers, function(key, value) {
      new_ids[value.id] = true;
      if(m.pins[value.id] == null) {
        add_pin(value, 'staffer');
      }
    });

    $.each(m.pins, function(key, value) {
      if(new_ids[key] == null) {
        if(value != null) {
          value.marker.setMap(null);
        }
        m.pins[key] = null;
      }
    });

    clear_locations_results();
  }

  var clear_locations = function(){
    $.each(m.pins, function(key, value){
      if(value != null) {
        value.marker.setMap(null);
      }
      m.pins[value] = null;
    });

    m.pins = [];
  };

  var clear_locations_results = function() {
    $('.results-container').empty();
  }

  var pan_to_pin = function(pin) {
    if(pin) {
      if(m.map.getZoom() < 10 ) {
        m.map.setZoom(10);
      }

      m.map.panTo(pin.marker.position);
      if($(window).width() < 600 && !$('.sidebar.left').hasClass('collapsed')) {
        var x = -$('.map-container').width() / 4;
        m.map.panBy(x, 0);
      }

      m.infowindow.close();
      m.infowindow.setContent(HandlebarsTemplates['map/pins/info'](pin.location));
      m.infowindow.open(m.map, pin.marker);
    }
  }

  var replace_locations_with_pins = function(pins) {
    clear_locations_results();
    for(var i=0; i<pins.length; i++) {
      add_locations_result(pins[i].location);
    }
  }

  //build a google maps marker and add it to m.makers
  var add_pin = function(loc, model) {
    var position = new google.maps.LatLng(loc.latitude, loc.longitude);
    if(position) {
      var pin = {}
      pin.location = loc;
      pin.location.is_staffer = model === 'staffer';
      pin.position = position;
      pin.marker = new google.maps.Marker({
        position: position,
        map: m.map,
      });

      google.maps.event.addListener(pin.marker, "click", function (e) {
        var dragging = false;
        var on_mouseup = function(e) {
          var target = $(e.target);
          if(dragging
          || target.hasClass('gm-style-iw')
          || target.closest('.gm-style-iw').length !== 0) {
            return;
          }
          m.infowindow.close();
          $(document).off('mouseup', '.map-container', on_mouseup);
        };

        google.maps.event.addListener(m.map, 'dragstart', function() {
          dragging = true;
        });

        google.maps.event.addListener(m.map, 'dragend', function() {
          setTimeout(function() {
            dragging = false;
          }, 1);
        });

        $(document).on('mouseup', '.map-container', on_mouseup);

        pan_to_pin(pin);
      });

      m.pins[pin.location.id] = pin;
    }
  };

  var get_pin_dom_element_by_title = function(title){
    for (var marker in m.map.getPanes().overlayImage.getElementsByTagName("div")) {
      if (marker.title == "some_id") return marker;
    }
  }


  /*
  *
  *********CLAIMS********
  *
  */
  var init_claims = function() {
    $('body').on('click', '.map-info-window .btn-claim', on_claim_location);
    $('body').on('click', '.map-info-window .btn-cancel-claim', on_cancel_claim_location);
  };

  var on_claim_location = function(e) {
    var el = $(this);
    $.ajax({
      method: 'POST',
      url: '/claims',
      data: {
        id: el.closest('.map-info-window').data('id')
      }
    })
    .done(function() {
      el.removeClass('btn-claim').addClass('btn-cancel-claim');
      el.val('Cancel Claim');
    });
  }

  var on_cancel_claim_location = function(e) {
    var el = $(this);
    $.ajax({
      method: 'DELETE',
      url: '/claims/' + el.closest('.map-info-window').data('id')
    })
    .done(function() {
      el.removeClass('btn-cancel-claim').addClass('btn-claim');
      el.val('Claim Location');
    });
  }



  /*
  *
  *********SEARCHING********
  *
  */
  var init_searching = function() {
    google.maps.event.addListener(m.map, 'idle', on_map_idle);

    $(document).on('click', '.service-list li', on_service_list_item_click)
    $(document).on('click', '.location-list-item .find-location', on_find_location_click);

    $(document).on('click', '.sidebar.left .expand', function() {
      if($(window).width() <= m.responsive_width) {
        $('.sidebar.right .sidebar-controls').fadeOut(200);
        $('.sidebar.right').addClass('collapsed');
      }
      $(this).closest('.sidebar').removeClass('collapsed');
    });
    $(document).on('click', '.sidebar.left .collapse', function() {
      if($(window).width() <= m.responsive_width) {
        $('.sidebar.right .sidebar-controls').fadeIn(200);
      }
      $(this).closest('.sidebar').addClass('collapsed');
    });
    $(document).on('click', '.sidebar.right .expand', function() {
      if($(window).width() <= m.responsive_width) {
        $('.sidebar.left .sidebar-controls').fadeOut(200);
        $('.sidebar.left').addClass('collapsed');
      }
      $(this).closest('.sidebar').removeClass('collapsed');
    });
    $(document).on('click', '.sidebar.right .collapse', function() {
      if($(window).width() <= m.responsive_width) {
        $('.sidebar.left .sidebar-controls').fadeIn(200);
      }
      $(this).closest('.sidebar').addClass('collapsed');
    });

    $(window).resize(function() {
      $('.sidebar').addClass('collapsed');
      if($(window).width() <= m.responsive_width) {
        $('.sidebar .sidebar-controls').fadeIn(200);
      }
    });

    Tree.expand_collapse_callback(expand_collapse_callback);
  };

  var on_map_idle = function() {
    if(m.view_state.get() == 'search') {
      get_available_services();
    } else if(m.view_state.get() == 'results') {
      m.search_data.bounds = get_bounds();
      refresh_service_results(false);
    }
  };

  var expand_collapse_callback = function(el) {
    var model = $('#selected_model').val();
    var element = $(el);
    var expanded = !element.hasClass('tree-collapsed');
    var key = element.data('key');
    if(model === 'service') {
      if(expanded) {
        if(m.expanded_service_results.indexOf(key) === -1) {
          m.expanded_service_results.push(key);
        }
      } else {
        m.expanded_service_results = jQuery.grep(m.expanded_service_results, function(value) {
          return value != key;
        });
      }
    } else if(model === 'staffer') {
      if(expanded) {
        if(m.expanded_staffer_results.indexOf(key) === -1) {
          m.expanded_staffer_results.push(key);
        }
      } else {
        m.expanded_staffer_results = jQuery.grep(m.expanded_staffer_results, function(value) {
          return value != key;
        });
      }
    }
  };

  var on_service_list_item_click = function(e) {
    if($(this).hasClass('service')) {
      $('#selected_model').val('service');
      $('#selected_service').val($(this).data('service-id'));
    } else if($(this).hasClass('staffer')) {
      $('#selected_model').val('staffer');
      $('#selected_service').val(null);
    }

    m.view_state.consume('next', get_search_data(), function(data) {
      var placeholders = $('.sidebar.left .tree-level.service .placeholder');
      Loading.show(placeholders, 80);

      refresh_service_results(true);
      $('.sidebar .view-states-wrapper .current').perfectScrollbar();

      m.expanded_service_results = [];
      m.expanded_staffer_results = [];
      setTimeout(function() {
        $.each($('.tree-level-0'), function(i, el) {
          var key = $(el).data('key')
          if(!$(el).hasClass('tree-collapsed')) {
            if($('#selected_model').val() === 'service') {
              m.expanded_service_results.push(key);
            } else {
              m.expanded_staffer_results.push(key);
            }
          }
        });
      }, 1000);
    });
  };

  var on_find_location_click = function(e) {
    e.stopPropagation();
    var key = null;
    if($('#selected_model').val() === 'service') {
      key = 'location-id';
    } else {
      key = 'staffer-id';
    }
    var id = parseInt($(this).closest('.location-list-item').data(key));
    pan_to_pin(m.pins[id]);
  };

  var get_available_services = function() {
    map_bounds = get_bounds();
    if(map_bounds === null) {
      return;
    }
    $.get('/locations/available_services', {
      location: $('.tbx-search-by-location').val(),
      bounds: map_bounds
    }, function(data) {
      m.states_with_locations = data.states;

      $('.service-list').html(HandlebarsTemplates['map/service_list/service']({
        all: data.all,
        visible: data.visible,
        selected: m.selected_services || [],
        any_staffers: data.any_staffers
      }));
      $('.service').trigger('mouseenter');
    });
  };



  //declare what is public

  return $.extend(true, m, {
    init: init,
    get_available_services: get_available_services,
    refresh_map: refresh_map,
    get_previous_search_data: get_previous_search_data,
    reset_map: reset_map,
    clear_locations: clear_locations
  });
}(jQuery, Map || {}));
