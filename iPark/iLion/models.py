#!/usr/bin/env python
# coding:utf8

from django.db import models

# Create your models here.


class User(models.Model):
    code = models.CharField(max_length=10)
    name = models.CharField(max_length=50)
    password = models.CharField(max_length=20)
    sex = models.IntegerField()
    email = models.EmailField()
    mobile = models.CharField(max_length=11)
    create_datetime = models.DateTimeField()

    class Meta:
        managed = True
        db_table = 'user'
        indexes = [
            models.Index(fields=['code'], name='index1'),
            models.Index(fields=['mobile'], name='index2')
            ]


