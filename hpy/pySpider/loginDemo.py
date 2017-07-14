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
import json
import urllib
import urllib2
import requests
import sys
reload(sys)
sys.setdefaultencoding('utf-8')


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
    seesion = requests.Session()
    reponse = seesion.post(website, params=payload, headers=headers)
    # print reponse.text
    print reponse.status_code


def login_ihotel(webindex, inttype):
    payload = {'hotelGroupId': 2}
    website = webindex + inttype
    # print website
    seesion = requests.Session()
    reponse = seesion.post(website, params=payload)
    result = reponse.json()
    for item in result['listTypeDto']:
        print item['code'],item['descript']


def register(webindex, inttype):
    payload = {'hotelGroupId': 2,
               'name': u'三明',
               'idType': '02',
               'sex': 1,
               'idNo': '31011974',
               'mobile': '11231831519',
               'email': '193501466@qq.com',
               'password': '123456',
               'cardType': 'CZK',
               'cardLevel': 'CZK',
               'cardSrc': 1}

    headers = {'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8'}
    website = webindex + inttype
    # reponse = requests.post(website, params=payload, headers=headers)
    reponse = requests.post(website, data=payload, headers=headers)
    result = reponse.text
    print result

if __name__ == '__main__':
    register('http://192.168.0.28:8102/ipmsmember/membercard/', 'registerMemberCardWithOutVerify')
    # login_url('http://192.168.0.7:9394/secure/Dashboard.jspa')
    # login_request('http://192.168.0.7:9394/secure/Dashboard.jspa')
    # login_ihotel('http://192.168.0.28:8102/ipmsmember/membercard/', 'getAllCardType')

