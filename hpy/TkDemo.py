#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :TkDemo.py
@time   :2017/6/20 22:26
@remark :
"""
from Tkinter import *

class TkMySQL(object):
    def __init__(self,root):
        self.root = root


def say_hello():
        print "hello"


if __name__ == '__main__':
    # 根窗口
    root = Tk()
    root.title('Tkdemo 事例')
    root.geometry('600x380+300+300')

    Label(root, text="酒店代码").place(x=350, y=10, width=60, height=28)
    Label(root, text="营业点").place(x=350, y=48, width=60, height=28)

    Entry(root).place(x=410, y=10, width=90, height=28)
    Entry(root).place(x=410, y=48, width=90, height=28)

    Button(root, text='查 询', command=say_hello).place(x=200, y=20, width=60, height=28)
    Button(root, text='删 除').place(x=510, y=10, width=60, height=28)
    Button(root, text='增 加').place(x=510, y=45, width=60, height=28)

    Listbox(root).pack()

    # 事件循环
    root.mainloop()


