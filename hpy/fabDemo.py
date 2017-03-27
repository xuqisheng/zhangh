#!/etc/bin/env python
# coding:utf-8

from fabric.api import *

env.user = 'root'
env.hosts = ['192.168.1.250']
env.port = 3305

def test():
    run("uname -s")
    run("/root/mode/seecfg -s 'show databases'")

# fab -f fabDemo.py test