#!/usr/bin/env python
# coding:utf-8

"""
@version:
@author :zhangh
@file   :lianjia_output.py
@time   :2017/5/5 21:56
@remark :
"""
import json
import sys,os
import pandas

reload(sys)
sys.setdefaultencoding('utf-8')


class LianjiaOutput(object):
    def collect(self, housemsg):
        # print json.dumps(housemsg, encoding='utf-8', ensure_ascii=False)

        if os.path.exists('lianjia_ershoufang.xlsx'):
            os.remove('lianjia_ershoufang.xlsx')

        df = pandas.DataFrame(housemsg)
        df.to_excel('lianjia_ershoufang.xlsx')