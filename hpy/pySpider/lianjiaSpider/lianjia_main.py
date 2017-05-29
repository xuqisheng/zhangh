#!/usr/bin/env python
# coding:utf-8

"""
@version:
@author :zhangh
@file   :lianjia_main.py
@time   :2017/5/5 21:53
@remark :
"""
from hpy.pySpider.lianjiaSpider import lianjia_download, lianjia_parser, lianjia_output, lianjia_url

class LianjiaMain(object):
    def __init__(self):
        # url管理器
        self.urls = lianjia_url.LianjiaUrl()
        # 下载器
        self.download = lianjia_download.LianjiaDownload()
        # 解析器
        self.parser = lianjia_parser.LianjiaParser()
        # 输出器
        self.output = lianjia_output.LianjiaOutput()

    def craw(self,root_url,pageMax=30):
        pageNum = 1
        while pageNum <= pageMax:
            # 循环得到url进行处理
            get_url = self.urls.get_url(root_url,pageNum)
            # 下载传的url内容
            html_text = self.download.download(get_url)
            # 解析usrl内容并返回指定内容
            housemsg  = self.parser.parse(html_text)

            pageNum = pageNum + 1

        # 输出内容，可以输出到mysql数据库或者execl谁的中
        self.output.collect(housemsg)

if __name__ == '__main__':
    root_url = "http://hz.lianjia.com/ershoufang/"
    lianjia = LianjiaMain()
    lianjia.craw(root_url,1)