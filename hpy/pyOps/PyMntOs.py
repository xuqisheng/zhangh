#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :pyLinuxBase.py
@time   :2017/5/22 13:52
@remark :使用python脚本维护Linux基本环境
"""
import os,re,platform


class PyMntOs(object):

    # yum源更新，来自于阿里云
    @staticmethod
    def yum_update(releasever):
        os.system('mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup')

        if float(5) <= releasever < float(6):
            os.system('wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-5.repo')
        elif float(6) <= releasever < float(7):
            os.system('wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo')
        elif float(7) <= releasever:
            os.system('wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo')

        os.system('yum makecache')

    # 获取centos的发行版本号
    @staticmethod
    def issue_num():
        if platform.system() == 'Linux':
            f = open('/etc/issue', 'r')
            num = re.search(r'[0-9].[0-9]',f.readline().strip('\n'))
            f.close()

            return num.group()

    @staticmethod
    def yum_inst_packs():
        # python-devel 开发环境
        os.system('yum install python-devel')
        # ansible执行所需环境
        os.system('yum install python-simplejson')

    # 安装 ansible 所需的基础环境
    def ansible_base(self):
        if os.system('yum makecache') == 0:
            self.yum_inst_packs()
        else:
            num = self.issue_num()
            self.yum_update(float(num))
            self.yum_inst_packs()

if __name__ == '__main__':
    zhexec = PyMntOs()
    zhexec.ansible_base()