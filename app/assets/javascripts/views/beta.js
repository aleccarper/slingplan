var Beta = (function($, m) {

  var current = 'overview';

  var init = function() {
    $(document).on('click', '.close-beta-how-to-expand, .close-beta-how-to-collapse', function(e) {
      var modal = $('.beta-modal');
      if(modal.hasClass('collapsed')) {
        modal.removeClass('collapsed');
        $('.close-beta-how-to-expand').hide();
        $('.close-beta-how-to-collapse').show();
      } else {
        modal.addClass('collapsed');
        $('.close-beta-how-to-expand').show();
        $('.close-beta-how-to-collapse').hide();
      }
    });

    $(document).on('click', '.beta-nav .btn', function(e) {
      e.preventDefault();
      if(current === $(this).data('page')) {
        return;
      }
      current = $(this).data('page');
      highlight_button();
    });

    highlight_button();
  };

  var highlight_button = function() {
    var nav = $('.beta-nav');
    nav.find('.btn').addClass('btn-dark');
    nav.find('.' + current).removeClass('btn-dark');
    $('.how-to').children('div').fadeOut();
    $('.how-to-' + current).fadeIn();
  };

  return {
    init: init
  };
}(jQuery, Beta || {}));


