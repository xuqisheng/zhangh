IF OBJECT_ID('p_zk_audit_rmuserate') IS NOT NULL
    DROP PROCEDURE p_zk_audit_rmuserate
;
create proc p_zk_audit_rmuserate
as
---------------------------------------------
-- 客房出租率报表
---------------------------------------------
declare
	@bdate			datetime,
	@bfdate			datetime,
	@duringaudit	char(1),
	@class			char(5),
	@market			char(3),
	@src				char(3),
	@channel			char(3),
	@ratecode		char(10),
	@tag				char(3),
	@charge			money,
	@charge_rm		money,
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
	@rmnum			money,
	@mbdate			datetime,
	@rarr				money,
	@rdep				money,
	@parr				int,
	@pdep				int,
	@noshow			int,
	@cxl				int,
	@master			char(10),
	@day_use_in		char(1),
	@packages		varchar(50),
	@roomno			char(5),
	@mm				money,
	@pccodeallow	char(100),
	 @restype  char(3)      ,
    @nation   char(3)      ,
    @country  char(3)      ,
    @company  char(10)     ,
    @saleid   char(10)     ,
	@haccnt		char(10),
	@sno			char(15),
	@type			char(5),
	@tmp_quantity	money,
	@tmp_quantity2	money,
	@saccnt		char(10),
	@arr			datetime,
	@dep			datetime,
	@package		char(10),
	@ref2			char(50)

--

select @mm = 0,@gstno = 0,@sno = '',@type = ''
select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate)


--计算房费的pccode
select @pccodeallow = value from sysoption where catalog='audit' and item='room_charge_pccodes'
if @@rowcount = 0 or @pccodeallow is null
	select @pccodeallow = '1000 '
--计算房晚的代码
select @nights_option = value from sysoption where catalog='audit' and item='addrm_night'
if @@rowcount = 0 or @nights_option is null
	select @nights_option = 'JjBbNPDd'

select @gst_calmode = value from sysoption where catalog='audit' and item='gst_calmode'
if @@rowcount = 0 or @gst_calmode is null or charindex(@gst_calmode,'01')=0 
	select @gst_calmode = '0'

select @day_use_in = value from sysoption where catalog='reserve' and item='day_use_in'
if @@rowcount = 0 or @day_use_in is null or charindex(@day_use_in,'TF')=0 
	select @day_use_in = 'F'
--

delete from rmuserate where date = @bdate
--
create table #roomno (roomno  char(5)  not null,
							 accnt   char(10)  not null,
							 arr		datetime   null,
							 dep		datetime	  null,
							 rm		money		 not null)

-- 

declare c_gltemp cursor for
	select a.accnt, a.accntof, a.tofrom, a.tag, a.charge, a.quantity, a.mode, a.pccode, b.class, b.rmposted, a.charge3, a.package_a ,b.master,a.ref2,a.roomno
	from  gltemp a, master_till b
	where a.accnt = b.accnt and a.pccode < '9' and (a.crradjt in ('AD', '') or (a.crradjt in ('LT', 'LA') and a.tofrom= ''))
union all
select a.accnt, a.accntof, a.tofrom, a.tag, a.charge, a.quantity, a.mode, a.pccode, b.class, b.rmposted, a.charge3, a.package_a ,b.master,a.ref2,a.roomno
	from  gltemp a, ar_master b
	where a.accnt = b.accnt and a.pccode < '9' and (a.crradjt in ('AD', '') or (a.crradjt in ('LT', 'LA') and a.tofrom= ''))
	order by a.pccode,a.accnt
