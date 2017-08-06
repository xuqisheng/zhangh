#!/usr/bin/env python
# coding:utf8

from __future__ import unicode_literals

from django.contrib import admin
from .models import *

# Register your models here.

admin.site.register(UserTable)
admin.site.register(Group)
admin.site.register(Hotel)
admin.site.register(GroupUrl)
admin.site.register(HotelUrl)