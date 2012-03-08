urbus-map-enhanced: a better interface to local (Yekaterinburg, RU) public transport real-time (position) data
--------------------

It's a simple browser (js-heavy) interface, utilizing Google Maps API (v3) to
draw real-time positions of buses of a [local public transport
company](http://www.urbus.ru/).

gps data is provided via json api, but stock interface to it on the company site
kinda sucks (to the point that js bails with a error for some maps), hence the
project.


Requirements:
--------------------

* Any modern browser
* (to recompile .js from .coffee) [coffescript](http://jashkenas.github.com/coffee-script/)
* (to fetch thread ids only) [python 2.7](http://python.org)
* (to fetch thread ids only) [lxml](http://lxml.de)


Usage notes:
--------------------

* Update urls on `$.getJSON` lines in `urbus_gps_map.coffee` (I'm using a local
  proxy urls to cache api queries, to minimize the strain on the service).
* `fetch_thread_ids.py` script produces json-encoded list of thread ids, which
  doesn't seem to be available through api, and should be served for
  /proxy/urbus_route_threads url in js (or maybe encoded there statically).
* Compile coffee to js with `coffee -c urbus_gps_map.coffee` on changes or
  change js directly.
