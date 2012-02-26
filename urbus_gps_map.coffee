google.load('jquery', '1.7.1')

google.setOnLoadCallback ->
	if not GBrowserIsCompatible()
		alert 'Google haets your browser, ie6?'

	$(window).resize ->
		if $(window).height() > $('body').height()
			$('#map_canvas').height( $(window).height()
				- ($('body').height() - $('#map_canvas').height()) )
	$(window).resize()

	map = new GMap2($('#map_canvas').get(0))
	map.setCenter(new GLatLng(56.8333, 60.5833), 12)
	map.setUIToDefault()

	# http://www.urbus.ru/passajiram/routes/
	$.getJSON "/proxy/urbus_route_threads",
		(threads, status, req) ->
			for thread in threads

				# http://sverhy.ru/gmap/getroutepoints.php?route_id=X&xmlhttp=XMLHttpRequest
				$.getJSON "/proxy/urbus_route_thread_#{thread}",
					(pos_data, status, req) ->
						line_points = (\
							new GLatLng(pos.latitude, pos.longitude)\
							for pos in pos_data )
						line = new GPolyline(line_points, '#0000ff', 2,1)
						map.addOverlay(line)

				# http://sverhy.ru/gmap/dragin.php?route_id=X&xmlhttp=XMLHttpRequest
				$.getJSON "/proxy/urbus_route_vehicles_#{thread}",
					(pos_data, status, req) ->
						for pos in pos_data
							center = new GLatLng(pos.latitude, pos.longitude)
							icon_size = 21*(Math.abs(Math.cos(pos.course*Math.PI/180))\
								+ 1*Math.abs(Math.sin(pos.course*Math.PI/180)))

							icon = new GIcon(G_DEFAULT_ICON);
							icon.image = "http://sverhy.ru/gmap/autoimg.php?angle=#{pos.course}";
							icon.shadow = '';
							icon.iconAnchor= new  GPoint(icon_size/2,icon_size/2);
							icon.iconSize = new GSize(icon_size, icon_size);

							marker = new GMarker(center, {icon: icon, draggable: false, clickable: false});
							map.addOverlay(marker)
