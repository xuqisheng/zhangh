#!/usr/bin/env python
# coding:utf-8

"""
@version:
@author :zhangh
@file   :lianjia_parser.py
@time   :2017/5/5 21:56
@remark :解析器
"""
import re
from bs4 import BeautifulSoup
from hpy.pySpider.lianjiaSpider import lianjia_download


class LianjiaParser(object):
    # 解析子url，得到明细数据
    def __init__(self):
        self.download = lianjia_download.LianjiaDownload()

    def get_detail(self,sub_url,j):
        # 所在区域、小区名称、房屋总价、平方均价、房屋户型、建筑面积、房屋朝向、装修情况、配备电梯、梯户比例、产权年限、房屋年限
        info = {}

        # print j,'<-->',sub_url
        sub_text = self.download.download(sub_url)
        sub_soup = BeautifulSoup(sub_text, 'html.parser')

        sub_overview = sub_soup.select(".overview .content .price span")
        # print sub_overview
        info['房屋总价'] = ''.join(list(re.compile('<span class="total">(.*?)</span>').findall(str(sub_overview))))
        info['平方均价'] = ''.join(list(re.compile('<span class="unitPriceValue">(.*?)<i>').findall(str(sub_overview))))

        # 为什么一样写法，此处取得结果是乱码 ?
        # sub_around1 = sub_soup.select(".overview .content .aroundInfo .communityName a")
        # print sub_around1
        # info['小区名称'] = ''.join(list(re.compile('<a class="info".*?target="_blank">(.*?)</a>').findall(str(sub_around1))))
        # sub_around2 = sub_soup.select(".overview .content .aroundInfo .areaName a")
        # print sub_around2
        # info['所在区域'] = ''.join(list(re.compile('<a href=.*?target="_blank">(.*?)</a>').findall(str(sub_around2))))
        sub_around1 = sub_soup.find('a', class_='info')
        # print sub_around1.contents
        info['小区名称'] = ''.join(sub_around1.contents)
        sub_around2 = sub_soup.find('span', class_='info')
        a1 = ''.join(list(re.compile('<a href=.*?target="_blank">(.*?)</a>').findall(str(sub_around2.contents[0]))))
        a2 = ''.join(list(re.compile('<a href=.*?target="_blank">(.*?)</a>').findall(str(sub_around2.contents[2]))))
        info['所在区域'] = a1 + a2

        sub_intro = sub_soup.select(".introContent .content li")
        # print sub_intro
        for sub_label in sub_intro:
            # 使用正则，取得dict的key
            re_key = ''.join(list(re.compile('<span class="label">(.*?)</span>').findall(str(sub_label))))
            # 使用正则，取得dict的value
            re_value = ''.join(list(re.compile('<span class="label">.*?</span>(.*?)</li>').findall(str(sub_label))))
            info[re_key] = re_value

        return info

    # 传入主url,解析出子url
    def parse(self, html_text):

        if html_text is None or len(html_text) == 0:
            return None

        housemsg = []
        soup = BeautifulSoup(html_text, 'html.parser')

        # 目前链家网一页显示30个信息
        for j in range(0,2):
            # 通过 CSS 选择器
            sub_url=soup.select(".sellListContent .title a")[j]['href']
            houseinfo = self.get_detail(sub_url,j)

            housemsg.append(houseinfo)

        return housemsg



