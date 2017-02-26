#coding:utf-8

from Tkinter import *
import tkMessageBox
import urllib
import json



def music():
    text = entry.get()
    if not text:
        tkMessageBox.showinfo('温馨提示','请先输入...')
        return
    html = urllib.urlopen('http://s.music.163.com/search/get/?type=1&s=%E6%B5%B7%E9%98%94%E5%A4%A9%E7%A9%BA&limit=9').read()
    text = json.loads(html)
    music_list = text['result']['songs']
    for i in music_list:
         print i
        # listbox.insert(0,i['name'] + ())




root = Tk() # 实例窗口对象(创建窗口)
root.title('Python学院 Music播放器') # 更新标题
root.geometry('500x300+400+200')
entry = Entry(root) # 创建一个输入框 布局：
entry.pack()
button = Button(root,text='搜索',command=music)
button.pack()
listbox = Listbox(root,wid=50)
listbox.pack()
label = Label(root,text='欢迎使用Music播放器',fg='red')
label.pack()
mainloop() # 显示窗口
