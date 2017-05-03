#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :url_manager.py
@time   :2017/5/1 21:48
@remark :url管理器
"""

class UrlManager(object):

    def __init__(self):
        # 用于保存url，通过set方法将url保存在内存中
        # url保存一般有三种方法：1、内存,通过set集合；2、关系型数据库，比如：MySQL；3、缓存型数据库 比如：redis
        self.new_urls = set()
        self.old_urls = set()

    # 最开始传入的url
    def add_new_url(self, url):
        if url is None:
            return
        if url not in self.new_urls and url not in self.old_urls:
            self.new_urls.add(url)
    # 新的url
    def add_new_urls(self, urls):
        if urls is None or len(urls) == 0:
            return
        for url in urls:
            self.add_new_url(url)

    # 判断是否新的url
    def has_new_url(self):
        return len(self.new_urls)

    # 得到url
    def get_new_url(self):
        # 针对已经解析的url进行pop弹出
        new_url = self.new_urls.pop()
        # 将弹出的url存放至旧的集合中
        self.old_urls.add(new_url)
        return new_url

