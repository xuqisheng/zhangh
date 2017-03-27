#!/etc/bin/env python
# coding:utf-8

from fabric.api import *

env.user = 'root'
env.hosts = ['218.25.99.195']
env.port = 3305
# env.password='xxxxxx'
env.key_filename = "D:\Python27\huiRsa"


def test():
    run("uname -s")
    run("/root/mode/seecode")



# fab -f fabDemo.py test