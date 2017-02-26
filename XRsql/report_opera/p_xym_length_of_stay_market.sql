
drop proc p_xym_length_of_stay_market;
create proc p_xym_length_of_stay_market
	@s_time			datetime,
   @e_time        datetime
as
-- ------------------------------------------------------------------------------------
--  前台客房信息查询  -- 客房可用与占用的 下半部分
-- ------------------------------------------------------------------------------------
declare
   @rooms       money,
   @revenue     money,
   @type        char(10),
   @mktcode     char(3),
   @result      money,
	@event	    varchar(60)

create table #info
(
type      char(12),
mktcode   char(3),
total     money,
date      datetime,
week      char(18),
adr4      money,
rooms4    money,
adr11     money,
rooms11   money,
adr29     money,
rooms29   money,
adr30     money,
rooms30   money,
subadr    money,
subrooms  money
)
declare c_info cursor for select type,mktcode from #info
while	@s_time <= @e_time
begin
   insert #info select a.type,b.code,a.quantity,@s_time,'',0,0,0,0,0,0,0,0,0,0 from typim a,mktcode b
   open  c_info
   fetch c_info into @type,@mktcode
   while @@sqlstatus = 0
	   begin
//4
        select @rooms = isnull((select count(distinct roomno) from master where sta='I' and class='F' and type = @type 
           and datediff(dd,arr,dep)<=4 and market = @mktcode and arr < =@s_time),0)
        select @revenue = isnull((select sum(setrate) from master where sta='I' and class='F' and type = @type 
           and datediff(dd,arr,dep)<=4 and market = @mktcode and arr < =@s_time),0)
        update #info set adr4 = round(@revenue/@rooms,2) where date = @s_time and @rooms <> 0 and type = @type and mktcode = @mktcode
        update #info set rooms4 = @rooms where date = @s_time and type = @type and mktcode = @mktcode
//11
        select @rooms = isnull((select count(distinct roomno) from master where sta='I' and class='F' and type = @type 
               and datediff(dd,arr,dep)>4 and datediff(dd,arr,dep)<=11 and market = @mktcode and arr < =@s_time),0)
        select @revenue = isnull((select sum(setrate) from master where sta='I' and class='F' and type = @type  
               and datediff(dd,arr,dep)>4 and datediff(dd,arr,dep)<=11 and market = @mktcode and arr < =@s_time),0)
        update #info set adr11 = round(@revenue/@rooms,2) where date = @s_time and @rooms <> 0 and type = @type and mktcode = @mktcode
        update #info set rooms11 = @rooms where date = @s_time and type = @type and mktcode = @mktcode
//29
        select @rooms = isnull((select count(distinct roomno) from master where sta='I' and class='F' and type = @type 
               and datediff(dd,arr,dep)>11 and datediff(dd,arr,dep)<=29 and market = @mktcode and arr < =@s_time),0)
        select @revenue = isnull((select sum(setrate) from master where sta='I' and class='F' and type = @type  
               and datediff(dd,arr,dep)>11 and datediff(dd,arr,dep)<=29 and market = @mktcode and arr < =@s_time),0)
        update #info set adr29 = round(@revenue/@rooms,2) where date = @s_time and @rooms <> 0 and type = @type and mktcode = @mktcode
        update #info set rooms29 = @rooms where date = @s_time and type = @type and mktcode = @mktcode
//30
        select @rooms = isnull((select count(distinct roomno) from master where sta='I' and class='F' and type = @type 
               and datediff(dd,arr,dep)>29 and market = @mktcode and arr < =@s_time),0)
        select @revenue = isnull((select sum(setrate) from master where sta='I' and class='F' and type = @type  
               and datediff(dd,arr,dep)>29 and market = @mktcode and arr < =@s_time),0)
        update #info set adr30 = round(@revenue/@rooms,2) where date = @s_time and @rooms <> 0 and type = @type and mktcode = @mktcode
        update #info set rooms30 = @rooms where date = @s_time and type = @type and mktcode = @mktcode
	   fetch c_info into @type,@mktcode
	   end
   close c_info
	select @s_time = dateadd(day, 1, @s_time)
end
deallocate cursor c_info

update #info set subadr = (adr4 * rooms4 + adr11 * rooms11 + adr29 * rooms29 + adr30 * rooms30)/(rooms4 + rooms11 + rooms29 + rooms30) where rooms4+rooms11+rooms29+rooms30>0
update #info set subrooms = rooms4 + rooms11 + rooms29 + rooms30


update #info set week=convert(char(8),date,3) + '(Sun)'
	where datepart(weekday,date) = 1
update #info set week=convert(char(8),date,3) + '(Mon)'
	where datepart(weekday,date) = 2
update #info set week=convert(char(8),date,3) + '(Tue)'
	where datepart(weekday,date) = 3
update #info set week=convert(char(8),date,3) + '(Wed)'
	where datepart(weekday,date) = 4
update #info set week=convert(char(8),date,3) + '(Thu)'
	where datepart(weekday,date) = 5
update #info set week=convert(char(8),date,3) + '(Fri)'
	where datepart(weekday,date) = 6
update #info set week=convert(char(8),date,3) + '(Sat)'
	where datepart(weekday,date) = 7

select b.descript1 + ' - ' + b.code,a.week,a.type,a.total,a.adr4,a.rooms4,a.adr11,a.rooms11,a.adr29,a.rooms29,a.adr30,a.rooms30,a.subadr,a.subrooms from #info a,mktcode b 
   where a.mktcode = b.code order by a.date,a.type,b.descript1


return 0;

exec p_xym_length_of_stay_market '2006/08/15','2006/08/16';