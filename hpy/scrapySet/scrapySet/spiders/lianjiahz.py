#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :lianjiahz.py
@time   :2017/6/22 21:52
@remark : 杭州链家二手房
"""
import scrapy
from scrapy.spider import CrawlSpider

class LianjiaHz(CrawlSpider):

    name = "lianjiahz"
    allowed_domains = ["hz.lianjia.com"]
    start_urls = ('http://hz.lianjia.com/ershoufang/')
