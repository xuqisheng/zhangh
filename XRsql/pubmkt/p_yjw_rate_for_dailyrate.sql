IF OBJECT_ID('dbo.p_yjw_rate_for_dailyrate') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_yjw_rate_for_dailyrate
    IF OBJECT_ID('dbo.p_yjw_rate_for_dailyrate') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_yjw_rate_for_dailyrate >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_yjw_rate_for_dailyrate >>>'
END
;
create proc p_yjw_rate_for_dailyrate
	@types    		varchar(255) = '',		-- format: aaa,aaa,aaa
	@s_time			datetime,
	@e_time			datetime,
	@gstno			int,
	@ratecode		char(10),
   @rate          money output

as
-- ------------------------------------------------------------------------------------
--  房价查询 -- 兼顾 <可用房>
-- ------------------------------------------------------------------------------------
declare		@type					char(5),
				@pos					int,
				@over					int,
				@value				int,
				@bdate				datetime,
				@long					int,
				@seq_code			int,
				@seq_type			int,
				@ret					int,
				@msg					varchar(60),
				@rmrate				money,
				@rate1				money,
				@rate2				money,
            @tmp              char(5)

declare		@day					char(5),
				@week					char(1)

declare		@diff					int

select @s_time = convert(datetime,convert(char(8),@s_time,1))
select @e_time = convert(datetime,convert(char(8),@e_time,1))

select @week = convert(char(1), datepart(weekday,@s_time)-1)
select @day = substring(convert(char(10), @s_time, 111),6,5)

--
select @bdate = bdate1 from sysdata
select @diff = datediff(dd, getdate(), @s_time)
select @long = datediff(dd, @s_time, @e_time)

---------------------------------
-- 符合条件的房价码
---------------------------------
create table #ratecode (code varchar(10) not null)
-- 1. 指定房价码
if rtrim(@ratecode) is not null
	insert #ratecode values(@ratecode)
---------------------------------
-- 数据输出表
---------------------------------
create table #goutput
(
	code				char(20)					not null,
	type				char(5)					not null,
	value				money						null,
	seq_code			int		default 0	not null,
	seq_type			int		default 0	not null
)

-- 生成客房资源
while @types <> ''
begin
	select @pos = charindex(',', @types)
	if @pos > 0
	begin
		select @type = substring(@types, 1, @pos - 1)
		select @types = ltrim(stuff(@types, 1, @pos, ''))
	end
	else
	begin
		select @type = @types
		select @types = ''
	end
	if exists(select 1 from #goutput where type=@type)
		continue
	select @seq_code = 0
end

-- 生成房价信息
create table #rate (
	code				char(10)					not null,	-- 房价码
	def				char(10)					not null,	-- 明细码
	ratemode			char(1)					not null,	-- 定价模式  S=实价 D=优惠 (但是针对加床、小孩床仍是实价)
	type				char(5)					not null,
	rate1				money						null,
	rate2				money						null,
	rate3				money						null,
	rate4				money						null,
	rate5				money						null,
	rate6				money						null,
	factor			char(1)	default ''	not null,
	multi				money		default 1	not null,
	adder				money		default 0	not null,
   types          varchar(100) default '' not null,
   staymin         money    default 0   not null
)

if @types='' or @types is null
begin
	declare c_gettype cursor for select type from typim
	open c_gettype
	fetch c_gettype into @tmp
	while @@sqlstatus=0
		 begin
			select @types=rtrim(@types)+rtrim(@tmp)+','
			fetch c_gettype into @tmp
		 end
	close c_gettype
	deallocate cursor c_gettype
end


insert #rate select b.code, d.code, d.ratemode, @type, d.rate1, d.rate2, d.rate3, d.rate4, d.rate5, d.rate6, '', e.multi, e.addition,d.type,e.staymin
	from #ratecode b, rmratecode_link c, rmratedef d , rmratecode e
	where b.code=c.code and c.rmcode=d.code and b.code=e.code
 		and (d.begin_ is null or d.begin_<=@s_time)
		and (d.end_ is null or d.end_>=@s_time)
		and (d.stay<=@long or d.stay=0) and (d.stay_e>=@long or d.stay=0)
		and (charindex(@week,week)>0 or week='')


