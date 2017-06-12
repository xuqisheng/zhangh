#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :ExcelDemo.py
@time   :2017/6/12 15:57
@remark : Execl 处理 示例
"""


import xlrd,sys

# 打开需编辑的execl文件
def open_excel(file='file.xls'):
    try:
        data = xlrd.open_workbook(file)
        return data
    except Exception,e:
        print str(e)

def excel_byindex(file='file.xls',colnameindex=0,by_index=0):
    data = open_excel(file)
    table = data.sheets()[by_index]
    nrows = table.nrows # 行数
    nclos = table.ncols # 列数

