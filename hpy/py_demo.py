#!/usr/bin/env python
#coding=utf-8
from __future__ import print_function   # 将print从语言语法中移除，让你可以使用函数的形式
from collections import OrderedDict     # 字典排序
import pprint                           # 美观打印数据结构
import sys

'''
测试数据类型的bool情况
None、 0、空字符串、以及没有元素的容器对象都可视为 False，反之为 True
map()是 Python 内置的高阶函数，它接收一个函数 f 和一个 list，
并通过把函数 f 依次作用在 list 的每个元素上，得到一个新的 list 并返回
'''
'''
print map(bool,[None,0,dict(),tuple(),list(),set(),1])

print sys.path

dictTest = OrderedDict()
print type(dictTest),type(1.1),type(1)

str1 = "model name	: Intel(R) Xeon(R) CPU           E5620  @ 2.40GHz"
dict1 = str1.split(':')
dict2 = str1.split(':')[0].strip()
dict3 = str1.split(':')[1].strip()
print dict2,'<--->',dict3
'''

