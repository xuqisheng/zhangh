#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :view.py
@time   :2017/7/18 20:44
@remark :
"""

from django.shortcuts import render
from django.http import HttpResponse


def index(request):
    context = {}
    context['index'] = 'Hello World iLion!!!'
    return render(request,'index.html',context)
    # return HttpResponse("Hello World!!")