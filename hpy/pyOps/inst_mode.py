#!/etc/bin/env python
# coding:utf-8

import os,re

# yum remove
os.system('yum remove mysql')

# 打开文件
f = open('/etc/issue','r')
line = f.readline().strip('\n')
# 正则匹配
m = re.search(r'[0-9].[0-9]',line)

if float(m.group()) >= 6.3:
    os.system('rpm -qa | grep -i mysql | xargs rpm -e --nodeps')
    os.system('yum install ld-linux.so.2')
else:
    pass

# 关闭文件
f.close()

# 开始安装mode
os.system('/root/mode/settz')
os.system('/root/mode/disusb')

# 如何解决install.sh中read交互输入的问题?
os.system('export HBLACKBOX2=1;/root/mode/install.sh')

# export HBLACKBOX2=1;用于解决确认执行脚本过程中提交是否输入y/n的问题
os.system('export HBLACKBOX2=1;/root/mode/inst_mysql')
os.system('export HBLACKBOX2=1;/root/mode/config_mem max')