open  c_gltemp
fetch c_gltemp into @accnt, @accntof, @tofrom, @market, @charge, @quantity, @mode, @pccode, @class, @rmposted, @rsvc, @rpak ,@master,@ref2,@roomno
while @@sqlstatus = 0
	begin 
	if rtrim(@accntof) <> null
		select @accnt = @accntof
	if not exists (select 1 from mktcode where code = @market)
		select @market = market from master_till where accnt = (select min(master) from master_till where accnt = @accnt )
	select @src = src,@master = master,@packages = packages,@ratecode = ratecode,@restype = restype,@haccnt = haccnt,@saleid = saleid,
			@channel = channel,@saccnt = saccnt,@arr = arr,@dep = dep
		 from master_till where accnt = (select master from master_till where accnt = @accnt )
	if @tofrom = 'TO' and @accntof <> ''
		select @master = @accntof
	select @gstno = isnull((select count(1) from master_till where roomno = substring(@mode,2,5) and ((@arr >= arr and @arr < dep) or (@dep > arr and @dep <= dep)) ),0)
	select @company = isnull(ltrim(rtrim(cusno + agent + source)),'') from master_till where accnt = @master
	select @country = country,@nation = nation,@sno = sno from guest where no = @haccnt
	select @sno = sno,@saleid = @saleid from guest where no = @company
	
	-- 什么情况下计算房晚
	if charindex(substring(@mode, 1, 1), rtrim(@nights_option) ) = 0
		select @quantity = 0
	--什么情况计算房费
	if charindex(rtrim(@pccode), rtrim(@pccodeallow)) = 0
		select @charge = 0

	if @mode = ' pkg_c   A'
			begin
			select @package = substring(@ref2,charindex('{',@ref2) + 1,charindex('>}',@ref2) - charindex('{',@ref2) - 1)
			if exists (select 1 from package where code = @package and substring(rule_calc,1,1) = '1')
				begin
--insert gdsmsg select convert(char,@charge)+','+@package+','+@pccode
				select @charge = 0
				end
			end

	select @charge_rm = 0
	if charindex(rtrim(@pccode), @pccodeallow) > 0
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
		select @quantity = 0,@charge_rm = 0

//if @quantity>0
//	select @quantity,@mode,@accnt,@master
//select * from #roomno order by roomno



	if @quantity > 0 or @charge_rm <> 0
		begin
		if not substring(@mode,2,5) = ''
			select @roomno = substring(@mode,2,5)
		select @rmnum = 1  from rmuserate where roomno = @roomno and date = @bdate
		if @@rowcount=0
			begin
			insert rmuserate (roomno,sta,date,quantity,rmrate,gstno,type,packages,market,src,restype,ratecode,channel,nation,country,company,sno,saleid,master,mode,log_date) values
					(@roomno,'I',@bdate,@quantity,@charge_rm,@gstno,'',isnull(@packages,''),isnull(@market,''),isnull(@src,''),@restype,@ratecode,@channel,@nation,@country,@company,isnull(@sno,''),@saleid,@master,@mode,getdate())
			end
		else
			begin
			update rmuserate set quantity = @quantity + quantity,rmrate = rmrate + @charge_rm where rtrim(roomno) = rtrim(@roomno) and date = @bdate
			end
		end
	select @packages='',@market='',@src='',@restype='',@ratecode='',@nation='',@country='',@company='',@sno='',@saleid='',@master='',@mode=''

	fetch c_gltemp into @accnt, @accntof, @tofrom, @market, @charge, @quantity, @mode, @pccode, @class, @rmposted, @rsvc, @rpak ,@master,@ref2,@roomno
	end
close c_gltemp
deallocate cursor c_gltemp
update rmuserate set type = b.type from rmsta b where b.roomno = rmuserate.roomno and rmuserate.date = @bdate

declare c_ooo cursor for select roomno,sta from  rm_ooo where dbegin<=@bdate and dend>=@bdate --and sta='O'
open  c_ooo
fetch c_ooo into @roomno,@sta
while @@sqlstatus = 0
	begin
	if @sta = 'O'
	if not exists (select 1 from rmuserate where roomno=@roomno and date=@bdate and sta='O')
		insert rmuserate (roomno,sta,date,quantity,rmrate,gstno,type,packages,market,src,restype,ratecode,channel,nation,country,company,sno,saleid,master,mode,log_date) values
					(@roomno,'O',@bdate,0,0,0,'','','','','','','','','','','','','','',getdate())
	else if @sta='S'
	if not exists (select 1 from rmuserate where roomno=@roomno and date=@bdate and sta='S')
		insert rmuserate (roomno,sta,date,quantity,rmrate,gstno,type,packages,market,src,restype,ratecode,channel,nation,country,company,sno,saleid,master,mode,log_date) values
					(@roomno,'O',@bdate,0,0,0,'','','','','','','','','','','','','','S',getdate())
//		insert rmuserate (roomno,sta,date,quantity,rmrate,type,packages,mkt,src,master,mode,log_date) values
//				(@roomno,'O',@bdate,1,0,'','','','','','',getdate())
	fetch c_ooo into @roomno,@sta
	end
close c_ooo
deallocate cursor c_ooo

//select * from rmuserate

return 0
;