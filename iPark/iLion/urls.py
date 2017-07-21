#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :urls.py
@time   :2017/7/20 13:25
@remark :
"""
from django.conf.urls import url
from . import views

urlpatterns = [
    # ex: /iLion/
    url(r'^$', views.index),
    # ex: /iLion/5/
    url(r'^(?P<question_id>[0-9]+)/$', views.detail, name='detail'),
    # ex: /iLion/5/results/
    url(r'^(?P<question_id>[0-9]+)/results/$', views.results, name='results'),
    # ex: /iLion/5/vote/
    url(r'^(?P<question_id>[0-9]+)/vote/$', views.vote, name='vote'),
]