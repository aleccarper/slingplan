var SmallMap = (function($, m) {
  var maps = []

  var init_map = function(selector, locations, show_infoboxes, lock_map, zoom_control, zoom_scroll, center) {
    var m = {}
    m.map_selector = selector;
    m.locations = locations;
    m.show_infoboxes = show_infoboxes;
    m.pins = [];
    m.infowindow = new google.maps.InfoWindow({content: ''});
    m.first_idle = true;
    m.lock_map = lock_map;
    m.center = center;

    m.map = new google.maps.Map(
      $(selector)[0],
      {
        center: new google.maps.LatLng(38.850033, -95.6500523),
        zoom: 5,
        styles: map_styles,
        //panControl: !lock_map,
        zoomControl: zoom_control,
        //draggable: !lock_map,
        scaleControl: zoom_control,
        scrollwheel: zoom_scroll,
        disableDoubleClickZoom: zoom_scroll
      }
    );
    build_map_pins(m);
    zoom_map_to_fit_pins(m);


    google.maps.event.addListener(m.map, 'idle', function(){
      if(m.first_idle || m.lock_map) {
        if(m.pins.length > 0) {
          if(m.map.getZoom() > 8) {
            m.map.setZoom(8);
          }
        }
      }
      m.first_idle = false;
    });


    maps.push(m);
  };

  var build_map_pins = function(map){
    for(var i=0; i<map.locations.length; i++) {
      var loc = map.locations[i];
      var position = new google.maps.LatLng(loc.latitude, loc.longitude);

      if(position) {
        var marker = {}
        marker.location = loc;
        marker.position = position;
        marker.marker = new google.maps.Marker({
          position: position,
          map: map.map,
        });

        if(map.show_infoboxes) {
          google.maps.event.addListener(marker.marker, "click", function (e) {
            marker.location.hide_buttons = true;
            map.infowindow.close();
            map.infowindow.content = HandlebarsTemplates['map/pins/info'](marker.location);
            map.infowindow.open(map.map, marker.marker);
          });
        }
        map.pins.push(marker);
      }
    }

    if(!map.center) return;

    var position = new google.maps.LatLng(map.center.latitude, map.center.longitude);

    if(!position) return;

    var pinImage = new google.maps.MarkerImage(
      "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2|168746",
      new google.maps.Size(21, 34),
      new google.maps.Point(0,0),
      new google.maps.Point(10, 34)
    );

    var marker = {}
    marker.location = map.center;
    marker.position = position;
    marker.marker = new google.maps.Marker({
      position: position,
      map: map.map,
      icon: pinImage
    });

    if(map.center.radius === 'undefined') return;

    map.circle = new google.maps.Circle({
      strokeColor: "#168746",
      strokeOpacity: 0.5,
      strokeWeight: 2,
      fillColor: "#1f904f",
      fillOpacity: 0.2,
      map: map.map,
      center: position,
      radius: map.center.radius * 1609.34
    });
    map.circle.bindTo('center', marker.marker, 'position');

    // google.maps.event.addListener(map.circle, 'radius_changed', function() {
    //   circle.setRadius(map.circle.value);
    // });

    map.pins.push(marker);
  };

  var zoom_map_to_fit_pins = function(obj) {
    if(obj.pins.length > 0) {
      var bounds = new google.maps.LatLngBounds();
      for (var i = 0; i < obj.pins.length; i++) {
        bounds.extend(obj.pins[i].marker.getPosition());
      }
      obj.map.fitBounds(bounds);
    }
  };


  return {
    init_map: init_map,
    maps: maps
  }
}(jQuery, SmallMap || {}));
