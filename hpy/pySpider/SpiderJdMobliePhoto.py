#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@time   :2017/12/7
@remark : 爬取京东手机图片
"""

import re
import urllib.request


def craw(url, page):
    html1 = str(urllib.request.urlopen(url).read())
    pattern1 = '<div id="plist".+? <div class="page clearfix">'
    result1 = re.compile(pattern1).findall(html1)[0]
    pattern2 = '<img width="220" height="220" data-img="1" src="//(.+?\.jpg)"'
    imagelist = re.compile(pattern2).findall(result1)
    x = 1
    for imageurl in imagelist:
        imagename = "d://myweb/"+str(page)+str(x)+".jpg"
        imageurl = "http://"+imageurl
        try:
            urllib.request.urlretrieve(imageurl,filename=imagename)
        except urllib.error.URLError as e:
            if hasattr(e,"code"):
                x += 1
            if hasattr(e,"reason"):
                x += 1
        x += 1

for i in range(1,10):
    url = "https://list.jd.com/list.html?cat=9987,653,655&page="+str(i)
    craw(url,i)