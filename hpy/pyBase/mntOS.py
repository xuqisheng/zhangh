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

