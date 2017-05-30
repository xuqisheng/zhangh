#!/usr/bin/env python
# coding:utf-8

"""
@version:
@author :zhangh
@file   :SQLALchemyCase.py
@time   :2017/5/29 6:12
@remark :
"""

from datetime import datetime
from sqlalchemy import (MetaData, Table, Column, Integer, Numeric, String, DateTime, ForeignKey, create_engine)
from sqlalchemy import insert
from sqlalchemy.sql import select, func

# 通过 SQLALchemy core 方式操作
metadata = MetaData()

cookies = Table('cookies', metadata,
    Column('cookie_id', Integer(), primary_key=True),
    Column('cookie_name', String(50), index=True),
    Column('cookie_recipe_url', String(255)),
    Column('cookie_sku', String(55)),
    Column('quantity', Integer()),
    Column('unit_cost', Numeric(12, 2))
)

users = Table('users', metadata,
    Column('user_id', Integer(), primary_key=True),
    Column('customer_number', Integer(), autoincrement=True),
    Column('username', String(15), nullable=False, unique=True),
    Column('email_address', String(255), nullable=False),
    Column('phone', String(20), nullable=False),
    Column('password', String(25), nullable=False),
    Column('created_on', DateTime(), default=datetime.now),
    Column('updated_on', DateTime(), default=datetime.now, onupdate=datetime.now)
)

orders = Table('orders', metadata,
    Column('order_id', Integer(), primary_key=True),
    Column('user_id', ForeignKey('users.user_id'))
)

line_items = Table('line_items', metadata,
    Column('line_items_id', Integer(), primary_key=True),
    Column('order_id', ForeignKey('orders.order_id')),
    Column('cookie_id', ForeignKey('cookies.cookie_id')),
    Column('quantity', Integer()),
    Column('extended_cost', Numeric(12, 2))
)

engine = create_engine('mysql://root:action@127.0.0.1/test',encoding='utf8',echo=True)

connection = engine.connect()

metadata.create_all(engine)

# Insert
# 单条插入
# ins = cookies.insert().values(
#     cookie_name="chocolate chip",
#     cookie_recipe_url="http://some.aweso.me/cookie/recipe.html",
#     cookie_sku="CC01",
#     quantity="12",
#     unit_cost="0.50"
# )
# result = connection.execute(ins)
# 显示执行生成sql脚本
# print(str(ins))
# print ins.compile().params
# print result.inserted_primary_key

# 多条插入
# inventory_list = [{
#     'cookie_name': 'peanut butter',
#     'cookie_recipe_url': 'http://some.aweso.me/cookie/peanut.html',
#     'cookie_sku': 'PB01',
#     'quantity': '24',
#     'unit_cost': '0.25'
#     },
#     {
#     'cookie_name': 'oatmeal raisin',
#     'cookie_recipe_url': 'http://some.okay.me/cookie/raisin.html',
#     'cookie_sku': 'EWW01',
#     'quantity': '100',
#     'unit_cost': '1.00'
#     }]
#
# ins = cookies.insert()
# result = connection.execute(ins, inventory_list)

# query查询
# s = select([cookies])
# rp = connection.execute(s)
# results = rp.fetchall()
# print results
# print rp.first()

# s = select([func.count(cookies.c.cookie_name)])
# rp = connection.execute(s)
# print rp.first()

s = select([cookies]).where(cookies.c.cookie_name == 'peanut butter')
rp = connection.execute(s)
record = rp.first()
print(record.items())





