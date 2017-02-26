//================================================================================
// 	���ڴ������
//================================================================================
if  exists(select * from sysobjects where name = "p_gds_con_date_create")
	drop proc p_gds_con_date_create;
create proc p_gds_con_date_create
as

declare		@count		int,
				@begin		datetime,
				@end			datetime

-----------------
-- 	year
-----------------
delete basecode_cat where cat='con_year'
insert basecode_cat(cat, descript, descript1, len)
	values('con_year', '���', 'Years', 4)
delete basecode where cat='con_year'
select @count = 2003
while @count <= 2020
begin
	insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp)
		select 'con_year', convert(char(4),@count),'','','T','F',0,''
	select @count = @count + 1
end
update basecode set descript=code, descript1=code where cat='con_year'

-----------------
-- 	month
-----------------
delete basecode_cat where cat='con_month'
insert basecode_cat(cat, descript, descript1, len)
	values('con_month', '�·�', 'months', 2)
delete basecode where cat='con_month'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '01','1��','','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '02','2��','','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '03','3��','','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '04','4��','','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '05','5��','','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '06','6��','','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '07','7��','','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '08','8��','','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '09','9��','','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '10','10��','','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '11','11��','','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '12','12��','','T'

-----------------
-- 	week
-----------------
delete basecode_cat where cat='con_week'
insert basecode_cat(cat, descript, descript1, len)
	values('con_week', '����', 'weeks', 1)
delete basecode where cat='con_week'
insert basecode(cat,code,descript,descript1,sys) select 'con_week', '1','����1','Monday','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_week', '2','����2','Tuesday','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_week', '3','����3','Wedesday','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_week', '4','����4','Thurday','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_week', '5','����5','Friday','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_week', '6','����6','Saturday','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_week', '0','����0','Sunday','T'


-----------------
-- 	day
-----------------
delete basecode_cat where cat='con_day'
insert basecode_cat(cat, descript, descript1, len)
	values('con_day', '��', 'days', 5)
delete basecode where cat='con_day'
select @begin = convert(datetime, '2002.1.1')
select @end   = convert(datetime, '2003.1.1')
while @begin < @end
begin
	insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp)
		select 'con_day', convert(char(5),@begin,1),'','','T','F',0,''
	select @begin = dateadd(dd, 1, @begin)
end
update basecode set descript=code, descript1=code where cat='con_day'

return 0
;

//exec p_gds_con_date_create;
//select * from basecode where cat like 'con_%' order by cat, code;