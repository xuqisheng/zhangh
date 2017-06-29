#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :lianjiahz.py
@time   :2017/6/22 21:52
@remark : 上海链家二手房
"""
from scrapy import Selector, settings
from scrapy.spider import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor
# ..items 表示上级目录
from ..items import LianjiaItem


class LianjiaHz(CrawlSpider):
    # 爬虫名
    name = "lianjiash"
    # 若未指定其他的url，以start_urls中的链接为入口爬取
    start_urls = ['http://sh.lianjia.com/ershoufang/']

    # 带着cookie向网页请求
    # cookie = settings['COOKIE']

    rules = (
        Rule(LinkExtractor(allow='ershoufang', ), callback='parse_lianjia', follow=True),
        Rule(LinkExtractor(allow='ershoufang/.*\.html',), callback='parse_lianjia', follow=True),
    )

    # 分析一个具体房源的页面信息
    def parse_lianjia(self, response):
        def deal_item(item):
            new_item = LianjiaItem()
            for key, value in item.items():
                if isinstance(value, list) and value:
                    new_item[key] = value[0].strip().strip('\n').strip('\t').strip('\n')
                else:
                    new_item[key] = value
            return new_item

        item = LianjiaItem()
        sel = Selector(response)
        content = sel.xpath("//body")
        # url地址
        item['page_url'] = response.url
        # 小区名称
        item['house_name'] = content.xpath("//aside[@class='content-side']/ul[@class='maininfo-minor maininfo-item']"
                                           "//span[@class='maininfo-estate-name']"
                                           "/a[@gahref='ershoufang_gaiyao_xiaoqu_link']/text()").extract()
        # 总价
        item['total_price'] = content.xpath("//aside[@class='content-side']/div[@class='maininfo-price maininfo-item']"
                                            "/div[@class='price-total']/span[@class='price-num']/text()").extract()
        # 单价
        item['unit_prcie'] = content.xpath("//aside[@class='content-side']/div[@class='maininfo-price maininfo-item']"
                                           "/div[@class='price-unit']//span[@class='u-bold']/text()").extract()
        # 所在地址
        item['house_address'] = content.xpath("//aside[@class='content-side']/ul[@class='maininfo-minor maininfo-item']"
                                              "//span[@class='item-cell maininfo-estate-address']/text()").extract()
        # 房层户型
        item['house_type'] = content.xpath("//aside[@class='content-side']/ul[@class='maininfo-main maininfo-item']"
                                           "/li[@class='main-item']/p[@class='u-fz20 u-bold']/text()").extract()
        # 楼层
        item['house_layout'] = content.xpath("//aside[@class='content-side']/ul[@class='maininfo-main maininfo-item']"
                                             "/li[@class='main-item u-tc']//p[@class='u-mt8 u-fz12']/text()").extract()
        # 朝向
        item['house_direction']=content.xpath("//aside[@class='content-side']/ul[@class='maininfo-main maininfo-item']"
                                              "/li[@class='main-item u-tc']//p[@class='u-fz20 u-bold']/text()").extract()
        # 装修情况
        item['house_decorate'] = content.xpath("//aside[@class='content-side']/ul[@class='maininfo-main maininfo-item']"
                                               "/li[@class='main-item']/p[@class='u-mt8 u-fz12']/text()").extract()
        # 建筑面积
        item['house_area'] = content.xpath("//aside[@class='content-side']/ul[@class='maininfo-main maininfo-item']"
                                           "/li[@class='main-item u-tr']/p[@class='u-fz20 u-bold']/text()").extract()
        # 建筑时间
        item['house_year'] = content.xpath("//aside[@class='content-side']/ul[@class='maininfo-main maininfo-item']"
                                           "/li[@class='main-item u-tr']/p[@class='u-mt8 u-fz12']/text()").extract()

        return deal_item(item)

