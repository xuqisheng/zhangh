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
from bs4 import BeautifulSoup


r = requests.get('http://www.dy2018.com')

def gethtml(url):






if __name__ == '__main__':
    get_url = 'http://www.dy2018.com/html/gndy/dyzz/index.html'
    page = gethtml(get_url)
