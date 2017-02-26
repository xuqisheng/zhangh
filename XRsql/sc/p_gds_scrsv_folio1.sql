if exists(select * from sysobjects where name = "p_gds_scrsv_folio1_1")
   drop proc p_gds_scrsv_folio1_1;
create proc p_gds_scrsv_folio1_1
   @accnt 	char(10)
as
--------------------------------------------------------
-- SC 单据打印1 - 1 normal info.
--------------------------------------------------------

declare	@today		varchar(30),
			@market		char(3),
			@restype		varchar(30),
			@mktgrp		char(10)

create table #info (
	today			varchar(20)	null,
	accnt			varchar(10)	null,
	name			varchar(50)	null,

	cusno			varchar(50)	null,
	street1		varchar(50)	null,
	country1		varchar(30)	null,
	city1			varchar(30)	null,
	phone1		varchar(20)	null,
	fax1			varchar(20)	null,
	
	agent			varchar(50)	null,
	street2		varchar(50)	null,
	country2		varchar(30)	null,
	city2			varchar(30)	null,
	phone2		varchar(20)	null,
	fax2			varchar(20)	null,

	contact		varchar(50)	null,
	phone3		varchar(20)	null,
	fax3			varchar(20)	null,

	status			varchar(10)	null,
	arr				varchar(10)	null,
	dep				varchar(10)	null,
	nights			varchar(5)	null,
	market			varchar(30)	null,
	mktgrp			varchar(10)	null,
	restype			varchar(30)	null,
	saleid			varchar(10)	null
	
)

select @today = convert(char(10), getdate(), 111) + ' ' + convert(char(8), getdate(), 8)

insert #info 
select 
	@today,
	a.accnt,
	a.name,
	
	b.name,
	b.street,
	b.country,
	b.town,
	b.phone,
	b.fax,
	
	c.name,
	c.street,
	c.country,
	c.town,
	c.phone,
	c.fax,
	
	d.name,
	d.phone,
	d.fax,
	
	a.status,
	convert(char(10), a.arr, 111),
	convert(char(10), a.dep, 111),
	convert(char(5), datediff(dd, a.arr, a.dep)),
	a.market,
	'',
	a.restype,
	a.saleid
from sc_master a, guest b, guest c, guest d
	where a.accnt=@accnt and a.cusno*=b.no and a.agent*=c.no and a.contact*=d.no
		
update #info set mktgrp=a.grp from mktcode a where #info.market=a.code
update #info set #info.market=#info.market + ' ' + a.descript1  from mktcode a where #info.market=a.code
update #info set restype=restype + ' ' + a.descript from restype a where #info.restype=a.code

select * from #info 

return ;


if exists(select * from sysobjects where name = "p_gds_scrsv_folio1_2")
   drop proc p_gds_scrsv_folio1_2;
create proc p_gds_scrsv_folio1_2
   @accnt 	char(10)
as
------------------------------------------------------------------
-- SC 单据打印1 - 2 rm booking info = nights + rate + revenue 
--  简单格式 -- 把每天的客房情况拼接为一行 
------------------------------------------------------------------
declare		@arr 			datetime, 
				@dep 			datetime, 
				@date			datetime,
				@types		varchar(250),
				@type			char(3),
				@type_num	int,
				@quan			int,
				@rate			money,
				@pos			int,
				@remark		varchar(255)

create table #info (
	date			datetime				not null,
	datedes		varchar(10)			null,
	remark		varchar(255)		null
)

-- 
select @arr=arr,@dep=dep from sc_master where accnt=@accnt
if @@rowcount = 0
	goto gout
if not exists(select 1 from rsvsrc where accnt=@accnt and id>0)
	goto gout

select @arr = min(begin_) from rsvsrc where accnt=@accnt and id>0
select @dep = max(end_) from rsvsrc where accnt=@accnt and id>0
select @dep = dateadd(dd, -1, @dep)

