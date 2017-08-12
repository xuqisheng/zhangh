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

from views_hello import *
from . import views

urlpatterns = [
    # ex: /ilion/
    # 这个例子用于说明views可以多个
    url(r'^hello1', hello1),
    url(r'^hello2', hello2),

    # 正式
    url(r'^index', views.index),
    url(r'^login', views.login),

    url(r'^system', views.system),
    url(r'^process', views.process),
    url(r'^health', views.health),
    url(r'^config_code', views.config_code),
    url(r'^config_params', views.config_params),
    url(r'^listparams', views.list_params),
    url(r'^zhangh', views.zhangh),
]