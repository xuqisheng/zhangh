#!/usr/bin/env python
# coding:utf8


import urllib2

req = urllib2.Request('http://www.baidu.com')
try:
    urllib2.urlopen(req)
except urllib2.HTTPError, e:
    print e.code
except urllib2.URLError, e:
    print e.reason
else:
    print "OK"