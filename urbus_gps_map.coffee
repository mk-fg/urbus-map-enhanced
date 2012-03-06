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
				$.getJSON "/proxy/urbus_route_vehicles_#{thread}",
					(pos_data, status, req) ->
						for pos in pos_data
							icon_size = 21*(Math.abs(Math.cos(pos.course*Math.PI/180))\
								+ 1*Math.abs(Math.sin(pos.course*Math.PI/180)))
							new gmaps.Marker
								map: map
								position: new gmaps.LatLng(pos.latitude, pos.longitude)
								icon: new gmaps.MarkerImage(
									"http://sverhy.ru/gmap/autoimg.php?angle=#{pos.course}",
									new gmaps.Size(icon_size, icon_size),
									null, new gmaps.Point(icon_size/2, icon_size/2) )
								draggable: false
								clickable: false
								flat: true
