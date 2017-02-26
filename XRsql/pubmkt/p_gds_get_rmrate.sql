IF OBJECT_ID('dbo.p_gds_get_rmrate') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_gds_get_rmrate
END
;

create proc p_gds_get_rmrate
	@stay				datetime,					-- 居住日期
	@long				int,							-- 天数
	@type				char(5),
	@roomno			char(5),
	@rmnums			int,
	@gstno			int,							-- 人数
	@ratecode		char(10),					--	房价码
	@groupno			char(10),
	@retmode			char(1),   					-- R,S
	@rmrate			money			output,		-- 房价
	@msg				varchar(60)	output
as
-- ------------------------------------------------------------------------------------
--		根据客房协议取得房价，及房价方案
--		当系统有效取值的时候，@msg 返回当前的( 房价明细码 )
-----------------------------------------------------------------------------
declare
	@hall				char(1),
	@gtype			char(3),
	@flr				varchar(3),
	@diff				int,
   @ratemode      char(1),      		--  定义方式,D=打折法,S=实价法 
   @discount     	money,		  		--  打折因子 
	@qtrate			money,
	@ret  			int,
	@ok				char(1),
	@rmcode			char(10),				-- 房价明细码
	@bdate			datetime,
	@e_time			datetime,
	@pri				int,
	@week					char(1),
	@code				char(10),
	@sswr				int,
	@weeks			char(7),
	@num				int,
	@len				int

select @ret=0, @msg='',@rmrate=0, @ok='F', @bdate=bdate1 from sysdata
select @stay = convert(datetime,convert(char(8),@stay,1))
select @diff = datediff(dd, getdate(), @stay)
select @week = convert(char(1), datepart(weekday,@stay)-1)
if @week='0' select @week='7'
select @e_time = dateadd(dd,@long,@stay)
select @sswr = isnull(staymin,0) from rmratecode where code = @ratecode

exec p_zk_converttoweek @stay,@e_time,'T',@weeks out		--得到一周中在住的星期 比如2007-1-5到2007-1-11就返回'12356'

if rtrim(@roomno) is not null and @roomno>='0'
begin
	select @hall=hall, @type=type, @flr=flr, @qtrate=rate from rmsta where roomno=@roomno
	if @@rowcount=0
	begin
		select @ret=1, @msg= '%1 房号不存在 !^'+@roomno 
		goto done
	end
end
else 
	select @hall = null, @flr=null, @roomno=null

if rtrim(@type) is null
begin
	select @ret=1, @msg='没有客房信息'
	goto done
end

select @gtype=gtype from typim where type=@type
if @roomno is null
	select @qtrate = rate from typim where type=@type


-- 没有协议, 取原房价
if rtrim(@ratecode) is null  
	or not exists(select 1 from rmratecode where code=@ratecode 
			and (begin_ is null or @stay>=begin_)	and (end_ is null or @stay<=end_)
			and (thoughmin<=@long or thoughmin=0) and (thoughmax>=@long or thoughmax=0 )
			and (arrmin<=@diff or arrmin=0) and (arrmax>=@diff or arrmax=0 ))
begin
	select @ret=1, @rmrate=0, @msg='房价码不存在 或者 已经无效'
	goto done
end

                                               
if exists (select 1 from rmratecode_ava where charindex(rtrim(@ratecode)+',',rtrim(ratecode)+',') > 0 
			and rtrim(rate_cat) = null and rtrim(room_class) = null and rtrim(room_type) = null 
				and (charindex('C',value)>0 or (min_stay > @long and min_stay <> 0) or (max_stay < @long and max_stay <> 0)) and ((date >= @stay and date < @e_time) or (date >= @stay and date <= @e_time and @stay = @e_time)))
or exists (select 1 from rmratecode_ava where charindex(rtrim(@type)+',',rtrim(room_type)+',') > 0 
			and rtrim(rate_cat) = null and rtrim(room_class) = null and rtrim(ratecode) = null 
				and (charindex('C',value)>0 or (min_stay > @long and min_stay <> 0) or (max_stay < @long and max_stay <> 0)) and ((date >= @stay and date < @e_time) or (date >= @stay and date <= @e_time and @stay = @e_time)))
