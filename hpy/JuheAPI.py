#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :JuheAPI.py
@time   :2017/7/15 16:36
@remark :
"""


import json, urllib
from urllib import urlencode

# ----------------------------------
# 股票数据调用示例代码 － 聚合数据
# 在线接口文档：http://www.juhe.cn/docs/21
# ----------------------------------


# 沪深股市
def request1(appkey, m="GET"):
    url = "http://web.juhe.cn:8080/finance/stock/hs"
    params = {
        "gid": "sh6000519",  # 股票编号，上海股市以sh开头，深圳股市以sz开头如：sh601009
        "key": appkey,  # APP Key

    }
    print params
    params = urlencode(params)
    if m == "GET":
        f = urllib.urlopen("%s?%s" % (url, params))
    else:
        f = urllib.urlopen(url, params)

    content = f.read()
    res = json.loads(content)
    if res:
        error_code = res["error_code"]
        if error_code == 0:
            # 成功请求
            print res["result"]
        else:
            print "%s:%s" % (res["error_code"], res["reason"])
    else:
        print "request api error"


def main():
    # 配置您申请的APPKey
    appkey = "bdc3330f8c75d7fae86bd838c957dfcb"

    # 1.沪深股市
    request1(appkey, "GET")


if __name__ == '__main__':
    main()