#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :toolkit.py
@time   :2017/8/24 9:56
@remark : 常用工具集
"""


# 更改用户名
import chardet
import os


def file_rename():
    path = "E:\\abc"

    for (path, dirs, files) in os.walk(path):
        for filename in files:
            # 判断下文件的编码
            # print chardet.detect(filename)
            # 列出文件夹下所有的文件
            # print filename.decode('GB2312')
            oldname = filename.decode('GB2312')
            newname = oldname.replace('绿云学院','项目部')
            print newname

file_rename()