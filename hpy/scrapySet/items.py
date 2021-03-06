# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

# 保存了爬取到得数据

# 爬取的主要目标就是从非结构性的数据源提取结构性数据

import scrapy


class LianjiaItem(scrapy.Item):
    # Field 对象对接受的值没有任何限制
    # page_url = scrapy.Field()           # 爬的url
    house_name = scrapy.Field()         # 小区名称
    total_price = scrapy.Field()        # 总价
    unit_prcie = scrapy.Field()         # 单价
    house_address = scrapy.Field()      # 所在地址
    house_type = scrapy.Field()         # 房层户型
    house_layout = scrapy.Field()       # 楼层
    house_direction = scrapy.Field()    # 朝向
    house_decorate = scrapy.Field()     # 装修情况
    house_area = scrapy.Field()         # 建筑面积
    house_year = scrapy.Field()         # 建筑时间
