if object_id('manager_rep') is not null
	drop TABLE manager_rep;
CREATE TABLE manager_rep 
(
    order_    char(6)     NOT NULL,
    class     char(10)    NOT NULL,
    descript  varchar(40) NULL,
    descript1 varchar(40) NULL
);
EXEC sp_primarykey 'manager_rep', class;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON manager_rep(class);


if object_id('p_yb_manager_report') is not null
	drop proc p_yb_manager_report;
create proc p_yb_manager_report
	@bdate		datetime
as
create table #gout
(class			char(6),			
 descript		char(40),
 day				char(20),
 month			char(20),
 year				char(20),
 lday				char(20),
 lmonth			char(20),
 lyear			char(20)
)


insert #gout 
select a.order_,a.descript1,convert(varchar,convert(money,b.amount),1),convert(varchar,convert(money,b.amount_m),1),convert(varchar,convert(money,b.amount_y),1),
	convert(varchar,convert(money,c.amount),1),convert(varchar,convert(money,c.amount_m),1),convert(varchar,convert(money,c.amount_y),1) from manager_rep a,
	yaudit_impdata b,yaudit_impdata c where b.date = @bdate 
		and a.class*=b.class and a.class*=c.class and c.date = dateadd(year,  -1,  @bdate)
			and a.order_ in ('000010','000070','000080','000100','000490')



insert #gout 
select a.order_,a.descript1,convert(varchar,b.amount*100)+'%',convert(varchar,b.amount_m*100)+'%',
	convert(varchar,b.amount_y*100)+'%',convert(varchar,c.amount*100)+'%',
	convert(varchar,c.amount_m*100)+'%',convert(varchar,c.amount_y*100)+'%' from manager_rep a,
	yaudit_impdata b,yaudit_impdata c where b.date = @bdate 
		and a.class*=b.class and a.class*=c.class and c.date = dateadd(year,  -1,  @bdate)
			and a.order_ in ('000060')


insert #gout 
select a.order_,a.descript1,convert(varchar,convert(int,b.amount)),convert(varchar,convert(int,b.amount_m)),
	convert(varchar,convert(int,b.amount_y)),convert(varchar,convert(int,c.amount)),
	convert(varchar,convert(int,c.amount_m)),convert(varchar,convert(int,c.amount_y)) from manager_rep a,
	yaudit_impdata b,yaudit_impdata c where b.date = @bdate 
		and a.class*=b.class and a.class*=c.class and c.date = dateadd(year,  -1,  @bdate)
			and a.order_ not in ('000010','000060','000070','000080','000100','000490')


update #gout set lday='' where lday = '%'
update #gout set lmonth='' where lmonth = '%'
update #gout set lyear='' where lyear = '%'

select * from #gout order by class

return 0;
