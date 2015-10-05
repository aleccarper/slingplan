var Home = (function($, m) {

  var init = function() {
    $('.for-planners-btn, .for-vendors-btn').on('click', function(e){
      e.preventDefault();
      var targetClass = $(this).attr('data-target');

      $('.animation-wrapper').each(function(index, element){
        setTimeout(function(){
          if($(this).hasClass(targetClass)) {
            $(this).addClass('on-screen');
          } else {
            $(this).removeClass('on-screen');
          }
        }, index * 75);
      });
    });
  };


  return {
    init: init
  };


}(jQuery, Home || {}));
