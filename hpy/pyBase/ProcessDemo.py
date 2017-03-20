#!/etc/bin/env python
# coding:utf-8

import time
import thread
import sys

class Progress:
    def __init__(self):
        self._flag = False
    def timer(self):
        i = 19
        while self._flag:
            print "\t\t\t%s \r" % (i * "="),
            sys.stdout.flush()
            i = (i + 1) % 20
            time.sleep(0.05)
        print "\t\t\t%s\n" % (19 * "="),
        thread.exit_thread()
    def start(self):
        self._flag = True
        thread.start_new_thread(self.timer, ())
    def stop(self):
        self._flag = False
        time.sleep(1)


progress = Progress()
progress.start()
time.sleep(5)
progress.stop()