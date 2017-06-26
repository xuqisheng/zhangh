#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :lianjiahz.py
@time   :2017/6/22 21:52
@remark : 上海链家二手房
"""
from scrapy import Selector
from scrapy.spider import CrawlSpider, Rule
from scrapy.linkextractors import LinkExtractor
# ..items 表示上级目录
from ..items import LianjiaItem


class LianjiaHz(CrawlSpider):
    # 爬虫名
    name = "lianjiash"
    # 若未指定其他的url，以start_urls中的链接为入口爬取
    start_urls = ['http://sh.lianjia.com/ershoufang/']

    rules = (
        Rule(LinkExtractor(allow='ershoufang/[0-9]*\.html',), callback='parse_lianjia', follow=True),
        Rule(LinkExtractor(allow='ershoufang',), callback='parse_lianjia', follow=True),
    )

    # 分析一个具体房源的页面信息
    def parse_lianjia(self, response):
        def deal_item(item):
            new_item = LianjiaItem()
            for key, value in item.items():
                if isinstance(value, list) and value:
                    new_item[key] = value[0].strip('\n').strip('\t').strip('\n')
                else:
                    new_item[key] = value.strip('\n').strip('\t').strip('\n')
            return new_item

        item = LianjiaItem()
        sel = Selector(response)
        content = sel.xpath("//body//div[@class='content']")
        item['page_url'] = response._get_url()
        # item['house_name'] =   # 小区名称
        item['total_price'] = content.xpath("//span[@class='total-price strong-num']/text()").extract() # 总价
        item['unti_prcie'] = content.xpath("//span[@class='info-col price-item minor']/text()").extract()  # 单价
        # item['area_name'] =   # 所在区域
        # item['house_type'] =   # 房层户型
        # item['house_layout'] =   # 楼层
        # item['house_direction'] =   # 朝向
        # item['house_decorate'] =   # 装修情况
        # item['house_area'] =   # 建筑面积
        # item['house_farea'] =   # 实际面积
        # item['house_begin_sell'] =   # 挂牌时间
        # item['house_purpose'] =   # 房屋用途
        # item['house_transacton'] =   # 交易权属

        return deal_item(item)

