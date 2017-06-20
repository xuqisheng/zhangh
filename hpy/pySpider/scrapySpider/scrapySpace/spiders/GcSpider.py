#!/usr/bin/env python
# coding:utf-8

"""
@version:
@author :zhangh
@file   :GcSpider.py
@time   :2017/6/4 12:13
@remark :
"""

import scrapy


class GcSpider(scrapy.Spider):

    # 必须定义
    # 在 scrapySpace 目录下执行 scrapy crawl ihotel
    # 爬虫的名字，必须唯一（如果在控制台使用的话，必须配置）
    name = "ihotel"

    # 初始urls  爬虫初始爬取的链接列表
    start_urls = ["http://www.ihotel.cn"]

    # 默认response处理函数
    def parse(self, response):
        # 把结果写到文件中
        filename = "D:\iHotel.txt"
        with open(filename, 'wb') as f:
            f.write(response.body)
        # print response.body