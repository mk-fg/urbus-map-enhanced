google.load('jquery', '1.7.1')

google.setOnLoadCallback ->

	gmaps = google.maps
	map = new gmaps.Map $('#map_canvas').get(0),
		center: new gmaps.LatLng(56.8333, 60.5833)
		zoom: 12
		mapTypeId: gmaps.MapTypeId.ROADMAP

	# http://www.urbus.ru/passajiram/routes/
	$.getJSON "/proxy/urbus_route_threads",
		(threads, status, req) ->
			for thread in threads

				# http://sverhy.ru/gmap/getroutepoints.php?route_id=X&xmlhttp=XMLHttpRequest
				$.getJSON "/proxy/urbus_route_thread_#{thread}",
					(pos_data, status, req) ->
						new gmaps.Polyline
							map: map
							path: (\
								new gmaps.LatLng(pos.latitude, pos.longitude)\
								for pos in pos_data )
							strokeColor: '#0000ff'
							strokeWeight: 2
							clickable: false

				# http://sverhy.ru/gmap/dragin.php?route_id=X&xmlhttp=XMLHttpRequest
				do (thread) ->
					$.getJSON "/proxy/urbus_route_vehicles_#{thread}",
						(pos_data, status, req) ->
							for pos in pos_data
								marker = new gmaps.Marker
									map: map
									position: new gmaps.LatLng(pos.latitude, pos.longitude)
									visible: false
									draggable: false
									clickable: false
									flat: true
								ib = new InfoBox
									content:\
										$("""<img src="arrow.png"
												title="Bus №#{thread}, speed: #{pos.velocity} km/h" />""")\
											.css(
												transform: "rotate(#{pos.course}deg)"
												'-moz-transform': "rotate(#{pos.course}deg)"
												'-o-transform': "rotate(#{pos.course}deg)"
												'-webkit-transform': "rotate(#{pos.course}deg)" ).get(0)
									disableAutoPan: true
									pixelOffset: new google.maps.Size(0, 0)
									boxClass: 'marker_box'
									pane: 'floatPane'
									enableEventPropagation: true
									closeBoxURL: ''
								ib.open(map, marker)