--  room type
select @type_num = 0
declare c_type cursor for select distinct a.type from rsvsrc a, typim b 
	where a.accnt=@accnt and a.type=b.type and a.id>0 order by b.sequence desc 
open c_type
fetch c_type into @type 
while @@sqlstatus = 0
begin
	select @types = @types + @type + '_', @type_num = @type_num + 1
	fetch c_type into @type 
end
close c_type
deallocate cursor c_type 

--
while @arr <= @dep
begin
	select @pos = 0, @remark=''
	while @pos < @type_num
	begin
		select @pos = @pos + 1
		select @type = substring(@types, (@pos - 1)*4 + 1, 3)
		select @quan = isnull((select sum(quantity) from rsvsrc where accnt=@accnt and type=@type and @arr>=begin_ and @arr<end_ and id>0), 0)
		select @rate = isnull((select max(rate) from rsvsrc where accnt=@accnt and type=@type and @arr>=begin_ and @arr<end_ and id>0), 0)

		select @remark = @type + ' ' + convert(char(3),@quan) + convert(char(6),@rate) + '   ' + @remark
	end
	insert #info(date, remark) values(@arr, @remark)

	select @arr = dateadd(dd, 1, @arr)
end


-- output
gout:
update #info set datedes=convert(char(10), date, 11)
select datedes, remark from #info order by date

return ;


