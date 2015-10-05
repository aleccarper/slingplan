var MapBookmarks = (function($, m) {

  var view_state;
  var first_time_sidebar_opened = false;

  var init = function() {
    init_view_state();

    $(document).on('change', '#bookmark_list_id', on_bookmark_list_change);
    $(document).on('click', '.add-bookmark', add_bookmark_from_results);
    $(document).on('click', '.add-bookmark-from-infowindow', add_bookmark_from_infowindow);
    $(document).on('click', '.btn-back-to-bookmarks', on_back_to_bookmarks_click);
    $(document).on('click', '.btn-back-to-export', on_back_to_export_click);
    $(document).on('click', '.btn-delete-bookmark-list', on_delete_bookmark_list_click);
    $(document).on('click', '.btn-print-friendly', on_print_friendly_click);
    $(document).on('click', '.remove-bookmark', remove_bookmark);
    $(document).on('click', '.sidebar.right .btn-csv', on_csv_click);
    $(document).on('click', '.sidebar.right .btn-email', on_email_click);
    $(document).on('click', '.sidebar.right .btn-export', on_export_click);
    $(document).on('click', '.sidebar.right .btn-xls', on_xls_click);
    $(document).on('submit', '#new_bookmark_list', on_new_bookmark_list_submit);
    $(document).on('submit', '.export-email form', on_export_email_click);

    if(get_current_bookmark_list_id() != '') {
      on_bookmark_list_change();
    }
    $('.sidebar .view-states-wrapper .current').perfectScrollbar();
  };

  var init_view_state = function() {
    view_state = ViewStates.init({
      parent: '.sidebar.right',
      endpoint: '/map/render_view_state',
      states: [
        {
          initial: true,
          name: 'bookmarks',
          events: {
            'next': 'export'
          }
        },
        {
          name: 'export',
          events: {
            'back': 'bookmarks',
            'next': 'email'
          }
        },
        {
          name: 'email',
          events: {
            'back': 'export',
            'next': 'email_success'
          }
        },
        {
          name: 'email_success',
          events: {
            'back': 'bookmarks'
          }
        }
      ],
      after_init: function() {
        update_sidebar_for_bookmark_presence(true);
      }
    });
  };

  var add_bookmark_from_infowindow = function(){
    var id = $(this).closest('.map-info-window').attr('data-id');
    add_bookmark(id);
  };

  var add_bookmark_from_results = function(){
    var id = $(this).closest('.location-list-item').data('location-id');
    add_bookmark(id);
  };

  var add_bookmark = function(loc_id) {
    var location_id = loc_id;
    if(!location_id || location_id == 0 || location_id == '0') { return; }

    location_id = parseInt(loc_id);
    var bookmark_list_id = get_current_bookmark_list_id();
    var location_element = $('.left .results').find('[data-location-id="'+location_id+'"]').first();
    var bookmark_list = $('.bookmarks-list');
    var bookmark = location_element.clone();

    if(bookmark_list.find('[data-location-id="'+location_id+'"]').length > 0) {
      return alert('This location has already been bookmarked');
    };

    Loading.show(location_element, 75);
    Loading.show(bookmark, 75);

    $.ajax({
      method: 'PUT',
      url: get_url_for_add_remove_bookmark(location_id)
    })
    .done(function(data) {
      // ensure it got added to session/list
      Loading.hide(location_element);
      Loading.hide(bookmark);

      if(data.bookmarks.indexOf(location_id) === -1) {
        return alert('There was a problem bookmarking this location.');
      }
      // offset the bookmark to the left of the pane
      bookmark.css(add_bookmark_before_slide_in_css());

      bookmark.insertAfter(bookmark_list.children('*:visible:not(.location-list-item)').last())

      // animate the bookmark in
      bookmark.animate(add_bookmark_slide_in_css(location_element), 500, function() {
        bookmark.animate({'left' : '0%'}, 250, function() {
          // hide bookmark button for location list item in left and right sidebar
          location_element.addClass('bookmarked');
          bookmark.addClass('for_bookmarks bookmarked');

          update_sidebar_for_bookmark_presence(false);
        });
      });

      if($(window).width() > 540) {
        expand_sidebar_unless_previously_opened();
      } else {
        FlashBackground.notice("Bookmark added successfully.");
      }
    });
  };

  var remove_bookmark = function() {
    var bookmark_list_id = get_current_bookmark_list_id();

    var location_element = $(this).closest('.location-list-item');
    var location_id = location_element.data('location-id');
    var bookmark = get_location_list_item_within($('.bookmarks-list'), location_id);
    var result = get_location_list_item_within($('.results'), location_id);

    Loading.show(result, 75);
    Loading.show(bookmark, 75);

    $.ajax({
      method: 'DELETE',
      url: get_url_for_add_remove_bookmark(location_id)
    })
    .done(function(data) {
      // ensure it got removed from session/list
      if(data.bookmarks.indexOf(location_id) !== -1) {
        return alert('There was a problem removing the bookmark for this location.');
      }

      bookmark.animate({'left': '300%'}, function() {
        setTimeout(function() {
          bookmark.animate(remove_bookmark_slide_out_css(), function() {
            setTimeout(function() {
              bookmark.remove();
              // show bookmark button for location list item in left sidebar
              result.removeClass('bookmarked');

              Loading.hide(bookmark);
              Loading.hide(result);

              update_sidebar_for_bookmark_presence(false);
            }, 250);
          });
        }, 250);
      });
    });
  };

  var on_bookmark_list_change = function(e) {
    var bookmark_list_id = get_current_bookmark_list_id();

    view_state.consume('reload', {
      bookmark_list_id: bookmark_list_id
    }, function() {
      update_sidebar_for_bookmark_presence(false);
    });

    if(Map.view_state.get() !== 'results') return;

    Map.view_state.consume('reload');
  };

  var on_back_to_bookmarks_click = function(e) {
    $('.sidebar.right .btn-export').fadeIn();
    view_state.consume('back');

    setTimeout(function(){
      $('.sidebar .view-states-wrapper .current').perfectScrollbar();
    }, 100);
  };

  var on_back_to_export_click = function(e) {
    view_state.back();
    setTimeout(function(){
      $('.sidebar .view-states-wrapper .current').perfectScrollbar();
    }, 100);
  };

  var on_new_bookmark_list_submit = function(e) {
    e.preventDefault();

    if($('.sidebar.right .location-list-item').length < 1) {
      return alert('You must first bookmark some locations.');
    } else if($('#bookmark_list_name').val().trim().length === 0) {
      return $('#bookmark_list_name').closest('.field').addClass('error');
    }

    Loading.show($('.sidebar'));

    $.ajax({
      url: 'create_bookmark_list',
      type: 'POST',
      data: $(this).serializeObject()
    }).success(function(data) {
      var bookmark_list_id = data.bookmark_list.id;
      if(!bookmark_list_id) return;

      $('.btn-export').addClass('has-bookmarks');

      view_state.consume('reload', {
        bookmark_list_id: bookmark_list_id
      }, function() {
        Loading.hide($('.sidebar'));
      });
    });
    return false;
  };

  var on_delete_bookmark_list_click = function(e) {
    e.preventDefault();

    var bookmark_list_id = get_current_bookmark_list_id();

    Loading.show($('.sidebar'));

    $.ajax({
      url: 'bookmark_list/' + bookmark_list_id,
      type: 'DELETE'
    }).success(function() {
      view_state.consume('reload', {
        bookmark_list_id: null
      }, function() {
        Loading.hide($('.sidebar'));
      });
    });

    return false;
  };

  var on_print_friendly_click = function(e) {
    e.preventDefault();

    var bookmark_list_id = get_current_bookmark_list_id();
    var path = 'bookmarks/print_friendly';

    if(bookmark_list_id !== '') {
      path += '?bookmark_list_id=' + bookmark_list_id;
    }
    window.open(path, '_blank');
  };

  var on_export_email_click = function(e) {
    e.stopPropagation();

    var data = {
      email: $('.tbx-export-email').val()
    };

    $.ajax({
      method: 'POST',
      url: '/email_bookmarks',
      data: data
    })
    .done(function() {
      view_state.consume('next', data, function(){
        $('.sidebar .view-states-wrapper .current').perfectScrollbar();
      });
    });

    return false;
  };

  var on_export_click = function(e) {
    e.preventDefault();

    $(this).fadeOut();

    view_state.consume('next', {
      bookmark_list_id: get_current_bookmark_list_id()
    }, function(){
      $('.sidebar .view-states-wrapper .current').perfectScrollbar();
    });
  };

  var on_xls_click = function(e) {
    e.preventDefault();

    var bookmark_list_id = get_current_bookmark_list_id();
    var path = 'bookmarks/to_file.xls';

    if(bookmark_list_id !== '') {
      path += '?bookmark_list_id=' + bookmark_list_id;
    }
    window.open(path, '_blank');
  };

  var on_csv_click = function(e) {
    e.preventDefault();

    var bookmark_list_id = get_current_bookmark_list_id();
    var path = 'bookmarks/to_file.csv';

    if(bookmark_list_id !== '') {
      path += '?bookmark_list_id=' + bookmark_list_id;
    }
    window.open(path, '_blank');
  };

  var on_email_click = function() {
    view_state.consume('next', {}, function(){
      $('.sidebar .view-states-wrapper .current').perfectScrollbar();
      Validation.init();
    });
  };

  var update_sidebar_for_bookmark_presence = function(initial) {
    var bookmark_list_id = get_current_bookmark_list_id();
    var bookmarks_present = $('.bookmarks-list .location-list-item').length > 0;

    var update = function() {
      $('.btn-export').toggleClass('has-bookmarks', bookmarks_present);
      $('.hint.no-bookmarks').toggleClass('shown', !bookmarks_present);

      if(bookmark_list_id !== '') {
        $('.sidebar.right form .submit').toggleClass('disabled', !bookmarks_present);
      }
    };

    if(!bookmarks_present
    && typeof view_state !== 'undefined'
    && view_state.get() !== 'bookmarks'
    && !initial) {
      init_view_state();
      view_state.consume('reload', {}, update);
    } else {
      update();
    }
  };

  var expand_sidebar_unless_previously_opened = function() {
    if(!first_time_sidebar_opened && $('.sidebar.right').hasClass('collapsed')) {
      first_time_sidebar_opened = true;
      $('.sidebar.right').removeClass('collapsed');
    }
  };

  var get_location_list_item_within = function(parent, location_id) {
    return parent.find('.location-list-item[data-location-id=' + location_id + ']');
  };

  var get_url_for_add_remove_bookmark = function(location_id) {
    var bookmark_list_id = get_current_bookmark_list_id();
    if(bookmark_list_id !== '' && typeof bookmark_list_id !== 'undefined') {
      return '/bookmark/' + bookmark_list_id + '/' + location_id;
    }
    return '/bookmark/' + location_id;
  };

  var add_bookmark_before_slide_in_css = function() {
    return {
      //'height': '0',
      'left' : '-300%',
      //'padding': '0',
      'margin-bottom': '0'
    };
  };

  var add_bookmark_slide_in_css = function(result) {
    return {
      //'height' : result.css('height'),
      //'padding': result.css('padding'),
      'margin-bottom': result.css('margin-bottom')
    };
  };

  var remove_bookmark_slide_out_css = function() {
    return {
      //'height': '0',
      //'padding': '0',
      'margin-bottom': '0'
    };
  };

  var get_current_bookmark_list_id = function() {
    return $('#bookmark_list_id').val();
  };

  return {
    init: init,
    view_state: view_state,
    first_time_sidebar_opened: first_time_sidebar_opened
  }
}(jQuery, MapBookmarks || {}));
