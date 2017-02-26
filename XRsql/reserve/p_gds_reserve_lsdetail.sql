if exists(select * from sysobjects where name = "p_gds_reserve_lsamt")
   drop proc p_gds_reserve_lsamt
;
create  proc p_gds_reserve_lsamt
	@rmode		char(3),
	@rate			money,
	@arr			datetime,
	@dep			datetime,
	@retmode		char(1) = 'S',
	@amount		money  output 
as
--------------------------------------------
-- 计算长包房总价格
--------------------------------------------
declare	@i				money,
			@k				money

select @arr = convert(datetime,convert(char(8),@arr,1))
select @dep = convert(datetime,convert(char(8),@dep,1))
select @amount = 0

-- mode sequence 
select @i=convert(money,sequence) from basecode where code=@rmode and cat='timeterm'
if @@rowcount=0 goto gout

-- 日期判断
if @arr is null or @dep is null or @arr>=@dep  goto gout 

-- 总天数
select @k = convert(money, datediff(dd,@arr,@dep))
-- 获取总价格
select @amount = round(@rate*@k/@i, 2)

gout:
if @retmode='S'
	select @amount
return 0;



if exists(select * from sysobjects where name = "p_gds_reserve_lsdetail")
   drop proc p_gds_reserve_lsdetail
;
create  proc p_gds_reserve_lsdetail
   @accnt		char(10),
	@rmode		char(3),
	@rate			money,
	@arr			datetime,
	@dep			datetime,
	@amount		money,
	@pmode		char(3),
	@retmode		char(10)=''   -- 1=自动插入所有日期
as
--------------------------------------------
-- 产生长包房明细纪录
--------------------------------------------
declare	@i				money,
			@j				money,
			@k				money,
			@reb			char(1),		-- 重新创建
			@plen			int,			-- 入账间隔
			@punit		char(3),		-- 入账间隔单位 - D,W,M,Y 
			@prate		money,		-- 入账价格
			@pdate		datetime,	-- 入账日期
			@ttl			money,		-- 累计入账金额
			@bdate		datetime

if @retmode is null select @retmode=''
select @bdate=bdate1 from sysdata
select @arr = convert(datetime,convert(char(8),@arr,1))
select @dep = convert(datetime,convert(char(8),@dep,1))

create table #gout (
	date		datetime		null,
	rate		money			null
)

if rtrim(@accnt) is null select @accnt='' 
select @reb=substring(@retmode,2,1)
select @retmode=substring(@retmode,1,1)
if @reb<>'1' and exists(select 1 from ls_detail where accnt=@accnt)
begin
	insert #gout (date, rate) select date, rate from ls_detail where accnt=@accnt
	while @arr<=@dep and @retmode='1'
	begin
		if not exists(select 1 from ls_detail where accnt=@accnt and date=@arr)
			insert #gout values(@arr, 0)
		select @arr=dateadd(dd,1,@arr)
	end 
	goto gout 
end
else
begin
	if @rmode=''  -- 表示直接取 ls_master 的数据
	begin
		select @rmode=rmode,@rate=rate,@arr=arr,@dep=dep,@amount=amount,@pmode=pmode from ls_master where accnt=@accnt
		if @@rowcount=0 goto gout
	end
end

-- mode sequence 
select @i=convert(money,sequence) from basecode where code=@rmode and cat='timeterm'
if @@rowcount=0  goto gout
select @j=convert(money,sequence), @punit=substring(grp,1,3) from basecode where code=@pmode and cat='timeterm'
if @@rowcount=0  goto gout
-- if @j>@i goto gout 

--
if rtrim(@punit) is null goto gout
select @plen=convert(int,substring(@punit,1,2))
if @plen is null or @plen<=0 goto gout
select @punit = substring(@punit,3,1)

-- 日期判断
if @arr is null or @dep is null or @arr>=@dep  goto gout 
if datediff(year,@arr,@dep)>5 select @dep=dateadd(year,5,@arr)

--
if @rate<=0 goto gout

-- 总天数
select @k = convert(money, datediff(dd,@arr,@dep))
-- 获取总价格
if @amount = 0
	exec p_gds_reserve_lsamt @rmode,@rate,@arr,@dep,'R',@amount out

-- post rate
select @prate=round(@amount/(@k/@j), 2)

--
select @ttl=0
if @arr>=@bdate 
	select @pdate=@arr
else
	select @pdate=@bdate 

while @arr<=@dep 
begin
	if @arr<@bdate 
	begin
		select @i=isnull((select rate from ls_detail where accnt=@accnt and date=@arr), 0)
		if @i <> 0
			insert #gout select @arr, @i
		else if @retmode='1'
			insert #gout select @arr, 0
		select @ttl=@ttl+@i
	end
	else
	begin
		if @ttl+@prate>=@amount or @arr>=@dep 
		begin
			select @prate=@amount-@ttl
			insert #gout(date, rate) values(@arr, @prate)
			goto gout
		end
		else
		begin
			if @pdate=@arr
			begin
				insert #gout(date, rate) values(@arr, @prate)
				select @ttl=@ttl+@prate
				if @punit='D'
					select @pdate=dateadd(dd,@plen,@arr)
				else if @punit='W'
					select @pdate=dateadd(week,@plen,@arr)
				else if @punit='Q'
					select @pdate=dateadd(quarter,@plen,@arr)
				else if @punit='M'
					select @pdate=dateadd(mm,@plen,@arr)
				else if @punit='Y'
					select @pdate=dateadd(year,@plen,@arr)
				else
					select @pdate=dateadd(dd,@plen,@arr)
			end
			else
			begin
				if @retmode='1'
					insert #gout(date, rate) values(@arr, 0)
			end
		end
	end 

	select @arr=dateadd(dd,1,@arr)
end



gout:
select date, rate, bdate=@bdate from #gout order by date
return 0;
