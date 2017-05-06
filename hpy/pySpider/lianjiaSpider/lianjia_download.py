#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :lianjia_download.py
@time   :2017/5/5 21:57
@remark : 下载器
"""
import urllib2
import random

class LianjiaDownload(object):
    def __init__(self):

        self.user_agent = 'Mozilla/5.0 (compatible; MSIE 5.5; Windows NT)'
        # self.user_agent = 'Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.1.6) Gecko/20091201 Firefox/3.5.6'
        # 初始化headers
        self.headers = {'User-Agent': self.user_agent}
        self.ip_list = ['111.202.121.198:8118','111.39.186.151:8123','180.170.102.218:8118','27.18.122.157:8998']

    def download(self, url):
        if url is None:
            return None
        try:
            # 参数是一个字典{'类型':'代理ip:端口号'}
            proxy_support = urllib2.ProxyHandler({'http':random.choice(self.ip_list)})
            opener = urllib2.build_opener(proxy_support)
            urllib2.install_opener(opener)
            # 构建请求的request
            request = urllib2.Request(url, headers=self.headers)
            # 利用urlopen获取页面代码
            response = urllib2.urlopen(request)

            # 判断是否正常返回
            # if response.getcode() != 200:
            #     return None
            #
            pageCode = response.read().decode('utf-8')
            return pageCode
        except urllib2.URLError,e:
            if hasattr(e,"reason"):
                print u"连接失败，错误原因",e.reason
                return None