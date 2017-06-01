#!/usr/bin/env python
# coding:utf8

"""
@version:
@author :zhangh
@file   :SQLAlchemyORMCase.py
@time   :2017/5/31 15:54
@remark : SQLALchemyORM 事例
"""
from datetime import datetime
from sqlalchemy import *
from sqlalchemy.orm import *
from sqlalchemy.ext.declarative import declarative_base


Base = declarative_base()


class Cookie(Base):
    __tablename__ = 'cookies'

    cookie_id = Column(Integer, primary_key=True)
    cookie_name = Column(String(50))
    cookie_recipe_url = Column(String(255))
    cookie_sku = Column(String(55))
    quantity = Column(Integer)
    unit_cost = Column(Numeric(12, 2))

    def __repr__(self):
        return "Cookie(cookie_name='{self.cookie_name}', " \
            "cookie_recipe_url='{self.cookie_recipe_url}', " \
            "cookie_sku='{self.cookie_sku}', " \
            "quantity={self.quantity}, " \
            "unit_cost={self.unit_cost})".format(self=self)

class User(Base):
        __tablename__ = 'users'

    user_id = Column(Integer(), primary_key=True)
    username = Column(String(15), nullable=False, unique=True)
    email_address = Column(String(255), nullable=False)
    phone = Column(String(20), nullable=False)
    password = Column(String(25), nullable=False)
    created_on = Column(DateTime(), default=datetime.now)
    updated_on = Column(DateTime(), default=datetime.now,onupdate=datetime.now)

    def __repr__(self):
        return "User(username='{self.username}', " \
            "email_address='{self.email_address}', " \
            "phone='{self.phone}', " \
            "password='{self.password}')".format(self=self)


class Order(Base):
    __tablename__ = 'orders'
    order_id = Column(Integer(), primary_key=True)
    user_id = Column(Integer())

    def __repr__(self):
        return "Order(user_id={self.user_id}, " \
            "shipped={self.shipped})".format(self=self)


class LineItem(Base):
    __tablename__ = 'line_items'
    line_item_id = Column(Integer(), primary_key=True)
    order_id = Column(Integer())
    cookie_id = Column(Integer())
    quantity = Column(Integer())
    extended_cost = Column(Numeric(12, 2))

    def __repr__(self):
        return "LineItems(order_id={self.order_id}, " \
            "cookie_id={self.cookie_id}, " \
            "quantity={self.quantity}, " \
            "extended_cost={self.extended_cost})".format(self=self)


# 创建到数据库的连接,echo=True 表示用logging输出调试结果(显示每条执行的 SQL 语句),生产环境下建议关闭
# '数据库类型+数据库驱动名称://用户名:口令@机器地址:端口号/数据库名'
engine = create_engine('mysql://root:action@127.0.0.1/zhangh', encoding='utf8', echo=False)
# 执行生成实体表
Base.metadata.create_all(engine)

Session = sessionmaker(bind=engine)

session = Session()

# # Inserting a single object
# cc_cookie = Cookie(
#         cookie_name='chocolate chip',
#         cookie_recipe_url='http://some.aweso.me/cookie/recipe.html',
#         cookie_sku='CC01',
#         quantity='12',
#         unit_cost='0.5')
#
# session.add(cc_cookie)
#
# session.commit()

# print cc_cookie.cookie_id

# # Multiple inserts
# dcc = Cookie(
#     cookie_name='dark chocolate chip',
#     cookie_recipe_url='http://some.aweso.me/cookie/recipe_dark.html',
#     cookie_sku='CC02',
#     quantity=1,
#     unit_cost=0.75)
# mol = Cookie(
#     cookie_name='molasses',
#     cookie_recipe_url='http://some.aweso.me/cookie/recipe_molasses.html',
#     cookie_sku='MOL01',
#     quantity=1,
#     unit_cost=0.80)
#
# session.add(dcc)
# session.add(mol)

# # flush预提交，等于提交到数据库内存，还未写入数据库文件
# # commit完全提交
# session.commit()
# session.flush()
#
# print(dcc.cookie_id)
# print(mol.cookie_id)

