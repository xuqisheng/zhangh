IF OBJECT_ID('dbo.p_zk_ratecode_ava') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_zk_ratecode_ava
END;

create proc p_zk_ratecode_ava
	@ratecode      char(10),
	@year				char(4),
	@class			char(10),
	@month			char(2)
as
declare		@ret		int,
				@msg		varchar(60),
				@begin	datetime,
				@end     datetime,
				@day    datetime,
				@var_day   char(5),
				@falg     char(1),
				@var_value char(255),
				@long int,
				@var_code   char(255),
				@var_col  int,
				@s_time	datetime,
				@e_time  datetime,
				@ms		datetime,
				@me		datetime,
				@begin_	datetime,
				@end_		datetime





create table #date (
	month				char(10)								not null,	-- ÔÂ·İ
	d1					char(1)	default ''				null,	
	d2					char(1)	default ''				null,
	d3					char(1)	default ''					null,
	d4					char(1)	default ''					null,
	d5					char(1)	default ''					null,
	d6					char(1)	default ''					null,
	d7					char(1)	default ''					null,
	d8					char(1)	default ''					null,
	d9		   		char(1)	default ''					null,
	d10				char(1)		default ''			null,
	d11				char(1)		default ''			null,
	d12				char(1)	default ''				null,	
	d13				char(1)	default ''				null,
	d14				char(1)	default ''					null,
	d15				char(1)	default ''					null,
	d16				char(1)	default ''					null,
	d17				char(1)	default ''					null,
	d18				char(1)	default ''					null,
	d19				char(1)	default ''					null,
	d20		   	char(1)	default ''					null,
	d21				char(1)		default ''			null,
	d22				char(1)		default ''			null,
	d23				char(1)	default ''				null,	
	d24				char(1)	default ''				null,
	d25				char(1)	default ''					null,
	d26				char(1)	default ''					null,
	d27				char(1)	default ''					null,
	d28				char(1)	default ''					null,
	d29				char(1)	default ''					null,
	d30				char(1)	default ''					null,
	d31		   	char(1)	default ''					null,
	code				char(2)                          not null,
	flag				char(31) 								not null,
	flag1				char(31) 								not null
)

if convert(datetime,@year+'-1-1 00:00:00')>@end or convert(datetime,@year+'-12-31 23:59:59')<@begin
	begin
	select @ret=1
	goto gout
	end


if rtrim(@month)=null select @month='01'
select @day=convert(datetime,@year+'-'+@month+'-1 00:00:00')
select @begin=@day
select @end=dateadd(dd,-1,dateadd(mm,1,@begin))
if @ratecode='%' and @class='ratecode'
	insert #date select code,'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',code
			 ,'0000000000000000000000000000000','0000000000000000000000000000000' from rmratecode where halt='F'
else if @ratecode='%' and @class='rmtype'
	insert #date select type,'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',type
			 ,'0000000000000000000000000000000','0000000000000000000000000000000' from typim
else if @ratecode='%' and @class='room_class'
	insert #date select code,'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',code
			 ,'0000000000000000000000000000000','0000000000000000000000000000000' from gtype
else if @ratecode='%' and @class='rmratecat'
	insert #date select code,'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',code
			 ,'0000000000000000000000000000000','0000000000000000000000000000000' from basecode where cat='rmratecat'
else
	begin
	select @day=convert(datetime,@year+'-1-1 00:00:00')
	insert #date select descript,'','','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',code
			 ,'0000000000000000000000000000000','0000000000000000000000000000000' from basecode where cat='con_month'
	select @begin=begin_,@end=end_ from rmratecode where code = @ratecode and @class='ratecode'
	if @@rowcount <=0
		begin
		select @begin=convert(datetime,'1999-1-1 00:00:00'),@end=convert(datetime,'2050-1-1 00:00:00')
		end
	end

if @class='overview' 
	goto gout

