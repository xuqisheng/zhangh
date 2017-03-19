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

cursor = cnx.cursor()

query = ("select code from hotel")

cursor.execute(query)

hotel_code=[]

for (code) in cursor:
	hotel_code.append(code)	
	print code,

print hotel_code

cnx.close()
