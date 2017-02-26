if exists(select 1 from sysobjects where name = "p_gds_reserve_occ_grf")
	drop proc p_gds_reserve_occ_grf;
create proc p_gds_reserve_occ_grf
	@date			datetime,
	@ten			char(1),
	@mode			char(1),  	-- 1=确定性 2=散客vs团体
	@seg			char(1),		-- 1=1w, 2=2w, 3=1m, 4=2m, 5=3m 
	@types		varchar(255)
as
-----------------------------------------------
--		occ grf
-----------------------------------------------
declare		@type			char(5),
				@bdate		datetime,
				@s_time		datetime,
				@e_time		datetime

select @bdate = bdate1 from sysdata
select @s_time=@date
if rtrim(@ten) is null or @ten<>'F'
	select @ten='%'  -- 所有
else
	select @ten='T'	-- 仅仅包含确定

-- 时间间隔
if @seg='1' 
	select @e_time=dateadd(dd,7,@s_time)
else if @seg='2' 
	select @e_time=dateadd(dd,14,@s_time)
else if @seg='3' 
	select @e_time=dateadd(mm,1,@s_time)
else if @seg='4' 
	select @e_time=dateadd(mm,2,@s_time)
else if @seg='5' 
	select @e_time=dateadd(mm,3,@s_time)
else
	select @e_time=dateadd(mm,1,@s_time)

-- 拼字符串
if rtrim(@types) is null or @types='%' 
begin
	select @types='_'
	select @type=isnull((select min(type) from typim where type>'' and tag='K'), '')
	while @type <> ''
	begin
		select @types = @types+substring(@type, 1, 5)+'_'
		select @type=isnull((select min(type) from typim where type>@type and tag='K'), '')
	end
end

create table #gout(
	date			datetime						not null,	
	item			varchar(30)	default ''	null,
	quan			int			default 0	null
)

while	@s_time < @e_time
begin
	if @mode = '1'  -- 对比 ‘确定’vs  ‘不确定’
	begin
		insert #gout
			select @s_time, c.definite, isnull(sum(a.quantity),0) from rsvsaccnt a, master b, restype c
				where charindex(a.type,@types)>0 and a.begin_<>a.end_ and a.begin_<=@s_time and a.end_>@s_time
					and a.accnt=b.accnt and b.restype=c.code and c.definite like @ten
			group by c.definite
	end
	else  -- 对比 ‘散客’vs  ‘团体’
	begin
		insert #gout
			select @s_time, 'FIT', isnull(sum(a.quantity),0) from rsvsaccnt a, master b, restype c
				where charindex(a.type,@types)>0 and a.begin_<>a.end_ and a.begin_<=@s_time and a.end_>@s_time
					and a.accnt=b.accnt and b.groupno='' and b.restype=c.code and c.definite like @ten
		insert #gout
			select @s_time, 'GRP', isnull(sum(a.quantity),0) from rsvsaccnt a, master b, restype c
				where charindex(a.type,@types)>0 and a.begin_<>a.end_ and a.begin_<=@s_time and a.end_>@s_time
					and a.accnt=b.accnt and b.groupno<>'' and b.restype=c.code and c.definite like @ten
	end

	select @s_time = dateadd(day, 1, @s_time)
end

----------------------------------------------------------------------------
-- output
----------------------------------------------------------------------------
-- 四位的年份, 以及星期
select date, cdate=convert(char(8),date,11)+'-'+convert(char(1),datepart(weekday, date)-1), item, quan  from #gout order by date, item 


return 0
;
