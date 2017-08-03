#!/usr/bin/env python
# coding:utf8

from __future__ import unicode_literals


from django.shortcuts import render


def index(request):
    data = [1, 2, 3, 4]
    return render(request, 'index.html', {'data': data})


def login(request):
    return render(request, 'login.html')