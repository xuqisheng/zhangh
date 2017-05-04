#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :html_downloader.py
@time   :2017/5/1 21:48
@remark :下载器
"""
import urllib2

class HtmlDownloader(object):
    def download(self, url):
        if url is None:
            return None

        response = urllib2.urlopen(url)

        if response.getcode() != 200:
            return None

        return response.read()
