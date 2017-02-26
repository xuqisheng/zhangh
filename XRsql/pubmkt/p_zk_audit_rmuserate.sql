
if exists (select * from sysobjects where name ='p_zk_audit_rmuserate' and type ='P')
	drop proc p_zk_audit_rmuserate;
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
	@packages		varchar(50),
	@roomno			char(5)

-- 
select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate)


--
select @day_use_in = value from sysoption where catalog='reserve' and item='day_use_in'
if @@rowcount = 0 or @day_use_in is null
	select @day_use_in = 'F'
select @pcaddbed = value from sysoption where catalog='audit' and item='room_charge_pccode_extra'
if @@rowcount = 0 or @pcaddbed is null
	select @pcaddbed = '1050'
select @nights_option = value from sysoption where catalog='audit' and item='addrm_night'
if @@rowcount = 0 or @nights_option is null
	select @nights_option = 'JjBbNPDd'
-- 

delete from rmuserate where date = @bdate
--
create table #roomno (roomno  char(10)  not null,
							 accnt   char(10)  not null,
							 master	char(10)  not null,
							 rm		money		 not null)

--  计算收入
declare c_gltemp cursor for
	select a.accnt, a.accntof, a.tofrom, a.tag, a.charge, a.quantity, a.mode, a.pccode, b.type, b.rmposted, a.charge3, a.package_a ,b.master,b.packages,b.src
	from  gltemp a, master_till b
	where a.accnt = b.accnt and a.pccode < '9' and (a.crradjt in ('AD', '') or (a.crradjt in ('LT', 'LA') and a.tofrom= ''))
open  c_gltemp
fetch c_gltemp into @accnt, @accntof, @tofrom, @market, @charge, @quantity, @mode, @pccode, @class, @rmposted, @rsvc, @rpak ,@master,@packages,@src
while @@sqlstatus = 0
	begin 
		-- 什么情况下计算房晚
		if substring(@mode, 1, 1)='' or charindex(substring(@mode, 1, 1), @nights_option) = 0
			select @quantity = 0

		-- 这里值得思考：是放入 @mode, 还是 substring(@mode,2,5) ?
		if @day_use_in='F'
			begin
			if substring(@mode,2,5) <> '' and @quantity !=  0 and @pccode<>@pcaddbed and @class<>'C' 
				begin
				if not exists(select 1 from #roomno where roomno = substring(@mode,2,5))
					insert #roomno select substring(@mode,2,5),'','',0
				else
					select @quantity = 0
				end
			else
				select @quantity = 0
			end
		else
			begin
			if substring(@mode,2,5) <> '' and @quantity !=  0 and @pccode<>@pcaddbed
				begin
				if not exists(select 1 from #roomno where roomno = substring(@mode,2,5) and master = @master and accnt=@accnt)
					begin
					insert #roomno select substring(@mode,2,5),@accnt,@master,@quantity
					select @quantity = 0 from #roomno where roomno = substring(@mode,2,5) and master = @master and accnt = @accnt and rm <= (select max(rm) from #roomno where roomno = substring(@mode,2,5) and master = @master and accnt <> @accnt)
					end
				else
					begin
					update #roomno set rm = @quantity + rm where roomno = substring(@mode,2,5) and master = @master and accnt = @accnt
					select @quantity = 0 from #roomno where roomno = substring(@mode,2,5) and master = @master and accnt = @accnt and rm <= (select max(rm) from #roomno where roomno = substring(@mode,2,5) and master = @master and accnt <> @accnt)
					end
				end
			else
				select @quantity = 0
			end
	if @quantity > 0
		begin
		select @rmnum=1  from rmuserate where rtrim(roomno)=rtrim(substring(@mode,2,5)) and date=@bdate and sta='I'
		if @@rowcount=0
			insert rmuserate (roomno,sta,date,quantity,rmrate,type,packages,mkt,src,master,mode,log_date) values 
					(substring(@mode,2,5),'I',@bdate,@quantity,@charge,@class,isnull(@packages,''),isnull(@market,''),isnull(@src,''),@master,'',getdate())
		else
			begin
			update rmuserate set quantity=@quantity+quantity where roomno=substring(@mode,2,5) and date=@bdate and sta='I'
			end
		end
	fetch c_gltemp into @accnt, @accntof, @tofrom, @market, @charge, @quantity, @mode, @pccode, @class, @rmposted, @rsvc, @rpak ,@master,@packages,@src
	end
close c_gltemp
deallocate cursor c_gltemp

declare c_ooo cursor for
	select roomno
	from  rm_ooo
	where dbegin<=@bdate and dend>=@bdate
open  c_ooo
fetch c_ooo into @roomno
while @@sqlstatus = 0
	begin
	select 1 from rmuserate where roomno=@roomno and date=@bdate and sta='O'
	if @@rowcount=0
		insert rmuserate (roomno,sta,date,quantity,rmrate,type,packages,mkt,src,master,mode,log_date) values 
				(@roomno,'O',@bdate,1,0,'','','','','','',getdate())
	fetch c_ooo into @roomno
	end
close c_ooo
deallocate cursor c_ooo

select 0
return 0
;




