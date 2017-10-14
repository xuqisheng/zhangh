#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :GetIP138.py
@time   :2017/6/19 13:30
@remark : 从 ip138网站上获取本机的外网IP地址
"""
import requests


class GetIP138(object):
    def __init__(self):
        self.url = r'http://2017.ip138.com/ic.asp'

    def getip_main(self):
        response = requests.get(self.url)
        # 设置 字符集
        response.encoding = 'gbk'
        # print response.text
        # print response.json()
        txt = response.text
        print(txt)
        # find 返回int ，采用切片方式返回结果
        ip = txt[txt.find("[") + 1:txt.find("]")]
        print(u'本机外网ip地址:' + ip)
        return ip


if __name__ == '__main__':
    getip = GetIP138()
    getip.getip_main()

