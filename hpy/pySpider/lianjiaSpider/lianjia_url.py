#!/usr/bin/env python
# coding:utf-8

"""
@version:
@author :zhangh
@file   :lianjia_url.py
@time   :2017/5/6 8:28
@remark :
"""


class LianjiaUrl(object):

    def get_url(self,old_url,pageNum):

        get_new_url = old_url + "pg/"+ str(pageNum)

        if get_new_url is None or len(get_new_url) == 0:
            return None

        return get_new_url


