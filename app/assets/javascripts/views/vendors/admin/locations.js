var Vendors = (function($, m) {

  var max_active_allowed;
  var map_load_attempts = 0;

  var init = function() {
    max_active_allowed = $('#max_active_allowed').val();

    update_location_totals();

    $("#location_phone_number").mask("(999) 999-9999");

    Slider.init({
      slider_class: '.location-active',
      false_class: 'inactive',
      ensure: function(that) {
        if(that.hasClass('inactive')) {
          if(max_active_allowed === 'Unlimited') {
            return true;
          } else {
            return $('.tab-content .inner > .locations.max-allowed').length == 0;
          }
        } else {
          return true;
        }
      },
      callback: function(that, bool) {
        var parent = that.closest('.location-list-item');

        $('.location-list-item').find('*').attr('disabled', true);

        Loading.show('.tab-content');

        var location_id = that.closest('.location-list-item').attr('data-location-id');
        var status = bool ? 'active' : 'disabled';

        $.ajax({
          url: '/vendors/admin/locations/update_status',
          data: {
            location_id: location_id,
            status: status
          },
          type: 'POST'
        }).done(function(data) {
          // Re-enable controls
          parent.find('*').attr('disabled', false);
          // Unblock slider events
          Slider.finished();

          // If for some reason setting the location status failed, update
          // the UI with the actual location status
          if(data.location.status !== status) {
            Slider.set_state(that, data.location.status === 'active');
          } else {
            update_location_totals(data);
            parent.toggleClass('active', data.location.status === 'active');
          }

          if($('.slider:not(.inactive)').length >= max_active_allowed) {
            $('.tab-content .inner > .locations').addClass('max-allowed');
          } else {
            $('.tab-content .inner > .locations').removeClass('max-allowed');
          }
          Loading.hide('.tab-content');
        });
        return false;
      }
    });

    $(document).on('submit', '.vendors-admin-locations .new form', function(e) {
      if($('#js-field-service_ids input[type=checkbox]:checked').length === 0) {
        $('#js-field-service_ids input[type=checkbox]').change();
        return false;
      }
    });


    var path = window.location.pathname;


    if(path.indexOf('/edit/') !== -1) {
      init_edit_crumbs();
    } else {
      init_manage_crumbs();
    }

    $('#location_country_code').closest('.field').addClass('valid');

    $('.location-services').submit(function(e) {
      if($('input[type=checkbox]:checked').length === 0) {
        $('.errors').html('You must choose services to continue.').show();

        $('body').animate({
          scrollTop: 0
        }, 250);

        e.preventDefault();
        return false;
      }
    });

    $(document).on('change', '#js-field-service_ids input[type=checkbox]', function() {
      if($('#js-field-service_ids input[type=checkbox]:checked').length === 0) {
        var error = '<li>... must have at least 1 service</li>';
        $('#js-field-service_ids')
          .removeClass('valid')
          .addClass('error')
          .find('.errorlist')
          .html(error);
      } else {
        $('#js-field-service_ids')
          .removeClass('error')
          .addClass('valid')
          .find('.errorlist')
          .html('');
      }
    });

    $(document).on('click', '.claim-location', function(e) {
      e.preventDefault();

      var created_id = $('#id').val();
      var claimed_id = $(this).closest('.location-list-item').data('location-id');

      if(window.confirm('Are you sure you want to claim this location rather than creating a new one?  This location will be destroyed in lieu of the claim.')) {
        Loading.show('body');
        $.ajax({
          type: 'POST',
          url: '/vendors/admin/locations/claim',
          data: {
            created_id: created_id,
            claimed_id: claimed_id
          }
        }).done(function(data) {
          if(data.success) {
            var path = '/vendors/admin/locations/claimed'
            window.location.replace(path);
          } else {
            // TODO: https://github.com/CriticalMech/slingplan/issues/611
          }
        });
      }
      return false;
    });

    $(document).on('click input change propertychange', [
      '.tab-content form input',
      '.tab-content form textarea',
      '.tab-content form select:not(#service_rfps)'
    ].join(', '), function() {
      $(this).addClass('dirty');
    });

    var path = window.location.pathname;
    if(path.indexOf('edit/finalize') > -1) {
      init_small_map();
    }
  };

  var init_edit_crumbs = function() {
    $('.location-edit-crumbs .step-' + $('#crumbs_step').val()).addClass('current');
    $('.location-edit-crumbs a.step').on('click', function(e) {
      e.preventDefault();
      e.stopPropagation();
      var path = $(this).attr('href');

      var submit_changes = function() {
        $('.tab-content form')
          .append("<input id='next_page' name='next_page' type='hidden' value='" + path + "' />")
          .submit();
      };

      // user clicked service-rfps crumb
      if($(this).hasClass('step-finalize')) {
        // on services page
        if($('.crumbs .step.current').hasClass('step-services')) {
          // no services checked in ui
          if($('.service-selection input[type=checkbox]:checked').length === 0) {
            return alert('You must first select some services to finalize your location.');
          }
        } else {
          // no services checked in db
          if(current_location_services.length === 0) {
            return alert('You must first select some services to finalize your location.');
          }
        }
      }

      if(form_changed()) {
        if(confirm('You have unsaved changes.  Save before changing pages?')) {
          return submit_changes();
        }
      }

      window.location.replace(path);
      return false;
    });
  };

  var init_manage_crumbs = function() {
    $('.location-crumbs .step-' + $('#crumbs_step').val()).addClass('current');
    $('.location-crumbs a.step').on('click', function(e) {
      e.preventDefault();
      e.stopPropagation();
      window.location.replace($(this).attr('href'));
      return false;
    });
  };

  var init_small_map = function() {
    var attempt_interval = null;
    var lat = $('[name=lat]').val();
    var lng = $('[name=lng]').val();

    var attempt_map_load = function() {
      try {
        m.map = new google.maps.Map($('.map')[0], {
          center: new google.maps.LatLng(lat, lng),
          zoom: 16,
          scrollwheel: false,
          styles: map_styles
        });

        google.maps.event.addListener(m.map, 'idle', function() {
          setTimeout(function() {
            var loc = new google.maps.LatLng(lat, lng);
            if(loc) {
              var marker = {}
              marker.location = loc;
              marker.marker = new google.maps.Marker({
                position: loc,
                map: m.map,
              });
            }

            Loading.hide('body');
          }, 250);
          clearInterval(attempt_interval);
          google.maps.event.clearListeners(m.map, 'idle');
        });
      } catch(e) {
        if(m.map_load_attempts++ >= 5) {
          return clearInterval(attempt_interval);
        }
      }
    };

    // try once per second to load the map.  try five times.
    // google is awesome at providing reliable 'loaded' events.  /s
    attempt_interval = setInterval(attempt_map_load, 1000);
  };

  var form_changed = function() {
    return $('.tab-content form .dirty').length > 0;
  };

  var update_location_totals = function(data) {
    var used = $('.used');
    var percentage;
    if(data) {
      percentage = data.percentage;
      $('.current-max').html(data.current + '/' + data.max);
      set_location_totals_bar_width(used, percentage);
    } else {
      percentage = used.data('percentage');
      setTimeout(function() {
        set_location_totals_bar_width(used, percentage);
      }, 1000);
    }
  };

  var set_location_totals_bar_width = function(el, percentage) {
    el.css('right', (100 - percentage) + '%');
  };

  m.Admin.Locations = {
    init: init,
    init_manage_crumbs: init_manage_crumbs
  };

  return m;
}(jQuery, Vendors || {}));
