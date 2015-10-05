var Admin = (function($, m) {

  var init = function() {
    Slider.init({
      slider_class: '.location-active',
      false_class: 'inactive',
      callback: function(that, bool) {
        // Disable controls to prevent concurrent actions
        that.closest('.location-list-item').find('*').attr('disabled', true);

        var location_id = that.closest('.location-list-item').attr('data-location-id');
        var status = bool ? 'active' : 'disabled';

        $.ajax({
          url: '/admin/locations/update_status',
          data: {
            location_id: location_id,
            status: status
          },
          type: 'POST'
        }).done(function(data) {
          // Re-enable controls
          that.closest('.location-list-item').find('*').attr('disabled', false);
          // Unblock slider events
          Slider.finished();
          // If for some reason setting the location status failed, update
          // the UI with the actual location status
          if(data.location.status !== status) {
            Slider.set_state(that, data.location.status === 'active');
          }
        });
        return false;
      }
    });
  };

  m.Locations = {
    init: init
  };

  return m;
}(jQuery, Admin || {}));
