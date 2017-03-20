#!/usr/bin/env python
#coding=utf-8

import time
import sys

# 关键点是输出'\r',这个字符可以使光标回到一行的开头，这时输出其它内容就会将原内容覆盖 \r 回车符
def progress_test(bar_length):
    # bar_length = 30
    for percent in xrange(0, 101):
        hashes = '#' * int(percent / 100.0 * bar_length)
        spaces = ' ' * (bar_length - len(hashes))
        sys.stdout.write("\rPercent: [%s] %d %%" % (hashes + spaces, percent))   # 格式化输出 %%:字符"%"
        sys.stdout.flush()
        time.sleep(0.1)


progress_test(30)