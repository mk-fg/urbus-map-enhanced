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
		strokeColor: 'red'
	style_line_inactive =
		strokeOpacity: 0.5
		strokeWeight: 2
		strokeColor: 'blue'
	style_line_hidden =
		strokeOpacity: 0.1
		strokeWeight: 2
		strokeColor: 'blue'
	style_marker_width = 14

	$(window).resize ->
		$('#map_canvas').height(
			$(window).height() - $('#map_controls').height() )

	# http://www.urbus.ru/passajiram/routes/
	$.getJSON "/proxy/urbus_route_threads",
		(threads, status, req) ->
			thread_lines = {}
			thread_markers = {}
			line_over_lock = false
			controls = $('#map_controls')

			for thread in threads
				do (thread) ->

					## Interaction
					thread_isolate = (hide=true) ->
						for xthread in threads
							continue if thread == xthread
							thread_lines[xthread].setOptions( if hide\
								then style_line_hidden else style_line_inactive )
							for marker in thread_markers[xthread]
								if hide\
									then marker.addClass('hidden')\
									else marker.removeClass('active hidden')
					thread_highlight = (highlight=true) ->
						for marker in thread_markers[thread]
							if highlight\
								then marker.addClass('active')\
								else marker.removeClass('active')
						if highlight\
							then $("#_blk_#{thread}").addClass('active')\
							else $("#_blk_#{thread}").removeClass('active')
						thread_lines[thread].setOptions( if highlight\
							then style_line_active else style_line_inactive )

					## Handle
					handle = $("""
						<label
							id="_blk_#{thread}"
							for="_in_toggle_#{thread}">
							<!-- <input type="checkbox"
								id="_in_toggle_#{thread}"
								name="toggle_#{thread}" /> -->
							<div>#{thread}</div>
						</label>""")
					controls.append(handle)
					handle = handle.get(0)

					gmaps.event.addDomListener(
						handle, 'mouseover', ->
							thread_isolate(true)
							thread_highlight(true) )
					gmaps.event.addDomListener(
						handle, 'mouseout', ->
							thread_isolate(false)
							thread_highlight(false) )

					## Line
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
									return if line_over_lock
									thread_highlight(true) )
							gmaps.event.addListener(
								line, 'mouseout', ->
									return if line_over_lock
									thread_highlight(false) )

					## Markers
					# http://sverhy.ru/gmap/dragin.php?route_id=X&xmlhttp=XMLHttpRequest
					$.getJSON "/proxy/urbus_route_vehicles_#{thread}",
						(pos_data, status, req) ->
							markers = thread_markers[thread] = []
							for pos in pos_data
								pos.course += 180
								marker = new gmaps.Marker
									map: map
									position: new gmaps.LatLng(pos.latitude, pos.longitude)
									visible: false
									draggable: false
									clickable: false
									flat: true
								ib_marker = $("""<div class="css_marker"
										title="Bus #{thread}, speed: #{pos.velocity} km/h"></div>""")\
									.css(
										transform: "translateX(-#{style_marker_width/2}px) rotate(#{pos.course}deg)"
										'-moz-transform': "translateX(-#{style_marker_width/2}px) rotate(#{pos.course}deg)"
										'-o-transform': "translateX(-#{style_marker_width/2}px) rotate(#{pos.course}deg)"
										'-webkit-transform': "translateX(-#{style_marker_width/2}px) rotate(#{pos.course}deg)" )
								markers.push(ib_marker)
								ib_marker = ib_marker.get(0)
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
										thread_isolate(true)
										thread_highlight(true)
										line_over_lock = true )
								gmaps.event.addDomListener(
									ib_marker, 'mouseout', ->
										thread_isolate(false)
										thread_highlight(false)
										line_over_lock = false )

			$(window).resize()
