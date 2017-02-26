
IF OBJECT_ID('p_gds_reserve_rate_query') IS NOT NULL
    DROP PROCEDURE p_gds_reserve_rate_query
;
create proc p_gds_reserve_rate_query
	@pc_id			char(4),
	@types    		varchar(255),		-- format: aaa,aaa,aaa
	@s_time			datetime,
	@e_time			datetime,
	@gstno			int,
	@rmnum			int,
	@ratecode		char(10),
	@haccnt			char(7),
	@cusno			char(7),
	@agent			char(7),
	@source			char(7),
	@mode				char(1),				-- P=private, A-all, B-pri&pub
	@closed			char(1),				-- 'T'-include closed 
	@rate				money,
	@rate_link		money=null,			-- 这个价格表示范围
	@class			char(1) = 'F',		-- 表示入口处是散客还是团队
	@rmnum_before	int = 0				-- 表示计算剩余房量的时候必须扣除修改房量之前的，不然就是重复计算了
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
				@rate2				money

declare		@day					char(5),
				@week					char(1),
				@weeks				char(7),
				@num					int,
				@len					int

declare		@diff					int

delete rate_query_filter where pc_id=@pc_id 
select @s_time = convert(datetime,convert(char(8),@s_time,1))
select @e_time = convert(datetime,convert(char(8),@e_time,1))

select @week = convert(char(1), datepart(weekday,@s_time)-1)
if @week = '0'
	select @week = '7'
select @day = substring(convert(char(10), @s_time, 111),6,5)

exec @ret = p_zk_converttoweek @s_time,@e_time,'T',@weeks out		--得到一周中在住的星期 比如2007-1-5到2007-1-11就返回'12356'

-- 清除外部坐标对照表
delete rate_query_item where pc_id = @pc_id
update rmratecode set sequence = 9000 + sequence where sequence < 100

--
select @bdate = bdate1 from sysdata
select @diff = datediff(dd, getdate(), @s_time)
select @long = datediff(dd, @s_time, @e_time)
if @long <= 0 
	select @long = 1
if @rate is null or @rate<=0  -- 表示对价格没有限制
begin
	if @rate_link is null or @rate_link<=0  -- 表示对价格没有限制
		select @rate1=0, @rate2=1000000
	else
		select @rate1 = round(@rate_link*0.9, 2), @rate2 = round(@rate_link*1.1, 2)  -- 10% 的变化幅度
end
else
begin
	if @rate_link is null or @rate_link<=0 or @rate=@rate_link  -- 表示对价格没有限制
		select @rate1 = round(@rate*0.9, 2), @rate2 = round(@rate*1.1, 2)  -- 10% 的变化幅度
	else
	begin
		if @rate > @rate_link
			select @rate1=@rate_link, @rate2=@rate
		else
			select @rate1=@rate, @rate2=@rate_link
	end
end

------------------------------------------------------------------
-- @types -- 没有指定房类的时候，需要自己串起所有房类
------------------------------------------------------------------
-- 客房范围处理 
declare	@empno			char(10),
			@shift			char(1),
			@appid			char(1),
			@ghall			varchar(255),
			@gtype			varchar(255),
			@pcid				char(4)
select @ghall='', @gtype='' 
exec @ret = p_gds_get_login_info 'R', @empno output, @shift output, @pcid output, @appid output 
if @ret=0 and @pcid=@pc_id 
begin 
	if exists(select 1 from sysoption where catalog='hotel' and item='emp_rm_scope' and value='T') 
	begin 
		select @ghall=halls, @gtype=types from hall_station_user where empno=@empno
		if @@rowcount = 0  
			select @ghall=halls, @gtype=types from hall_station_user a, sys_empno b where a.empno=b.deptno and b.empno=@empno 
	end
	if @ghall='-' select @ghall='' 
	if @gtype='-' select @gtype='' 
	if @ghall = '' and @gtype = ''
		select @ghall=halls, @gtype=types from hall_station where pc_id = @pcid
end
insert rate_query_filter(pc_id, class, grp, code) 
		select @pc_id, 'rmtype', gtype, type from typim 
			where tag='K' and (rtrim(@types) is null or @types='%' or (charindex(','+rtrim(type)+',',','+@types+',')>0))
				and type in (select distinct type from rmsta where (@ghall='' or charindex(hall,@ghall)>0) and (@gtype='' or charindex(','+rtrim(type)+',',','+@gtype+',')>0))

