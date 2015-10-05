var Pagination = (function($, m) {

  var pagers = {};

  var init = function(opts) {
    if($(opts.id).length === 0) return;
    pagers[opts.id] = new Pager(opts);
  };

  function Pager(opts) {
    var that = this;
    this.id = opts.id;
    this.url = opts.url;
    this.data_func = opts.data_func;

    var page_click = function(e) {
      e.preventDefault();
      var page = $(this).data('page');
      that.draw(page);
    };

    var first_click = function(e) {
      e.preventDefault();
      that.draw(0);
    };

    var prev_click = function(e) {
      e.preventDefault();
      var page = parseInt($(that.id + ' .pagination-current-page').data('page')) - 1;
      that.draw(page);
    };

    var next_click = function(e) {
      e.preventDefault();
      var page = parseInt($(that.id + ' .pagination-current-page').data('page')) + 1;
      that.draw(page);
    };

    var last_click = function(e) {
      e.preventDefault();
      var page = parseInt($('#pagination_last_page').val());
      that.draw(page);
    };

    this.draw = function(page) {
      Loading.show(that.id);
      $.ajax({
        type: 'POST',
        url: that.url,
        data: that.data_func(page)
      }).done(function(data) {
        $(that.id).replaceWith(data.view);
        Loading.hide(that.id);
      });
    };

    $(document).on('click', this.id + ' .pagination-page', page_click);
    $(document).on('click', this.id + ' .pagination-first', first_click);
    $(document).on('click', this.id + ' .pagination-prev', prev_click);
    $(document).on('click', this.id + ' .pagination-next', next_click);
    $(document).on('click', this.id + ' .pagination-last', last_click);

    this.draw();
  };

  return {
    init: init,
    pagers: pagers
  };
}(jQuery, Pagination || {}));

