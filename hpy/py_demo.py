#!/usr/bin/env python
#coding=utf-8

import os

fileSize = round(os.path.getsize('E:\Software\Git_2.12_64.exe') / (1024*1024.00),2)
print fileSize


'''
import tqdm
import time

for i in tqdm.tqdm(range(1000)):
    time.sleep(0.01)


测试数据类型的bool情况
None、 0、空字符串、以及没有元素的容器对象都可视为 False，反之为 True
map()是 Python 内置的高阶函数，它接收一个函数 f 和一个 list，
并通过把函数 f 依次作用在 list 的每个元素上，得到一个新的 list 并返回
print map(bool,[None,0,dict(),tuple(),list(),set(),1])

print sys.path

dictTest = OrderedDict()
print type(dictTest),type(1.1),type(1)

str1 = "model name	: Intel(R) Xeon(R) CPU           E5620  @ 2.40GHz"
dict1 = str1.split(':')
dict2 = str1.split(':')[0].strip()
dict3 = str1.split(':')[1].strip()
print dict2,'<--->',dict3

services_list = ['anacron','auditd','autofs','avahi-daemon','avahi-dnsconfd','bluetooth','cpuspeed','firstboot','gpm',
                 'haldaemon','hidd','ip6tables','ipsec','isdn','lpd','mcstrans','messagebus','netfs','nfs','nfslock',
                 'nscd','readahead_early','restorecond','rpcgssd','rpcidmapd','rstatd','setroubleshoot']
print services_list


class student(object):
    def __init__(self,name,score):
        self.name = name
        self.score = score

    def print_score(self):
        print('%s: %s' % (self.name,self.score))


dohotel_valid = student('ABC',69)
dohotel_valid.print_score()


root = Tk()
for fm in ['red','blue','yellow','green','white','black']:
    Frame(height=10, width=10, bg=fm).pack

root.mainloop()

import os

filename = 'D:\Python27\zhangh\prob1eip'
# filepath = os.path.dirname(filename)
# file = filename[len(filepath)+1:]
# print os.path.isfile(filename),filepath,'<---->', bool(filepath),'<---->',file
print os.path.isfile(filename)
'''