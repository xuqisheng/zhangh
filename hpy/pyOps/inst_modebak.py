#!/etc/bin/env python
# coding:utf-8

import os,re

# yum remove 可能会将一些依赖包都删除，风险大
# os.system('yum remove mysql')
os.system('rpm -qa | grep -i mysql | rpm -e --nodeps')

# 1.校验版本号，打补丁
# 打开CentOS发行版本文件
# with open('/etc/issue','r') as issue_r:
issue_r = open('/etc/issue','r')
line = issue_r.readline().strip('\n')
# 正则匹配
m = re.search(r'[0-9].[0-9]',line)

if float(m.group()) >= 6.2:
    os.system('rpm -qa | grep -i mysql | xargs rpm -e --nodeps')
    os.system('yum install ld-linux.so.2')
else:
    pass

issue_r.close()

# 2. 处理ssh配置文件，避免端口修改后造成ansible连接失败
ssh_r1=open("/etc/ssh/sshd_config","r")
lines = ssh_r1.readlines()
ssh_w1=open("/etc/ssh/sshd_config","w")
for line in lines:
    if "#Port 22" in line:
        line = line.replace("#Port 22","Port 22")

    ssh_w1.write(line)
ssh_w1.close()
ssh_r1.close()

# 3.开始安装mode
os.system('/root/mode/settz')
os.system('/root/mode/disusb')

# 如何解决install.sh中read交互输入的问题?
os.system('export HBLACKBOX2=1;echo "dangeR" | /root/mode/install.sh')

# export HBLACKBOX2=1;用于解决确认执行脚本过程中提交是否输入y/n的问题
os.system('export HBLACKBOX2=1;/root/mode/inst_mysql')
os.system('export HBLACKBOX2=1;/root/mode/config_mem max')

# 4.删除ssh配置文件中添加的信息
ssh_r2=open("/etc/ssh/sshd_config","r")
lines = ssh_r2.readlines()
ssh_w2=open("/etc/ssh/sshd_config","w")
for line in lines:
    if "Port 22" in line:
        line = line.replace("Port 22","#Port 22")

    ssh_w2.write(line)
ssh_w2.close()
ssh_r2.close()