---------------------------------
-- 符合条件的房价码
---------------------------------
create table #ratecode (code varchar(10) not null)
-- 1. 指定房价码 需要过滤指定房价码是否有效
if rtrim(@ratecode) is not null
	insert #ratecode select (@ratecode) from rmratecode where code = @ratecode and 
		halt='F' and code not in (select c.code from #ratecode c)
		and (thoughmin<=@long or thoughmin=0) and (thoughmax>=@long or thoughmax=0 )
		and (arrmin<=@diff or arrmin=0) and (arrmax>=@diff or arrmax=0 )
		and (begin_<=@e_time or begin_ is null) and (end_>=@e_time or end_ is null)
		and (begin_<=@s_time or begin_ is null) and (end_>=@s_time or end_ is null)

-- 2. 私有房价码
if rtrim(@haccnt) is null select @haccnt = ''
if rtrim(@cusno) is null select @cusno = ''
if rtrim(@agent) is null select @agent = ''
if rtrim(@source) is null select @source = '' 
insert #ratecode select distinct a.value from guest_extra a, rmratecode b 
	where a.no in (@haccnt, @cusno, @agent, @source) and a.item='ratecode' 
		and a.value=b.code and b.halt='F' 
		and a.value not in (select c.code from #ratecode c)
		and (b.thoughmin<=@long or b.thoughmin=0) and (b.thoughmax>=@long or b.thoughmax=0 )
		and (b.arrmin<=@diff or b.arrmin=0) and (b.arrmax>=@diff or b.arrmax=0 )
		and (b.begin_<=@e_time or b.begin_ is null) and (b.end_>=@e_time or b.end_ is null)
		and (b.begin_<=@s_time or b.begin_ is null) and (b.end_>=@s_time or b.end_ is null)
		and (a.begin_<=@e_time or a.begin_ is null) and (a.end_>=@e_time or a.end_ is null)
		and (a.begin_<=@s_time or a.begin_ is null) and (a.end_>=@s_time or a.end_ is null)

-- 3. 公用房价码
if @mode = 'B' 
	insert #ratecode select code from rmratecode 
		where code not in (select c.code from #ratecode c)
			and private='F' and halt='F'
			  and (thoughmin<=@long or thoughmin=0) and (thoughmax>=@long or thoughmax=0 )
			and (arrmin<=@diff or arrmin=0) and (arrmax>=@diff or arrmax=0 )
			and (begin_<=@e_time or begin_ is null) and (end_>=@e_time or end_ is null)
			and (begin_<=@s_time or begin_ is null) and (end_>=@s_time or end_ is null)

-- 4. 所有房价码
if @mode = 'A' 
	insert #ratecode select code from rmratecode 
		where halt='F' and code not in (select c.code from #ratecode c)
		and (thoughmin<=@long or thoughmin=0) and (thoughmax>=@long or thoughmax=0 )
		and (arrmin<=@diff or arrmin=0) and (arrmax>=@diff or arrmax=0 )
		and (begin_<=@e_time or begin_ is null) and (end_>=@e_time or end_ is null)
		and (begin_<=@s_time or begin_ is null) and (end_>=@s_time or end_ is null)
--
if @closed = 'T'
	insert #ratecode select code from rmratecode 
		where halt='T' and code not in (select c.code from #ratecode c)
		and (thoughmin<=@long or thoughmin=0) and (thoughmax>=@long or thoughmax=0 )
		and (arrmin<=@diff or arrmin=0) and (arrmax>=@diff or arrmax=0 )

-- 
insert rate_query_filter(pc_id, class, grp, code) 
		select @pc_id, 'ratecode', a.cat, a.code from rmratecode a, #ratecode b where a.code=b.code 
-- 房价策略过滤 
exec p_gds_reserve_strategy_rq @pc_id,@s_time,@e_time,@gstno,@rmnum,@ratecode,@haccnt,@cusno,@agent,@source,@class,@rmnum_before

-- 
select @types = ','
declare c_type cursor for select a.type from typim a, rate_query_filter b 
	where a.type=b.code and b.pc_id=@pc_id and b.class='rmtype' order by a.sequence, a.type
open c_type
fetch c_type into @type
while @@sqlstatus = 0
begin
	select @types = @types + ',' + rtrim(@type)
	fetch c_type into @type
end
close c_type
deallocate cursor c_type
select @types = substring(@types, 3, datalength(@types) - 2)

delete #ratecode 
insert #ratecode select code from rate_query_filter where pc_id=@pc_id and class='ratecode' 


--提取需要屏蔽的房价信息
create table #filter 
(
	ratecode				char(255)					not null,
	ratecat				char(255)					not null,
	room_class			char(255)					not null,
	room_type			char(255)					not null,
	mins					int						not null,
	maxs					int						not null
)

insert #filter select ratecode,rate_cat,room_class,room_type,min_stay,max_stay from rmratecode_ava where (charindex('C',value)>0 or (min_stay>@long and min_stay<>0) or (max_stay<@long and max_stay<>0)) and ((date>=@s_time and date <@e_time) or (date>=@s_time and date <=@e_time and @s_time=@e_time))
insert #filter select ratecode,rate_cat,room_class,room_type,min_stay,max_stay from rmratecode_ava where (date=@s_time and charindex('B',value)>0) or (date=@e_time and charindex('E',value)>0)

 
                                                                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                                                                                             
                                                                                                                                                                     
--delete from #ratecode where code in (select code from rmratecode_link where rmcode in (select code from rmratedef where type like (select '%'+rtrim(code)+'%' from rmratecode_ava where date>=@s_time and date <@e_time and charindex('C',value)>0 and type='rmtype')))

---------------------------------
-- 数据输出表
---------------------------------
create table #goutput 
(
	code				char(20)					not null,
	cat				char(3)					not null,
	type				char(5)					not null,
	value				char(10)						null,
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

	-- room avail
	if exists(select 1 from rsvlimit where date=@s_time and type=@type) 
		select @over=a.overbook, @seq_type = b.sequence from rsvlimit a, typim b where a.date=@s_time and a.type=@type and a.type=b.type 
	else 
		select @over = overquan, @seq_type = sequence from typim where type=@type
	if @seq_type is null select @seq_type = 0
	exec p_gds_reserve_type_avail @type, @s_time, @e_time, '0', 'R', @value output
	if @rmnum - @rmnum_before > @value + @over
		continue   -- 客房资源不足
	insert #goutput(code,type,value,seq_code,seq_type,cat) select 'Avail', @type, convert(char(10),@value), @seq_code, @seq_type,''
	select @value = @value + @over
	insert #goutput(code,type,value,seq_code,seq_type,cat) select 'Avail(In.O)', @type, convert(char(10),@value), @seq_code, @seq_type,''
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
	sswr				int		default 0	not null,
	cat				char(3)					not null
)
insert #rate select b.code, d.code, d.ratemode, a.type, d.rate1, d.rate2, d.rate3, d.rate4, d.rate5, d.rate6, '', e.multi, e.addition ,isnull(e.staymin,0),e.cat
	from typim a, #ratecode b, rmratecode_link c, rmratedef d , rmratecode e
	where b.code=c.code and c.rmcode=d.code and b.code=e.code
		and ( charindex(','+rtrim(a.type)+',',','+rtrim(d.type)+',')>0 or rtrim(d.type) is null)
		and ( charindex(','+rtrim(a.gtype)+',',','+rtrim(d.gtype)+',')>0 or rtrim(d.gtype) is null)
		and (d.begin_ is null or d.begin_<=@s_time)
		and (d.end_ is null or d.end_>=@s_time)
		and a.type in (select type from #goutput where code = 'Avail')
		and a.tag='K'
		and (d.stay<=@long or d.stay=0) and (d.stay_e>=@long or d.stay=0)
		and (charindex(@week,week)>0 or rtrim(week) is null)
		and (d.begin_<=@s_time or d.begin_ is null) and (d.end_>=@s_time or d.end_ is null)
update #rate set multi=1 where multi=0

--
--去掉不符合房价明细中定义的每周可用规则
//select @num = 1
//select @len = datalength(rtrim(@weeks))
//while @len > 0
//	begin
//	delete from #rate where def not in (select code from rmratedef where charindex(substring(@weeks,@num,1),week)>0 or rtrim(week) = null)
//	select @len = @len - 1, @num = @num + 1
//	end

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

-- date format 
update #rate set rate1=rate1*multi+adder, rate2=rate2*multi+adder, rate3=rate3*multi+adder, 
		rate4=rate4*multi+adder, rate5=rate5*multi+adder, rate6=rate6*multi+adder

update #rate set multi = 1,adder = 0 

update #rate set factor=b.factor from rmratecode a, rmrate_calendar b where #rate.code=a.code and a.calendar='T' and b.date=@s_time 
update #rate set multi=a.multi, adder=a.adder from rmrate_factor a where #rate.factor=a.code 

update #rate set rate1=round(rate1*multi+adder, sswr), rate2=round(rate2*multi+adder, sswr), rate3=round(rate3*multi+adder, sswr), 
		rate4=round(rate4*multi+adder, sswr), rate5=round(rate5*multi+adder, sswr), rate6=round(rate6*multi+adder, sswr)

--
if @gstno <= 1 
begin
	if @rate1 <> 0 
		insert #goutput select code, cat, type, rate1, 0, 0 from #rate where rate1>=@rate1 and rate1<=@rate2
	else
		insert #goutput select code, cat, type, rate1, 0, 0 from #rate 
end
else if @gstno = 2
begin
	if @rate1 <> 0 
		insert #goutput select code, cat, type, rate2, 0, 0 from #rate where rate2>=@rate1 and rate2<=@rate2
	else
		insert #goutput select code, cat, type, rate2, 0, 0 from #rate 
end
else if @gstno = 3
begin
	if @rate1 <> 0 
		insert #goutput select code, cat, type, rate3, 0, 0 from #rate where rate3>=@rate1 and rate3<=@rate2
	else
		insert #goutput select code, cat, type, rate3, 0, 0 from #rate 
end
else if @gstno = 4
begin
	if @rate1 <> 0 
		insert #goutput select code, cat, type, rate4, 0, 0 from #rate where rate4>=@rate1 and rate4<=@rate2
	else
		insert #goutput select code, cat, type, rate4, 0, 0 from #rate 
end
else if @gstno = 5
begin
	if @rate1 <> 0 
		insert #goutput select code, cat, type, rate5, 0, 0 from #rate where rate5>=@rate1 and rate5<=@rate2
	else
		insert #goutput select code, cat, type, rate5, 0, 0 from #rate 
end
else if @gstno >= 6
begin
	if @rate1 <> 0 
		insert #goutput select code, cat, type, rate6, 0, 0 from #rate where rate6>=@rate1 and rate6<=@rate2
	else
		insert #goutput select code, cat, type, rate6, 0, 0 from #rate 
end

--屏蔽可用性中设置关闭的价格
delete from #goutput where (exists (select 1 from #filter where rtrim(ratecode)+',' like '%'+rtrim(#goutput.code)+',%' and rtrim(room_type)+',' like '%'+rtrim(#goutput.type)+',%')
								or exists (select 1 from #filter where rtrim(ratecode)+',' like '%'+rtrim(#goutput.code)+',%' and rtrim(room_type) = null and rtrim(ratecat) = null and rtrim(room_class) = null)
								or exists (select 1 from #filter where rtrim(ratecode) = null and rtrim(room_type)+',' like '%'+rtrim(#goutput.type)+',%' and rtrim(ratecat) = null and rtrim(room_class) = null)
								or	exists (select 1 from #filter where rtrim(ratecat)+',' like '%'+rtrim(#goutput.cat)+',%' and rtrim(room_type)+',' like '%'+rtrim(#goutput.type)+',%' ) 
								or exists (select 1 from #filter where rtrim(ratecat)+',' like '%'+rtrim(#goutput.cat)+',%' and rtrim(room_type) = null and rtrim(ratecode) = null and rtrim(room_class) = null)
								or exists (select 1 from #filter where rtrim(ratecat) = null and rtrim(room_type)+',' like '%'+rtrim(#goutput.type)+',%' and rtrim(ratecode) = null and rtrim(room_class) = null))
and code not like 'Avail%'
delete from #goutput where (exists (select 1 from #filter where rtrim(ratecode)+',' like '%'+rtrim(#goutput.code)+',%' and rtrim(#goutput.type) in (select rtrim(type) from typim where gtype = rtrim(#filter.room_class)) )
								or exists (select 1 from #filter where rtrim(ratecode)+',' like '%'+rtrim(#goutput.code)+',%' and rtrim(room_class) = null and rtrim(ratecat) = null and rtrim(room_type) = null)
								or exists (select 1 from #filter where rtrim(ratecode) = null and rtrim(#goutput.type) in (select rtrim(type) from typim where gtype = rtrim(#filter.room_class))  and rtrim(ratecat) = null and rtrim(room_type) = null)
								or exists (select 1 from #filter where rtrim(ratecat)+',' like '%'+rtrim(#goutput.cat)+',%' and rtrim(#goutput.type) in (select rtrim(type) from typim where gtype = rtrim(#filter.room_class)) )
								or exists (select 1 from #filter where rtrim(ratecat)+',' like '%'+rtrim(#goutput.cat)+',%' and rtrim(room_class) = null and rtrim(ratecode) = null and rtrim(room_type) = null)
								or exists (select 1 from #filter where rtrim(ratecat) = null and rtrim(#goutput.type) in (select rtrim(type) from typim where gtype = rtrim(#filter.room_class)) and rtrim(ratecode) = null and rtrim(room_type) = null ))
and code not like 'Avail%'
delete from #goutput where code not like 'Avail%' and exists(select 1 from rmratecode_ava where (rtrim(ratecode) = null and rtrim(room_type) = null and rtrim(rate_cat) = null and rtrim(room_class) = null 
				and ((date>=@s_time and date <@e_time) or (date>=@s_time and date <=@e_time and @s_time=@e_time))))

-- seq  次序的计算非常重要 ！！！
create table #code (code char(10) null, sequence int null)
insert #code (code) select distinct code from #goutput where code not like 'Avail%'
update #code set sequence = a.sequence from rmratecode a where #code.code=a.code
update #goutput set seq_code = (select count(1) from #code b 
		where right(rtrim('0000000000'+convert(char(10),b.sequence)),10)+b.code <= right(rtrim('0000000000'+convert(char(10),a.sequence)),10)+a.code) 
	from #code a where rtrim(#goutput.code)=rtrim(a.code)
delete #code
insert #code (code) select distinct type from #goutput
update #code set sequence = a.sequence from typim a where rtrim(#code.code)=rtrim(a.type)
update #goutput set seq_type = (select count(1) from #code b 
		where right(rtrim('0000000000'+convert(char(10),b.sequence)),10)+b.code <= right(rtrim('0000000000'+convert(char(10),a.sequence)),10)+a.code) 
	from #code a where rtrim(#goutput.type)=rtrim(a.code)


-- 上面已经算好了，这里不需要重新计算了 , 直接赋值
--update rate_query_item set seq1=
--	(select count(1) from rate_query_item a 
--		where rate_query_item.pc_id=a.pc_id and rate_query_item.flag=a.flag
--			and right(rtrim('0000000000'+convert(char(10),a.seq0)),10)+a.value <= right(rtrim('0000000000'+convert(char(10),rate_query_item.seq0)),10)+rate_query_item.value )
--	where pc_id = @pc_id


-- Record 
insert rate_query_item (pc_id,flag,seq0,seq1,value)
	select distinct @pc_id,'rate',seq_code,seq_code,code from #goutput where code not like 'Avail%'
insert rate_query_item (pc_id,flag,seq0,seq1,value)
	select distinct @pc_id,'type',seq_type,seq_type,type from #goutput

-- 
delete rate_query_filter where pc_id=@pc_id 

--调整格式
update #goutput set value = substring(value,1,charindex('.00',value) - 1) where charindex('.00',value) > 0

--配额房rate_query显示方案
if exists (select 1 from sysoption where catalog = 'hotel' and item = 'allotment' and value = 'T')
	begin
	update #goutput set value = '	' + value from rsv_plan_check b where code not like 'Avail%' and b.pc_id = @pc_id
				and ','+rtrim(b.ratecodes)+',' like '%,'+rtrim(#goutput.code)+',%' and ','+rtrim(b.rmtypes)+',' like '%,'+rtrim(#goutput.type)+',%' and class = @class
	
	update #goutput set value = value + '	' from rsv_plan_check b where code not like 'Avail%' and b.pc_id = @pc_id
				and ','+rtrim(b.ratecodes)+',' like '%,'+rtrim(#goutput.code)+',%' and ','+rtrim(b.rmtypes)+',' like '%,'+rtrim(#goutput.type)+',%' and leftn < 0 and class = @class
	end
--

-- Output
select code, seq_code, type, seq_type, value from #goutput order by seq_code, code, seq_type, type, value

return 0
;