or exists (select 1 from rmratecode_ava where charindex(rtrim(@type)+',',rtrim(room_type)+',') > 0 
			and rtrim(rate_cat) = null and rtrim(room_class) = null and charindex(rtrim(@ratecode)+',',rtrim(ratecode)+',') > 0
				and (charindex('C',value)>0 or (min_stay > @long and min_stay <> 0) or (max_stay < @long and max_stay <> 0)) and ((date >= @stay and date < @e_time) or (date >= @stay and date <= @e_time and @stay = @e_time)))
or exists (select 1 from rmratecode_ava where rtrim(rate_cat)+',' like (select rtrim(cat)+',%' from rmratecode where code = @ratecode)
			and rtrim(ratecode) = null and rtrim(room_class) = null and rtrim(room_type) = null 
				and (charindex('C',value)>0 or (min_stay > @long and min_stay <> 0) or (max_stay < @long and max_stay <> 0)) and ((date >= @stay and date < @e_time) or (date >= @stay and date <= @e_time and @stay = @e_time)))
or exists (select 1 from rmratecode_ava where rtrim(room_class) = (select rtrim(gtype) from typim where type = @type)
			and rtrim(rate_cat) = null and rtrim(room_type) = null and rtrim(ratecode) = null 
				and (charindex('C',value)>0 or (min_stay > @long and min_stay <> 0) or (max_stay < @long and max_stay <> 0)) and ((date >= @stay and date < @e_time) or (date >= @stay and date <= @e_time and @stay = @e_time)))
or exists (select 1 from rmratecode_ava where rtrim(room_class) = (select rtrim(gtype) from typim where type = @type)
			and rtrim(rate_cat) = null and rtrim(room_class) = null and rtrim(rate_cat)+',' like (select rtrim(cat)+',%' from rmratecode where code = @ratecode)
				and (charindex('C',value)>0 or (min_stay > @long and min_stay <> 0) or (max_stay < @long and max_stay <> 0)) and ((date >= @stay and date < @e_time) or (date >= @stay and date <= @e_time and @stay = @e_time)))
begin
	select @ret=1, @rmrate=0, @msg='房价码不存在 或者 已经无效'
	goto done
end
if exists (select 1 from rmratecode_ava where charindex(rtrim(@ratecode)+',',rtrim(ratecode)+',') > 0 
			and rtrim(rate_cat) = null and rtrim(room_class) = null and rtrim(room_type) = null 
				and charindex('B',value)>0 and date = @stay)
or exists (select 1 from rmratecode_ava where charindex(rtrim(@type)+',',rtrim(room_type)+',') > 0 
			and rtrim(rate_cat) = null and rtrim(room_class) = null and rtrim(ratecode) = null 
				and charindex('B',value)>0 and date = @stay)
or exists (select 1 from rmratecode_ava where charindex(rtrim(@type)+',',rtrim(room_type)+',') > 0 
			and rtrim(rate_cat) = null and rtrim(room_class) = null and charindex(rtrim(@ratecode)+',',rtrim(ratecode)+',') > 0
				and charindex('B',value)>0 and date = @stay)
or exists (select 1 from rmratecode_ava where rtrim(rate_cat)+',' like (select rtrim(cat)+',%' from rmratecode where code = @ratecode)
			and rtrim(ratecode) = null and rtrim(room_class) = null and rtrim(room_type) = null 
				and charindex('B',value)>0 and date = @stay)
or exists (select 1 from rmratecode_ava where rtrim(room_class) = (select rtrim(gtype) from typim where type = @type)
			and rtrim(rate_cat) = null and rtrim(room_type) = null and rtrim(ratecode) = null 
				and charindex('B',value)>0 and date = @stay)
or exists (select 1 from rmratecode_ava where rtrim(room_class) = (select rtrim(gtype) from typim where type = @type)
			and rtrim(rate_cat) = null and rtrim(room_class) = null and rtrim(rate_cat)+',' like (select rtrim(cat)+',%' from rmratecode where code = @ratecode)
				and charindex('B',value)>0 and date = @stay)
begin
	select @ret=1, @rmrate=0, @msg='房价码不存在 或者 已经无效'
	goto done
end
if exists (select 1 from rmratecode_ava where charindex(rtrim(@ratecode)+',',rtrim(ratecode)+',') > 0 
			and rtrim(rate_cat) = null and rtrim(room_class) = null and rtrim(room_type) = null 
				and charindex('E',value)>0 and date = @e_time)
