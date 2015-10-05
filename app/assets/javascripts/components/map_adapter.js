var MapAdapter = (function($, m) {
  'use strict';

  var adapters = [];
  var US = {
    latitude: 38.850033,
    longitude: -95.6500523
  };

  function Adapter(opts) {
    var that = this;

    this.o = opts;
    this.markers = [];
    this.map = null;

    this.init = function() {
      this.build_markers();
      this.build_map();
      this.bind_markers();
      this.fit_to_markers();
    };

    this.build_markers = function() {
      this.markers = $.map(this.o.markers, function(m) {
        return that.build_marker(m);
      });
    };

    this.build_marker = function(marker_opts) {
      var o = this.coalesce_marker_opts(marker_opts);
      return new google.maps.Marker(o);
    };

    this.build_map = function() {
      var el = $(this.o.selector)[0];
      var o = this.coalesce_map_opts();
      this.map = new google.maps.Map(el, o);
    };

    this.bind_markers = function() {
      $.each(this.markers, function() {
        this.setMap(that.map);
      });
    }

    this.coalesce_map_opts = function() {
      var bounds = this.get_bounds_for_markers();
      var dimensions = this.get_map_dimensions();
      var defaults = {
        center: new google.maps.LatLng(US.latitude, US.longitude),
        zoom: this.get_bounds_zoom_level(bounds, dimensions)
      };
      return $.extend(defaults, this.o.gmap_opts);
    };

    this.coalesce_marker_opts = function(opts) {
      var defaults = {
        position: new google.maps.LatLng(opts.latitude, opts.longitude)
      };
      var opts = $.extend(defaults, opts);
      if(typeof opts.color !== 'undefined') {
        opts.icon = this.marker_icon(opts.color);
      }
      return opts;
    };

    this.marker_icon = function(hex) {
      return new google.maps.MarkerImage(
        'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=%E2%80%A2|' + hex,
        new google.maps.Size(21, 34),
        new google.maps.Point(0,0),
        new google.maps.Point(10, 34)
      );
    };

    this.get_map_dimensions = function() {
      return {
        height: $(this.o.selector).height(),
        width: $(this.o.selector).width()
      };
    };

    this.get_bounds_zoom_level = function(bounds, dimensions) {
      var world = { height: 256, width: 256 };
      var max = 21;

      function lat_rad(lat) {
        var sin = Math.sin(lat * Math.PI / 180);
        var rad_x2 = Math.log((1 + sin) / (1 - sin)) / 2;
        return Math.max(Math.min(rad_x2, Math.PI), -Math.PI) / 2;
      }

      function zoom(map_px, world_px, fraction) {
        return Math.floor(Math.log(map_px / world_px / fraction) / Math.LN2);
      }

      var ne = bounds.getNorthEast();
      var sw = bounds.getSouthWest();

      var lat_fraction = (lat_rad(ne.lat()) - lat_rad(sw.lat())) / Math.PI;

      var lng_diff = ne.lng() - sw.lng();
      var lng_fraction = ((lng_diff < 0) ? (lng_diff + 360) : lng_diff) / 360;

      var lat_zoom = zoom(dimensions.height, world.height, lat_fraction);
      var lng_zoom = zoom(dimensions.width, world.width, lng_fraction);

      return Math.min(lat_zoom, lng_zoom, max);
    };

    this.get_bounds_for_markers = function() {
      if(this.markers.length === 0) return null;
      var bounds = new google.maps.LatLngBounds();
      $.each(this.markers, function() {
        bounds.extend(this.getPosition());
      });
      return bounds;
    };

    this.fit_to_markers = function() {
      if(this.markers.length === 0) return;
      var bounds = new google.maps.LatLngBounds();
      $.each(this.markers, function() {
        bounds.extend(this.getPosition());
      });
      this.map.fitBounds(bounds);
    };

    this.init();
  }



  var init = function(opts) {
    var adapter = new Adapter(opts);
    adapters.push(adapter);
    return adapter;
  };

  return {
    init: init
  };
}(jQuery, MapAdapter || {}));
