var Inquiries = (function($, m) {

  var to_read = [];
  var reading = false;

  var init = function() {
    if($('.inquiry-message-list, .negotiation-message-list').length === 0) {
      return;
    }

    $(document).scroll(throttled_scroll);

    $(document).on('click', '.new-message-tabs > div', function(e) {
      $(this).closest('.new-message')
        .removeClass('reply file')
        .addClass($(this).data('tab'));
    });
  };

  var scroll = function(e) {
    var scroll_top = $(document).scrollTop();
    var scroll_bottom = scroll_top + $(window).height();

    $.each($('.inquiry-message-list li.unread, .negotiation-message-list li.unread'), function(i, el) {
      var message_rect = el.getBoundingClientRect();
      var message_top = message_rect.top + scroll_top;
      var message_bottom = message_rect.bottom + scroll_top;

      if(message_top >= scroll_top && message_bottom <= scroll_bottom) {
        to_read.push($(el).data('id'));
      }
    });

    read();
  };

  var throttled_scroll = _.throttle(scroll, 1000);

  var read = function() {
    if(reading || to_read.length === 0) {
      return;
    }
    reading = true;

    $.ajax({
      method: 'POST',
      url: url_for_read_message(),
      data: {
        ids: to_read
      }
    }).done(function(data) {
      var page = on_inquiries_or_negotiations();
      var selector = null;
      switch(page) {
        case 'inquiries':
          selector = '.inquiry-message-list';
          break;
        case 'negotiations':
          selector = '.inquiry-message-list';
          break;
      }
      if(selector === null) {
        return;
      }
      $.each(data.read_ids, function(i, id) {
        $(selector).find('li.unread[data-id=' + id + ']').removeClass('unread');
      });
      to_read = [];
      reading = false;
    })
  };

  var url_for_read_message = function() {
    var page = on_inquiries_or_negotiations();
    switch(page) {
      case 'inquiries':
        return '/inquiries/read_inquiry_messages';
        break;
      case 'negotiations':
        return '/inquiries/read_negotiation_messages';
        break;
      default:
        return false;
    }
  };

  var on_inquiries_or_negotiations = function() {
    if($('.inquiry-message-list ').length !== 0) {
      return 'inquiries';
    } else if ($('.negotiation-message-list').length !== 0) {
      return 'negotiations';
    }
    return false;
  };

  return {
    init: init,
    scroll: scroll
  };
}(jQuery, Inquiries || {}));


