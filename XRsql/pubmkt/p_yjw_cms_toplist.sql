
IF OBJECT_ID('p_yjw_cms_toplist') IS NOT NULL
    DROP PROCEDURE p_yjw_cms_toplist
;
create proc p_yjw_cms_toplist
   @begin datetime,
   @end   datetime
as
--------------------------------------------
-- 提取佣金最多的前 10 个客户 
--------------------------------------------
declare
	@cms0sum  money,
	@belong   char(7),
	@count    int,
	@des      varchar(50)

--
if @begin is null or @end is null
begin
	select @end = bdate1 from sysdata 
	select @begin = dateadd(dd, -30, @begin) 
end 

-- 
delete cms_toplist where descript<>'无'
if not exists(select 1 from cms_toplist where descript='无') 
	insert cms_toplist(no,descript) values('','无') 

-- 
select @count = 0
declare c_calculate cursor for
	select belong,sum(cms0) from cms_rec
		where datediff(dd,bdate,@begin)<=0 and datediff(dd,bdate,@end)>=0	and belong<>''
			group by belong 
			order by sum(cms0) desc
open c_calculate
fetch c_calculate into @belong, @cms0sum
while @@sqlstatus=0
begin
	if @count>10
		break

	select @des=name from guest where no=@belong
	insert cms_toplist values (@belong,@des,@cms0sum,@begin,@end)
	select @count=@count+1

	fetch c_calculate into @belong,@cms0sum
end
close c_calculate
deallocate cursor c_calculate
;