# # Bulk inserting multiple records
# c1 = Cookie(
#     cookie_name='peanut butter',
#     cookie_recipe_url='http://some.aweso.me/cookie/peanut.html',
#     cookie_sku='PB01',
#     quantity=24,
#     unit_cost=0.25)
# c2 = Cookie(
#     cookie_name='oatmeal raisin',
#     cookie_recipe_url='http://some.okay.me/cookie/raisin.html',
#     cookie_sku='EWW01',
#     quantity=100,
#     unit_cost=1.00)
#
# session.bulk_save_objects([c1, c2])
# session.commit()
# print c1.cookie_id

# query 1
# cookies = session.query(Cookie).all()
# print cookies

# query 2
# for cookie in session.query(Cookie):
#     print cookie

# first() Returns the first record object if there is one
# print session.query(Cookie).first()
# one()   Queries all the rows, and raises an exception if anything other than a single result is returned
# print session.query(Cookie).one()
# scalar() Returns the first element of the first result, None if there is no result,
# or an error if there is more than one result
# print session.query(Cookie).scalar()

# print session.query(Cookie.cookie_name, Cookie.quantity).first()

# Order by quantity ascending
# for cookie in session.query(Cookie).order_by(Cookie.quantity):
#     # 填充与格式化 :[填充字符][对齐方式 <^>][宽度]
#     print('{:5} - {}'.format(cookie.quantity,cookie.cookie_name))

# Limit
# for cookie in session.query(Cookie).order_by((Cookie.quantity)).limit(2):
#     print('{:5} - {}'.format(cookie.quantity, cookie.cookie_name))

# Built-In SQL Functions and Labels
# inv_sum = session.query(func.sum(Cookie.quantity)).first()
# inv_sum = session.query(func.sum(Cookie.quantity)).one()
# inv_sum = session.query(func.sum(Cookie.quantity)).scalar()
# print(inv_sum)

# inv_count = session.query(func.count(Cookie.quantity)).scalar()
# inv_count = session.query(func.count(Cookie.quantity)).first()
# print(inv_count)

# rec_count = session.query(func.count(Cookie.cookie_name).label('inventory_count')).first()
# print(rec_count.keys())
# print(rec_count.inventory_count)

# Filter
# record = session.query(Cookie).filter(Cookie.cookie_name == 'chocolate chip').first()
# print(record)

# query = session.query(Cookie).filter(Cookie.cookie_name.like('%chocolate%'))
# for record in query:
#     print record
#     print(record.cookie_name)

# String concatenation with +
# results = session.query(Cookie.cookie_name, 'SKU-' + Cookie.cookie_sku).all()
# for row in results:
#     print(row)

# query = session.query(Cookie.cookie_name,cast((Cookie.quantity * Cookie.unit_cost),Numeric(12,2)).label('inv_cost'))
# for result in query:
#     print('{} - {}'.format(result.cookie_name, result.inv_cost))


# Using flter with multiple ClauseElement expressions to perform an AND
# query = session.query(Cookie).filter(Cookie.quantity > 23,Cookie.unit_cost < 0.40)
# for result in query:
#     print(result.cookie_name)
# and 这两种写法的结果一致
# query = session.query(Cookie).filter(and_(Cookie.quantity > 23,Cookie.unit_cost < 0.40))
# for result in query:
#     print(result.cookie_name)
# and_,or_,not_
# query = session.query(Cookie).filter(or_(Cookie.quantity > 23,Cookie.unit_cost < 0.40))
# for result in query:
#     print(result.cookie_name)


# # Update
# query = session.query(Cookie).filter(Cookie.cookie_name == "chocolate chip")
# query.update({Cookie.quantity: Cookie.quantity - 20})
# cc_cookie = query.first()
# session.commit()
# print(cc_cookie.quantity)

# # Delete
# query = session.query(Cookie)
# query = query.filter(Cookie.cookie_name == "dark chocolate chip")
# dcc_cookie = query.one()
# session.delete(dcc_cookie)
# session.commit()
# dcc_cookie = query.first()
# print(dcc_cookie)

# # Joins
# Using join to select from multiple tables
query = session.query(Order.order_id, User.username, User.phone,Cookie.cookie_name, LineItem.quantity,LineItem.extended_cost)
query = query.join(User).join(LineItem).join(Cookie)
results = query.filter(User.username == 'cookiemon').all()
print(results)

# Using outerjoin to select from multiple tables
query = session.query(User.username, func.count(Order.order_id))
query = query.outerjoin(Order).group_by(User.username)
for row in query:
    print(row)

