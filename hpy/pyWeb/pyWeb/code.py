#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :code.py.py
@time   :2017/7/15 22:20
@remark :
"""
from random import random

import web


urls = (
    '/', 'index'
)

app = web.application(urls, globals())


class index:
    def GET(self):
        return "welcome to web.py world!"

if __name__ == "__main__":
    app.run()

