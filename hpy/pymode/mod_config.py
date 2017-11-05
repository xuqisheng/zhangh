#!/usr/bin/env python
# coding:utf8

"""
@version:
@author : zhangh
@file   :
@time   : 2017/11/5
@remark : 对应 mode_config
          对配置文件配置的添加和修改
"""
import sys
import os

Hparams = sys.argv[1:]
Hconfigfile = Hparams[0]
Hconfigitem = Hparams[1]
Hafteritem  = Hparams[2]

# print(Hparams)
# print(Hconfigfile,"-",Hconfigitem,"-",Hafteritem)

# 检查配置文件是否存在
if Hconfigfile is None:
    print("Configuration file not provided!")
elif not os.path.isfile(Hconfigfile):
    print("File " + Hconfigfile + " doesn't exist!")

# 检查参数有效性
if Hconfigitem is None:
    print("Configuration item not provided!")
elif expression:
    pass


