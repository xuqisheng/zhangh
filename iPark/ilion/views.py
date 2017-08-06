#!/usr/bin/env python
# coding:utf8

from __future__ import unicode_literals

from django.shortcuts import render


# 登录页
def login(request):
    return render(request, 'login.html')


# 主页
def index(request):
    return render(request, 'index.html')


# 日常监控 --> 系统监控
def system(request):
    return render(request, 'system.html')


# 日常监控 --> 进程监控
def process(request):
    return render(request, 'process.html')


# 日常监控 --> 健康度监控
def health(request):
    return render(request, 'health.html')


# 测试
def zhangh(request):
    return render(request, 'zhangh.html')