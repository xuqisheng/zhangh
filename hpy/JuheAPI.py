#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :JuheAPI.py
@time   :2017/7/15 16:36
@remark :
"""


import json
import requests

# ----------------------------------
# 股票数据调用示例代码 － 聚合数据
# 在线接口文档：http://www.juhe.cn/docs/21
# ----------------------------------


# 沪深股市
def request1(appkey, m="GET"):
    url = "http://web.juhe.cn:8080/finance/stock/hs"
    params = {
        "gid": "sh600519",  # 股票编号，上海股市以sh开头，深圳股市以sz开头如：sh601009
        "key": appkey,  # APP Key

    }

    reponse = requests.get(url, params=params)

    content = reponse.text
    res = json.loads(content)

    result = res.get('result')

    print(result[0]['data'])

    """
    if res:
        error_code = res["error_code"]
        if error_code == 0:
            # 成功请求
            print res["result"]
        else:
            print "%s:%s" % (res["error_code"], res["reason"])
    else:
        print "request api error"
    """

def main():
    # 配置您申请的APPKey
    appkey = "bdc3330f8c75d7fae86bd838c957dfcb"

    # 1.沪深股市
    request1(appkey, "GET")


if __name__ == '__main__':
    main()