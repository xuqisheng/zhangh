#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :lianjiahz.py
@time   :2017/6/22 21:52
@remark : 杭州链家二手房
"""
from scrapy import Selector
from scrapy.spider import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor
# ..items 表示上级目录
from ..items import LianjiaItem


class LianjiaHz(CrawlSpider):
    # 爬虫名
    name = "lianjiahz"
    # allowed_domains = ["hz.lianjia.com"]
    # 若未指定其他的url，以start_urls中的链接为入口爬取
    start_urls = ['http://sh.lianjia.com/ershoufang/']

    # start_urls = ['http://www.ihotel.cn']
    def parse(self, response):
        sel = Selector(response)
        content = sel.xpath("//body//div[@class='content']")
        totalPrice = content.xpath("//span[@class='total-price strong-num']/text()").extract()
        print totalPrice

    """
    # 带着cookie向网页请求
    cookie = settings['COOKIE']
    # 发送给服务器的http头信息，有的网站需要伪装出浏览器头进行爬取，有的则不需要
    headers = {
        'Connection': 'keep-alive',
        'User-Agent': 'Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.1.6) Gecko/20091201 Firefox/3.5.6'
    }
    # 对请求的返回值进行处理
    meta = {
        'dont_redirect': True,    # 禁止网页重定向
        'handle_httpstatus_list': [301, 302]
    }
    """
    # rules = (
        # Rule(LinkExtractor(allow='ershoufang/[0-9]*\.html',), callback='parse_lianjia', follow=True),
    #     Rule(LinkExtractor(allow='ershoufang',), callback='parse_lianjia', follow=True),
    # )

    # # 分析一个具体房源的页面信息
    # def parse_lianjia(self, response):
    #     item = LianjiaItem()
    #     content = response.xpath("//body/div[@class='content '")
    #     print content.extract()
        # item['page_url'] = response._get_url()

    #     # item['house_name'] =   # 小区名称
    #     item['total_price'] = content.xpath("//div[@class='totalPrice']/span/text()").extract() # 总价
    #     item['unti_prcie'] = content.xpath("//div[@class='unitPrice']/span/text()").extract()  # 单价
    #     # item['area_name'] =   # 所在区域
    #     # item['house_type'] =   # 房层户型
    #     # item['house_layout'] =   # 楼层
    #     # item['house_direction'] =   # 朝向
    #     # item['house_decorate'] =   # 装修情况
    #     # item['house_area'] =   # 建筑面积
    #     # item['house_farea'] =   # 实际面积
    #     # item['house_begin_sell'] =   # 挂牌时间
    #     # item['house_purpose'] =   # 房屋用途
    #     # item['house_transacton'] =   # 交易权属
    #
        # print item

