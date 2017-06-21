#!/usr/bin/env python
# coding=utf-8

# import os
#
# fileSize = round(os.path.getsize('E:\Software\Git_2.12_64.exe') / (1024*1024.00),2)
# print fileSize


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



#
# info={}
# info['a'] = u'350'
# info['测试中文'] = u"树园"
# print json.dumps(info,encoding='utf-8',ensure_ascii=False)


# import os,time,datetime
#
#
# # f=open('D:\Python27\huiRsa')
# file_msg = os.stat('D:\Python27\README.txt')
#
# # mtime = time.ctime(os.path.getmtime('D:\Python27\huiRsa'))
# # ltime = time.ctime()
# abc=datetime.datetime.fromtimestamp(time.time())
# a1 = datetime.datetime.now()
# print abc,'###',a1
# # mtime = time.ctime(file_msg.st_mtime)
# a2 = datetime.datetime.fromtimestamp(file_msg.st_mtime)
# a3 = (a1-a2).days
#
# if a3 > 10:
#     print "OK"
# else:
#     print "No"
#
# print a3 in


# filemt= time.localtime(os.stat('D:\Python27\huiRsa').st_mtime)
# print time.strftime("%Y-%m-%d",filemt)


# from datetime import *
#
# print datetime.now()


# import sys
#
# a = sys.argv[0]
# b = sys.argv[1]
#
# print a,'<-->',b


# import win32api,win32con
# win32api.MessageBox(win32con.NULL, u'Python 你好！', u'你好', win32con.MB_OK)

# from Tkinter import *
# root = Tk()
# lb = Listbox(root)
# # for item in ['A1','A2','A3']:
# #     lb.insert(1,item)
# lb.insert(1,'A1','A2','A3')
# lb.insert(1,'B1','B2','B3')
# lb.pack()
# root.mainloop()

# import Tkinter
#
#
# class Application(Tkinter.Frame):
#     def __init__(self, master):
#         Tkinter.Frame.__init__(self, master)
#         self.master.minsize(width=256, height=256)
#         self.master.config()
#         self.pack()
#
#         self.main_frame = Tkinter.Frame()
#
#         self.some_list = [
#             'One',
#             'Two',
#             'Three',
#             'Four'
#         ]
#
#         self.some_listbox = Tkinter.Listbox(self.main_frame)
#
#         # bind the selection event to a custom function
#         # Note the absence of parentheses because it's a callback function
#         self.some_listbox.bind('<<ListboxSelect>>', self.listbox_changed)
#         self.some_listbox.pack(fill='both', expand=True)
#         self.main_frame.pack(fill='both', expand=True)
#
#         # insert our items into the list box
#         for i, item in enumerate(self.some_list):
#             self.some_listbox.insert(i, item)
#
#         # make a label to show the selected item
#         self.some_label = Tkinter.Label(self.main_frame, text="Welcome to SO!")
#         self.some_label.pack(side='top')
#
#         # not really necessary, just make things look nice and centered
#         self.main_frame.place(in_=self.master, anchor='c', relx=.5, rely=.5)
#
#     def listbox_changed(self, *args, **kwargs):
#         selection_index = self.some_listbox.curselection()
#         selection_text = self.some_listbox.get(selection_index, selection_index)
#         self.some_label.config(text=selection_text)
#
# root = Tkinter.Tk()
# app = Application(root)
# app.mainloop()

from Tkinter import *
from tkFileDialog   import askopenfilename

def callback():
    name= askopenfilename()
    print name

errmsg = 'Error!'
Button(text='File Open', command=callback).pack(fill=X)
mainloop()