var SseStream = (function($, m) {

  var sses = [];

  function SSE(opts) {
    var that = this;
    this.source = new EventSource(opts.source);
    this.callback = opts.callback || undefined;

    this.source.addEventListener('results', function(e) {
      $(opts.destination).html(JSON.parse(e.data).view);

      if(typeof that.callback !== 'undefined') {
        that.callback();
      }
    });

    this.source.addEventListener('finished', function(e) {
      this.source.close();
    });
  };

  var init = function(opts) {
    sses.push(new SSE(opts));
  };

  return {
    init: init
  };
}(jQuery, SseStream || {}));
