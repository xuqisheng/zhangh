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
import sys
from bs4 import BeautifulSoup

reload(sys)
sys.setdefaultencoding('utf-8')

url_init = 'http://www.dy2018.com/html/gndy/dyzz/index.html'
headers = {'user-agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/536.5 '
                         '(KHTML, like Gecko) Chrome/19.0.1084.54 Safari/536.5'}
r = requests.get(url_init, headers=headers)
r.encoding = 'utf-8'
content = r.text

soup = BeautifulSoup(content, 'html.parser')

# items = soup.find_all('div',class_='co_content8')
items = soup.find_all('a', class_='ulink')
print items
ret = []
for item in items:
    # title = item.a.get_text()
    print type(item)
    # ret.append(title)

print ret

# if __name__ == '__main__':
#     get_url = 'http://www.dy2018.com/html/gndy/dyzz/index.html'
#     page = gethtml(get_url)
