#!/etc/bin/env python
# coding:utf-8

import os
import re
from datetime import *


class InstMode(object):
    # 校验centos发行版本号，打补丁
    def issue_check(self):
        # 打开CentOS发行版本文件 with写法不适用于低版本的python
        # with写法更合理，但是此写法在低版本中无效
        # with open('/etc/issue','r') as issue_r:
        try:
            issue_r = open('/etc/issue', 'r')
            line = issue_r.readline().strip('\n')
            # 正则匹配
            m = re.search(r'[0-9].[0-9]', line)

            if float(m.group()) >= 6.2:
                os.system('yum install ld-linux.so.2')
            else:
                pass
        finally:
            if issue_r:
                issue_r.close()

    # mode安装的执行步骤
    def exec_mode(self,hrypasswd,apacheno):
        os.system('/root/mode/settz')
        os.system('/root/mode/disusb')

        # 如何解决install.sh中read交互输入的问题? 通过 echo "str" 加管道形式
        if apacheno == 0:
            os.system('export HBLACKBOX2=1;echo ' + hrypasswd + ' | /root/mode/install.sh')
        elif apacheno == 1:
            os.system('export HBLACKBOX2=1;echo ' + hrypasswd + ' | /root/mode/install.sh 1')
        elif apacheno == 2:
            os.system('export HBLACKBOX2=1;echo ' + hrypasswd + ' | /root/mode/install.sh 2')
        else:
            pass

        # export HBLACKBOX2=1;用于解决确认执行脚本过程中提交是否输入y/n的问题
        os.system('export HBLACKBOX2=1;/root/mode/inst_mysql')
        os.system('export HBLACKBOX2=1;/root/mode/config_mem max')
        # 删除老的jdk6
        os.system('/root/mode/gcserver stop')
        os.system('rm -Rf /usr/local/jdk6')

    # 文件中单行替换
    def file_deal(self,filename,oldcontent,newcontent):
        if os.path.exists(filename):
            file_read = open(filename,'r')
            file_lines = file_read.readlines()
            file_write = open(filename,'w')
            for line in file_lines:
                if oldcontent in line:
                    line = line.replace(oldcontent,newcontent)

                file_write.write(line)

            file_write.close()
            file_read.close()

    # 判断mysql是否需要处理
    def mysql_deal(self,mysql_index):
        # yum remove 可能会将一些依赖包都删除，风险大
        # os.system('yum remove mysql')
        # 加一个判断，表示mysql是正常在使用的
        if os.path.exists(mysql_index):
            file_msg = os.stat(mysql_index)
            os_time = datetime.now()
            file_mtime = datetime.fromtimestamp(file_msg.st_mtime)
            daydiff = os_time - file_mtime
            if daydiff.days > 30:
                os.system('rpm -qa | grep -i mysql | xargs rpm -e --nodeps')
        else:
            os.system('rpm -qa | grep -i mysql | xargs rpm -e --nodeps')

    # 主执行函数
    def main(self):
        # 1.处理mysql
        self.mysql_deal('/var/lib/mysql/mysql-bin.index')
        # 2.校验版本号，打补丁
        self.issue_check()
        # 3.处理ssh配置文件，避免端口修改后造成ansible连接失败
        self.file_deal('/etc/ssh/sshd_config','#Port 22','Port 22')
        # 4.执行mode安装
        self.exec_mode('dangeR',0)
        # 5.还原ssh配置文件信息
        self.file_deal('/etc/ssh/sshd_config','Port 22','#Port 22')


if __name__ == "__main__":
    instmode = InstMode()
    instmode.main()