if @ratecode='%'
	begin
	if @class='ratecode'
		begin
		declare c_1 cursor for select begin_,end_,#date.month  from rmratecode,#date where #date.month=rmratecode.code order by rmratecode.code
		open c_1
		fetch c_1 into @s_time,@e_time,@var_code
		while @@sqlstatus=0
			begin
			if @s_time=null 
				select @s_time=@begin
			if @e_time=null 
				select @e_time=@end
			if @s_time<@begin
				select @s_time=@begin
			if @e_time>@end
				select @e_time=@end
			if @s_time>@e_time
				begin
				fetch c_1 into @s_time,@e_time,@var_code
				continue
				end
			if @begin>=@s_time and @end>=@e_time
				begin
				select @long=datediff(dd,@begin,@end)
				if @long>31 select @long=31
				update #date set flag=substring('9999999999999999999999999999999',1,@long+1)+substring('0000000000000000000000000000000',1,31 -@long -1) where month=@var_code
				end
			else if @begin<=@s_time and @end>=@e_time
				begin
				select @long=datediff(dd,@s_time,@end)
				update #date set flag=substring('9999999999999999999999999999999',convert(integer,substring(convert(char,@s_time,15),1,2)),@long+1)+substring('0000000000000000000000000000000',1,31 -@long -1) where month=@var_code
				end
			else if @begin<=@s_time and @end<=@e_time
				begin
				select @long=datediff(dd,@begin,@e_time)
				update #date set flag=substring('9999999999999999999999999999999',1,@long+1)+substring('0000000000000000000000000000000',1,31 -@long -1) where month=@var_code
				end
			fetch c_1 into @s_time,@e_time,@var_code
			end
		close c_1
		end
	else
		begin
		select @long=datediff(dd,@begin,@end)
		if @long > 30 
			select @long = 30
		update #date set flag=substring('9999999999999999999999999999999',1,@long+1)+substring('0000000000000000000000000000000',1,31 -@long -1)
		end

	if @class = 'ratecode'
		declare c_2 cursor for select ratecode,date,value from rmratecode_ava where rtrim(ratecode) <> null and date>=@begin and date <= @end
	else if @class = 'rmratecat'
		declare c_2 cursor for select rate_cat,date,value from rmratecode_ava where rtrim(rate_cat) <> null and date>=@begin and date <= @end
	else if @class = 'room_class'
		declare c_2 cursor for select room_class,date,value from rmratecode_ava where rtrim(room_class) <> null and date>=@begin and date <= @end
	else if @class = 'rmtype'
		declare c_2 cursor for select room_type,date,value from rmratecode_ava where rtrim(room_type) <> null and date>=@begin and date <= @end
	else if @class = 'house'
		declare c_2 cursor for select room_type,date,value from rmratecode_ava where rtrim(room_class) = null and rtrim(rate_cat) = null or rtrim(room_type) = null and rtrim(ratecode) = null and date>=@begin and date <= @end
	open c_2
	fetch c_2 into @var_code,@day,@var_value
	while @@sqlstatus=0
		begin
		select @var_col=convert(integer,substring(convert(char,@day,15),1,2))
		if charindex('C',@var_value)>0 
			begin
			update #date set flag=substring(flag,1,@var_col -1)+'1'+substring(flag,@var_col+1,31) where charindex(rtrim(month) + ',',rtrim(@var_code) + ',') > 0
			end
		else if charindex('B',@var_value)>0
			begin
			update #date set flag=substring(flag,1,@var_col -1)+'2'+substring(flag,@var_col+1,31) where charindex(rtrim(month) + ',',rtrim(@var_code) + ',') > 0
			end
		else if charindex('E',@var_value)>0
			begin
			update #date set flag=substring(flag,1,@var_col -1)+'3'+substring(flag,@var_col+1,31) where charindex(rtrim(month) + ',',rtrim(@var_code) + ',') > 0
			end
		--else if charindex('A',@var_value)>0
		--	begin
		--	update #date set flag=substring(flag,1,@var_col -1)+'4'+substring(flag,@var_col+1,31) where charindex(rtrim(@var_code) + ',',rtrim(month) + ',') > 0
		--	end
		--else if charindex('D',@var_value)>0
		--	begin
		--	update #date set flag=substring(flag,1,@var_col -1)+'5'+substring(flag,@var_col+1,31) where charindex(rtrim(@var_code) + ',',rtrim(month) + ',') > 0
		--	end
		else
			begin
			update #date set flag=substring(flag,1,@var_col -1)+'9'+substring(flag,@var_col+1,31) where charindex(rtrim(month) + ',',rtrim(@var_code) + ',') > 0
			end
		fetch c_2 into @var_code,@day,@var_value
		end
	close c_2

	select @ms = convert(datetime,@year+'/'+@month+'/01')
	select @me = dateadd(dd,-1,dateadd(mm,1,@ms))
	select @day=@ms
	while @day<=@me and @day>=@ms
		begin
		select @var_day=convert(char,@day,10)
		if datepart(weekday,@day)  = 1 or datepart(weekday,@day)  = 7
			begin
			update #date set flag1=substring(flag1,1,convert(integer,substring(@var_day,4,5)) -1)+'6'+substring(flag1,convert(integer,substring(@var_day,4,5)) +1,31)
			end
		select @day=dateadd(day,1,@day)
		end
	select @ret=0
	goto gout
	end

