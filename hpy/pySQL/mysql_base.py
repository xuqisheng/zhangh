#!/usr/bin/env python
#coding=utf-8

import mysql.connector
import logging
import copy
import itertools
import time

class Connection(object):
	def __init__(self,user=None,password=None,host=None,database=None):
		self.host = host
		self.database = database

		args = dict(db=database,charset="utf8",raise_on_warnings=True,sql_mode="TRADITIONAL",time_zone="+8:00")

		if user is not None:
			args["user"] = user
		if password is not None:
			args["passwd"] = password

		args["host"] = host
		args["port"] = 3306

		self._db = None
		self._db_args = args
		
		try:
			self.reconnect()
		except:
			logging.error("Cannot connect to MySQL on %s", self.host,exc_info=True)	

	def __del__(self):
		self.close()

	def close(self):
		if self._db is not None:
			self._db.close()
			self._db = None

	def commit(self):
		if self._db is not None:
			try:
				self._db.ping()
			except:
				self.reconnect()

			try:
				self._db.commit()
			except Execption,e:
				self._db.rollback()
				logging.exception("Can not commit",e)

	def rollback(self):
		if self._db is not None:
			try:
				self._db.rollback()
			except Exception,e:
				logging.error("Caan not rollback")

	def reconnect(self):
		self.close()
		self._db = mysql.connector.connect(**self._db_args)
		# self._db.autocommit(False)

	def query(self,query,*params):
		cursor = self._cursor()
		try:
			self._execute(cursor,query,params)
      column_names = [d[0] for d in cursor.description]
      return [Row(itertools.izip(column_names, row)) for row in cursor]
    finally:
      cursor.close()
'''
  def iter(self, query, *params):
     """Returns an iterator for the given query and parameters."""
    if self._db is None: 
			self.reconnect()
			
      cursor = MySQLdb.cursors.SSCursor(self._db)
    try:
      self._execute(cursor, query, params)
      column_names = [d[0] for d in cursor.description]
      for row in cursor:
        yield Row(zip(column_names, row))
      finally:
        cursor.close()
'''
	def _cursor(self):
		if self._db is None: self.reconnect()
		try:
			self._db.ping()
		except:
			self.reconnect()
		return self._db.cursor()

	def _execute(self,cursor,query,params):
		try:
			return cursor.execute(query,params)
		except	OperationalError:
			logging.error("Error connecting to MySQL on %s",self.host)
			self.close()
			raise

	def	get(self,query,*params):
		rows = self.query(query,*params)
		if not rows:
			return None
		elif len(rows) > 1:
			raise Exception("Multiple rows returned for Database.get() query")
		else:
			return rows[0]

	def execute(self,query,*params):
		cursor = self._cursor()
		try:
			self._execute(cursor,query,params)
			return cursor.lastrowid
		finally
			cursor.close()

	def count(self,query,*params):
		cursor = self._cursor()
		try:
			cursor.execute(query,params)
			return cursor.fetchone()[0]
		finally:
			cursor.close()


