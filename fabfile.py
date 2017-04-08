#!/etc/bin/env python
# coding:utf-8

from fabric.api import local, settings, abort
from fabric.contrib.console import confirm
from fabric.api import *

# GcEng61的连接
# env.hosts = ['183.129.215.114']
# env.port  = 1300

env.user  = 'root'
env.hosts = ['192.168.0.28']
env.port  = 3305
# env.password='action'
# env.key_filename = "/root/.ssh/huiRsa"
env.key_filename = "D:\Python27\huiRsa"

def test():
    run('uname -a')

def hello():
    if confirm("Welcome Hello. Continue anyway?"):
        print "^_^ Hello World !!!"

# 上传本地文件到远程主机
def put_file():
    put('D:\Python27\zhangh\hpy\pyBase\mntOS.py','/root/')

# 将本地文件上传至Gc61服务器
def put61():
    put('D:\Python27\zhangh\hpy\pyOps\p','/root/zhangh')

    # 脚本上传时注意格式转化
    run('dos2unix /root/zhangh/')
    run('chmod u+x /root/zhangh/pytest')

# 从远程主机下文件到本地
def get_file():
    get('/root/zhangh/dbcloud','D:\Python27')


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
    # 上传本地文件，用于CentOS6.4版本及以上的基础组件安装
    put('D:\Python27\zhangh\hpy\pyBase\mntOS.py', '/root')
    run('python /root/mntOS.py')

    run('/root/mode/settz')
    run('/root/mode/disusb')
    run('/root/mode/install.sh')
    run('/root/mode/inst_mysql')
    run('/root/mode/config_mem max')

    # 删除上传的本地文件
    run('rm -Rf /root/mntOS.py')

    print '^_^ Congratulations! Mode deployment is successful!'