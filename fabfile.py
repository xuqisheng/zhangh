#!/etc/bin/env python
# coding:utf-8


from fabric.api import local, settings, abort
from fabric.contrib.console import confirm
from fabric.api import *

# hello world!!!
def hello():
    if confirm("Tests failed. Continue anyway?"):
        print "Hello World!!!"

# 部署函数
def deploy():
    pass

# 上传本地文件到远程主机
def put_file(source_file,object_file):
    print source_file ,'<-->',object_file

# 从远程主机下文件到本地
def get_file():
    print 'abc'