if @begin=null
	begin
	select @begin=convert(datetime,'1901-1-1 00:00:00')
	end
if @end=null
	begin
	select @end=convert(datetime,'2070-1-1 00:00:00')
	end

if @day < @begin select @day = @begin
while @day <= @end and @day >= @begin
	begin
	if @day >= convert(datetime,convert(char(4),convert(decimal,@year)+1)+'-1-1 00:00:00') 
		begin
		select @ret=0
		goto gout
		end
	select @var_day=convert(char,@day,10)
	if @class = 'ratecode'
		select @var_value = value from rmratecode_ava where  charindex(rtrim(@ratecode) + ',',rtrim(ratecode) + ',') > 0 and date = @day
	else if @class = 'rmratecat'
		select @var_value = value from rmratecode_ava where  charindex(rtrim(@ratecode) + ',',rtrim(rate_cat) + ',') > 0 and date = @day
	else if @class = 'room_class'
		select @var_value = value from rmratecode_ava where  charindex(rtrim(@ratecode) + ',',rtrim(room_class) + ',') > 0 and date = @day
	else if @class = 'rmtype'
		select @var_value = value from rmratecode_ava where  charindex(rtrim(@ratecode) + ',',rtrim(room_type) + ',') > 0 and date = @day
	
	if charindex('C',@var_value)>0 
		begin
		update #date set flag=substring(flag,1,convert(integer,substring(@var_day,4,5)) -1)+'1'+substring(flag,convert(integer,substring(@var_day,4,5)) +1,31) where code=substring(@var_day,1,2)
		end
	else if charindex('B',@var_value)>0
		begin
		update #date set flag=substring(flag,1,convert(integer,substring(@var_day,4,5)) -1)+'2'+substring(flag,convert(integer,substring(@var_day,4,5)) +1,31) where code=substring(@var_day,1,2)
		end
	else if charindex('E',@var_value)>0
		begin
		update #date set flag=substring(flag,1,convert(integer,substring(@var_day,4,5)) -1)+'3'+substring(flag,convert(integer,substring(@var_day,4,5)) +1,31) where code=substring(@var_day,1,2)
		end
	--else if charindex('A',@var_value)>0
	--	begin
	--	update #date set flag=substring(flag,1,convert(integer,substring(@var_day,4,5)) -1)+'4'+substring(flag,convert(integer,substring(@var_day,4,5)) +1,31) where code=substring(@var_day,1,2)
	--	end
	--else if charindex('D',@var_value)>0
	--	begin
	--	update #date set flag=substring(flag,1,convert(integer,substring(@var_day,4,5)) -1)+'5'+substring(flag,convert(integer,substring(@var_day,4,5)) +1,31) where code=substring(@var_day,1,2)
	--	end
	else
		begin
		update #date set flag=substring(flag,1,convert(integer,substring(@var_day,4,5)) -1)+'9'+substring(flag,convert(integer,substring(@var_day,4,5)) +1,31) where code=substring(@var_day,1,2)
		end
	if datepart(weekday,@day)  = 1 or datepart(weekday,@day)  = 7
		begin
		update #date set flag1=substring(flag1,1,convert(integer,substring(@var_day,4,5)) -1)+'6'+substring(flag1,convert(integer,substring(@var_day,4,5)) +1,31) where code=substring(@var_day,1,2)
		end
	select @day=dateadd(day,1,@day),@var_value=''
	
	end 


select @ret=0

gout:
select * from #date
return @ret;