or exists (select 1 from rmratecode_ava where charindex(rtrim(@type)+',',rtrim(room_type)+',') > 0 
			and rtrim(rate_cat) = null and rtrim(room_class) = null and rtrim(ratecode) = null 
				and charindex('E',value)>0 and date = @e_time)
or exists (select 1 from rmratecode_ava where charindex(rtrim(@type)+',',rtrim(room_type)+',') > 0 
			and rtrim(rate_cat) = null and rtrim(room_class) = null and charindex(rtrim(@ratecode)+',',rtrim(ratecode)+',') > 0
				and charindex('E',value)>0 and date = @e_time)
or exists (select 1 from rmratecode_ava where rtrim(rate_cat)+',' like (select rtrim(cat)+',%' from rmratecode where code = @ratecode)
			and rtrim(ratecode) = null and rtrim(room_class) = null and rtrim(room_type) = null 
				and charindex('E',value)>0 and date = @e_time)
or exists (select 1 from rmratecode_ava where rtrim(room_class) = (select rtrim(gtype) from typim where type = @type)
			and rtrim(rate_cat) = null and rtrim(room_type) = null and rtrim(ratecode) = null 
				and charindex('E',value)>0 and date = @e_time)
or exists (select 1 from rmratecode_ava where rtrim(room_class) = (select rtrim(gtype) from typim where type = @type)
			and rtrim(rate_cat) = null and rtrim(room_class) = null and rtrim(rate_cat)+',' like (select rtrim(cat)+',%' from rmratecode where code = @ratecode)
				and charindex('E',value)>0 and date = @e_time)
or exists (select 1 from rmratecode_ava where rtrim(room_type) = null and rtrim(ratecode) = null and rtrim(rate_cat) = null and 
			rtrim(room_class) = null and ((min_stay > @long and min_stay <> 0) or (max_stay < @long and max_stay <> 0)) 
				and ((date >= @stay and date < @e_time) or (date >= @stay and date <= @e_time and @stay = @e_time)))
begin
	select @ret=1, @rmrate=0, @msg='房价码不存在 或者 已经无效'
	goto done
end

if charindex(@week,@weeks) = 0 and @long> 0
	begin
	select @ret=1, @rmrate=0, @msg='房价码不存在 或者 已经无效'
	goto done
	end

--去掉不符合房价明细中定义的每周可用规则
//select @num = 1
//select @len = datalength(rtrim(@weeks))
//while @len > 0
//	begin
//	if exists(select 1 from rmratedef where code in (select rmcode from rmratecode_link where code = @ratecode) and charindex(substring(@weeks,@num,1),week) = 0 and rtrim(week) <> null)
//		begin
//		select @ret=1, @rmrate=0, @msg='房价码不存在 或者 已经无效'
//		goto done
//		end
//	select @len = @len - 1, @num = @num + 1
//	end

--
select @pri = null
select @pri = min(b.pri) from rmratedef a, rmratecode_link b 
	where a.code=b.rmcode and b.code=@ratecode 
		and @long>=a.stay
		and (rtrim(a.gtype) is null or @gtype is null or charindex(','+rtrim(@gtype)+',', ','+a.gtype+',') > 0 )
		and (rtrim(a.type) is null or @type is null or charindex(','+rtrim(@type)+',', ','+a.type+',') > 0 )
		and (rtrim(a.hall) is null or @hall is null or charindex(','+rtrim(@hall)+',', ','+a.hall+',') > 0 )
		and (rtrim(a.flr) is null or @flr is null or charindex(','+rtrim(@flr)+',', ','+a.flr+',') > 0 )
		and (rtrim(a.roomno) is null or @roomno is null or charindex(','+rtrim(@roomno)+',', ','+a.roomno+',') > 0 )
		and @rmnums >= a.rmnums
		and (a.begin_ is null or a.begin_<=@stay)
		and (a.end_ is null or a.end_>=@stay)
		and (a.stay<=@long or a.stay=0) and (a.stay_e>=@long or a.stay_e=0)
		and (charindex(@week,a.week)>0 or rtrim(a.week) = null)

