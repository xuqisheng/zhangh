//
//-- audit date
//if exists(select * from sysobjects where name = 'audit_date' and type = 'U')
//	drop table audit_date;
//CREATE TABLE audit_date 
//(
//    date			datetime 				not NULL,
//    begin_ 		datetime 				not NULL,
//    end_			datetime 				not NULL,
//	empno			char(10)					null
//)
//;
//EXEC sp_primarykey 'audit_date', date;
//CREATE UNIQUE NONCLUSTERED INDEX index1 ON audit_date(date);
//CREATE INDEX index2 ON audit_date(begin_, end_);
//
//insert audit_date (date, begin_, end_)
//	select distinct date,date,date from yjierep ;

//
//update audit_date set end_ = isnull((select max(a.changed) from hmaster a where a.sta='N' and datediff(dd,audit_date.date,a.changed)=1), end_);
//update audit_date set end_=dateadd(dd,1, date) where date=end_;
//update audit_date set begin_= date where date>begin_;


//update audit_date set begin_ = isnull((select a.end_ from audit_date a where datediff(dd,a.date,audit_date.date)=1), begin_);
//select * from audit_date order by date;
//