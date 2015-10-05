var ToolTips = (function($, m) {

  var margin = 3;
  var messages_hash;
  var tooltips_hash = {};

  var init = function() {
    if(isTouchDevice) return;
    tooltips_hash = {};

    // save hash of tip keys and their messages
    $.ajax({
      method: 'GET',
      url: '/tooltips',
      data: {
        current_controller: $('body').data('controller')
      }
    })
    .done(function(messages) {
      messages_hash = messages;

      // events for showing and hiding on hover
      $(document).on('mouseenter', '.tip', function(e) {
        // prevent showing tooltips if mouse buttons are held
        if(e.which !== 0) return;
        show(this);
      });
    });

    $(document).on('mouseleave', '.tip', function() {
      hide(this);
    });
    $(window).on('mousedown', function() {
      $('.tooltip').remove();
      tooltips_hash = {};
    });
    $(window).mouseout(function(e) {
      e = e ? e : window.event;
      var from = e.relatedTarget || e.toElement;
      if (!from || from.nodeName == "HTML") {
        $('.tooltip').remove();
        tooltips_hash = {};
      }
    });
  };

  var show = function(that) {
    var tip = new Tip(that);
    tooltips_hash[tip.key] = tip;
    tip.show()
  };

  var hide = function(el) {
    var key = $(el).data('msg');
    $('.tooltip-' + key).remove();
    delete tooltips_hash[key];
  };



  // OOP Tip class
  function Tip(that) {
    this.src = $(that);
    this.dir = this.src.data('dir');
    this.key = this.src.data('msg');
    this.msg = messages_hash[this.key];
    this.dom = undefined;

    this.exists = function() {
      return messages_hash.hasOwnProperty(this.key);
    };

    this.build = function() {
      this.dom = $('<div></div>')
        .addClass('tooltip')
        .addClass('tooltip-' + this.key)
        .html(this.msg);
    };

    this.show = function() {
      if(!this.exists()) {
        return;
      }
      this.build();
      this.append();
      this.position();
      this.dom.addClass('shown');
    };

    this.append = function() {
      $('body').append(this.dom);
    };

    this.get = function() {
      return $('.tooltip.tooltip-' + this.key);
    };

    this.hide = function() {
      if(typeof this.dom === 'undefined') {
        return;
      }
      this.remove();
    };

    this.remove = function() {
      this.dom.remove();
    };

    this.position = function() {
      var ww = $(window).width();
      var wh = $(window).height();
      var hr = this.src[0].getBoundingClientRect();
      var tr = this.dom[0].getBoundingClientRect();

      switch(this.dir) {
        case 'n':
          this.position_n(ww, wh, hr, tr);
          break;
        case 'e':
          this.position_e(ww, wh, hr, tr);
          break;
        case 's':
          this.position_s(ww, wh, hr, tr);
          break;
        case 'w':
          this.position_w(ww, wh, hr, tr);
          break;
      }
    };

    this.position_n = function(ww, wh, hr, tr) {
      var top = (hr.top - tr.height - margin) + window.scrollY;
      var left = (hr.left + hr.width / 2 - tr.width / 2) + window.scrollX;

      if(top < window.scrollY) {
        return this.position_s(ww, wh, hr, tr);
      }

      if(left + tr.width > ww) {
        left = ww - tr.width - margin;
      } else if(left < margin) {
        left = margin;
      }

      this.dom.css({
        top: top,
        left: left
      });
    };

    this.position_e = function(ww, wh, hr, tr) {
      var top = (hr.top + hr.height / 2 - tr.height / 2) + window.scrollY;
      var left = hr.right + margin + window.scrollX;

      if(left + tr.width > ww) {
        return this.position_w(ww, wh, hr, tr);
      }

      this.dom.css({
        top: top,
        left: left
      });
    };

    this.position_s = function(ww, wh, hr, tr) {
      var top = hr.bottom + margin + window.scrollY;
      var left = (hr.left + hr.width / 2 - tr.width / 2) + window.scrollX;

      if(top + tr.height > wh + window.scrollY) {
        return this.position_n(ww, wh, hr, tr);
      }

      if(left + tr.width > ww) {
        left = ww - tr.width - margin;
      } else if(left < margin) {
        left = margin;
      }

      this.dom.css({
        top: top,
        left: left
      });
    };

    this.position_w = function(ww, wh, hr, tr) {
      var top = (hr.top + hr.height / 2 - tr.height / 2) + window.scrollY;
      var left = (hr.left - tr.width - margin) + window.scrollX;

      if(left < margin) {
        return this.position_e(ww, wh, hr, tr);
      }

      this.dom.css({
        top: top,
        left: left
      });
    };
  };



  return {
    init: init,
    show: show,
    hide: hide
  };
}(jQuery, ToolTips || {}));
