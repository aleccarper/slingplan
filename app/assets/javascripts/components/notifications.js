var Notifications = (function($, m) {
  var priority_classes = [
    'green-priority',
    'yellow-priority',
    'red-priority'
  ];
  var open = false;

  var init = function() {
    $('body').on('click', '.js-open-close-notifications', open_or_close_notifications);
    $('body').on('click', '.js-remove-notification', remove_notification_click);
    $('body').on('click', '.js-notification-link', notification_link_click);
    $('.notifications').perfectScrollbar();


    $(document).click(function(e) {
      if(!$(e.target).closest('.js-open-close-notifications').length && !$(e.target).closest('.notifications-container').length) {
        hide(open = false);
      }
    });

    set_notification_priority();
  };

  var any_unread = function(){
    var found = false;
    $('.notifications .notifications-container .notification').each(function(){
      if($(this).attr('data-read') == 'false') {
        found = true;
      }
    });

    if(found) {
      $('.js-open-close-notifications').addClass('has-unread');
    } else {
      $('.js-open-close-notifications').removeClass('has-unread');
    }
  };

  var set_notification_priority = function(){
    var highest_priority = 1;
    var has_messages = false;
    $('.notifications .notifications-container .notification').each(function(){
      has_messages = true;
      var priority = parseInt($(this).attr('data-priority'));
      if(priority > highest_priority) {
        highest_priority = priority;
      }
      $(this).addClass(priority_classes[priority-1]);
    });

    for(var i=0; i < priority_classes.length; i++) {
      $('.js-open-close-notifications').removeClass(priority_classes[i]);
    }

    if(has_messages) {
      $('.js-open-close-notifications').addClass(priority_classes[highest_priority-1]);
    }
    any_unread();
  }

  var remove_notification_click = function() {
    var el = $(this).closest('.notification');
    remove_notification(el);
  };

  var notification_link_click = function(e) {
    var el = $(this).closest('.notification');
    var redirect_after = $(this).find('a').attr('href');
    remove_notification(el, function() {
      window.location = redirect_after;
    });
    return false;
  };

  var remove_notification = function(el, callback) {
    var id = el.attr('data-id');
    var elem = $(this)
    $.ajax({
      method: 'POST',
      url: '/notifications/read',
      data: {
        id: id
      }
    })
    .done(function() {
      el.animate({'height' : '0%'}, 250, function() {
        $(this).remove();
      });

      if(typeof callback !== 'undefined') {
        callback();
      }
    });
  };

  var open_or_close_notifications = function(e) {
    e.preventDefault();

    if(open = !open) {
      show();
    } else {
      hide();
    }
  };

  var show = function() {
    $('.notifications').addClass('active');
    $('.notifications-container .notification').each(function(index, element) {
      $(element).css({x: 260});

      setTimeout(function(){
        $(element).css({x: 0});
      }, 75 + (index * 50))
    });
  };

  var hide = function() {
    $('.notifications').removeClass('active');
  };


  return {
    init: init,
    set_notification_priority: set_notification_priority
  };

}(jQuery, Notifications || {}));


