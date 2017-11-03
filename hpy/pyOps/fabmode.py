#!/etc/bin/env python
# coding:utf-8

# fab -f fabmode.py seetom
# 如何并行???

from fabric.contrib.console import confirm
from fabric.api import local, settings, abort
from fabric.api import *

# 单个服务器，通过密码连接
env.user = 'root'
env.hosts = ['192.168.12.197']
env.port = 22
env.password='zhangh'

# 单个服务器，通过私钥连接
# env.user = 'root'
# env.hosts = ['182.254.135.193','www.gcihotel.com','182.254.244.164','115.159.190.22','182.254.129.77']
# env.port = 3305
# env.key_filename = "D:\Python27\huiRsa"

# 多个服务器，通过密码连接
# env.user = 'root'
# env.hosts = ['192.168.0.61','192.168.0.62','192.168.0.63']
# env.passwords = {
#     'root@192.168.0.61 3315' : 'passwd61',
#     'root@192.168.0.62 3325' : 'passwd62',
#     'root@192.168.0.63 3335' : 'passwd63'
# }


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
    # 这里加一步判断，是否已经部署mode
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

    print('^_^ Congratulations! Mode deployment is successful!')


def ansible_com():
    # 定义文件路径
    file_dir  = 'D:\Python27\zhangh\hpy\pyOps'
    # 定义文件名，注意带\
    file_name = '\PyMntOs.py'
    # 上传文件
    put(file_dir+file_name,'/')

    # 执行文件
    run('python /' + file_name)

    #删除文件
    run('rm /' + file_name)


# 通用函数:上传、解压、执行、删除文件
def func_com():
    # 定义文件路径
    file_dir  = 'D:\Python27\zhangh\hpy\pyOps'
    # 定义文件名，注意带\
    file_name = '\PyMntOs.py'
    # 上传文件
    put(file_dir+file_name,'/')

    # 执行文件
    run('python /' + file_name)

    #删除文件
    run('rm /' + file_name)


    # put('D:\Python27\zhangh\hpy\pyOps\pyLinuxBase.py','/')
    # run('python /pyLinuxBase.py')
    #
    # put('D:\Python27\zhangh\hbox\simplejson-2.1.0.tar.gz','/')
    # run('tar -zxvf simplejson-2.1.0.tar.gz')
    # run('python /simplejson-2.1.0/setup.py install')


