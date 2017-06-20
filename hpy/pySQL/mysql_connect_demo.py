# !/usr/bin/env python
#coding:utf-8

import mysql.connector


config = {
	'user':'root',
	'password':'deviskaifa',
	'host':'127.0.0.1',
	'database':'portal_group',
	'raise_on_warnings':True,
	'use_pure':False
	}

cnx = mysql.connector.connect(**config)

cnx.close()
