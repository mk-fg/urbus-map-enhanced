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
	parser.add_argument('--debug', action='store_true', help='Verbose operation mode.')
	optz = parser.parse_args()

	import itertools as it, operator as op, functools as ft
	from urllib2 import urlopen
	from time import time
	from io import BytesIO
	import os, sys, tempfile, logging

	logging.basicConfig(
		level=logging.WARNING if not optz.debug else logging.DEBUG,
		format='%(levelname)s :: %(name)s :: %(message)s' )
	log = logging.getLogger('pull_threads')

	cache = os.path.join(tempfile.gettempdir(), 'urbus_thread_data.html')
	try:
		if time() - os.stat(cache).st_mtime > cache_html_for: raise OSError
	except (OSError, IOError):
		thread_data = urlopen(source).read()
		with open(cache, 'wb') as tmp: tmp.write(thread_data)
	else: thread_data = open(cache, 'rb').read()

	from lxml.html import fromstring, tostring
	from lxml.html.clean import Cleaner
	from lxml.etree import XMLSyntaxError

	def soup(string):
		string = bytes(string)
		try: doc = fromstring(string)
		except SyntaxError: # last resort for "tag soup"
			from lxml.html.soupparser import fromstring as soup
			doc = soup(string)
		return doc

	threads = map( op.attrgetter('text'),
		soup(thread_data).xpath(source_threads_xpath) )

	import json
	json.dump( threads,
		sys.stdout if not optz.dst_file else open(optz.dst_file, 'wb') )

if __name__ == '__main__': main()
