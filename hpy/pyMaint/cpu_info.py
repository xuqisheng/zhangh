#!/usr/bin/env Python
# coding:utf-8

from __future__ import print_function   # 将print从语言语法中移除，让你可以使用函数的形式
from collections import OrderedDict     # 字典排序
import pprint                           # 美观打印数据结构


def CPUinfo():
    '''
    Return the information in /proc/cpuinfo
    as a dictionary in the following format:
    CPU_info['proc0']={...}
    CPU_info['proc1']={...}
    '''
    CPUinfo = OrderedDict()
    procinfo = OrderedDict()

    nprocs = 0
    with open('/proc/cpuinfo') as f:        # with ... as f 用于简化 try finally 语句
        for line in f:
            if not line.strip():            # Python strip() 方法用于移除字符串头尾指定的字符（默认为空格）
                # end of one processor
                CPUinfo['proc%s' % nprocs] = procinfo
                nprocs = nprocs + 1
                # Reset
                procinfo = OrderedDict()
            else:
                if len(line.split(':')) == 2:
                    procinfo[line.split(':')[0].strip()] = line.split(':')[1].strip()
                else:
                    procinfo[line.split(':')[0].strip()] = ''

    return CPUinfo


if __name__ == '__main__':
    CPUinfo = CPUinfo()
    for processor in CPUinfo.keys():
        print(CPUinfo[processor]['model name'])