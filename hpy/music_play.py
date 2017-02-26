#!/usr/bin/env python
# coding=utf-8
from Tkinter import *
# import Tkinter     # 两种导入方法的区别: 此行这一种导入在后续编码时，需写模块.函数  上一行在使用时，可以直接函数名,推荐上一行这种
import tkMessageBox
import urllib
import json
import mp3play
import time
import threading
import random

def music():
    text = entry.get()
    text = urllib.quote(text.encode("utf-8"))
    if not text:
        tkMessageBox.showinfo('温馨提示','请输入歌曲名字或者歌手')
        return

    url = 'http://s.music.163.com/search/get/?type=1&s=%s&limit=9' % text
    print url
    html = urllib.urlopen(url).read()
    # print type(html)
    text = json.loads(html)
    music_list = text['result']['songs']
    for ls in music_list:
        print ls
    print music_list
    global url_list
    url_list = []
    listbox.delete(0,listbox.size())
    for i in music_list:
        listbox.insert(0,i['name'] + '(' + i['artists'][0]['name'] + ')')
        url_list.append(i['audio'])

def play():
    index = listbox.curselection()[0]
    # print index
    filename = r'%s.mp3' %random.randint(1000,9999)
    # print url_list[index]
    urllib.urlretrieve(url_list[index],filename)
    mp3 = mp3play.load(filename=filename)
    mp3.play()
    # time.sleep(10)
    time.sleep(mp3.seconds())
    mp3.stop()


def th(event):
    time.sleep(2)
    thr = threading.Thread(target=play)
    thr.start()

root = Tk()     # 实例窗口对象（创建窗口）
root.title('Python Music播放器')
# root.geometry('300x200+800+400')
root.geometry('+900+300')
entry = Entry(root)  # 创建一个输入框 布局：显示的方式和位置
entry.pack()
button = Button(root,text='搜 索',command=music)
button.pack()
var = StringVar()
listbox = Listbox(root,width=50,listvariable = var)
listbox.bind('<Double-Button-1>',th)
listbox.pack()
lable = Label(root,text='欢迎使用Python Music播放器',fg='red')
lable.pack()
mainloop()  # 显示窗口

if __name__ == '__main__':
    pass