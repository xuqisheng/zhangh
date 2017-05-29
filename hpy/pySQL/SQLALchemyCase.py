#!/usr/bin/env python
# coding:utf-8

"""
@version:
@author :zhangh
@file   :SQLALchemyCase.py
@time   :2017/5/29 6:12
@remark :
"""

from sqlalchemy.orm import *
from ALTables import *


# 创建到数据库的连接,echo=True 表示用logging输出调试结果(显示每条执行的 SQL 语句),生产环境下关闭
# '数据库类型+数据库驱动名称://用户名:口令@机器地址:端口号/数据库名'
engine = create_engine('mysql://root:action@127.0.0.1/zhangh',encoding='utf8',echo=False)

DBsession = sessionmaker(bind=engine)
# 创建session对象
session = DBsession()
query = session.query(Zhmsg).filter(Zhmsg.code.like('00%')).count()
print query

# for instance in session.query(Zhmsg).filter_by(code='002'):
#     print instance.code,instance.descript

#提交
session.commit()
#关闭
session.close()