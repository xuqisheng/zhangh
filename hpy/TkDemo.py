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


def say_hello():
    print "Hello"


# 根窗口
root = Tk()
root.title('Tkdemo 事例')
root.geometry('600x380+300+300')


# entry = Entry(root)  # 创建一个输入框 布局：显示的方式和位置
# entry.pack()
button = Button(root,text='增 加',command=say_hello)
button.pack(side=RIGHT)

button = Button(root,text='删 除',command=say_hello)
button.pack(side=BOTTOM)

# 事件循环
root.mainloop()


if __name__ == '__main__':
    pass


