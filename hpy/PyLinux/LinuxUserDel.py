#!/usr/bin/env python
#coding:utf-8

import os
import re

user_list  = ['adm','lp','sync','halt','news','uucp','opertor','games','gopher']
group_list = ['adm','lp','news','uucp','games','dip','pppuers','popusers','slipusers']

print type(user_list),type(group_list)

with open('/etc/passwd_bak') as f:
    for line in f:
        for u in user_list:
            if re.match(r'^u',line):
                cmd1 = "userdel " + u
                os.system(userdel u)

