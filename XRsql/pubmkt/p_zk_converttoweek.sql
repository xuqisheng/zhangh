if  exists(select * from sysobjects where name = "p_zk_converttoweek" and type = "P")
	drop proc p_zk_converttoweek;
create proc p_zk_converttoweek
	@s_time			datetime,
	@e_time			datetime,
	@flag				char(1) ,			--T输出正 F输出负
	@weeks			char(7) out
as
-- ------------------------------------------------------------------------------------
--  日期转换成星期，假如是一段时间 那就转换成星期从小到大的排序
-- ------------------------------------------------------------------------------------
declare
	@this_time		datetime,
	@week			char(1),
	@long				int,
	@add			int,
	@len			int,
	@num			int,
	@len_old		int,
	@week_all	char(7) 

select @long = datediff(dd, @s_time, @e_time)
select @week = ''
select @weeks = ''
select @add = 0,@num = 1,@week_all = '1234567'
if datediff(dd,@s_time,@e_time)<>0
	select @e_time = dateadd(dd,-1,@e_time)

if @long >= 7  
	begin
	select @weeks = '1234567'
	goto gend
	end

while @long > 0
	begin
	select @week = convert(char(1), datepart(weekday,dateadd(dd,@add,@s_time))-1)
	if @week = '0'
		select @week = '7'
	if @weeks = ''
		select @weeks = @week
	if charindex(@week,@weeks)=0
		begin
		if convert(integer,substring(@weeks,1,1))>convert(integer,@week)
			select @weeks =  @week + @weeks
		else
			select @len = datalength(rtrim(@weeks))
			select @len_old = @len,@num = 1
			while @len > 0 
				begin
				if convert(integer,substring(@weeks,@num,1)) > convert(integer,@week)
					begin
					select @weeks = substring(@weeks,1,@num -1) + @week + isnull(substring(@weeks,@num,7),'')
					goto gout
					end
				select @len = @len -1,@num = @num + 1
				end
gout:
			if datalength(rtrim(@weeks)) = @len_old
				select @weeks = @weeks +@week
		end
	
		
	select @long =@long -1,@add=@add+1
	end

gend:

if @flag = 'F'
	begin
	select @len = datalength(rtrim(@weeks)), @num = 1
			while @len > 0 
				begin
				if charindex(substring(@weeks,@num,1),@week_all) > 0
					select @week_all = substring(@week_all,1,charindex(substring(@weeks,@num,1),@week_all) -1) + isnull(substring(@week_all,charindex(substring(@weeks,@num,1),@week_all)+1,7),'')
				select @len = @len -1,@num = @num + 1
				end
	return 0
	end

return 0
;