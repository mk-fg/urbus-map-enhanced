// Generated by CoffeeScript 1.2.1-pre
(function() {

  google.load('jquery', '1.7.1');

  google.setOnLoadCallback(function() {
    var gmaps, map, style_line_active, style_line_hidden, style_line_inactive, style_marker_width;
    gmaps = google.maps;
    map = new gmaps.Map($('#map_canvas').get(0), {
      center: new gmaps.LatLng(56.8333, 60.5833),
      zoom: 12,
      mapTypeId: gmaps.MapTypeId.ROADMAP
    });
    style_line_active = {
      strokeOpacity: 1.0,
      strokeWeight: 3,
      strokeColor: 'red'
    };
    style_line_inactive = {
      strokeOpacity: 0.5,
      strokeWeight: 2,
      strokeColor: 'blue'
    };
    style_line_hidden = {
      strokeOpacity: 0.1,
      strokeWeight: 2,
      strokeColor: 'blue'
    };
    style_marker_width = 14;
    $(window).resize(function() {
      return $('#map_canvas').height($(window).height() - $('#map_controls').height());
    });
    return $.getJSON("/proxy/urbus_route_threads", function(threads, status, req) {
      var controls, lock_handle, lock_line, lock_marker, thread, thread_handles, thread_highlight, thread_isolate, thread_lines, thread_lock, thread_markers, _fn, _i, _len;
      thread_lines = {};
      thread_markers = {};
      thread_handles = {};
      lock_line = lock_marker = lock_handle = false;
      controls = $('#map_controls');
      thread_isolate = function(thread, hide) {
        var marker, xthread, _i, _len, _results;
        if (hide == null) hide = true;
        _results = [];
        for (_i = 0, _len = threads.length; _i < _len; _i++) {
          xthread = threads[_i];
          if (thread === xthread) continue;
          thread_lines[xthread].setOptions(hide ? style_line_hidden : style_line_inactive);
          _results.push((function() {
            var _j, _len1, _ref, _results1;
            _ref = thread_markers[xthread];
            _results1 = [];
            for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
              marker = _ref[_j];
              if (hide) {
                _results1.push(marker.addClass('hidden'));
              } else {
                _results1.push(marker.removeClass('active hidden'));
              }
            }
            return _results1;
          })());
        }
        return _results;
      };
      thread_highlight = function(thread, highlight) {
        var marker, _i, _len, _ref;
        if (highlight == null) highlight = true;
        _ref = thread_markers[thread];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          marker = _ref[_i];
          if (highlight) {
            marker.addClass('active');
          } else {
            marker.removeClass('active');
          }
        }
        if (highlight) {
          $("#_blk_" + thread).addClass('active');
        } else {
          $("#_blk_" + thread).removeClass('active');
        }
        return thread_lines[thread].setOptions(highlight ? style_line_active : style_line_inactive);
      };
      thread_lock = function(thread) {
        if (lock_handle) {
          if (lock_handle === thread) {
            thread_isolate(thread, false);
            thread_highlight(thread, false);
            lock_line = lock_marker = lock_handle = false;
            return;
          } else {
            thread_lock(lock_handle);
          }
        }
        thread_isolate(thread, true);
        thread_highlight(thread, true);
        return lock_line = lock_marker = lock_handle = thread;
      };
      _fn = function(thread) {
        var handle;
        handle = $("<label\n		id=\"_blk_" + thread + "\"\n		for=\"_in_toggle_" + thread + "\">\n	" + thread + "\n</label>");
        controls.append(handle);
        thread_handles[thread] = handle;
        handle = handle.get(0);
        gmaps.event.addDomListener(handle, 'click', function() {
          return thread_lock(thread);
        });
        gmaps.event.addDomListener(handle, 'mouseover', function() {
          if (lock_handle) return;
          thread_isolate(thread, true);
          return thread_highlight(thread, true);
        });
        gmaps.event.addDomListener(handle, 'mouseout', function() {
          if (lock_handle) return;
          thread_isolate(thread, false);
          return thread_highlight(thread, false);
        });
        $.getJSON("/proxy/urbus_route_thread_" + thread, function(pos_data, status, req) {
          var line, pos;
          line = thread_lines[thread] = new gmaps.Polyline({
            map: map,
            path: (function() {
              var _j, _len1, _results;
              _results = [];
              for (_j = 0, _len1 = pos_data.length; _j < _len1; _j++) {
                pos = pos_data[_j];
                _results.push(new gmaps.LatLng(pos.latitude, pos.longitude));
              }
              return _results;
            })(),
            clickable: true
          });
          line.setOptions(style_line_inactive);
          gmaps.event.addListener(line, 'click', function() {
            return thread_lock(thread);
          });
          gmaps.event.addListener(line, 'mouseover', function() {
            if (lock_line) return;
            return thread_highlight(thread, true);
          });
          return gmaps.event.addListener(line, 'mouseout', function() {
            if (lock_line) return;
            return thread_highlight(thread, false);
          });
        });
        return $.getJSON("/proxy/urbus_route_vehicles_" + thread, function(pos_data, status, req) {
          var ib, ib_marker, marker, markers, pos, _j, _len1, _results;
          markers = thread_markers[thread] = [];
          _results = [];
          for (_j = 0, _len1 = pos_data.length; _j < _len1; _j++) {
            pos = pos_data[_j];
            pos.course += 180;
            marker = new gmaps.Marker({
              map: map,
              position: new gmaps.LatLng(pos.latitude, pos.longitude),
              visible: false,
              draggable: false,
              clickable: false,
              flat: true
            });
            ib_marker = $("<div class=\"css_marker\"\ntitle=\"Bus " + thread + ", speed: " + pos.velocity + " km/h\"></div>").css({
              transform: "translateX(-" + (style_marker_width / 2) + "px) rotate(" + pos.course + "deg)",
              '-moz-transform': "translateX(-" + (style_marker_width / 2) + "px) rotate(" + pos.course + "deg)",
              '-o-transform': "translateX(-" + (style_marker_width / 2) + "px) rotate(" + pos.course + "deg)",
              '-webkit-transform': "translateX(-" + (style_marker_width / 2) + "px) rotate(" + pos.course + "deg)"
            });
            markers.push(ib_marker);
            ib_marker = ib_marker.get(0);
            ib = new InfoBox({
              content: ib_marker,
              disableAutoPan: true,
              pixelOffset: new google.maps.Size(0, 0),
              boxClass: 'marker_box',
              pane: 'floatPane',
              enableEventPropagation: true,
              closeBoxURL: ''
            });
            ib.open(map, marker);
            gmaps.event.addDomListener(ib_marker, 'click', function() {
              return thread_lock(thread);
            });
            gmaps.event.addDomListener(ib_marker, 'mouseover', function() {
              if (lock_marker) return;
              thread_isolate(thread, true);
              thread_highlight(thread, true);
              return lock_line = thread;
            });
            _results.push(gmaps.event.addDomListener(ib_marker, 'mouseout', function() {
              if (lock_marker) return;
              thread_isolate(thread, false);
              thread_highlight(thread, false);
              return lock_line = false;
            }));
          }
          return _results;
        });
      };
      for (_i = 0, _len = threads.length; _i < _len; _i++) {
        thread = threads[_i];
        _fn(thread);
      }
      return $(window).resize();
    });
  });

}).call(this);
