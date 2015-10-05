  var ViewStates = (function($, m) {

    function ViewState(opts) {
      var parent;
      var states;
      var current;
      var current_index;
      var prev_index;
      var before_back;
      var render_opts = {};
      var index = {};

      var direction = function(opts) {
        if(opts.reload) {
          return 'none'
        }
        return current_index > prev_index ? 'forward' :
               current_index == prev_index ? 'none' : 'back';
      };

      var render = function(opts) {
        var dir = direction(opts);

        // fade current view out
        if(dir === 'forward') {
          parent.find('.current').css('overflow-y', 'hidden').addClass('slide-out');
        } else if(dir === 'back') {
          parent.find('.current').addClass('invisible');
        }

        // change sidebar class to current viewstat
        if(prev_index) {
          parent.removeClass(states[prev_index].name)
        }
        parent.addClass(current.name);

        // get and render the new view
        $.ajax({
          url: endpoint,
          data: $.extend(true, { state: current.name }, opts.data),
          type: 'POST'
        })
        .done(function(data) {
          var old_current = parent.find('.current');

          if(dir === 'none') {
            old_current.html(data.view);
          } else {
            var view = $("<div class='stage'></div>");

            if(dir === 'forward') {
              view.addClass('invisible');
            } else if(dir === 'back') {
              view.addClass('slide-out');
            }

            view.append(data.view);

            parent.find('.view-states').append(view);

            old_current.remove();

            parent.find('.stage')
              .removeClass('stage')
              .addClass('current');
          }


          if(current.name === 'search') {
            Map.get_available_services();
          }
          if(dir === 'forward') {
            parent.find('.current.invisible').fadeIn().removeClass('invisible');
          } else if(dir === 'back') {
            parent.find('.current.slide-out').fadeIn().removeClass('slide-out');
          }

          delete render_opts.reload;

          if(typeof render_opts.callback !== 'undefined') {
            render_opts.callback(data);
          }
        });
      };



      this.consume = function(event_name, data, callback) {
        if(event_name !== 'reload') {
          render_opts = {
            data: data,
            callback: callback,
            event_name: event_name
          };

          prev_index = index[current.name];
          if(current.events[event_name]) {
            current_index = index[current.events[event_name]];
            current = states[current_index];
          }
        } else {
          render_opts.reload = true;

          if(typeof data !== 'undefined') {
            render_opts.data = data;
          }
          if(typeof callback !== 'undefined') {
            render_opts.callback = callback;
          }
        }

        render(render_opts);
      };

      this.get = function() {
        return current.name;
      };


      this.back = function() {
        var next = states[index[this.get()] - 1];

        if(typeof next !== 'undefined') {
          if(typeof before_back !== 'undefined') {
            before_back(this);
          }
          this.consume('back', {});
        }
      };

      this.get_parent = function() {
        return parent;
      };

      this.init = function() {
        parent = $(opts.parent);
        endpoint = opts.endpoint;
        states = opts.states;
        before_back = opts.before_back;
        // convenient way to get state index from name
        for(var i = 0; i < states.length; i++) {
          index[states[i].name] = i;
          if(states[i].initial) {
            current = states[i];
          }
        }

        parent.addClass(this.get());

        parent.find('.view-states .current').removeClass('invisible');

        if(typeof opts.after_init !== 'undefined') {
          opts.after_init(this);
        }
      };
    }

    var init = function(opts) {
      var state = new ViewState(opts);
      state.init();
      return state;
    };

    return {
      init: init
    };
  }(jQuery, ViewStates || {}));
