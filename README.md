urbus-map-enhanced: a better interface to local (Yekaterinburg, RU) public transport real-time (position) data
--------------------

It's a simple browser (js-heavy) interface, utilizing Google Maps API (v3) to
draw real-time positions of buses of a [local public transport
company](http://www.urbus.ru/).

GPS data is provided via JSON API, but stock interface to it on the company site
kinda sucks, hence the project.

While putting together an initial version, I've noted that data on threads that
are of most interest to me seem to be missing (guess they don't have tracking
devices on buses there), so there probably won't be much progress until more
data will be made available.


Requirements:
--------------------

* Any modern browser
* [coffescript](http://jashkenas.github.com/coffee-script/)
* (to fetch thread ids only) [python 2.7](http://python.org)
* (to fetch thread ids only) [lxml](http://lxml.de)


Usage notes:
--------------------

* Update URLs on `$.getJSON` lines in `urbus_gps_map.coffee` (I'm using a local
  proxy URLs to cache API queries, to minimize the strain on the service).
* `fetch_thread_ids.py` script produces JSON-encoded list of thread ids, which
  doesn't seem to be available through API, and should be served for
  /proxy/urbus_route_threads URL in js (or maybe encoded there statically).
* Compile js with `coffee -c urbus_gps_map.coffee`.
