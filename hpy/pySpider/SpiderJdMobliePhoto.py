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