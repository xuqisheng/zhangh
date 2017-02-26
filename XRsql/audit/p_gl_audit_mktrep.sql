
if exists (select * from sysobjects where name ='p_gl_audit_mktrep' and type ='P')
	drop proc p_gl_audit_mktrep;
create proc p_gl_audit_mktrep
as
---------------------------------------------
-- 市场码、来源、渠道 分析报表统计
---------------------------------------------
declare 
	@bdate			datetime, 
	@bfdate			datetime, 
	@duringaudit	char(1), 
	@class			char(1), 
	@market			char(3), 
	@src				char(3), 
	@channel			char(3), 
	@ratecode		char(10),
	@tag				char(3), 
	@charge			money, 
	@charge_rm		money,
	@charge_fb		money, 
	@quantity		money, 
	@mode				char(10), 
	@pccode			char(5), 
	@pcaddbed		char(5),		-- 加床费用码
	@isone			money, 
	@accnt			char(10), 
	@accntof			char(10), 
	@tofrom			char(2),
	@gstno			integer,
	@rmposted		char(1),
	@rm_pccodes		varchar(255),
	@nights_option	char(20),	 --  房晚计算选项：JjBbNPDd。对应account.mode的第一位，有则计算，没有则不算；Dd对应Day Use。
										-- parms --> sysoption / audit / addrm_night / ???  def=JjDd
	@gst_calmode	char(1),		-- 人数统计的方法 - 0=人数 1=主单数
	@rsvc				money,		-- 房费 - 服务费
	@rpak				money			-- 房费 - 包价

declare	
	@sta				char(1),
	@rmnum			int,
	@mbdate			datetime,
	@rarr				int,
	@rdep				int,
	@parr				int,
	@pdep				int,
	@noshow			int,
	@cxl				int,
	@master			char(10),
	@day_use_in		char(1),
	@restype       char(3),
	@roomno			char(5),
	@tmp_quantity	money,
	@tmp_quantity2	money,
	@saccnt			char(10),
	@arr				datetime,
	@dep				datetime,
	@ref2				char(50),
	@package			char(8)

-- 
select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate)

delete mktsummaryrep
delete mktsummaryrep_detail

--
select @nights_option = value from sysoption where catalog='audit' and item='addrm_night'
if @@rowcount = 0 or @nights_option is null
	select @nights_option = 'JjBbNPDd'
select @rm_pccodes = value from sysoption where catalog='audit' and item='room_charge_pccodes'
if @@rowcount = 0 or @rm_pccodes is null
	select @rm_pccodes = '1000 ,1001 ,1002 ,1003 ,1004 ,1005 ,1006 ,'
select @gst_calmode = value from sysoption where catalog='audit' and item='gst_calmode'
if @@rowcount = 0 or @gst_calmode is null or charindex(@gst_calmode,'01')=0 
	select @gst_calmode = '0'

select @pcaddbed = value from sysoption where catalog='audit' and item='room_charge_pccode_extra'
if @@rowcount = 0 or @pcaddbed is null
	select @pcaddbed = '1040'

select @day_use_in = value from sysoption where catalog='reserve' and item='day_use_in'
if @@rowcount = 0 or @day_use_in is null or charindex(@day_use_in,'TF')=0 
	select @day_use_in = 'F'
-- 
insert mktsummaryrep (date, class, grp, code)   -- market
	select @bfdate, 'M', grp, code from mktcode
insert mktsummaryrep (date, class, grp, code)   -- source
	select @bfdate, 'S', grp, code from srccode
insert mktsummaryrep (date, class, grp, code)   -- channel
	select @bfdate, 'C', '', code from basecode where cat = 'channel'
insert mktsummaryrep (date, class, grp, code)   -- ratecode
	select @bfdate, 'R', cat, code from rmratecode
insert mktsummaryrep (date, class, grp, code)   -- restype
	select @bfdate, 'L', '', code from restype

