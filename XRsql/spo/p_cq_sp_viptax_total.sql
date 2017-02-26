drop proc p_cq_sp_viptax_total
;
create proc p_cq_sp_viptax_total
	@date				datetime,
	@types			varchar(255) = '%'
as

declare
	@bdate			datetime,
	@cdate			datetime,
	@quantity0		money, 
	@quantity1		money, 
	@quantity2		money, 
	@quantity3		money, 
	@quantity4		money, 
	@quantity5		money, 
	@quantity6		money, 
	@quantity7		money,
	@quantity8		money, 
	@quantity9		money,
	@quantity10		money, 
	@qty010			integer, 
	@qty020			integer, 
	@qty060			integer, 
	@count			integer, 
	@ntmp				int,
	@descript		char(30),
	@descript1		char(30),
	@code				char(3),
	@paycode			char(5)


create table #control_panel
(
	date				datetime, 
	code				char(3)			not null,
	paycode			char(5)			not null,
	descript			char(50)			null,
	descript1		char(50)			null,
	quantity			money				default 0 null
)
create table #print
(
	code				char(3)			not null,
	paycode			char(5)			not null,
	descript			char(50)			null,
	descript1		char(50)			null,
	day0				money				default 0 null,
	day1				money				default 0 null,
	day2				money				default 0 null,
	day3				money				default 0 null,
	day4				money				default 0 null,
	day5				money				default 0 null,
	day6				money				default 0 null,
	format			char(50)			default "0" not null,
	alignment		integer			default 1 null,					-- 对齐方式
	sequence			integer			null,
	color				integer			default 0	not null
)
//select @types = @types + '#'
select @bdate = bdate1, @count = 0 from sysdata 
declare c_paycode cursor for select distinct rtrim(a.paycode) from sp_hviptax a,vipcard b where a.bdate = @cdate 
	and a.no = b.no and (charindex(rtrim(b.type),@types) > 0 or @types = '%')
while @count < 7
	begin
	select @cdate = dateadd(dd, @count, @date)
	open c_paycode
	fetch c_paycode into @paycode
	while @@sqlstatus = 0
		begin
		select @descript = descript ,@descript1 = descript1 from pccode where pccode = @paycode
		//金额统计
		select @quantity0 = isnull(sum(a.amount),0) from sp_hviptax a,vipcard b where a.bdate = @cdate and a.paycode = @paycode
				and a.no = b.no and (charindex(rtrim(b.type),@types) > 0 or @types = '%')
		select @quantity1 = isnull(sum(a.rate0),0)  from sp_hviptax a,vipcard b where a.bdate = @cdate and a.paycode = @paycode
				and a.no = b.no and (charindex(rtrim(b.type),@types) > 0 or @types = '%')
		select @quantity2 = isnull(sum(a.posted),0) from sp_hviptax a,vipcard b where a.bdate = @cdate and a.paycode = @paycode
				and a.no = b.no and (charindex(rtrim(b.type),@types) > 0 or @types = '%')
		select @quantity3 = isnull(sum(a.amount) - sum(a.posted),0) from sp_hviptax a,vipcard b where a.bdate = @cdate and a.paycode = @paycode
				and a.no = b.no and (charindex(rtrim(b.type),@types) > 0 or @types = '%')
		insert #control_panel (date, code, paycode,descript,descript1,quantity) select @cdate, 'A', @paycode,@descript,@descript1,@quantity0
		insert #control_panel (date, code, paycode,descript,descript1,quantity) select @cdate, 'B', @paycode,@descript,@descript1,@quantity1
		insert #control_panel (date, code, paycode,descript,descript1,quantity) select @cdate, 'C', @paycode,@descript,@descript1,@quantity2
		insert #control_panel (date, code, paycode,descript,descript1,quantity) select @cdate, 'D', @paycode,@descript,@descript1,@quantity3
		fetch c_paycode into @paycode
		end
	close c_paycode
	//包价个数统计
	select @quantity4 = isnull(count(1),0) from sp_hviptax a,vipcard b where a.bdate = @cdate and a.class = '0'
			and a.no = b.no and (charindex(rtrim(b.type),@types) > 0 or @types = '%')
	select @quantity5 = isnull(count(1),0) from sp_hviptax a,vipcard b where a.bdate = @cdate and a.class = '1'
			and a.no = b.no and (charindex(rtrim(b.type),@types) > 0 or @types = '%')
	select @quantity6 = isnull(count(1),0) from sp_hviptax a,vipcard b where a.bdate = @cdate and a.class = '2'
			and a.no = b.no and (charindex(rtrim(b.type),@types) > 0 or @types = '%')
	insert #control_panel (date, code, paycode,descript,descript1,quantity) select @cdate, '1', '0','按每日分摊(个)','',@quantity4
	insert #control_panel (date, code, paycode,descript,descript1,quantity) select @cdate, '1', '1','按发生分摊(个)','',@quantity5
	insert #control_panel (date, code, paycode,descript,descript1,quantity) select @cdate, '1', '2','直接入帐(个)','',@quantity6	
	//当日购买
	select @quantity7 = isnull(count(1),0) from sp_hviptax a,vipcard b where a.bdate = @cdate 
			and a.no = b.no and (charindex(rtrim(b.type),@types) > 0 or @types = '%') and datediff(dd,logdate,@cdate) = 0
	select @quantity8 = isnull(sum(a.amount),0) from sp_hviptax a,vipcard b where a.bdate = @cdate 
			and a.no = b.no and (charindex(rtrim(b.type),@types) > 0 or @types = '%') and datediff(dd,logdate,@cdate) = 0
	insert #control_panel (date, code, paycode,descript,descript1,quantity) select @cdate, '2', '','当日购买(个)','',@quantity7
	insert #control_panel (date, code, paycode,descript,descript1,quantity) select @cdate, '2', '1','总金额(元)','',@quantity8
	//当日完全入帐
	select @quantity9 = isnull(count(1),0) from sp_hviptax a,vipcard b where a.bdate = @cdate 
			and a.no = b.no and (charindex(rtrim(b.type),@types) > 0 or @types = '%') and a.amount = a.posted
	select @quantity10 = isnull(sum(a.amount),0) from sp_hviptax a,vipcard b where a.bdate = @cdate 
			and a.no = b.no and (charindex(rtrim(b.type),@types) > 0 or @types = '%') and a.amount = a.posted
	insert #control_panel (date, code, paycode,descript,descript1,quantity) select @cdate, '3', '','当日完全入帐(分摊)(个)','',@quantity9
	insert #control_panel (date, code, paycode,descript,descript1,quantity) select @cdate, '3', '1','总金额(元)','',@quantity10
	
	select @count = @count + 1
	end
