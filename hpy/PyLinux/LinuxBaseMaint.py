#!/usr/bin/env python
#coding:utf-8

import os
import re

user_list  = ['adm','lp','sync','halt','news','uucp','opertor','games','gopher']
group_list = ['adm','lp','news','uucp','games','dip','pppuers','popusers','slipusers']
user_dels  = []
group_dels = []
# 删除不必要的用户
with open('/etc/passwd','r') as f:
    for line in f:
        for user in user_list:
            if re.match(user,line):
                user_dels.append(user)

for u in user_dels:
    cmd1 = "userdel " + u
    os.system(cmd1)
# 删除不必要的用户组
with open('/etc/group','r') as f:
    for line in f:
        for group in user_list:
            if re.match(group,line):
                user_dels.append(group)

for g in user_dels:
    cmd2 = "groupdel " + g
    os.system(cmd2)

