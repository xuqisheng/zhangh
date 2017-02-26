drop proc p_gds_reserve_walkin_rep;
create proc p_gds_reserve_walkin_rep
	@begin		datetime,
	@end			datetime
as
create table #walkin (
	accnt			char(10)						 	not null,
	haccnt		char(7)						 	not null,
	name			varchar(60)		default ''	not null,
	cusno			char(7)			default '' 	null,
	cname			varchar(60)		default ''	null,
	arr			datetime							not null,
	dep			datetime							not null,
	type			char(5)							not null,
	roomno		char(5)							not null,
	rate			money				default 0	not null,
	ratecode		char(10)			default ''	not null,
	charge		money				default 0	not null,
	ciby			char(10)			default ''	not null,
	ref			varchar(100)	default ''	not null,
	extra			char(15)							not null
)

--  and type>='A' => 这个条件是锦江宾馆的

-- 由于营业日期在结账的时候会发生变化，因此，查询历史的情况有问题！！！ :(

-- 1. sta = I  -- R 状态暂时不放入
insert #walkin
	select accnt,haccnt,'',cusno,'',arr,dep,type,roomno,setrate,ratecode,charge,ciby,ref,extra from master
		where class='F' and sta in ('I') and bdate>=@begin and bdate<=@end --and substring(extra,9,1)='1' and type>='A'
union
	select accnt,haccnt,'',cusno,'',arr,dep,type,roomno,setrate,ratecode,charge,ciby,ref,extra from hmaster
		where class='F' and sta in ('I') and bdate>=@begin and bdate<=@end --and substring(extra,9,1)='1' and type>='A'

-- 2. sta = O, S
declare	@s_time	datetime,
			@e_time	datetime
select @s_time = isnull((select begin_ from audit_date where date=@begin), @begin)
select @e_time = isnull((select end_ from audit_date where date=@end), @end)

insert #walkin
	select accnt,haccnt,'',cusno,'',arr,dep,type,roomno,setrate,ratecode,charge,ciby,ref,extra from master
		where class='F' and sta in ('O','S') and arr>=@s_time and arr<=@e_time --and substring(extra,9,1)='1' and type>='A'
union
	select accnt,haccnt,'',cusno,'',arr,dep,type,roomno,setrate,ratecode,charge,ciby,ref,extra from hmaster
		where class='F' and sta in ('O','S') and arr>=@s_time and arr<=@e_time --and substring(extra,9,1)='1' and type>='A'
-- GaoLiang 2005/11/09
delete #walkin where substring(extra,9,1)<>'1'
-- Name
update #walkin set name=a.name from guest a where #walkin.haccnt=a.no
update #walkin set cname=a.name from guest a where #walkin.cusno=a.no

-- Output
select accnt,name,cname,arr,dep,type,roomno,rate,ratecode,charge,ciby,ref,haccnt from #walkin  order by type, arr

return 0;
