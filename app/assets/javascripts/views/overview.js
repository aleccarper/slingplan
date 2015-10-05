var Overview = (function($, m) {

  var init = function() {
    $(document).on('click', '.circle', function(e) {
      var clicked = $(this);
      $.each($('.circle'), function(i, circle) {
        var c = $(circle);
        if(c.is(clicked)) return;
        $(c).removeClass('selected');
        // $('.overlay').removeClass('shown');
      });
      if(!$(this).hasClass('selected')) {
        $(this).addClass('selected');
        // $('.overlay').addClass('shown');
        return false;
      }
    });

    $(document).on('click', '.circle-hint-close', function(e) {
      $(this).closest('.circle')
        .removeClass('selected')
        .delay(1000)
        .trigger('mouseover');
      // $('.overlay').removeClass('shown');
      return false;
    });

    $(document).click(function(e) {
      $('.circle').removeClass('selected');
      // $('.overlay').removeClass('shown');
    });
  };

  return {
    init: init
  };
}(jQuery, Overview || {}));
