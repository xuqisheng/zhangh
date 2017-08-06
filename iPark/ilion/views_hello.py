#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :views_hello.py
@time   :2017/8/6 8:01
@remark :
"""

from __future__ import unicode_literals

from django.http import HttpResponse
from django.shortcuts import render


def hello1(request):
    return HttpResponse("Hello world ")


def hello2(request):
    data = 'Hello World !!!'
    return render(request, 'hello.html', {'data': data})
