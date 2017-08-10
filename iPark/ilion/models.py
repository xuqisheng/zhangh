#!/usr/bin/env python
# coding:utf8

from django.db import models

# Create your models here.


# 集团信息
class Group(models.Model):
    code = models.CharField(max_length=20)
    name = models.CharField(max_length=50, default='')
    area = models.CharField(max_length=10, default='')
    create_datetime = models.DateTimeField(auto_now_add=True)

    def __unicode__(self):
        return self.name

    class Meta:
        db_table= 'group'
        indexes = [models.Index(fields=['code'], name='group1')]


# 酒店信息
class Hotel(models.Model):
    group_code = models.CharField(max_length=20)
    code = models.CharField(max_length=20)
    name = models.CharField(max_length=50, default='')
    area = models.CharField(max_length=10, default='')
    city = models.CharField(max_length=20, default='')
    address = models.CharField(max_length=100, default='', null=True, blank=True)
    create_datetime = models.DateTimeField(auto_now_add=True)

    def __unicode__(self):
        return self.name

    class Meta:
        db_table= 'hotel'
        indexes = [models.Index(fields=['code'], name='hotel1')]


# 集团Url
class GroupUrl(models.Model):
    code = models.CharField(max_length=20)
    url = models.CharField(max_length=200, default='')

    def __unicode__(self):
        return self.code

    class Meta:
        db_table = 'group_url'
        indexes = [models.Index(fields=['code'], name='group_url1')]


# 酒店Url
class HotelUrl(models.Model):
    code = models.CharField(max_length=20)
    url = models.CharField(max_length=200, default='')

    def __unicode__(self):
        return self.code

    class Meta:
        db_table = 'hotel_url'
        indexes = [models.Index(fields=['code'], name='hotel_url1')]


# code_base 基础代码表
class CodeBase(models.Model):
    code = models.CharField(max_length=20)
    parent_code = models.CharField(max_length=20)
    descript = models.CharField(max_length=50)
    create_user = models.CharField(max_length=20)
    create_datetime = models.DateTimeField(auto_now_add=True)

    def __unicode__(self):
        return self.code

    class Meta:
        db_table = 'code_base'
        indexes = [models.Index(fields=['code'], name='code_base1')]


# code_country 国家代码表
class CodeCountry(models.Model):
    code_type = models.CharField(max_length=20)
    code = models.CharField(max_length=20)
    descript = models.CharField(max_length=50)
    create_user = models.CharField(max_length=20)
    create_datetime = models.DateTimeField(auto_now_add=True)

    def __unicode__(self):
        return self.code

    class Meta:
        db_table = 'code_country'
        indexes = [models.Index(fields=['code_type', 'code'], name='code_country1')]


# code_provice 省份代码表
class CodeProvice(models.Model):
    code = models.CharField(max_length=20)
    descript = models.CharField(max_length=50)
    create_user = models.CharField(max_length=20)
    create_datetime = models.DateTimeField(auto_now_add=True)

    def __unicode__(self):
        return self.descript

    class Meta:
        db_table = 'code_provice'
        indexes = [models.Index(fields=['code'], name='code_provice1')]


# code_city 城市代码表
class CodeCity(models.Model):
    province_code = models.CharField(max_length=20)
    code = models.CharField(max_length=20)
    descript = models.CharField(max_length=50)
    create_user = models.CharField(max_length=20)
    create_datetime = models.DateTimeField(auto_now_add=True)

    def __unicode__(self):
        return self.code

    class Meta:
        db_table = 'code_city'
        indexes = [models.Index(fields=['province_code', 'code'], name='code_city1')]


# sys_option 参数配置表
class SysOption(models.Model):
    catalog = models.CharField(max_length=20)
    item = models.CharField(max_length=20)
    set_value = models.CharField(max_length=100)
    def_value = models.CharField(max_length=100)
    descript = models.CharField(max_length=50)
    create_user = models.CharField(max_length=20)
    create_datetime = models.DateTimeField(auto_now_add=True)

    def __unicode__(self):
        return self.item

    class Meta:
        db_table = 'sys_option'
        indexes = [models.Index(fields=['catalog', 'item'], name='sys_option1')]