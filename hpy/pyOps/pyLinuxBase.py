#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :pyLinuxBase.py
@time   :2017/5/22 13:52
@remark :使用python脚本维护Linux基本环境
"""
import os
import re


class PyLinuxBase(object):

    # 安装ansible所需的基础环境
    def ansible_base(self):

        f = open('/etc/issue', 'r')
        line = f.readline().strip('\n')
        # 正则匹配
        m = re.search(r'[0-9].[0-9]', line)
        os.system('mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup')
        if float(m.group()) >= 5.0 and float(m.group()) < 6.0:
            os.system('wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-5.repo')
        elif float(m.group()) >= 6.0 and float(m.group()) < 7.0:
            os.system('wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo')
        elif float(m.group()) >= 7.0:
            os.system('wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo')
        # 关闭文件
        f.close()
        os.system('yum makecache')
        os.system('yum install python-devel')

if __name__ == '__main__':
    zhexec = PyLinuxBase()
    zhexec.ansible_base()