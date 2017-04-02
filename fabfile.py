#!/etc/bin/env python
# coding:utf-8

from fabric.api import local, settings, abort
from fabric.contrib.console import confirm
from fabric.api import *

env.user  = 'root'
env.hosts = ['192.168.2.69']
env.port  = 22
# env.password='action'
# env.key_filename = "/root/.ssh/huiRsa"
env.key_filename = "D:\Python27\huiRsa"

# hello world!!!
def hello():
    if confirm("Tests failed. Continue anyway?"):
        print "Hello World!!!"

# 部署 mode
def deploy_mode():
    get_mode()
    exec_mode()

# 下载 mode 并 解压
def get_mode():
    if confirm("DownLoad recent mode & packages?"):
        with cd('/'):
            run('wget http://www.ipms.cn:8090/mode.tar.gz')
            run('wget http://www.ipms.cn:8090/packages.tar.gz')
            run('tar zxvf mode.tar.gz')
            run('tar zxvf packages.tar.gz')

# 执行 mode 安装
def exec_mode():
    put('D:\Python27\zhangh\mntOS', '/root')

    # run('chmod u+x /root/mntOS')
    # run('/root/mntOS')

    run('/root/mode/settz')
    run('/root/mode/disusb')
    run('/root/mode/install.sh')
    run('/root/mode/inst_mysql')
    run('/root/mode/config_mem max')

    # run('rm -Rf /root/mntOS')



# 上传本地文件到远程主机
def put_file():
    put('D:\Python27\zhangh\mntOS','/root/')

# 从远程主机下文件到本地
def get_file():
    get('/root/zhangh/dbapp','D:\Python27')