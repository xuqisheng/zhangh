/*
		统计vip卡使用次数
*/
if exists(select 1 from sysobjects where name = 'p_cq_spo_vip_use_place' and type = 'P')
	drop proc p_cq_spo_vip_use_place;

create proc p_cq_spo_vip_use_place
	@begin_			datetime,
	@end_				datetime
as

declare	@no			char(7),
			@count		int

create table #tmp_list1
(
	sno			char(7),
	no				char(7),
	name			char(20),
	placecode	char(3),
	placename	char(20),
	times1		int,				           
	times2		int,
	times3		int				           
)


create table #tmp_list2
(
	sno			char(7),
	no				char(7),
	name			char(20),
	placecode	char(3),
	placename	char(20),
	times1		int,				           
	times2		int,
	times3		int			           
)
//预订
--          
insert into #tmp_list1
select '',a.cardno, '',b.placecode,'',1,0,0 from sp_reserve a,sp_plaav b 
where a.resno = b.menu  and a.cardno <> '' and a.bdate >=@begin_ and a.bdate<=@end_ order by a.cardno, b.placecode

insert into #tmp_list2	
select sno,no,name,placecode,placename,sum(times1),0,0 from #tmp_list1
group by sno,no,name,placecode,placename
order by sno,no,name,placecode,placename

update #tmp_list2 set sno = b.sno, name = b.name from #tmp_list2 a, vipcard b
where a.no = b.no
update #tmp_list2 set placename = b.name from #tmp_list2 a, sp_place b
where a.placecode= b.placecode
//直接场地记录
--                     
delete #tmp_list1
insert into #tmp_list1
select a.sno,a.no, '',a.placecode,'',0,1,0 from pos_pla_use a
where  a.bdate >=@begin_ and a.bdate<=@end_ order by a.sno, a.placecode
//select * from #tmp_list1

insert into #tmp_list2	
select sno,no,name,placecode,placename,sum(times1),0,0 from #tmp_list1 where no not in (select no from #tmp_list2)
group by sno,no,name,placecode,placename
order by sno,no,name,placecode,placename


update #tmp_list2 set times2 = isnull(times2,0) + (select isnull(sum(times2),0) from #tmp_list1 b where a.no = b.no and a.placecode = b.placecode)
from #tmp_list2 a
//select * from #tmp_list2
delete #tmp_list1 where rtrim(no)+rtrim(placecode) in (select rtrim(no)+rtrim(placecode) from #tmp_list2 )
insert into #tmp_list2	
select sno,no,name,placecode,placename,0,sum(times2),0 from #tmp_list1 
group by sno,no,name,placecode,placename
order by sno,no,name,placecode,placename

update #tmp_list2 set sno = b.sno, name = b.name from #tmp_list2 a, vipcard b
where a.no = b.no
update #tmp_list2 set placename = b.name from #tmp_list2 a, sp_place b
where a.placecode= b.placecode
 


//直接开单消费

delete #tmp_list1 
insert into #tmp_list1
select '',a.cardno, '',b.placecode,'',0,0,1 from sp_hmenu a,sp_plaav b 
where a.menu = b.menu  and a.cardno <> '' and a.bdate >=@begin_ and a.bdate<=@end_ order by a.cardno, b.placecode


insert into #tmp_list2	
select sno,no,name,placecode,placename,sum(times1),0,0 from #tmp_list1 where no not in (select no from #tmp_list2)
group by sno,no,name,placecode,placename
order by sno,no,name,placecode,placename


update #tmp_list2 set times3 = isnull(times3,0) + (select isnull(sum(times3),0) from #tmp_list1 b where a.no = b.no and a.placecode = b.placecode)
from #tmp_list2 a

delete #tmp_list1 where rtrim(no)+rtrim(placecode) in (select rtrim(no)+rtrim(placecode) from #tmp_list2 )
insert into #tmp_list2	
select sno,no,name,placecode,placename,0,0,sum(times3) from #tmp_list1 
group by sno,no,name,placecode,placename
order by sno,no,name,placecode,placename

update #tmp_list2 set sno = b.sno, name = b.name from #tmp_list2 a, vipcard b
where a.no = b.no
update #tmp_list2 set placename = b.name from #tmp_list2 a, sp_place b
where a.placecode= b.placecode


select * from #tmp_list2

;
