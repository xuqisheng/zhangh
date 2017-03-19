#!/usr/bin/env python
#coding=utf-8

import MySQLdb
import sys

reload(sys)
sys.setdefaultencoding('utf-8')

# 数据库连接
db = MySQLdb.connect(host="localhost",user="root",passwd="action",db="zhangh",charset="utf8")
# 获取操作游标
cursor = db.cursor()
# 执行sql语句
cursor.execute("SELECT VERSION()")
data = cursor.fetchone()
print "Database version : %s " % data

cursor.execute("DROP TABLE IF EXISTS zh_demo")
# 定义创建表的SQL语句
table_sql = """
    CREATE TABLE zh_demo (
      hotel_group_id INT NOT NULL,
      hotel_id 		 INT NOT NULL,
      id 			 BIGINT(16) NOT NULL AUTO_INCREMENT,
      accnt 		 BIGINT(16) DEFAULT NULL,
      ta_descript    VARCHAR(100),
      PRIMARY KEY (id),
      KEY Index_2 (hotel_group_id,hotel_id,accnt)
      )
"""
cursor.execute(table_sql)
# 定义insert 语句
insert_sql = """
insert into zh_demo(hotel_group_id,hotel_id,accnt,ta_descript)
    select 2,11,123,'第一条数据'
"""
try:
    cursor.execute(insert_sql)
    db.commit()
except:
    db.rollback()

#定义select 语句
select_sql = """
SELECT code,descript FROM code_base WHERE hotel_group_id=2 AND hotel_id=0 AND parent_code='shift'
"""

try:
    cursor.execute(select_sql)
    results = cursor.fetchall()
    # 数据库返回结果集为 tuple 元组
    print type(results)
    for row in results:
        code = row[0]
        descript = row[1]
        print "code=%s, descript=%s" % (code,descript)
except:
    print "Error: unable to fecth data"


db.close()


