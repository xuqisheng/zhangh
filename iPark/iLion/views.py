#!/usr/bin/env python
# coding:utf8

from __future__ import unicode_literals

from django.shortcuts import render

# Create your views here.

# coding:utf-8
from django.http import HttpResponse


def index(request):
    data = [1, 2, 3, 4]
    return render(request, 'index.html', {'data': data})


def login(request):
    return render(request, 'login.html')

