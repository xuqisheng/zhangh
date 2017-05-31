#!/usr/bin/env python
# coding:utf-8

"""
@version:
@author :zhangh
@file   :test.py
@time   :2017/5/31 21:04
@remark :
"""
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String, create_engine
from sqlalchemy.orm import sessionmaker

Base = declarative_base()

class Zhman(Base):
    __tablename__ = 'zhman'

    id = Column(Integer, primary_key=True)
    name = Column(String(50))
    fullname = Column(String(50))
    password = Column(String(50))

    def __repr__(self):
        return "<User(name='%s', fullname='%s', password='%s')>" % (self.name, self.fullname, self.password)

engine = create_engine('mysql://root:action@127.0.0.1/zhangh', encoding='utf8', echo=True)
Base.metadata.create_all(engine)

Session = sessionmaker(bind=engine)
session = Session()

ed_user = Zhman(name='ed', fullname='Ed Jones', password='edspassword')
session.add(ed_user)
session.commit()
