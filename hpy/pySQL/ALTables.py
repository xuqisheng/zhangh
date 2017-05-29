#!/usr/bin/env python
# coding:utf-8

"""
@version:
@author :zhangh
@file   :ALTables.py
@time   :2017/5/29 9:48
@remark : SQLALchemy 维护的表结构
"""

from sqlalchemy import *
from sqlalchemy.ext.declarative import *


# 创建对象的基类
TableBase = declarative_base()


class Person(TableBase):
    # 表名
    __tablename__ = 'person'

    # 表结构
    id = Column(Integer, primary_key=True)
    code = Column(String(10), default='')
    descript = Column(String(20), default='')

    def __repr__(self):
        return "<Person(code='%s,descript='%s')>" % (self.code,self.descript)


class Zhmsg(TableBase):
    # 表名
    __tablename__ = 'zhmsg'

    # 表结构
    id = Column(Integer, primary_key=True)
    code = Column(String(10), default='')
    descript = Column(String(20), default='')


if __name__ == '__main__':
    # 创建到数据库的连接,echo=True 表示用logging输出调试结果(显示每条执行的 SQL 语句),生产环境下建议关闭
    # '数据库类型+数据库驱动名称://用户名:口令@机器地址:端口号/数据库名'
    engine = create_engine('mysql://root:action@127.0.0.1/zhangh', encoding='utf8', echo=True)
    # 执行生成实体表
    TableBase.metadata.create_all(engine)