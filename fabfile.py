#!/etc/bin/env python
# coding:utf-8

from fabric.api import local, settings, abort
from fabric.contrib.console import confirm
from fabric.api import *

# GcEng61的连接
# env.hosts = ['192.168.0.61']
# env.port  = 1300

env.user  = 'root'
env.hosts = ['115.159.118.110','124.31.124.231','218.25.99.195','182.151.196.252']
env.port  = 3305
# env.password='deviskaifa'
# env.key_filename = "/root/.ssh/huiRsa"
env.key_filename = "D:\Python27\huiRsa"

def test():
    run('hostname')

def zhexec():
    file_put()
    file_exec()

def hello():
    if confirm("Welcome Hello. Continue anyway?"):
        print "^_^ Hello World !!!"

# 上传本地文件到远程主机
def file_put():
    put('D:\Python27\simplejson-2.1.0.tar.gz','/')

# 从远程主机下文件到本地
def file_get():
    get('/etc/hosts','D:\Python27')

def file_exec():
    with cd('/'):
        run('tar -zxvf simplejson-2.1.0.tar.gz')
        run('python /simplejson-2.1.0/setup.py install')

def file_del():
    with cd('/'):
        run('rm -Rf simplejson*')