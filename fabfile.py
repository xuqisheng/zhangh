#!/etc/bin/env python
# coding:utf-8

from fabric.api import local, settings, abort
from fabric.contrib.console import confirm
from fabric.api import *

# GcEng61的连接
# env.hosts = ['192.168.0.61']
# env.port  = 1300

env.user  = 'root'
env.hosts = ['114.251.134.199']
env.port  = 3305
# env.password='deviskaifa'
# env.key_filename = "/root/.ssh/huiRsa"
env.key_filename = "D:\Python27\huiRsa"

def test():
    run('hostname')

def hello():
    if confirm("Welcome Hello. Continue anyway?"):
        print "^_^ Hello World !!!"

# 上传本地文件到远程主机
def put_file():
    put('D:\Python27\zhangh\hpy\pyBase\mntOS.py','/root/')

# 将本地文件上传至Gc61服务器
def put61():
    put('D:\Python27\zhangh\hbox\*.tar.gz','/root/zhangh/hbox')

    # 脚本上传时注意格式转化
    # run('dos2unix /root/zhangh/pyInstBase')
    # run('chmod u+x /root/zhangh/pyInstBase')

# 从远程主机下文件到本地
def get_file():
    get('/etc/hosts','D:\Python27')