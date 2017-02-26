

if exists (select * from sysobjects where name ='p_aaa_mktrep_reb' and type ='P')
	drop proc p_aaa_mktrep_reb;
create proc p_aaa_mktrep_reb
	@date		datetime
as
---------------------------------------------
-- 西湖大酒店重建 来源码的 分析报表数据
---------------------------------------------
declare 
	@market			char(3), 
	@src				char(3), 
	@channel			char(3), 
	@tag				char(3), 
	@charge			money, 
	@quantity		money, 
	@mode				char(10), 
	@pccode			char(5), 
	@isone			money, 
	@accnt			char(10), 
	@accntof			char(10), 
	@tofrom			char(2),
	@gstno			integer,
	@nights_option	char(20)	 --  房晚计算选项：JjBbNPDd。对应account.mode的第一位，有则计算，没有则不算；Dd对应Day Use。
									-- parms --> sysoption / audit / addrm_night / ???  def=JjDd

-- 
delete mktsummaryrep

--
select @nights_option = value from sysoption where catalog='audit' and item='addrm_night'
if @@rowcount = 0 or @nights_option is null
	select @nights_option = 'JjBbNPDd'

-- 
//insert mktsummaryrep (date, class, grp, code)   -- market
//	select @date, 'M', grp, code from mktcode

insert mktsummaryrep (date, class, grp, code)   -- source
	select @date, 'S', grp, code from srccode
insert mktsummaryrep (date, class, grp, code)   -- channel
	select @date, 'C', '', code from basecode where cat = 'channel'

--
create table #roomno (roomno  char(10)  not null)
select * into #account from account where 1 = 2
insert #account 
	select * from account where bdate = @date 
	union all select * from haccount where bdate = @date 

--  计算收入
declare c_gltemp cursor for
	select a.accnt, a.accntof, a.tofrom, a.tag, a.charge, a.quantity, a.mode, a.pccode
	from  #account a
	where a.pccode < '9' and (a.crradjt in ('AD', '') or (a.crradjt in ('LT', 'LA') and a.tofrom= ''))
open  c_gltemp
fetch c_gltemp into @accnt, @accntof, @tofrom, @market, @charge, @quantity, @mode, @pccode
while @@sqlstatus = 0
	begin 
	select @src=isnull(rtrim(src),''), @channel=isnull(rtrim(channel),'') from master_till where accnt=@accnt 
	if @@rowcount = 0
		select @src=isnull(rtrim(src),''), @channel=isnull(rtrim(channel),'') from hmaster where accnt=@accnt 

	-- total income 
//	update mktsummaryrep set tincome = tincome + @charge where class='M' and code = @market 
	update mktsummaryrep set tincome = tincome + @charge where class='S' and code = @src 
	update mktsummaryrep set tincome = tincome + @charge where class='C' and code = @channel

	if @pccode like '0%' 
		begin

		-- DayUse单独计算
//		if @rmposted = 'F' and @mode like 'N%'
//			select @mode = 'D' + substring(@mode, 2, 9)
//		else if @rmposted = 'F' and @mode like 'P%'
//			select @mode = 'd' + substring(@mode, 2, 9)

		-- 什么情况下计算房晚
		if charindex(substring(@mode, 1, 1), @nights_option) = 0
			select @quantity = 0

		-- room rate income 
//		update mktsummaryrep set rincome = rincome + @charge where class='M' and code = @market 
		update mktsummaryrep set rincome = rincome + @charge where class='S' and code = @src 
		update mktsummaryrep set rincome = rincome + @charge where class='C' and code = @channel

		-- 这里值得思考：是放入 @mode, 还是 substring(@mode,2,5) ?
		if substring(@mode,2,5) <> '' and @quantity != 0
			begin
			if not exists(select 1 from #roomno where roomno = @mode)
				insert #roomno select @mode
			else
				select @quantity = 0
			end
		else
			select @quantity = 0

//		update mktsummaryrep set rquan = rquan + @quantity where class='M' and code = @market 
		update mktsummaryrep set rquan = rquan + @quantity where class='S' and code = @src
		update mktsummaryrep set rquan = rquan + @quantity where class='C' and code = @channel

		end 
	fetch c_gltemp into @accnt, @accntof, @tofrom, @market, @charge, @quantity, @mode, @pccode
	end
close c_gltemp
deallocate cursor c_gltemp

-- 
declare c_guest cursor for 
	select market, src, channel, gstno from master where class = 'F' and sta in ('I', 'S', 'O') and arr<=@date and dep>=@date
	union all 
	select market, src, channel, gstno from hmaster where class = 'F' and sta in ('I', 'S', 'O') and arr<=@date and dep>=@date
open  c_guest
fetch c_guest into @market, @src, @channel, @gstno
while @@sqlstatus = 0
	begin
//	update mktsummaryrep set pquan = pquan + @gstno where class='M' and code = @market 
	update mktsummaryrep set pquan = pquan + @gstno where class='S' and code = @src 
	update mktsummaryrep set pquan = pquan + @gstno where class='C' and code = @channel
	fetch c_guest into @market, @src, @channel, @gstno
	end
close c_guest
deallocate cursor c_guest

--
delete ymktsummaryrep where date = @date and class<>'M'
insert ymktsummaryrep 
	select * from mktsummaryrep 
		where class<>'M' and pquan <> 0 or rquan <> 0 or rincome <> 0 or tincome <> 0


return 0
;

