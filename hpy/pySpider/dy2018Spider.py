#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :dy2018Spider.py
@time   :2017/7/10 21:50
@remark : 对电影天堂进行爬虫，获取相关信息，比如 电影名称、下载地址、更新日期、点击次数
"""
import os
import pandas
import requests
import sys
from bs4 import BeautifulSoup

url_init = 'http://www.dy2018.com/html/gndy/dyzz/index.html'
url_index = 'http://www.dy2018.com'
headers = {'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/536.5 '
                         '(KHTML, like Gecko) Chrome/19.0.1084.54 Safari/536.5'}
response = requests.get(url_init, headers=headers)
response.encoding = 'gb2312'
content = response.text

soup = BeautifulSoup(content, 'html.parser')

items = soup.find_all('a', class_='ulink')

ret = []
for item in items:
    info = {}
    title = item['title']
    info['title'] = title.strip()
    href = item['href']
    info['url'] = url_index + href.strip()
    ret.append(info)

if os.path.exists('dy2018.xlsx'):
    os.remove('dy2018.xlsx')

df = pandas.DataFrame(ret)
df.to_excel('dy2018.xlsx')