update #rate set types=@types where types=''


delete #rate where charindex(','+rtrim(type)+',',','+rtrim(types)+',')=0


update #rate set multi=1 where multi=0
update #rate set factor=b.factor from rmratecode a, rmrate_calendar b where #rate.code=a.code and a.calendar='T' and b.date=@s_time
--update #rate set multi=a.multi, adder=a.adder from rmrate_factor a where #rate.factor=a.code
-- 特殊日期

update #rate set rate1=a.rate1,rate2=a.rate2,rate3=a.rate3,
					rate4=a.rate4,rate5=a.rate5,rate6=a.rate6
	from rmratedef_sslink a, rmrate_season b
	where #rate.def=a.code and a.season=b.code
		and b.sequence = isnull((select min(x.sequence) from rmrate_season x, rmratedef_sslink y
											where x.code=y.season and y.code=#rate.def
												and (x.day='' or charindex(@day, x.day)>0)
												and (x.week='' or charindex(@week, x.week)>0)
												and (x.begin_ is not null and @s_time>=x.begin_)
												and (x.end_ is not null and @s_time<=x.end_)
										), 999999)

-- 优惠模式的价格需要进一步调整
update #rate set rate1=a.rate*(1-rate1), rate2=a.rate*(1-rate2), rate3=a.rate*(1-rate3),
					  rate4=a.rate*(1-rate4), rate5=a.rate*(1-rate5), rate6=a.rate*(1-rate6)
	from typim a where #rate.type=a.type and #rate.ratemode<>'S'

-- 价格推算 - 1
update #rate set rate5=rate6 where rate5=0 and rate6<>0
update #rate set rate4=rate5 where rate4=0 and rate5<>0
update #rate set rate3=rate4 where rate3=0 and rate4<>0
update #rate set rate2=rate3 where rate2=0 and rate3<>0
update #rate set rate1=rate2 where rate1=0 and rate2<>0
-- 价格推算 - 2
update #rate set rate2=rate1 where rate2=0 and rate1<>0
update #rate set rate3=rate2 where rate3=0 and rate2<>0
update #rate set rate4=rate3 where rate4=0 and rate3<>0
update #rate set rate5=rate4 where rate5=0 and rate4<>0
update #rate set rate6=rate5 where rate6=0 and rate5<>0


-- date type
update #rate set rate1=round(rate1*multi+adder, staymin), rate2=round(rate2*multi+adder, staymin), rate3=round(rate3*multi+adder, staymin),
		rate4=round(rate4*multi+adder, staymin), rate5=round(rate5*multi+adder, staymin), rate6=round(rate6*multi+adder, staymin)

--
if @gstno <= 1
begin
	insert #goutput select code, type, rate1, 0, 0 from #rate
end
else if @gstno = 2
begin
	insert #goutput select code, type, rate2, 0, 0 from #rate
end
else if @gstno = 3
begin
	insert #goutput select code, type, rate3, 0, 0 from #rate
end
else if @gstno = 4
begin
	insert #goutput select code, type, rate4, 0, 0 from #rate
end
else if @gstno = 5
begin
	insert #goutput select code, type, rate5, 0, 0 from #rate
end
else if @gstno >= 6
begin
	insert #goutput select code, type, rate6, 0, 0 from #rate
end

-- Output

select @rate=value from #goutput


return 0


;
EXEC sp_procxmode 'dbo.p_yjw_rate_for_dailyrate','unchained'
;
IF OBJECT_ID('dbo.p_yjw_rate_for_dailyrate') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_yjw_rate_for_dailyrate >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_yjw_rate_for_dailyrate >>>'
;