deallocate cursor c_paycode

insert #control_panel (date, code, paycode,quantity) select date, code, '',sum(quantity) from #control_panel where paycode <> ''
		group by date,code
update #control_panel set descript = '总包价数(个)' where code = '1' and paycode = ''
update #control_panel set descript = '包价总金额(元)' where code = 'A' and paycode = ''
update #control_panel set descript = '当日入帐(分摊)(元)' where code = 'B' and paycode = ''
update #control_panel set descript = '已经入帐(分摊)(元)' where code = 'C' and paycode = ''
update #control_panel set descript = '剩余金额(元)' where code = 'D' and paycode = ''

//select distinct code,paycode from #control_panel
-- 转换成显示格式
insert #print (code, paycode) 
	select distinct code, paycode from #control_panel order by code,paycode

select @count = 0
while @count < 7
	begin
	select @cdate = dateadd(dd, @count, @date)
	if @count = 0
		update #print set day0 = a.quantity,descript = a.descript ,descript1 = a.descript1 from #control_panel a
			where a.date = @cdate and #print.code = a.code and #print.paycode = a.paycode
	else if @count = 1
		update #print set day1 = a.quantity,descript = a.descript ,descript1 = a.descript1 from #control_panel a
			where a.date = @cdate and #print.code = a.code and #print.paycode = a.paycode
	else if @count = 2
		update #print set day2 = a.quantity,descript = a.descript ,descript1 = a.descript1 from #control_panel a
			where a.date = @cdate and #print.code = a.code and #print.paycode = a.paycode
	else if @count = 3
		update #print set day3 = a.quantity,descript = a.descript ,descript1 = a.descript1 from #control_panel a
			where a.date = @cdate and #print.code = a.code and #print.paycode = a.paycode
	else if @count = 4
		update #print set day4 = a.quantity,descript = a.descript ,descript1 = a.descript1 from #control_panel a
			where a.date = @cdate and #print.code = a.code and #print.paycode = a.paycode
	else if @count = 5
		update #print set day5 = a.quantity,descript = a.descript ,descript1 = a.descript1 from #control_panel a
			where a.date = @cdate and #print.code = a.code and #print.paycode = a.paycode
	else if @count = 6
		update #print set day6 = a.quantity,descript = a.descript ,descript1 = a.descript1 from #control_panel a
			where a.date = @cdate and #print.code = a.code and #print.paycode = a.paycode
	select @count = @count + 1
	end

-- update #print set format = '0.00%' where code in ('120', '130')
update #print set color=16777215 where paycode <> ''
update #print set color=65535 where paycode = ''
update #print set descript = '     '+descript ,descript1 = '     '+descript1 where paycode <> ''

select code,paycode, descript, descript1, day0, day1, day2, day3, day4, day5, day6, format, alignment,color from #print order by sequence;
