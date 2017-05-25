#!/bin/bash
# ===================================================
# set ssh config scp to remote machine
#
# ===================================================

Htp=$$

if [ -z "$1" ]; then
   echo "Please input IP"
   exit
fi

echo "Set Hosts code:" $1

scp /root/.ssh/id_rsa.pub root@$1:/root/tmpssh$Htp

ssh -lroot $1 "mkdir -p /root/.ssh;chmod 700 /root/.ssh;touch /root/.ssh/authorized_keys;cat /root/.ssh/authorized_keys | grep \"\`cat /root/tmpssh$Htp\`\" > /dev/null || cat /root/tmpssh$Htp >> /root/.ssh/authorized_keys"

ssh -lroot $1 "rm -f /root/tmpssh$Htp"
