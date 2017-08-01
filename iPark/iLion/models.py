#!/usr/bin/env python
# coding:utf8

from django.db import models

# Create your models here.


# 用户表
class User(models.Model):
    code = models.CharField(max_length=10)
    name = models.CharField(max_length=50, default='')
    password = models.CharField(max_length=20, default='')
    sex = models.IntegerField()
    email = models.EmailField()
    mobile = models.CharField(max_length=11, default='')
    create_datetime = models.DateTimeField(auto_now_add=True)

    # __str__方法是为了后台管理(admin)和django shell的显示
    def __str__(self):
        return self.name

    class Meta:
        db_table = 'user'
        indexes = [
            models.Index(fields=['code'], name='user1'),
            models.Index(fields=['mobile'], name='user2')
            ]


# 集团信息
class Group(models.Model):
    code = models.CharField(max_length=20)
    name = models.CharField(max_length=50, default='')
    area = models.CharField(max_length=10, default='')
    create_datetime = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

    class Meta:
        db_table= 'group'
        indexes = [models.Index(fields=['code'], name='group1')]


# 酒店信息
class Hotel(models.Model):
    code = models.CharField(max_length=20)
    name = models.CharField(max_length=50, default='')
    area = models.CharField(max_length=10, default='')
    city = models.CharField(max_length=20, default='')
    address = models.CharField(max_length=100, default='')
    create_datetime = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

    class Meta:
        db_table= 'hotel'
        indexes = [models.Index(fields=['code'], name='hotel1')]


# 集团Url
class GroupUrl(models.Model):
    code = models.CharField(max_length=20)
    url  = models.CharField(max_length=200, default='')

    def __str__(self):
        return self.code

    class Meta:
        db_table = 'group_url'
        indexes = [models.Index(fields=['code'], name='group_url1')]


# 酒店Url
class HotelUrl(models.Model):
    code = models.CharField(max_length=20)
    url  = models.CharField(max_length=200, default='')

    def __str__(self):
        return self.code

    class Meta:
        db_table = 'hotel_url'
        indexes = [models.Index(fields=['code'], name='hotel_url1')]
