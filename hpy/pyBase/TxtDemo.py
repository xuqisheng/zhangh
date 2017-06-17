#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :TxtDemo.py
@time   :2017/6/17 6:53
@remark :
"""
# import pandas as pd
# 读取所有内容，并输出
# with open('D:\crshotel.txt','r') as f:
#     txtihotel = []
#     for line in f.readlines():
#         temp = line.split('\t')
#         txtihotel.append(temp)
#
#     # print txtihotel
#
# frame = pd.DataFrame(txtihotel)
# # frame.to_excel('D:\crshotel.xls')
# frame.to_csv('D:\crshotel.csv')

# 读取两行内容，并输出
# with open('D:\crshotel.txt','r') as f:
#     # temp = f.readline().split('\t')
#     # print temp
#     count = 0
#     txtihotel=[]
#     for line in f.readlines():
#         temp = line.split('\t')
#         txtihotel.append(temp)
#
#         count = count + 1
#         if count >= 2:
#             break
#
#     print txtihotel
