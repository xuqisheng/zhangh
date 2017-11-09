#!/usr/bin/env python
# coding:utf8

"""
@version:
@author : zhangh
@file   :
@time   : 2017/11/5
@remark : 对应 mod_config
          对配置文件配置的添加和修改
"""
import sys
import os, re

# 需要修改的文件
config_file = sys.argv[1:][0]
# 文件的值
config_item = sys.argv[1:][1]
# 文件中分类，用于判断值添加在什么位置
after_item  = sys.argv[1:][2]

# 检查配置文件是否存在
if config_file is None:
    print("Configuration file not provided!") & exit(1)
elif not os.path.isfile(config_file):
    print("File " + config_file + " doesn't exist!") & exit(1)

# 检查参数有效性
if config_item is None:
    print("Configuration item not provided!") & exit(1)
elif re.compile(r'=.*=').search(config_item):
    print("More than 1 \"=\" in Configuration item is not allowed!") & exit(1) 

# 提取Hconfigitem中等号前后内容
item_name  = ""
item_value = ""
if config_item.find("=") > 0:
    item_name  = re.sub(r'=', "", re.compile(r'(^.*)=').search(config_item).group(0)).strip()
    item_value = re.sub(r'=', "", re.compile(r'=(.*)').search(config_item).group(0)).strip()

# print(item_name, '<->', item_value)

'''
判断文件中 item_name 是否存在，如果不存在，在配置文件中增加 config_item
如果存在，但是不相等，替换为新的 item_value
'''
try:
    with open(config_file, 'r', encoding="utf-8") as file_read:
        lines = file_read.readlines()
    with open(config_file, 'w', encoding="utf-8") as file_write:
        for line in lines:
            if item_name != "" and line.strip().find("=") > 0:
                if re.sub(r'=', "", re.compile(r'(^.*)=').search(line.strip()).group(0)).strip() == item_name:
                    if re.sub(r'=', "", re.compile(r'=(.*)').search(line.strip()).group(0)).strip() != item_value:            
                        line = line.replace(line.strip() ,config_item)
            file_write.write(line)

    file_write.close()
    file_read.close()
finally:
    if file_write or file_read:
        file_write.close()
        file_read.close()
