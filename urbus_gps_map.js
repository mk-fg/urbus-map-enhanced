// Generated by CoffeeScript 1.2.1-pre
(function() {

  google.load('jquery', '1.7.1');

  google.setOnLoadCallback(function() {
    var gmaps, map;
    gmaps = google.maps;
    map = new gmaps.Map($('#map_canvas').get(0), {
      center: new gmaps.LatLng(56.8333, 60.5833),
      zoom: 12,
      mapTypeId: gmaps.MapTypeId.ROADMAP
    });
    return $.getJSON("/proxy/urbus_route_threads", function(threads, status, req) {
      var thread, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = threads.length; _i < _len; _i++) {
        thread = threads[_i];
        $.getJSON("/proxy/urbus_route_thread_" + thread, function(pos_data, status, req) {
          var pos;
          return new gmaps.Polyline({
            map: map,
            path: (function() {
              var _j, _len1, _results1;
              _results1 = [];
              for (_j = 0, _len1 = pos_data.length; _j < _len1; _j++) {
                pos = pos_data[_j];
                _results1.push(new gmaps.LatLng(pos.latitude, pos.longitude));
              }
              return _results1;
            })(),
            strokeColor: '#0000ff',
            strokeWeight: 2,
            clickable: false
          });
        });
        _results.push((function(thread) {
          return $.getJSON("/proxy/urbus_route_vehicles_" + thread, function(pos_data, status, req) {
            var ib, marker, pos, _j, _len1, _results1;
            _results1 = [];
            for (_j = 0, _len1 = pos_data.length; _j < _len1; _j++) {
              pos = pos_data[_j];
              marker = new gmaps.Marker({
                map: map,
                position: new gmaps.LatLng(pos.latitude, pos.longitude),
                visible: false,
                draggable: false,
                clickable: false,
                flat: true
              });
              ib = new InfoBox({
                content: $("<img src=\"arrow.png\"\ntitle=\"Bus №" + thread + ", speed: " + pos.velocity + " km/h\" />").css({
                  transform: "rotate(" + pos.course + "deg)",
                  '-moz-transform': "rotate(" + pos.course + "deg)",
                  '-o-transform': "rotate(" + pos.course + "deg)",
                  '-webkit-transform': "rotate(" + pos.course + "deg)"
                }).get(0),
                disableAutoPan: true,
                pixelOffset: new google.maps.Size(0, 0),
                boxClass: 'marker_box',
                pane: 'floatPane',
                enableEventPropagation: true,
                closeBoxURL: ''
              });
              _results1.push(ib.open(map, marker));
            }
            return _results1;
          });
        })(thread));
      }
      return _results;
    });
  });

}).call(this);
