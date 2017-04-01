#!/etc/bin/env python
# coding:utf-8

from fabric.api import local, settings, abort
from fabric.contrib.console import confirm
from fabric.api import *

env.user = 'root'
env.hosts = ['192.168.0.28']
env.port = 3305
# env.password='xxxxxx'
env.key_filename = "/root/.ssh/huiRsa"

# hello world!!!
def hello():
    if confirm("Tests failed. Continue anyway?"):
        print "Hello World!!!"

# 部署函数
def deploy():
    pass

# 上传本地文件到远程主机
def put_file():
    put('/root/zhangh/psping','/root/')

# 从远程主机下文件到本地
def get_file():
    print 'abc'