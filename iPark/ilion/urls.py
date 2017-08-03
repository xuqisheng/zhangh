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
    # ex: /ilion/
    url(r'^index', views.index),
    url(r'^login', views.login)
]