#!/usr/bin/env Python
# coding:utf-8

"""
采集系统的基本性能信息包括 cpu、memory、disks、network、process
"""

import psutil


# CPU
# 2 CPU * 8 cores * 2 HT = 32 logical processor(s)