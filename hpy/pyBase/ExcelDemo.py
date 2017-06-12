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
def open_excel(file='E:/pydemo.xls'):
    try:
        data = xlrd.open_workbook(file)
        return data
    except Exception,e:
        print str(e)


def excel_byindex(file='E:/pydemo.xls', colnameindex=0, by_index=0):
    data = open_excel(file)
    table = data.sheets()[by_index]
    nrows = table.nrows  # 行数
    # nclos = table.ncols  # 列数
    colnames = table.row_values(colnameindex)
    list = []

    for rownum in range(1,nrows):
        row = table.row_values(rownum)
        if row:
            app = {}
            for i in range(len(colnames)):
                app[colnames[i]] = row[i]

            list.append(app)
    return list


# 根据名称获取Excel表格中的数据   参数:file：Excel文件路径     colnameindex：表头列名所在行的所以  ，by_name：Sheet1名称
def excel_table_byname(file='E:/pydemo.xls', colnameindex=0, by_name=u'Sheet1'):
    data = open_excel(file)
    table = data.sheet_by_name(by_name)
    nrows = table.nrows  # 行数
    colnames = table.row_values(colnameindex)  # 某一行数据
    list = []
    for rownum in range(1,nrows):
         row = table.row_values(rownum)
         if row:
             app = {}
             for i in range(len(colnames)):
                app[colnames[i]] = row[i]
             list.append(app)
    return list


def main():
    tables = excel_byindex()
    for row in tables:
        print row

    tables = excel_table_byname()
    for row in tables:
        print row


if __name__=='__main__':
    main()