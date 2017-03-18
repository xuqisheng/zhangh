#!/usr/bin/env python
#coding:utf-8

import os
import re

# 删除不必要的用户
user_list  = ['adm','lp','sync','halt','news','uucp','opertor','games','gopher']
user_dels  = []
with open('/etc/passwd','r') as f:
    for line in f:
        for user in user_list:
            if re.match(user,line):
                user_dels.append(user)

for u in user_dels:
    cmd_u = "userdel " + u
    os.system(cmd_u)

# 删除不必要的用户组
group_list = ['adm','lp','news','uucp','games','dip','pppuers','popusers','slipusers']
group_dels = []
with open('/etc/group','r') as f:
    for line in f:
        for group in user_list:
            if re.match(group,line):
                user_dels.append(group)

for g in user_dels:
    cmd_g = "groupdel " + g
    os.system(cmd_g)

# 关闭不必要的服务
services_list = ['anacron','auditd','autofs','avahi-daemon','avahi-dnsconfd','bluetooth','cpuspeed','firstboot','gpm',
                 'haldaemon','hidd','ip6tables','ipsec','isdn','lpd','mcstrans','messagebus','netfs','nfs','nfslock',
                 'nscd','readahead_early','restorecond','rpcgssd','rpcidmapd','rstatd','setroubleshoot']

for sers in services_list:
    cmd_s = "chkconfig --level 345 " + sers + " off"
    os.system(cmd_s)