//================================================================================
// 	日期代码产生
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
	values('con_year', '年份', 'Years', 4)
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
	values('con_month', '月份', 'months', 2)
delete basecode where cat='con_month'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '01','1月','','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '02','2月','','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '03','3月','','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '04','4月','','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '05','5月','','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '06','6月','','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '07','7月','','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '08','8月','','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '09','9月','','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '10','10月','','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '11','11月','','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_month', '12','12月','','T'

-----------------
-- 	week
-----------------
delete basecode_cat where cat='con_week'
insert basecode_cat(cat, descript, descript1, len)
	values('con_week', '星期', 'weeks', 1)
delete basecode where cat='con_week'
insert basecode(cat,code,descript,descript1,sys) select 'con_week', '1','星期1','Monday','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_week', '2','星期2','Tuesday','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_week', '3','星期3','Wedesday','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_week', '4','星期4','Thurday','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_week', '5','星期5','Friday','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_week', '6','星期6','Saturday','T'
insert basecode(cat,code,descript,descript1,sys) select 'con_week', '0','星期0','Sunday','T'


-----------------
-- 	day
-----------------
delete basecode_cat where cat='con_day'
insert basecode_cat(cat, descript, descript1, len)
	values('con_day', '天', 'days', 5)
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