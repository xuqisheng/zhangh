#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :main.py
@time   :2017/6/25 7:54
@remark : 用于执行爬虫
"""
from scrapy import cmdline
# 链家杭州
# cmdline.execute("scrapy crawl lianjiahz".split())
# 链家上海
# cmdline.execute("scrapy crawl lianjiash".split())

# 输出csv格式
# cmdline.execute("scrapy crawl lianjiash -o lianjiash.csv".split())
# 输入json格式
cmdline.execute("scrapy crawl lianjiash -o lianjiash.json".split())