//if exists(select * from sysobjects where name = "p_gds_scrsv_folio1_2")
//   drop proc p_gds_scrsv_folio1_2;
//create proc p_gds_scrsv_folio1_2
//   @accnt 	char(10),
//	@mode		char(1)
//as
//------------------------------------------------------------------
//-- SC 单据打印1 - 2 rm booking info = nights + rate + revenue 
//--  目前只考虑最多显示 8 个房类
//--	两个 grid 表，分别表现房数、房价、收入等
//------------------------------------------------------------------
//declare		@arr 			datetime, 
//				@dep 			datetime, 
//				@date			datetime,
//				@types		varchar(250),
//				@type			char(3),
//				@quan			int,
//				@rate			money,
//				@pos			int,
//				@type1		char(3),
//				@type2		char(3),
//				@type3		char(3),
//				@type4		char(3),
//				@type5		char(3),
//				@type6		char(3),
//				@type7		char(3),
//				@type8		char(3),
//				@amount		money
//
//create table #info (
//	date			datetime				not null,
//	datedes		varchar(10)			null,
//
//	type1			int					null,
//	rate1			money					null,
//	t1				varchar(10)			null,
//
//	type2			int					null,
//	rate2			money					null,
//	t2				varchar(10)			null,
//
//	type3			int					null,
//	rate3			money					null,
//	t3				varchar(10)			null,
//
//	type4			int					null,
//	rate4			money					null,
//	t4				varchar(10)			null,
//
//	type5			int					null,
//	rate5			money					null,
//	t5				varchar(10)			null,
//
//	type6			int					null,
//	rate6			money					null,
//	t6				varchar(10)			null,
//
//	type7			int					null,
//	rate7			money					null,
//	t7				varchar(10)			null,
//
//	type8			int					null,
//	rate8			money					null,
//	t8				varchar(10)			null,
//
//	ttl			int					null,
//	trate			money					null,
//	tt				varchar(10)			null
//)
//
//-- 
//select @arr=arr,@dep=dep from sc_master where accnt=@accnt
//if @@rowcount = 0
//	goto gout
//
//select @arr = convert(datetime,convert(char(10),@arr,111))
//select @dep = convert(datetime,convert(char(10),@dep,111))
//
//--  types = AB _ATM_TM _  每个房类占4位
//select @types = '', @pos = 0, @type1='', @type2='', @type3='', @type4='', @type5='', @type6='', @type7='', @type8=''
//declare c_type cursor for select distinct a.type from rsvsrc a, typim b 
//	where a.accnt=@accnt and a.type=b.type and a.id>0 order by b.sequence
//open c_type
//fetch c_type into @type 
//while @@sqlstatus = 0
//begin
//	select @types = @types + @type + '_', @pos = @pos + 1
//	if @pos = 1 
//		select @type1 = @type
//	else if @pos = 2
//		select @type2 = @type
//	else if @pos = 3
//		select @type3 = @type
//	else if @pos = 4
//		select @type4 = @type
//	else if @pos = 5
//		select @type5 = @type
//	else if @pos = 6
//		select @type6 = @type
//	else if @pos = 7
//		select @type7 = @type
//	else if @pos = 8
//		select @type8 = @type
//	
//	fetch c_type into @type 
//end
//close c_type
//deallocate cursor c_type 
//
//-- data
//declare c_block cursor for select type,begin_,end_,quantity,rate from rsvsrc where accnt=@accnt and id>0 
//open c_block
//fetch c_block into @type,@arr,@dep,@quan,@rate
//while @@sqlstatus = 0
//begin
//	select @date = @arr 
//	while @date < @dep
//	begin
//		if not exists(select 1 from #info where date=@date)
//			insert #info(date) values(@date)
//
//		select @pos = charindex(@type + '_', @types) / 4 + 1
//		if @pos > 5 
//		begin
//			select @date = dateadd(dd, 1, @date)
//			continue 
//		end
//
//		if @pos = 1 
//			update #info set type1=isnull(type1,0)+@quan, rate1=@rate where date=@date
//		else if @pos = 2
//			update #info set type2=isnull(type2,0)+@quan, rate2=@rate where date=@date
//		else if @pos = 3
//			update #info set type3=isnull(type3,0)+@quan, rate3=@rate where date=@date
//		else if @pos = 4
//			update #info set type4=isnull(type4,0)+@quan, rate4=@rate where date=@date
//		else if @pos = 5
//			update #info set type5=isnull(type5,0)+@quan, rate5=@rate where date=@date
//		else if @pos = 6
//			update #info set type6=isnull(type6,0)+@quan, rate6=@rate where date=@date
//		else if @pos = 7
//			update #info set type7=isnull(type7,0)+@quan, rate7=@rate where date=@date
//		else if @pos = 8
//			update #info set type8=isnull(type8,0)+@quan, rate8=@rate where date=@date
//
//		select @date = dateadd(dd, 1, @date)
//	end
//
//	fetch c_block into @type,@arr,@dep,@quan,@rate
//end
//close c_block
//deallocate cursor c_block
//
//--
//if exists(select 1 from #info)
//begin
//	if @mode = 'R'  -- 客房数量
//	begin
//		update #info set ttl=isnull(type1,0)+isnull(type2,0)+isnull(type3,0)+isnull(type4,0)
//								+isnull(type5,0)+isnull(type6,0)+isnull(type7,0)+isnull(type8,0)
//		-- 合计客房 
//		select @quan = isnull((select sum(ttl) from #info), 0)
//		select @date = convert(datetime, '2030.1.1')
//		insert #info (date, datedes, tt) values(@date , 'Nighs', ltrim(rtrim(convert(char(10),@quan))) )
//
//		update #info set datedes=convert(char(10), date, 11),
//								t1 = convert(char(5), type1),
//								t2 = convert(char(5), type2),
//								t3 = convert(char(5), type3),
//								t4 = convert(char(5), type4),
//								t5 = convert(char(5), type5),
//								t6 = convert(char(5), type6),
//								t7 = convert(char(5), type7),
//								t8 = convert(char(5), type8),
//								tt =  convert(char(5), ttl)
//			where date<>@date 
//	end
//	else				-- M 房价与收入 
//	begin
//		update #info set trate=isnull(type1,0)*isnull(rate1,0)
//								+isnull(type2,0)*isnull(rate2,0)
//								+isnull(type3,0)*isnull(rate3,0)
//								+isnull(type4,0)*isnull(rate4,0)
//								+isnull(type5,0)*isnull(rate5,0)
//								+isnull(type6,0)*isnull(rate6,0)
//								+isnull(type7,0)*isnull(rate7,0)
//								+isnull(type8,0)*isnull(rate8,0)
//		-- 合计收入 
//		select @amount = isnull((select sum(trate) from #info), 0)
//		select @date = convert(datetime, '2030.1.1')
//		insert #info (date, datedes, tt) values(@date , 'Revenue', ltrim(rtrim(convert(char(10),@amount))) )
//
//		update #info set datedes=convert(char(10), date, 11),
//								t1 = ltrim(rtrim(convert(char(10), rate1))),
//								t2 = ltrim(rtrim(convert(char(10), rate2))),
//								t3 = ltrim(rtrim(convert(char(10), rate3))),
//								t4 = ltrim(rtrim(convert(char(10), rate4))),
//								t5 = ltrim(rtrim(convert(char(10), rate5))),
//								t6 = ltrim(rtrim(convert(char(10), rate6))),
//								t7 = ltrim(rtrim(convert(char(10), rate7))),
//								t8 = ltrim(rtrim(convert(char(10), rate8))),
//								tt = ltrim(rtrim(convert(char(10), trate))) 
//			where date<>@date 
//	end
//
//
//	-- 第一行 
//	select @date = convert(datetime, '2000.1.1')
//	insert #info(date,datedes,t1,t2,t3,t4,t5,t6,t7,t8,tt) 
//		values(@date,'Date',@type1,@type2,@type3,@type4,@type5,@type6,@type7,@type8,'Total')
//	
//	-- 第末行 
//	-- ......
//
//end
//
//-- output
//gout:
//select datedes,tt,t1,t2,t3,t4,t5,t6,t7,t8
//	from #info order by date
//
//return ;
//


