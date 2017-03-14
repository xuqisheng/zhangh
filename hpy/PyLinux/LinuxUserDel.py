#!/usr/bin/env python
#coding:utf-8

import os
import re

user_list  = ['adm','lp','sync','halt','news','uucp','opertor','games','gopher']
group_list = ['adm','lp','news','uucp','games','dip','pppuers','popusers','slipusers']
user_dels = []

print type(user_list),type(group_list)

with open('/etc/passwd','r') as f:
    for line in f:
        for u in user_list:
            if re.match(r'^u:',line):
                user_dels.append(u)

print user_dels
"""
for user in user_dels:
    cmd1 = "userdel " + user
    os.system(cmd1)
"""
