var Negotiations = (function($, m) {

  var to_read = [];
  var reading = false;

  var init = function() {
    if($('.negotiation-message-list').length === 0) {
      return;
    }
    $('body').scroll(throttled_scroll);
  };

  var scroll = function(e) {
    var scroll_top = $('body').scrollTop();
    var scroll_bottom = scroll_top + $(window).height();

    $.each($('.negotiation-message-list li.unread'), function(i, el) {
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
      url: '/inquiries/read_negotiation_messages',
      data: {
        ids: to_read
      }
    }).done(function(data) {
      $.each(data.read_ids, function(i, id) {
        setTimeout(function() {
          $('.negotiation-message-list li.unread[data-id=' + id + ']').removeClass('unread');
        }, i * 500)
      });
      to_read = [];
      reading = false;
    })
  };

  return {
    init: init,
    scroll: scroll
  };
}(jQuery, Negotiations || {}));


