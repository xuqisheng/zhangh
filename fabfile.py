#!/etc/bin/env python
# coding:utf-8


from fabric.api import local, settings, abort
from fabric.contrib.console import confirm

# hello world!!!
def hello():
    if confirm("Tests failed. Continue anyway?"):
        print "Hello World!!!"

# 部署函数
def deploy():
    pass