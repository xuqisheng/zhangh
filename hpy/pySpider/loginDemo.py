#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :loginDemo.py
@time   :2017/7/13 13:02
@remark : 模拟登录公司老的JIRA
"""
import cookielib
import urllib
import urllib2

import requests


def login_url(website):
    username = 'zhanghui'
    password = '1234560'
    data = {'os_username': username, 'os_password': password}
    # 将post消息转化成可以让服务器编码的方式 os_password=1qaz2wsx&os_username=zhanghui
    post_data = urllib.urlencode(data)

    # 初始化一个CookieJar来处理Cookie
    cookie = cookielib.CookieJar()

    # 创建cookie处理器
    handler = urllib2.HTTPCookieProcessor(cookie)
    # 实例化一个全局opener
    opener = urllib2.build_opener(handler)
    urllib2.install_opener(opener)

    headers = {"User-agent": "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1"}
    # post方式处理
    request = urllib2.Request(website, post_data, headers)
    response = urllib2.urlopen(request)

    # 读取cookie信息
    # for item in cookie:
    #     print 'name:' + item.name + '-value:' + item.value
    #
    print response.read()


def login_request(website):
    payload = {'os_username': 'zhanghui', 'os_password': '1234560'}
    headers = {"User-agent": "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1"}
    reponse = requests.post(website, params=payload, headers=headers)
    print reponse.status_code
    # if reponse.status_code == 200:
    #     print "登录成功"
    # else:
    #     print "登录失败"

if __name__ == '__main__':
    login_url('http://192.168.0.7:9394/secure/Dashboard.jspa')
    # login_request('http://192.168.0.7:9394/secure/Dashboard.jspa')

