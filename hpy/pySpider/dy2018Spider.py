#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :dy2018Spider.py
@time   :2017/7/10 21:50
@remark : 对电影天堂进行爬虫，获取相关信息，比如 电影名称、下载地址、更新日期、点击次数
"""

import requests

r = requests.get('http://www.dy2018.com')
print type(r)
print r.status_code
print r.encoding
print r.cookies
print r.text
