if exists(select * from sysobjects where name = "p_gds_sc_rsvblk_cal")
   drop proc p_gds_sc_rsvblk_cal;
create proc p_gds_sc_rsvblk_cal
   @grpaccnt 	char(10),
	@till			char(1)='F',  -- 是否统计 rsvsrc_till, 夜审过程调用  
	@retmode		char(1)='S',
	@rmnum		int	output,
	@gstno		int	output,
	@rate			money	output
as
--------------------------------------------------------
-- sc 计算团体占房信息等 
--------------------------------------------------------
declare	@foact		char(10),
			@sta			char(1),
			@msta			char(1),
			@arr			datetime,
			@dep			datetime

select  @rmnum=0, @rate=0, @gstno=0
if @till = 'T'
	select @sta=sta, @foact=foact, @rmnum=rmnum, @rate=setrate, @gstno=gstno from sc_master_till where accnt=@grpaccnt
else
	select @sta=sta, @foact=foact, @rmnum=rmnum, @rate=setrate, @gstno=gstno from sc_master where accnt=@grpaccnt
if @@rowcount = 0 or charindex(@sta, 'RI') = 0
begin
	if @retmode = 'S'
		select @rmnum, @gstno, @rate
	return 
end

-- rate -- 获取较小的价格, 非0 
if @foact = '' 
begin
	if @till = 'T'
		select @rate = isnull((select min(rate) from rsvsrc_till where accnt=@grpaccnt and rate<>0 and id>0), 0)
	else
		select @rate = isnull((select min(rate) from rsvsrc where accnt=@grpaccnt and rate<>0 and id>0), 0)
end
else
begin
	if @till = 'T'
	begin
		select @rate = isnull((select min(rate) from rsvsrc_till where accnt=@foact and rate<>0 and id>0), 0)
		if exists(select 1 from master_till where groupno=@foact and charindex(@sta, 'RI')=0 and setrate<>0 and setrate<@rate)
			select @rate = isnull((select min(setrate) from master_till where groupno=@foact and charindex(sta, 'RI')=0 and setrate<>0 and setrate<@rate), 0)
	end
	else
	begin
		select @rate = isnull((select min(rate) from rsvsrc where accnt=@foact and rate<>0 and id>0), 0)
		if exists(select 1 from master where groupno=@foact and charindex(@sta, 'RI')=0 and setrate<>0 and setrate<@rate)
			select @rate = isnull((select min(setrate) from master where groupno=@foact and charindex(sta, 'RI')=0 and setrate<>0 and setrate<@rate), 0)
	end
end

-- rmnum -- 获得较大房数 
create table #rsv (begin_  datetime null, rmnum  int  default 0 null, gstno  int  default 0 null)
if @foact = ''
begin
	if @till = 'T'
		insert #rsv select begin_, sum(quantity), sum(quantity*gstno) from rsvsrc_till where accnt=@grpaccnt and id>0 group by begin_
	else
		insert #rsv select begin_, sum(quantity), sum(quantity*gstno) from rsvsrc where accnt=@grpaccnt and id>0 group by begin_
end
else
begin
	if @till = 'T'
		select @msta = sta, @rmnum=rmnum, @rate=setrate, @gstno=gstno, @arr=arr, @dep=dep from master_till where accnt=@foact 
	else
		select @msta = sta, @rmnum=rmnum, @rate=setrate, @gstno=gstno, @arr=arr, @dep=dep from master where accnt=@foact 
	if @@rowcount>0 and @msta = 'R' 
	begin
		select @arr = convert(datetime,convert(char(8),@arr,1))
		select @dep = convert(datetime,convert(char(8),@dep,1))
		while @arr < @dep
		begin
			insert #rsv select @arr, 0, 0 
			if @till = 'T'
			begin
				update #rsv set rmnum = rmnum + isnull((select sum(c.quantity) from rsvsrc_till c where c.accnt=@foact and c.id>0 and c.begin_<=@arr and c.end_>@arr ), 0) 
						+ isnull((select sum(a.quantity) from rsvsrc_till a, master_till b where a.accnt=b.accnt and b.groupno=@foact and b.class='F' and a.begin_<=@arr and a.end_>@arr ), 0) 
					where begin_ = @arr
				update #rsv set gstno = gstno + isnull((select sum(c.quantity*c.gstno) from rsvsrc_till c where c.accnt=@foact and c.id>0 and c.begin_<=@arr and c.end_>@arr ), 0) 
						+ isnull((select sum(a.quantity*a.gstno) from rsvsrc_till a, master_till b where a.accnt=b.accnt and b.groupno=@foact and b.class='F' and a.begin_<=@arr and a.end_>@arr ), 0) 
					where begin_ = @arr
			end
			else
			begin
				update #rsv set rmnum = rmnum + isnull((select sum(c.quantity) from rsvsrc c where c.accnt=@foact and c.id>0 and c.begin_<=@arr and c.end_>@arr ), 0) 
						+ isnull((select sum(a.quantity) from rsvsrc a, master b where a.accnt=b.accnt and b.groupno=@foact and b.class='F' and a.begin_<=@arr and a.end_>@arr ), 0) 
					where begin_ = @arr
				update #rsv set gstno = gstno + isnull((select sum(c.quantity*c.gstno) from rsvsrc c where c.accnt=@foact and c.id>0 and c.begin_<=@arr and c.end_>@arr ), 0) 
						+ isnull((select sum(a.quantity*a.gstno) from rsvsrc a, master b where a.accnt=b.accnt and b.groupno=@foact and b.class='F' and a.begin_<=@arr and a.end_>@arr ), 0) 
					where begin_ = @arr
			end

			select @arr = dateadd(dd, 1, @arr)
		end
	end
end
select @rmnum = isnull((select max(rmnum) from #rsv), 0)
select @gstno = isnull((select max(gstno) from #rsv), 0)

-- output 
if @retmode = 'S'
	select @rmnum, @gstno, @rate

return
;