--
create table #roomno (roomno  char(10)  not null,
							 accnt   char(10)  not null,
							 arr		datetime   null,
							 dep		datetime	  null,
							 rm		money		 not null)

--  计算收入
declare c_gltemp cursor for
	select a.accnt, a.accntof, a.tofrom, a.tag, a.charge, a.quantity, a.mode, a.pccode, b.class, b.rmposted, a.charge3, a.package_a ,b.master,a.ref2
	from  gltemp a, master_till b
	where a.accnt = b.accnt and a.pccode < '9' and (a.crradjt in ('AD', '') or (a.crradjt in ('LT', 'LA') and a.tofrom= ''))
union all
select a.accnt, a.accntof, a.tofrom, a.tag, a.charge, a.quantity, a.mode, a.pccode, b.class, b.rmposted, a.charge3, a.package_a ,b.master,a.ref2
	from  gltemp a, ar_master b
	where a.accnt = b.accnt and a.pccode < '9' and (a.crradjt in ('AD', '') or (a.crradjt in ('LT', 'LA') and a.tofrom= ''))
order by a.pccode,a.accnt
open  c_gltemp
fetch c_gltemp into @accnt, @accntof, @tofrom, @market, @charge, @quantity, @mode, @pccode, @class, @rmposted, @rsvc, @rpak ,@master,@ref2
while @@sqlstatus = 0
	begin 
	--select @mkt_flg = flag from mktcode where code = @market
	if rtrim(@accntof)<>null
		select @accnt = @accntof

	select @src=isnull(rtrim(src),''), @channel=isnull(rtrim(channel),''), @ratecode=isnull(rtrim(ratecode),'') ,@restype=isnull(rtrim(restype),'')
				,@saccnt = saccnt,@arr = arr,@dep = dep,@market = market
		from master_till where accnt=@accnt 

	if not exists(select 1 from mktsummaryrep_detail where accnt = @accnt)
		insert mktsummaryrep_detail(date, accnt) values(@bdate, @accnt)


	-- 什么情况下计算房晚
	if charindex(substring(@mode, 1, 1), rtrim(@nights_option) ) = 0
		select @quantity = 0

	--if charindex(rtrim(@pccode), @rm_pccodes) = 0
	--	select @charge = 0
    select @charge_fb=0
    if exists(select 1 from pccode where pccode=@pccode and deptno7='fb')
        select @charge_fb=@charge

	select @charge_rm = 0
	if charindex(rtrim(@pccode), @rm_pccodes) > 0
		begin
		-- room rate income 
		select @charge_rm = @charge
		-- DayUse单独计算
		if @rmposted = 'F' and @mode like 'N%'
			select @mode = 'D' + substring(@mode, 2, 9)
		else if @rmposted = 'F' and @mode like 'P%'
			select @mode = 'd' + substring(@mode, 2, 9)


		-- 这里值得思考：是放入 @mode, 还是 substring(@mode,2,5) ?
		if @day_use_in='F'
			begin
			if substring(@mode,2,5) <> '' and @quantity !=  0 and @pccode<>@pcaddbed and @class<>'C' 
				begin
				if not exists(select 1 from #roomno where roomno = substring(@mode,2,5))
					insert #roomno select substring(@mode,2,5),'',null,null,0
				else
					select @quantity = 0
				end
			else if @pccode <> @pcaddbed
				select @quantity = 0
			end
		else
			begin
			if substring(@mode,2,5) <> '' and @quantity !=  0 and @pccode<>@pcaddbed
				begin
				if not exists(select 1 from #roomno where roomno = substring(@mode,2,5))
					begin
					--该房号首次出现
					insert #roomno select substring(@mode,2,5),@accnt,@arr,@dep,@quantity
					end
				else if  not exists(select 1 from #roomno where roomno = substring(@mode,2,5) and ((@arr >= arr and @arr < dep) or (@dep > arr and @dep <= dep) or (@arr <= arr and @dep >= dep)))
					begin
					--该房号已出现,时间段尚无重叠
					insert #roomno select substring(@mode,2,5),@accnt,@arr,@dep,@quantity
					end
				else 
					begin
					--该房号已出现,时间段重叠情况也已出现
					if  not exists(select 1 from #roomno where roomno = substring(@mode,2,5) and accnt = @accnt)
					--该房号中@accnt首次出现
					insert #roomno select substring(@mode,2,5),@accnt,@arr,@dep,@quantity
					else
					--该房号中@accnt再次出现
					update #roomno set rm = @quantity + rm where roomno = substring(@mode,2,5) and accnt = @accnt
					declare @tmp_quantity_hry1 money,@tmp_quantity_hry2 money
					select @tmp_quantity_hry1  = isnull(max(rm),0) from #roomno where roomno = substring(@mode,2,5) and ((@arr >= arr and @arr < dep) or (@dep > arr and @dep <= dep) or (@arr <= arr and @dep >= dep)) and accnt <> @accnt
					select @tmp_quantity_hry2  = rm - @quantity from #roomno where roomno = substring(@mode,2,5) and accnt = @accnt
					if @tmp_quantity_hry2 < @tmp_quantity_hry1
						begin
						select @quantity = @tmp_quantity_hry2  - @tmp_quantity_hry1 + @quantity
						if @quantity < 0
							 select @quantity = 0
						end
					end
				end
			else
				select @quantity = 0
			end
		end 
	else
		select @quantity = 0, @rsvc=0, @rpak=0

	if @mode = ' pkg_c   A'
		begin
		select @package = substring(@ref2,charindex('{',@ref2) + 1,charindex('>}',@ref2) - charindex('{',@ref2) - 1)
		if exists (select 1 from package where code = @package and substring(rule_calc,1,1) = '1')
			begin
--insert gdsmsg select convert(char,@charge)+','+@package+','+@pccode
			select @charge_rm = 0
			end
		end
    select @charge = @charge+@rpak
	-- update
	update mktsummaryrep set tincome = tincome + @charge, rincome = rincome + @charge_rm, rquan = rquan + @quantity, rsvc=rsvc+@rsvc, rpak=rpak+@rpak,fincome=fincome+@charge_fb where class='M' and code = @market 
	update mktsummaryrep set tincome = tincome + @charge, rincome = rincome + @charge_rm, rquan = rquan + @quantity, rsvc=rsvc+@rsvc, rpak=rpak+@rpak,fincome=fincome+@charge_fb where class='S' and code = @src 
	update mktsummaryrep set tincome = tincome + @charge, rincome = rincome + @charge_rm, rquan = rquan + @quantity, rsvc=rsvc+@rsvc, rpak=rpak+@rpak,fincome=fincome+@charge_fb where class='C' and code = @channel
	update mktsummaryrep set tincome = tincome + @charge, rincome = rincome + @charge_rm, rquan = rquan + @quantity, rsvc=rsvc+@rsvc, rpak=rpak+@rpak,fincome=fincome+@charge_fb where class='R' and code = @ratecode
	update mktsummaryrep set tincome = tincome + @charge, rincome = rincome + @charge_rm, rquan = rquan + @quantity, rsvc=rsvc+@rsvc, rpak=rpak+@rpak,fincome=fincome+@charge_fb where class='L' and code = @restype
	
	update mktsummaryrep_detail set tincome = tincome + @charge, rincome = rincome + @charge_rm, rquan = rquan + @quantity, rsvc=rsvc+@rsvc, rpak=rpak+@rpak,fincome=fincome+@charge_fb where accnt = @accnt

	fetch c_gltemp into @accnt, @accntof, @tofrom, @market, @charge, @quantity, @mode, @pccode, @class, @rmposted, @rsvc, @rpak ,@master,@ref2
	end
close c_gltemp
deallocate cursor c_gltemp

-- 
declare c_guest cursor for select accnt, market, src, channel, gstno, ratecode, sta, bdate, rmnum ,restype
	from master_till where class = 'F'
open  c_guest
fetch c_guest into @accnt, @market, @src, @channel, @gstno, @ratecode, @sta, @mbdate, @rmnum ,@restype
while @@sqlstatus = 0
	begin
	select @rarr=0, @rdep=0, @parr=0, @pdep=0, @noshow=0, @cxl=0
	if @mbdate=@bdate 
	begin
		if @sta='N' select @noshow=@rmnum
		if @sta='X' select @cxl=@rmnum
		if @sta='O'
		begin
			select @rdep = @rmnum
			if @gst_calmode <> '0'
				select @pdep = 1
			else
				select @pdep = @gstno
		end
		if @sta='I' or (not exists(select 1 from master_last where accnt=@accnt) and @sta='O')
		begin
			select @rarr = @rmnum
			if @gst_calmode <> '0'
				select @parr = 1
			else
				select @parr = @gstno
		end
	end
	if @sta <> 'I'
		select @gstno = 0
	else if @gst_calmode <> '0'
		select @gstno = 1

	if @gstno=0 and @rarr=0 and @rdep=0 and @parr=0 and @pdep=0 and @noshow=0 and @cxl=0
	begin
		fetch c_guest into @accnt, @market, @src, @channel, @gstno, @ratecode, @sta, @mbdate, @rmnum,@restype
		continue 
	end

	if not exists(select 1 from mktsummaryrep_detail where accnt = @accnt)
		insert mktsummaryrep_detail(date, accnt) values(@bdate, @accnt)

	if not exists(select 1 from mktcode where code=@market)
		select @market = min(code) from mktcode
	if not exists(select 1 from srccode where code=@src)
		select @src = min(code) from srccode
	if not exists(select 1 from basecode where cat='channel' and code=@channel)
		select @channel = min(code) from basecode where cat='channel'
	if not exists(select 1 from rmratecode where code=@ratecode)
		select @ratecode = min(code) from rmratecode
	if not exists(select 1 from restype where code=@restype)
		select @restype = min(code) from restype

	update mktsummaryrep set pquan = pquan + @gstno, rarr=rarr+@rarr, rdep=rdep+@rdep, parr=parr+@parr, pdep=pdep+@pdep, noshow=noshow+@noshow, cxl=cxl+@cxl where class='M' and code = @market 
	update mktsummaryrep set pquan = pquan + @gstno, rarr=rarr+@rarr, rdep=rdep+@rdep, parr=parr+@parr, pdep=pdep+@pdep, noshow=noshow+@noshow, cxl=cxl+@cxl where class='S' and code = @src 
	update mktsummaryrep set pquan = pquan + @gstno, rarr=rarr+@rarr, rdep=rdep+@rdep, parr=parr+@parr, pdep=pdep+@pdep, noshow=noshow+@noshow, cxl=cxl+@cxl where class='C' and code = @channel
	update mktsummaryrep set pquan = pquan + @gstno, rarr=rarr+@rarr, rdep=rdep+@rdep, parr=parr+@parr, pdep=pdep+@pdep, noshow=noshow+@noshow, cxl=cxl+@cxl where class='R' and code = @ratecode
	update mktsummaryrep set pquan = pquan + @gstno, rarr=rarr+@rarr, rdep=rdep+@rdep, parr=parr+@parr, pdep=pdep+@pdep, noshow=noshow+@noshow, cxl=cxl+@cxl where class='L' and code = @restype

	update mktsummaryrep_detail set pquan = pquan + @gstno, rarr=rarr+@rarr, rdep=rdep+@rdep, parr=parr+@parr, pdep=pdep+@pdep, noshow=noshow+@noshow, cxl=cxl+@cxl where accnt=@accnt

	fetch c_guest into @accnt, @market, @src, @channel, @gstno, @ratecode, @sta, @mbdate, @rmnum ,@restype
	end
close c_guest
deallocate cursor c_guest

-- update mktsummaryrep_detail info
update mktsummaryrep_detail set haccnt=a.haccnt,sta=a.sta,roomno=a.roomno,rate=a.setrate,arr=a.arr,dep=a.dep,
		market=a.market,src=a.src,channel=a.channel,ratecode=a.ratecode,restype=a.restype,
		cusno=a.cusno, agent=a.agent, source=a.source 
	from master_till a where mktsummaryrep_detail.accnt=a.accnt
update mktsummaryrep_detail set name=a.name from guest a where mktsummaryrep_detail.haccnt=a.no

-- Backup
update mktsummaryrep set date = @bdate
update mktsummaryrep_detail set date = @bdate

delete ymktsummaryrep where date = @bdate
insert ymktsummaryrep select * from mktsummaryrep where pquan <> 0 or rquan <> 0 or rincome <> 0 or tincome <> 0

delete ymktsummaryrep_detail where date = @bdate
insert ymktsummaryrep_detail select * from mktsummaryrep_detail where pquan <> 0 or rquan <> 0 or rincome <> 0 or tincome <> 0

--
exec p_gl_statistic_saveas 'pcid', @bdate, 'mktsummaryrep'

return 0
;


-- 来源分析报表打印临时表
if exists (select * from sysobjects where name ='pmktsummaryrep' and type ='U')
   drop table pmktsummaryrep;
create table  pmktsummaryrep
(
    pc_id     char(4)       NULL,
    grp       char(10)       NOT NULL,
    grp_des   char(60)      NULL,
    grp_seq   int           NULL,
    code      char(10)       NULL,
    code_des  char(60)      NULL,
    code_seq  int           NULL,
    pquan     int           DEFAULT 0 	 NOT NULL,
    rquan     numeric(10,1) DEFAULT 0 NOT NULL,
    rincome   money         DEFAULT 0 NOT NULL,
    rsvc  	 money         DEFAULT 0 NOT NULL,
    rpak   	money         DEFAULT 0 NOT NULL,
    tincome   money         DEFAULT 0 NOT NULL,
    m_pquan   int           DEFAULT 0 	 NOT NULL,
    m_rquan   numeric(10,1) DEFAULT 0 NOT NULL,
    m_rincome money         DEFAULT 0 NOT NULL,
    m_rsvc  	 money         DEFAULT 0 NOT NULL,
    m_rpak   	money         DEFAULT 0 NOT NULL,
    m_tincome money         DEFAULT 0 NOT NULL
)
create index index1 on pmktsummaryrep(pc_id,grp,code)
;


-- 来源分析报表打印准备 
drop proc p_hry_audit_pmktrep;
create proc p_hry_audit_pmktrep
	@pc_id		char(4),
	@pmark		char(2),		-- 'D', 某日, 'W' 某日周累计, 'M', 某日月累计 ,'Y' 年,'S' ,区间
	@class		char(1),    -- M=market, S=src, C=channel , R=ratecode ,L=restype
	@pfalg 		char(1),
	@beg_			datetime,	-- 日期
	@end_			datetime,	-- 预留出区间报表
	@langid		int=0
as

declare
	@monthbeg	datetime,
	@isfstday	char(1),
	@isyfstday	char(1)

select @monthbeg = @beg_, @isfstday = 'F'
delete pmktsummaryrep where pc_id = @pc_id

-- 计算时间段
if @pmark = 'D'
	select @monthbeg = @beg_
else
	begin
	if @pmark = 'W'
		begin
		while datepart(dw, @monthbeg) <> 2
			select @monthbeg=dateadd(dd, -1, @monthbeg)
		end
	else if @pmark = 'M'
		begin
		exec p_hry_audit_fstday @monthbeg, @isfstday out, @isyfstday out
		while @isfstday = 'F'
			begin
			select @monthbeg = dateadd(dd, -1, @monthbeg)
			exec p_hry_audit_fstday @monthbeg, @isfstday out, @isyfstday out
			end
		end
	else if @pmark = 'Y'
		begin
		select @monthbeg=convert(char(4),@beg_,111)+'-01-01'
		end
	else if @pmark = 'S'
		begin
		select @monthbeg=@beg_
		select @beg_=@end_
		end
	end

-- 收集数据
insert pmktsummaryrep(pc_id,grp,code,pquan,rquan,rincome,tincome,rsvc,rpak)
	select @pc_id, grp, code, sum(pquan), sum(rquan), sum(rincome), sum(tincome), sum(rsvc), sum(rpak)
	from  ymktsummaryrep
	where class=@class and date >= @monthbeg and date <= @beg_
	group by class, grp, code

-- 补齐
if @class = 'M'
begin
	update pmktsummaryrep set grp=a.grp from mktcode a
		where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.code=a.code
	insert pmktsummaryrep(pc_id,grp,code,pquan,rquan,rincome,tincome)
		select @pc_id, grp, code, 0, 0, 0, 0
		from  mktcode where code not in (select code from pmktsummaryrep where pc_id=@pc_id)
end
else if @class = 'S'
begin
	update pmktsummaryrep set grp=a.grp from srccode a
		where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.code=a.code
	insert pmktsummaryrep(pc_id,grp,code,pquan,rquan,rincome,tincome)
		select @pc_id, grp, code, 0, 0, 0, 0
		from  srccode where code not in (select code from pmktsummaryrep  where pc_id=@pc_id)
end
else if @class = 'C'
begin
	update pmktsummaryrep set grp=a.grp from basecode a
		where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.code=a.code and a.cat='channel'
	insert pmktsummaryrep(pc_id,grp,code,pquan,rquan,rincome,tincome)
		select @pc_id, grp, code, 0, 0, 0, 0
		from  basecode where cat='channel' and code not in (select code from pmktsummaryrep  where pc_id=@pc_id)
end
else if @class = 'R'
begin
	update pmktsummaryrep set grp=a.cat from rmratecode a
		where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.code=a.code
	insert pmktsummaryrep(pc_id,grp,code,pquan,rquan,rincome,tincome)
		select @pc_id, cat, code, 0, 0, 0, 0
		from  rmratecode where code not in (select code from pmktsummaryrep  where pc_id=@pc_id)
end
else if @class = 'L'
begin
	update pmktsummaryrep set grp='' from restype a
		where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.code=a.code 
	insert pmktsummaryrep(pc_id,grp,code,pquan,rquan,rincome,tincome)
		select @pc_id, '', code, 0, 0, 0, 0
		from  restype where code not in (select code from pmktsummaryrep  where pc_id=@pc_id)
end
else
begin
	update pmktsummaryrep set grp=a.cat from rmratecode a
		where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.code=a.code
--	insert pmktsummaryrep(pc_id,grp,code,pquan,rquan,rincome,tincome)
--		select @pc_id, grp, code, 0, 0, 0, 0
--		from  rmratecode where code not in (select code from pmktsummaryrep  where pc_id=@pc_id)
end

update pmktsummaryrep set grp='-' where rtrim(grp) is null and pc_id=@pc_id

-- 合计
if @pfalg <> '1'
	update pmktsummaryrep set
			pquan   = isnull((select b.pquan   from ymktsummaryrep b where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.grp = b.grp and  pmktsummaryrep.code = b.code and b.date=@beg_),0) ,
			rquan   = isnull((select b.rquan   from ymktsummaryrep b where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.grp = b.grp and  pmktsummaryrep.code = b.code and b.date=@beg_),0) ,
			rincome = isnull((select b.rincome from ymktsummaryrep b where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.grp = b.grp and  pmktsummaryrep.code = b.code and b.date=@beg_),0) ,
			rsvc 	  = isnull((select b.rsvc    from ymktsummaryrep b where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.grp = b.grp and  pmktsummaryrep.code = b.code and b.date=@beg_),0) ,
			rpak 	  = isnull((select b.rpak    from ymktsummaryrep b where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.grp = b.grp and  pmktsummaryrep.code = b.code and b.date=@beg_),0) ,
			tincome = isnull((select b.tincome from ymktsummaryrep b where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.grp = b.grp and  pmktsummaryrep.code = b.code and b.date=@beg_),0)
		where pc_id = @pc_id

-- 翻译
if @langid = 0
begin
	if @class = 'M'
	begin
		update pmktsummaryrep set grp_des=a.descript, grp_seq=a.sequence from basecode a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.grp=a.code and a.cat='market_cat'
		update pmktsummaryrep set code_des=a.descript, code_seq=a.sequence from mktcode a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.code=a.code
	end
	else if @class = 'S'
	begin
		update pmktsummaryrep set grp_des=a.descript, grp_seq=a.sequence from basecode a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.grp=a.code and a.cat='src_cat'
		update pmktsummaryrep set code_des=a.descript, code_seq=a.sequence from srccode a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.code=a.code
	end
	else if @class = 'C'
	begin
		update pmktsummaryrep set grp_des=a.descript, grp_seq=a.sequence from basecode a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.grp=a.code and a.cat='channel_cat'
		update pmktsummaryrep set code_des=a.descript, code_seq=a.sequence from basecode a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.code=a.code and a.cat='channel'
	end
	else if @class = 'R'
	begin
		update pmktsummaryrep set grp_des=a.descript, grp_seq=a.sequence from basecode a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.grp=a.code and a.cat='rmratecat'
		update pmktsummaryrep set code_des=a.descript, code_seq=a.sequence from rmratecode a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.code=a.code
	end
	else if @class = 'L'
	begin
		update pmktsummaryrep set grp_des=a.descript, grp_seq=a.sequence from restype a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.grp=a.code 
		update pmktsummaryrep set code_des=a.descript, code_seq=a.sequence from restype a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.code=a.code 
	end
	else
	begin
		update pmktsummaryrep set grp_des=rtrim(a.code)+'-'+a.descript, grp_seq=a.sequence from basecode a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.grp=a.code and a.cat='rmratecat'
		update pmktsummaryrep set code_des=rtrim(a.code)+'-'+a.descript, code_seq=a.sequence from rmratecode a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.code=a.code
	end
end
else
begin
	if @class = 'M'
	begin
		update pmktsummaryrep set grp_des=a.descript1, grp_seq=a.sequence from basecode a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.grp=a.code and a.cat='market_cat'
		update pmktsummaryrep set code_des=a.descript1, code_seq=a.sequence from mktcode a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.code=a.code
	end
	else if @class = 'S'
	begin
		update pmktsummaryrep set grp_des=a.descript1, grp_seq=a.sequence from basecode a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.grp=a.code and a.cat='src_cat'
		update pmktsummaryrep set code_des=a.descript1, code_seq=a.sequence from srccode a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.code=a.code
	end
	else if @class = 'C'
	begin
		update pmktsummaryrep set grp_des=a.descript1, grp_seq=a.sequence from basecode a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.grp=a.code and a.cat='channel_cat'
		update pmktsummaryrep set code_des=a.descript1, code_seq=a.sequence from basecode a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.code=a.code and a.cat='channel'
	end
	else if @class = 'R'
	begin
		update pmktsummaryrep set grp_des=a.descript1, grp_seq=a.sequence from basecode a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.grp=a.code and a.cat='rmratecat'
		update pmktsummaryrep set code_des=a.descript1, code_seq=a.sequence from rmratecode a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.code=a.code
	end
	else if @class = 'L'
	begin
		update pmktsummaryrep set grp_des=a.descript1, grp_seq=a.sequence from restype a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.grp=a.code 
		update pmktsummaryrep set code_des=a.descript1, code_seq=a.sequence from restype a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.code=a.code 
	end
	else
	begin
		update pmktsummaryrep set grp_des=rtrim(a.code)+'-'+a.descript1, grp_seq=a.sequence from basecode a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.grp=a.code and a.cat='rmratecat'
		update pmktsummaryrep set code_des=rtrim(a.code)+'-'+a.descript1, code_seq=a.sequence from rmratecode a
			where pmktsummaryrep.pc_id=@pc_id and pmktsummaryrep.code=a.code
	end
end

return 0

;

