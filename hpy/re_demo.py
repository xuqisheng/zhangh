#!/usr/bin/env python
#coding=utf-8

import re

s = '[#master_base:market]'

ms = re.match(r"^\[#+.*\]$",s)

print ms.group()