if @pri is not null
begin
	select @ok = 'T'
	select @rmcode = rmcode from rmratecode_link where code=@ratecode and pri=@pri

	--  人数与价格
	declare @rate1 money,@rate2 money,@rate3 money,@rate4 money,@rate5 money,@rate6 money, @row int
	declare	@season 	char(3),
				@day		char(5)

	
	select @day = substring(convert(char(10), @stay, 111),6,5)
	select @season = a.season from rmratedef_sslink a, rmrate_season b     -- 特殊日期
		where a.code=@rmcode and a.season=b.code 
			and b.sequence = isnull((select min(x.sequence) from rmrate_season x, rmratedef_sslink y 
											where x.code=y.season and y.code=@rmcode
												and (x.day='' or charindex(@day, x.day)>0)
												and (x.week='' or charindex(@week, x.week)>0)
												and (x.begin_ is null or (x.begin_ is not null and @stay>=x.begin_))
												and (x.end_ is null or (x.end_ is not null and @stay<=x.end_))
										), 999999)
	if @@rowcount = 0
		select @rate1=rate1,@rate2=rate2,@rate3=rate3,@rate4=rate4,@rate5=rate5,@rate6=rate6 from rmratedef where code=@rmcode
	else
		select @rate1=rate1,@rate2=rate2,@rate3=rate3,@rate4=rate4,@rate5=rate5,@rate6=rate6 from rmratedef_sslink where code=@rmcode and season=@season
	select @ratemode=ratemode from rmratedef where code=@rmcode

------------------------------------------------------------------------------------
-- 方法 1 不采用临时表 - gaoliang 
------------------------------------------------------------------------------------
	select @row = @gstno, @rmrate=0
	while @row > 0
		begin
		if @rmrate<> 0
			break
		else if @row = 1 and @rate1 <> 0
			select @rmrate = @rate1
		else if @row = 2 and @rate2 <> 0
			select @rmrate = @rate2
		else if @row = 3 and @rate3 <> 0
			select @rmrate = @rate3
		else if @row = 4 and @rate4 <> 0
			select @rmrate = @rate4
		else if @row = 5 and @rate5 <> 0
			select @rmrate = @rate5
		else if @row = 6 and @rate6 <> 0
			select @rmrate = @rate6
		select @row = @row - 1
		end
	if @rmrate = 0
		begin
		select @row = 1
		while @row <= 6
			begin
			if @rmrate<> 0
				break
			else if @row = 1 and @rate1 <> 0
				select @rmrate = @rate1
			else if @row = 2 and @rate2 <> 0
				select @rmrate = @rate2
			else if @row = 3 and @rate3 <> 0
				select @rmrate = @rate3
			else if @row = 4 and @rate4 <> 0
				select @rmrate = @rate4
			else if @row = 5 and @rate5 <> 0
				select @rmrate = @rate5
			else if @row = 6 and @rate6 <> 0
				select @rmrate = @rate6
			select @row = @row + 1
			end
		end
------------------------------------------------------------------------------------
-- 获取价格 end
------------------------------------------------------------------------------------
--
if @ratemode='D'
	select @rmrate = round(@qtrate*(1 - @rmrate), @sswr)
	select @msg = @rmcode
end
 declare	@multi money, @adder money 
if @ok='F'
	select @ret=1, @rmrate=0, @msg='房价码未涉及, 自动提取门市价'
else
begin
	if exists(select 1 from rmratecode where code=@ratecode and calendar='T')  -- 房价日历的支持  modified by yjw 2008-10-8
    	begin
            select @multi=multi,@adder=addition from rmratecode where code = @ratecode 
		    if @multi=0 
			     select @multi=1
		    select @rmrate=round(@rmrate*@multi+@adder, @sswr)
		    if exists(select 1 from rmrate_calendar where date=@stay)
				 begin
				 select @multi=a.multi, @adder=a.adder from rmrate_factor a, rmrate_calendar b where a.code=b.factor and b.date=@stay 
				 if @@rowcount<>0
					 select @rmrate=round(@rmrate*@multi+@adder, @sswr)  
				 end
//            else
//                begin
//		            select @multi=multi,@adder=addition from rmratecode where code = @ratecode 
//		            if @multi=0 
//			             select @multi=1
//		            select @rmrate=round(@rmrate*@multi+@adder, @sswr)
//	             end
	    end
	else if  exists(select 1 from rmratecode where multi<>0 or addition<>0 and code = @ratecode)
	    begin
		    select @multi=multi,@adder=addition from rmratecode where code = @ratecode 
		    if @multi=0 
			     select @multi=1
		    select @rmrate=round(@rmrate*@multi+@adder, @sswr)
	    end
end 

done:
if @retmode = 'S'
	select @ret, @msg, @rmrate
return @ret

;