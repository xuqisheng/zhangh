#!/etc/bin/env python
# coding:utf-8

# fab -f fabmode.py seetom

from fabric.api import *

env.user = 'root'
env.hosts = ['115.159.202.175']
env.port = 3305
# env.password='xxxxxx'
env.key_filename = "D:\Python27\huiRsa"

def get_message():
    run('cat /etc/issue;df;free')

def seetom():
    # 远程切换目录
    with cd('/root/mode'):
        run("./seetom")

def seecode():
    run("/root/mode/seecode")

def jvstat():
    run('/root/mode/jvstat')

def eval_app():
    run('/root/mode/eval_app -ll')

def showlist():
    run("/root/mode/seecfg 'show processlist'")

def showdb():
    run("/root/mode/seecfg 'show databases'")

def showuser():
    run("/root/mode/.do1au")



