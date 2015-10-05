var DatePicker = (function($, m) {

  function Picker(parent_class, opts) {
    this.that = this;
    this.parent = $(parent_class);
    this.picker = this.parent.datepicker(opts);
  }

  var init = function(parent_class, opts) {
    return new Picker(parent_class, opts);
  };

  var get_datepicker_cell_date = function(cell) {
    var date_day = cell.find('a').html();
    var date_month = cell.data('month');
    var date_year = cell.data('year');
    if(typeof date_day === 'undefined' ||
       typeof date_month === 'undefined' ||
       typeof date_year === 'undefined') {
      return undefined;
    }
    return new Date([date_month + 1, date_day, date_year].join('/'));
  };

  var get_today_date = function() {
    return new Date(new Date().setHours(0, 0, 0, 0));
  };

  return {
    init: init,
    get_datepicker_cell_date: get_datepicker_cell_date,
    get_today_date: get_today_date
  }
}(jQuery, DatePicker || {}));


