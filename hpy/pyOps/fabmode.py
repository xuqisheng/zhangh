#!/etc/bin/env python
# coding:utf-8

# fab -f fabmode.py seetom

from fabric.api import *

env.user = 'root'
env.hosts = ['114.251.134.199']
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

def getip():
    run("ifconfig")

def shutdown():
    run("shutdown -h now")

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

