#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function

####################

source = 'http://www.urbus.ru/passajiram/routes/'
source_threads_xpath = '//div[@id="panel1"]'\
	'/table[@class="tbl"]//a[@class="more"]'

cache_html_for = 3600

####################

def main():
	import argparse
	parser = argparse.ArgumentParser(
		description='Pull data about all the threads'
			' that should be on the map to use later in JS.')
	parser.add_argument('dst_file', nargs='?',
		help='Dump resulting JSON to a file instead of stdout.')
	optz = parser.parse_args()

	import itertools as it, operator as op, functools as ft
	from urllib2 import urlopen
	from time import time
	import os, sys, re, tempfile, json

	from lxml.html import fromstring

	cache = os.path.join(tempfile.gettempdir(), 'urbus_thread_data.html')
	try:
		if time() - os.stat(cache).st_mtime > cache_html_for: raise OSError
	except (OSError, IOError):
		threads = urlopen(source).read()
		with open(cache, 'wb') as tmp: tmp.write(threads)
	else: threads = open(cache, 'rb').read()

	try: threads = fromstring(threads)
	except SyntaxError: # last resort for "tag soup"
		from lxml.html.soupparser import fromstring
		threads = fromstring(threads)
	threads = map(op.attrgetter('text'), threads.xpath(source_threads_xpath))

	json.dump( threads,
		sys.stdout if not optz.dst_file else open(optz.dst_file, 'wb') )

if __name__ == '__main__': main()
