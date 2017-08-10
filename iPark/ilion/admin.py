#!/usr/bin/env python
# coding:utf8

from __future__ import unicode_literals

from django.contrib import admin
from .models import *

# Register your models here.
# 注册models中表对象，以便使用Django自带的后台界面进行管理
admin.site.register([UserTable, Group, Hotel, GroupUrl, HotelUrl])