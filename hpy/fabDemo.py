#!/etc/bin/env python
# coding:utf-8

from fabric.api import *

env.user = 'root'
env.hosts = ['115.159.202.175']
env.port = 3305
# env.password='xxxxxx'
env.key_filename = "D:\Python27\huiRsa"


def test():
    #run("uname -s")
    #run("/root/mode/seecode")
    run("/root/mode/seetom")



# fab -f fabDemo.py test