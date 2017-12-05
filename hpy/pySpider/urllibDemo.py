#!/usr/bin/env python
# coding:utf8


# import urllib2

# req = urllib2.urlopen('http://www.baidu.com')
# print req.getcode()
# print len(req.read())

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

# from bs4 import BeautifulSoup

# html_doc = """
# <html><head><title>The Dormouse's story</title></head>
# <body>
# <p class="title"><b>The Dormouse's story</b></p>

# <p class="story">Once upon a time there were three little sisters; and their names were
# <a href="http://example.com/elsie" class="sister" id="link1">Elsie</a>,
# <a href="http://example.com/lacie" class="sister" id="link2">Lacie</a> and
# <a href="http://example.com/tillie" class="sister" id="link3">Tillie</a>;
# and they lived at the bottom of a well.</p>

# <p class="story">...</p>
# """

# soap = BeautifulSoup(html_doc,'html.parser',from_encoding='utf-8')
# links = soap.find_all('a')

# for link in links:
#     print link.name,link['href'],link.get_text()

import urllib.request
import urllib.error

# 常规方式，不带header
file = urllib.request.urlopen("http://www.baidu.com")
# 读取方式一
data = file.read()
print(data)
# 读取方式二
dataline = file.readline()
print(dataline)
# 读取方式三
datalines = file.readlines()
print(datalines)

# 带header的读取方式，模仿浏览器
url = "http://www.baidu.com"
headers = ("User-Agent","Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 UBrowser/6.2.3831.407 Safari/537.36")
opener = urllib.request.build_opener()
opener.addheaders = [headers]
data = opener.open(url).read()
print(data)

# POST方式认证登录
url = "http://www.baidu.com"
postdata = urllib.parse.urlencode({
    "name":"huilead",
    "pass":"abc123"
}).encode('utf-8')
req = urllib.request.Request(url,postdata)
req.add_header("User-Agent","Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 UBrowser/6.2.3831.407 Safari/537.36")
data = urllib.request.urlopen(req).read()
print(data)

# 使用代理方式进行爬虫
url = "http://www.baidu.com"
proxy_addr = "202.120.46.180:443"
proxy = urllib.request.ProxyHandler({'http':proxy_addr})
opener = urllib.request.build_opener(proxy,urllib.request.HTTPHandler)
urllib.request.install_opener(opener)
data = urllib.request.urlopen(url).read().decode('utf-8')
print(len(data)

# URLError错误捕捉
try:
    urllib.request.urlopen("http://blog.csdn.net")
except urllib.error.URLError as e:
    print(e.reason)