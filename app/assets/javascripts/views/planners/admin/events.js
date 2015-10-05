var Planners = (function($, m) {

  var max_active_allowed;

  var datepicker;
  var start_date = null;
  var end_date = null;
  var new_confirm_submitted = false;

  var init = function() {
    max_active_allowed = $('#max_active_allowed').val();
    update_event_totals();

    $('.btn-clone').on('click', function(e) {
      e.preventDefault();
      var path = $(this).attr('href');
      if(confirm('Note this will clone all pre-negotiation event information BUT the start and end date.  Continue?')) {
        return window.location.replace(path);
      }
      return false;
    });

    $(document).on('click', '.hide-vendor', function(e) {
      e.preventDefault();

      if(confirm('This Vendor will permanently be hidden for this event.')) {
        var service_rfp = $(this).closest('.service-rfp');
        var service_rfp_id = service_rfp.data('id');
        var vendor_rfp = $(this).closest('.vendor-rfp');
        var vendor_rfp_id = vendor_rfp.data('id');

        var url = '/planners/admin/events/' + service_rfp_id + '/' + vendor_rfp_id;

        Loading.show(vendor_rfp, 80);

        $.ajax({
          url: url,
          method: 'DELETE'
        }).done(function(data) {
          // the vendor rfps for this service rfp
          if(data.vendor_rfp_ids.indexOf(vendor_rfp_id) !== -1) return;

          vendor_rfp.animate({
            height: 0
          }, 200, function() {
            vendor_rfp.remove();
          });
        });
      }

      return false;
    });

    init_crumbs();
    $('.event-crumbs a.step').on('click', function(e) {
      e.preventDefault();
      e.stopPropagation();
      var path = $(this).attr('href');

      var submit_changes = function() {
        $('.tab-content form')
          .append("<input id='next_page' name='next_page' type='hidden' value='" + path + "' />")
          .submit();
      };

      // user clicked service-rfps crumb
      if($(this).hasClass('step-service-rfps')) {
        // on services page
        if($('.crumbs .step.current').hasClass('step-services')) {
          // no services checked in ui
          if($('.service-selection input[type=checkbox]:checked').length === 0) {
            return alert('You must first select some services to continue to the Service RFPs page.');
          }
        } else {
          // no services checked in db
          if(current_event_services.length === 0) {
            return alert('You must first select some services to continue to the Service RFPs page.');
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


    $('#event_country_code').closest('.field').addClass('valid');

    $('.event-services').submit(function(e) {
      if($('.in-area input[type=checkbox]:checked').length === 0
      && $('input[type=submit][clicked=true]').attr('name') !== 'back') {
        $('.in-area .errors').html('You must choose services to continue.').show();

        $('body').animate({
          scrollTop: 0
        }, 250);

        e.preventDefault();
        return false;
      }
    });

    $('.btn-submit-service-request').on('click', function(e) {
      e.preventDefault();

      var checked = $('.service-selection .out-of-range input[type=checkbox]:checked');
      var service_ids = $.map(checked, function(el) { return $(el).val(); });

      if(service_ids.length === 0) {
        return alert('You must first select some services to submit a Service Request.');
      }
      var data = {
        event_id: $('#id').val(),
        is_service_request: true,
        service_ids: service_ids
      };
      $.ajax({
        type: 'POST',
        url: $(this).attr('href'),
        data: data
      }).done(function() {
        $('.out-of-range').addClass('submitted');
      });
      return false;
    });

    $(document).on('click input change propertychange', [
      '.tab-content form input',
      '.tab-content form textarea',
      '.tab-content form select:not(#service_rfps)'
    ].join(', '), function() {
      $(this).addClass('dirty');
    });

    $(document).on('change', '#service_rfps', function() {
      var event_id = $('#id').val();
      var service_rfp_id = $(this).closest('select').val();
      var path = '/planners/admin/events/' + event_id + '/edit/service_rfp/' + service_rfp_id;
      if(form_changed()) {
        if(confirm('You have unsaved changes.  Save before changing to a different Service RFP?')) {
          return $('form.new-service-rfp')
            .append("<input id='next_page' name='next_page' type='hidden' value='" + path + "' />")
            .submit();
        }
      }
      window.location.replace(path);
    });

    $(document).on('change', '#show_service_rfps', function() {
      var event_id = $('#id').val();
      var service_rfp_id = $(this).closest('select').val();
      var path = '/planners/admin/events/' + event_id + '/service_rfp/' + service_rfp_id;
      window.location.replace(path);
    });

    $('.btn-make-outside-arrangements').on('click', function(e) {
      e.preventDefault();

      var prompt = 'Careful!\n\nBy making outside arrangements, all Vendors who received RFPs';
      prompt += ' for this service will be notified, and any approved bids will be revoked.\n\n';
      prompt += 'Are you sure you want to make outside arrangements?  Cancel to abort.';

      if(confirm(prompt)) {
        var form = $(this).closest('form');
        var event_id = $('#id').val();
        var service_rfp_id = form.find('.service-rfp').data('id');
        var url = '/planners/admin/events/' + event_id + '/edit/service_rfp/' + service_rfp_id + '/make_outside_arrangements';

        Loading.show(form, 160);

        $.ajax({
          url: url,
          method: 'POST'
        }).done(function(data) {
          Loading.hide(form);
          if(data.success) {
            form.addClass('outside-arrangements-made');
          }
        });
      }

      return false;
    });

    $('.btn-cancel-outside-arrangements').on('click', function(e) {
      e.preventDefault();

      var prompt = 'Careful!\n\nBy cancelling outside arrangements, all Vendors who initially received RFPs';
      prompt += ' for this service will be notified, but you will have to re-approve any bids that were previously approved for the service.\n\n';
      prompt += 'Are you sure you want to cancel outside arrangements and reopen the negotiations?  Cancel to abort.';

      if(confirm(prompt)) {
        var form = $(this).closest('form');
        var event_id = $('#id').val();
        var service_rfp_id = form.find('.service-rfp').data('id');
        var url = '/planners/admin/events/' + event_id + '/edit/service_rfp/' + service_rfp_id + '/cancel_outside_arrangements';

        Loading.show(form, 160);

        $.ajax({
          url: url,
          method: 'POST'
        }).done(function(data) {
          Loading.hide(form);
          if(data.success) {
            form.removeClass('outside-arrangements-made');
          }
        });
      }

      return false;
    });

    var path = window.location.pathname;
    if(path.indexOf('edit/date') > -1) {
      init_datepickers();
    } else if (path.indexOf('edit/service_rfp') > -1) {
      init_edit_service_rfp();
    }
  };

  var init_crumbs = function() {
    $('.event-crumbs .step-' + $('#crumbs_step').val()).addClass('current');
  };

  var form_changed = function() {
    return $('.tab-content form .dirty').length > 0;
  };


  var init_edit_service_rfp = function() {
    // window.onbeforeunload = function() {
    //   return "You haven't yet confirmed this event.  Are you sure you want to navigate away from this page?  If so, you can find and complete your event later at the top of your Events page.";
    // };

    $(document).on('click', '.hide-location', function(e) {
      e.preventDefault();

      if(confirm('This Location will permanently be hidden for this service within this event.')) {
        var service_rfp_id = $(this).closest('.new-service-rfp').find('#service_rfp_id').val();
        var location = $(this).closest('.location-list-item');
        var location_id = location.data('location-id');

        Loading.show(location, 80);

        $.ajax({
          url: '/planners/admin/events/hide_location_from_service_rfp',
          method: 'POST',
          data: {
            service_rfp_id: service_rfp_id,
            location_id: location_id
          }
        }).done(function(data) {
          if(!data.hidden_location_id === location_id) {
            return;
          }
          Loading.hide(location, 80);
          location.addClass('hidden');
        });
      }

      return false;
    });

    $(document).on('click', '.undo-hide-location', function(e) {
      e.preventDefault();

      var service_rfp_id = $(this).closest('.new-service-rfp').find('#service_rfp_id').val();
      var location = $(this).closest('.location-list-item');
      var location_id = location.data('location-id');

      Loading.show(location, 80);

      $.ajax({
        url: '/planners/admin/events/undo_hide_location_from_service_rfp',
        method: 'POST',
        data: {
          service_rfp_id: service_rfp_id,
          location_id: location_id
        }
      }).done(function(data) {
        if(!data.hidden_location_id === location_id) {
          return;
        }
        Loading.hide(location);
        location.removeClass('hidden');
      });

      return false;
    });

    $('input[type=number]').numeric({
      negative: false,
      decimal: false
    });

    Validation.init();
    init_eligibility_sliders();
  };

  var init_eligibility_sliders = function() {
    var current_radius = $('#service_rfp_radius').val() || null;

    var locations_in_radius = function() {
      if($('#service_rfp_radius').val().trim().length === 0) {
        $('#service_rfp_locations').html('');
        return;
      }
      Loading.show('#service_rfp_locations');
      $.ajax({
        type: 'POST',
        url: '/planners/admin/events/page_service_rfp_locations',
        data: {
          event_id: $('#id').val(),
          service_rfp_id: $('#service_rfp_id').val(),
          mile_radius: $('#service_rfp_radius').val(),
          page: 0
        }
      }).done(function(data) {
        $('#page_service_rfp_locations').html(data.view);
        Loading.hide('#service_rfp_locations');
      });
    };
    var debounced_locations_in_radius = _.debounce(locations_in_radius, 500);

    // http://skidding.github.io/dragdealer/
    var d = $('#eligibility-radius');
    new Dragdealer(d.attr('id'), {
      x: current_radius === null ? 0.5 : (current_radius / 100) * 0.5,
      steps: 21,
      snap: true,
      horizontal: true,
      right: 9,
      left: 7,
      animationCallback: function(x, y) {
        var miles = Math.round(x * 200);
        var html = miles + ' miles'
        d.find('.value').html(html);
        // update circle on google maps
        var parent_form = $(this.handle).closest('form');
        var map_selector = parent_form.find('.map').first().attr('id');
        var m = jQuery.grep(SmallMap.maps, function(map, i) {
          return $(map.map_selector).attr('id') === map_selector;
        })[0];
        m.circle.setRadius(miles * 1609.34);
        d.closest('form').find('#service_rfp_radius').val(miles);
        debounced_locations_in_radius();
      },
      callback: function(x, y) {
      },
      dragStartCallback: function(x, y) {
        // hide tooltip when user clicks the slider
        ToolTips.hide($(this.wrapper).find('.tip')[0]);
      },
      dragStopCallback: function(x, y) {
        // show tooltip when user releases the slider
        ToolTips.show($(this.wrapper).find('.tip')[0]);
      }
    });
  };

  var init_datepickers = function() {
    var start = $('#js_start_date').val()
    var end = $('#js_end_date').val()
    if(start) start_date = new Date(start).getTime();
    if(end) end_date = new Date(end).getTime();
    // default datepicker opts
    var datepicker_opts = {
      showOtherMonths: true,
      dayNamesMin: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'],
      prevText: '',
      nextText: '',
      dateFormat: 'mm/dd/yy'
    };

    datepicker = DatePicker.init('.date', $.extend(datepicker_opts, {
      onSelect: function(selected_date) {
        var date = new Date(selected_date).getTime();
        if(start_date === null && end_date === null) {
          set_start_date(date);
        } else if(end_date === null && start_date !== null) {
          if(start_date < date) {
            set_end_date(date);
          }
          if(start_date > date) {
            set_end_date(start_date);
            set_start_date(date);
          }
        } else {
          set_end_date(null);
          set_start_date(date);
        }

        style_datepicker();
      },
      onChangeMonthYear: function() {
        style_datepicker();
      }
    }));

    style_datepicker();
  };

  var style_datepicker = function() {
    setTimeout(function() {
      var today_date = DatePicker.get_today_date().getTime();
      clear_datepicker_classes(datepicker);
      $.each(datepicker.parent.find('td'), function(i, c) {
        var cell = $(c);
        var cell_date = DatePicker.get_datepicker_cell_date(cell);

        if(typeof cell_date !== 'undefined') {
          cell_date = cell_date.getTime();
        }
        if(cell_date < today_date) {
          cell.addClass('before-today');
        }
        if(cell_date == today_date) {
          cell.addClass('today');
        }
        if(cell_date > today_date) {
          cell.addClass('after-today');
        }
        if(cell_date === start_date) {
          cell.addClass('event start');
        }
        if(end_date !== null) {
          if(cell_date > start_date && cell_date < end_date) {
            cell.addClass('event');
          }
          if(cell_date == end_date) {
            cell.addClass('event end');
          }
          if(cell_date > end_date) {
            cell.addClass('after-event');
          }
        }
      });

      // go to next month if last day of month
      if($('.ui-datepicker-calendar .after-today').length === 0) {
        $('.ui-datepicker-next').trigger('click');
      }
    }, 1);
  };

  var set_start_date = function(date) {
    start_date = date;
    $('#event_start_date').val(format_date(date)).trigger('input');
  };

  var set_end_date = function(date) {
    if(!date) {
      end_date = null;
    } else {
      end_date = date;
    }
    $('#event_end_date').val(format_date(date)).trigger('input');
  };

  var format_date = function(epoch) {
    if(epoch === null) return null;
    return moment(epoch).format('l');
  };

  var clear_datepicker_classes = function(datepicker) {
    datepicker.parent.find('td').removeClass(
      'before-today today after-today before-event event start end'
    );
  };

  var update_event_totals = function(data) {
    var used = $('.used');
    var percentage;
    if(data) {
      percentage = data.percentage;
      $('.current-max').html(data.current + '/' + data.max);
      set_event_totals_bar_width(used, percentage);
    } else {
      percentage = used.data('percentage');
      setTimeout(function() {
        set_event_totals_bar_width(used, percentage);
      }, 1000);
    }
  };

  var set_event_totals_bar_width = function(el, percentage) {
    el.css('right', (100 - percentage) + '%');
  };

  m.Admin.Events = {
    init: init,
    init_crumbs: init_crumbs
  };

  return m;
}(jQuery, Planners || {}));
