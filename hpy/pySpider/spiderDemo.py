#!/usr/bin/env python
# coding:utf8


import urllib2

res = urllib2.urlopen("http://www.ihotel.cn")
print type(res)
# print res.read()