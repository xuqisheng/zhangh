#!/etc/bin/env python
# coding:utf-8

import os,re

f = open('/etc/issue','r')

for line in f:
    print line

f.close()