if exists(select * from sysobjects where name = "p_gds_scrsv_folio1_3")
   drop proc p_gds_scrsv_folio1_3;
create proc p_gds_scrsv_folio1_3
   @accnt 	char(10)
as
--------------------------------------------------------
-- SC 单据打印1 - 3 booking notes  
--------------------------------------------------------
select id*10, remark from sc_remark 
	where accnt=@accnt and owner='BOOKING' and type='MSTBLK'  -- MSTBLK / MSTEVT / MSTAGR
union all -- empno info 
select id*10 + 5, convert(text, '  ---- ' + cby + ' ' +  convert(char(10), changed, 111) + ' ' + convert(char(8), changed, 8))  from sc_remark 
	where accnt=@accnt and owner='BOOKING' and type='MSTBLK'

return ;



if exists(select * from sysobjects where name = "p_gds_scrsv_folio1_4")
   drop proc p_gds_scrsv_folio1_4;
create proc p_gds_scrsv_folio1_4
   @accnt 	char(10)
as
--------------------------------------------------------
-- SC 单据打印1 - 4 agreement notes  
--------------------------------------------------------
select id*10, remark from sc_remark 
	where accnt=@accnt and owner='BOOKING' and type='MSTAGR'  -- MSTBLK / MSTEVT / MSTAGR
union all -- empno info 
select id*10 + 5, convert(text, '  ---- ' + cby + ' ' +  convert(char(10), changed, 111) + ' ' + convert(char(8), changed, 8))  from sc_remark 
	where accnt=@accnt and owner='BOOKING' and type='MSTAGR'

return ;


if exists(select * from sysobjects where name = "p_gds_scrsv_folio1_6")
   drop proc p_gds_scrsv_folio1_6;
create proc p_gds_scrsv_folio1_6
   @accnt 	char(10)
as
--------------------------------------------------------
-- SC 单据打印1 - 6 billing struction 
--------------------------------------------------------
select id*10, remark from sc_remark 
	where accnt=@accnt and owner='BOOKING' and type='MSTBIL'  -- 
union all -- empno info 
select id*10 + 5, convert(text, '  ---- ' + cby + ' ' +  convert(char(10), changed, 111) + ' ' + convert(char(8), changed, 8))  from sc_remark 
	where accnt=@accnt and owner='BOOKING' and type='MSTBIL'  -- 

return ;
