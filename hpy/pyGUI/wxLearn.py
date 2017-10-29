#!/usr/bin/env python
# coding:utf8

"""
@version:
@author : zhangh
@file   :
@time   : 2017/10/29
@remark :
"""

import wx


class MainWindow(wx.Frame):
    def __init__(self, parent, title):
        wx.Frame.__init__(self, parent, title=title, size=(500, 300))
        self.control = wx.TextCtrl(self, style = wx.TE_MULTILINE)
        self.CreateStatusBar() # 创建位于窗口的底部的状态栏

        # 设置菜单
        filemenu = wx.Menu()
        menuAbout = filemenu.Append(wx.ID_ABOUT, u"关于", u"关于程序的信息")
        filemenu.AppendSeparator()
        menuExit = filemenu.Append(wx.ID_EXIT, u"退出", u"终止应用程序")

        # 创建菜单栏
        menuBar = wx.MenuBar()
        menuBar.Append(filemenu, u"文件")
        self.SetMenuBar(menuBar)

        # 设置Events
        self.Bind(wx.EVT_MENU, self.onabout, menuAbout)
        self.Bind(wx.EVT_MENU, self.onexit, menuExit)

        self.Show(True)

    def onabout(self, e):
        dlg = wx.MessageDialog(self, u"简易编辑器", u"关于简易编辑器", wx.OK)
        dlg.ShowModal()
        dlg.Destroy()

    def onexit(self, e):
        self.Close(True)


app = wx.App(False)
frame=MainWindow(None,'Small Editor')
app.MainLoop()