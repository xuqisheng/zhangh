#!/usr/bin/env python
# coding:utf8

from __future__ import unicode_literals

from django.shortcuts import render

# Create your views here.

# coding:utf-8
from django.http import HttpResponse


def index(request):
    context = {}
    context['index'] = 'Hello World Index !!!'
    return render(request, 'index.html', context)

