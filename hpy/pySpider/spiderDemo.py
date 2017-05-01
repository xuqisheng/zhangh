#!/usr/bin/env python
# coding:utf8


# import urllib2
#
# req = urllib2.urlopen('http://www.baidu.com')
# print req.getcode()
# print len(req.read())
#
# req1 = urllib2.urlopen('http://www.ihotel.cn')
# print req1.getcode()
# print len(req1.read())

# try:
#     urllib2.urlopen(req)
# except urllib2.HTTPError, e:
#     print e.code
# except urllib2.URLError, e:
#     print e.reason
# else:
#     print "OK"

# import requests
#
# r=requests.get('http://www.ihotel.cn')
# print type(r)
# print r.status_code
# print r.encoding
# print r.cookies

from bs4 import BeautifulSoup

html_doc = """
<html><head><title>The Dormouse's story</title></head>
<body>
<p class="title"><b>The Dormouse's story</b></p>

<p class="story">Once upon a time there were three little sisters; and their names were
<a href="http://example.com/elsie" class="sister" id="link1">Elsie</a>,
<a href="http://example.com/lacie" class="sister" id="link2">Lacie</a> and
<a href="http://example.com/tillie" class="sister" id="link3">Tillie</a>;
and they lived at the bottom of a well.</p>

<p class="story">...</p>
"""

soap = BeautifulSoup(html_doc,'html.parser',from_encoding='utf-8')
links = soap.find_all('a')

for link in links:
    print link.name,link['href'],link.get_text()
