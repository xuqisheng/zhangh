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


def detail(request, question_id):
    return HttpResponse("You're looking at question %s." % question_id)


def results(request, question_id):
    response = "You're looking at the results of question %s."
    return HttpResponse(response % question_id)


def vote(request, question_id):
    return HttpResponse("You're voting on question %s." % question_id)