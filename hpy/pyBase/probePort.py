#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :probePort.py
@time   :2017/11/29
@remark : 探测指定IP地址的端口是否打开 
          socket客户端 | 使用多线程方式进行
"""

import socket
import os
import threading

HOST = '183.129.215.114'


def probe1(HOST,beginNo,endNo):
  fp = open('d:/port1.txt','a')
  PORT = beginNo
  while PORT < endNo:
    sk = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sk.settimeout(1)
    if sk.connect_ex((HOST,PORT)) == 0:
      print("Success " + str(PORT))
      fp.write(str(PORT) + '\n')
      sk.close()
    # print(PORT)
    PORT += 1    

  fp.close()
  sk.close()


def probe2(HOST,beginNo,endNo):
  fp = open('d:/port2.txt','a')
  PORT = beginNo
  while PORT < endNo:
    sk = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sk.settimeout(1)
    if sk.connect_ex((HOST,PORT)) == 0:
      print("Success " + str(PORT))
      fp.write(str(PORT) + '\n')
      sk.close()
    # print(PORT)
    PORT += 1  
    
  fp.close()
  sk.close()      


def probe3(HOST,beginNo,endNo):
  fp = open('d:/port3.txt','a')
  PORT = beginNo
  while PORT < endNo:
    sk = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sk.settimeout(1)
    if sk.connect_ex((HOST,PORT)) == 0:
      print("Success " + str(PORT))
      fp.write(str(PORT) + '\n')
      sk.close()
    # print(PORT)
    PORT += 1

  fp.close()
  sk.close()

def probe4(HOST,beginNo,endNo):
  fp = open('d:/port4.txt','a')
  PORT = beginNo
  while PORT < endNo:
    sk = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sk.settimeout(1)
    if sk.connect_ex((HOST,PORT)) == 0:
      print("Success " + str(PORT))
      fp.write(str(PORT) + '\n')
      sk.close()
    # print(PORT)
    PORT += 1

  fp.close()
  sk.close()

def probe5(HOST,beginNo,endNo):
  fp = open('d:/port5.txt','a')
  PORT = beginNo
  while PORT < endNo:
    sk = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sk.settimeout(1)
    if sk.connect_ex((HOST,PORT)) == 0:
      print("Success " + str(PORT))
      fp.write(str(PORT) + '\n')
      sk.close()
    # print(PORT)
    PORT += 1

  fp.close()
  sk.close()

def probe6(HOST,beginNo,endNo):
  fp = open('d:/port6.txt','a')
  PORT = beginNo
  while PORT < endNo:
    sk = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sk.settimeout(1)
    if sk.connect_ex((HOST,PORT)) == 0:
      print("Success " + str(PORT))
      fp.write(str(PORT) + '\n')
      sk.close()
    # print(PORT)
    PORT += 1

  fp.close()
  sk.close()

threads = []
t1 = threading.Thread(target=probe1,args=(HOST,1000,1500))
threads.append(t1)
t2 = threading.Thread(target=probe2,args=(HOST,1500,2000))
threads.append(t2)
t3 = threading.Thread(target=probe3,args=(HOST,2000,2500))
threads.append(t3)
t4 = threading.Thread(target=probe3,args=(HOST,2500,3000))
threads.append(t4)
# t5 = threading.Thread(target=probe3,args=(HOST,50000,55000))
# threads.append(t5)
# t6 = threading.Thread(target=probe3,args=(HOST,55000,60000))
# threads.append(t6)

if __name__ == '__main__':
  for t in threads:
    t.setDaemon(True)
    t.start()
  t.join()

  print("OK")