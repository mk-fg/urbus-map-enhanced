google.load('jquery', '1.7.1')

google.setOnLoadCallback ->

	gmaps = google.maps
	map = new gmaps.Map $('#map_canvas').get(0),
		center: new gmaps.LatLng(56.8333, 60.5833)
		zoom: 12
		mapTypeId: gmaps.MapTypeId.ROADMAP

	style_line_active =
		strokeOpacity: 1.0
		strokeWeight: 3
		strokeColor: '#f00'
	style_line_inactive =
		strokeOpacity: 0.5
		strokeWeight: 2
		strokeColor: '#00f'
	style_line_hidden =
		strokeOpacity: 0.1
		strokeWeight: 2
		strokeColor: '#00f'

	# http://www.urbus.ru/passajiram/routes/
	$.getJSON "/proxy/urbus_route_threads",
		(threads, status, req) ->
			thread_lines = {}
			line_over_lock = false

			for thread in threads
				do (thread) ->

					# http://sverhy.ru/gmap/getroutepoints.php?route_id=X&xmlhttp=XMLHttpRequest
					$.getJSON "/proxy/urbus_route_thread_#{thread}",
						(pos_data, status, req) ->
							line = thread_lines[thread] = new gmaps.Polyline
								map: map
								path: (\
									new gmaps.LatLng(pos.latitude, pos.longitude)\
									for pos in pos_data )
								clickable: true
							line.setOptions(style_line_inactive)

							gmaps.event.addListener(
								line, 'mouseover', ->
									line.setOptions(style_line_active) unless line_over_lock )
							gmaps.event.addListener(
								line, 'mouseout', ->
									line.setOptions(style_line_inactive) unless line_over_lock )

					# http://sverhy.ru/gmap/dragin.php?route_id=X&xmlhttp=XMLHttpRequest
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
								ib_marker = $("""<img src="arrow.png"
										title="Bus #{thread}, speed: #{pos.velocity} km/h" />""")\
									.css(
										transform: "rotate(#{pos.course}deg)"
										'-moz-transform': "rotate(#{pos.course}deg)"
										'-o-transform': "rotate(#{pos.course}deg)"
										'-webkit-transform': "rotate(#{pos.course}deg)" ).get(0)
								ib = new InfoBox
									content: ib_marker
									disableAutoPan: true
									pixelOffset: new google.maps.Size(0, 0)
									boxClass: 'marker_box'
									pane: 'floatPane'
									enableEventPropagation: true
									closeBoxURL: ''
								ib.open(map, marker)

								gmaps.event.addDomListener(
									ib_marker, 'mouseover', ->
										for _, line of thread_lines
											line.setOptions(style_line_hidden)
										gmaps.event.trigger(thread_lines[thread], 'mouseover')
										line_over_lock = true )
								gmaps.event.addDomListener(
									ib_marker, 'mouseout', ->
										for _, line of thread_lines
											line.setOptions(style_line_inactive)
										gmaps.event.trigger(thread_lines[thread], 'mouseout')
										line_over_lock = false )
