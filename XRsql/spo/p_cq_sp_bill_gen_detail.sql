create proc p_cq_sp_bill_gen_detail
	@menus				varchar(255),
	@today				char(1),					-- T:打印当天的账单F:打印以前的账单
	@paid					char(1),					-- T:结账打单 F:非结账打单
	@multi				char(1),					-- T:在原帐单上打印
	@code					char(10),				-- 头2位为打印类型，第3位为是否打印套菜明细，
														--		第4位为是否打印套菜明细单价，后2位为中英文
	@pc_id				char(4)
as
--------------------------------------------------------------------------------------------------
--	餐饮账单 --- X5
--	说明：1、赠送(dish.sta= '3')、全免(dish.sta= '5')处理方法要根据饭店实际要求而定
--				一般处理方法：金额不为零, 金额记入折扣；金额为零, 金额不记入折扣
--			2、折扣处理方法：A：每次都打印折扣总额；B：每次只打印新点的菜的折扣
--			3、支持套菜特殊处理
--			5、支持中英文
--------------------------------------------------------------------------------------------------
declare
	@ls_menus			varchar(255),
	@menu					char(10),
	@min_charge			money,
	@total0				money,
	@total1				money,
	@total2				money,
	@paymth				varchar(255),
	@transfer			varchar(255),
	@paycode				char(3),
	@distribute			char(4),
	@ld_amount			money,
	@accnt				varchar(10),
	@class				char(1),
	@dec_length			integer,
	@dec_mode			char(1),
	@inumber				int,                -- 在一张账单上打印明细帐要记已打的sp_dish.inumber
	@dish_inumber		int,                -- dish 的最大inumber
	@hline				int,
	@ii					int,
	@amount				decimal(10,2),
	@samount				varchar(40),
	@deptno2				char(3),
	@dsc_rate			money,
	@srv_rate			money,
	@tax_rate			money,
	@remark				char(20),
	@stdprint			char(1),				-- 套菜明细是否要打印
	@stdprice			char(1),				-- 套菜单价是否要打印
	@sbal					char(255),
	@tmpdsc1				money,         -- 已经打印的折扣
	@tmpdsc2				money,		   -- 总折扣
	@tmpsrv1				money,         -- 已经打印的服务费
	@tmpsrv2				money,		   -- 总服务费
	@tmptax1				money,         -- 已经打印的税
	@tmptax2				money,		   -- 总税
	@tmptea1				money,         -- 已经打印的茶位费
	@tmptea2				money,		   -- 总茶位费
	@add					char(1)  		--是否加减菜


select @stdprint = substring(@code, 3, 1), @stdprice = substring(@code, 4, 1)
if @stdprint is null
	select @stdprint = 'T'
if @stdprice is null
	select @stdprice = 'F'

delete bill_data where pc_id  = @pc_id
select * into #dish from sp_dish where 1=2
select * into #menu from sp_menu where 1=2
create index index1 on #dish(code)
create table #bill
(
	menu			char(10)		not null,						-- 主单号码
	inumber		integer		not null,						-- ID号
	code			char(15)		default '' not null,			-- 代码
	empno			char(3)		default '' not null,			-- 工号
	name1			char(60)		default '' not null,			-- 中文名称
	name2			char(60)		null,								-- 英文名称
	number		money			not null,						-- 份量
	unit			char(4)		null,								-- 单位
	price			money			default 0 not null,			-- 单价
	amount		money			not null,						-- 金额
	log_date		datetime		not null,						-- 写盘时间
	status		integer		not null,						-- 0.菜. 5.英文. 10. --. 15.小计. 20.服务费. 30.附加费.
	      															--			40.折扣. 50.累计. 60.合计.
																		--	70.其中付款. 80.转账帐号余额
	sta         char(1)    	default '0' null,
	sort        integer	   not null,			    		-- 用于排序
	id_master	integer		not null                   -- 用于排序
)

create table #checkout
(
	paycode		char(3)		null,								--付款方式
	amount		money			not null,						--付款金额
	remark		char(20)		null								--零头去向,帐号,理由等
)

select @ls_menus = @menus, @total0 = 0, @total1 = 0, @total2 = 0, @paymth = '', @transfer = '', @tmpdsc2 = 0, @tmpsrv2 = 0, @tmptax2 = 0, @tmptea2 = 0

-- --已打的序号
select @inumber = inumber, @hline = hline,@tmpdsc1 = isnull(dsc, 0),@tmpsrv1 = isnull(srv, 0),@tmptax1 = isnull(tax, 0),@tmptea1 = isnull(tea, 0) from pos_menu_bill where menu = substring(@menus, 1, 10)

if @inumber = null
	select @inumber = 0, @hline = 0

while datalength(@ls_menus) > 1
	begin
	select @menu = substring(@ls_menus, 1, 10), @ls_menus = substring(@ls_menus, 12, 255)
	if @today = 'T'
		-- -- 打印当天的账单, 取自 sp_dish, 不过滤套菜明细
		begin
		select @dish_inumber = max(inumber) from sp_dish where menu = @menu
		if @multi = 'T'
			begin
			-- --被冲账可能已经打印，所以对冲销菜的id_cancel作判断. 被冲菜不打印
			insert #dish select * from sp_dish where menu = @menu and (id_cancel =  0 or id_cancel <= @inumber) and charindex(sta,  '1468') =0 and inumber > @inumber and charindex(rtrim(code), 'YZ') = 0 order by inumber
			select @total0 = @total0 + isnull(sum(amount), 0) from sp_dish where menu = @menu and sta ='3'
			select @total1 = @total1 + isnull(sum(amount), 0) from sp_dish where menu = @menu and sta ='5'
			select @tmptea2 = @tmptea2 + isnull(sum(amount), 0) from sp_dish where menu = @menu and rtrim(code) = 'X'
			end
		else
			begin
			-- --一次打单可以过滤所有冲账和被冲账
			insert #dish select * from sp_dish where menu = @menu and charindex(sta, '03579MA') > 0 and charindex(rtrim(code), 'YZ') = 0 order by inumber
			select @total0 = @total0 + isnull(sum(amount), 0) from sp_dish where menu = @menu and sta ='3'
			select @total1 = @total1 + isnull(sum(amount), 0) from sp_dish where menu = @menu and sta ='5'
			select @tmptea2 = @tmptea2 + isnull(sum(amount), 0) from sp_dish where menu = @menu and rtrim(code) = 'X'
			end
		insert #menu select * from sp_menu where menu = @menu
		-- --最低消费
		if @paid = 'F'
			begin
			exec p_gl_pos_create_min_charge	@menu, @min_charge out, 'R', 0
			if @min_charge != 0
				select @total2 = @total2 + @min_charge
			end
		end
	else
		begin
		-- --打印以前的账单, 取自 sp_hdish, 不过滤套菜明细
		select @dish_inumber = max(inumber) from sp_hdish where menu = @menu
		insert #dish select * from sp_hdish where menu = @menu and charindex(sta, '03579M') > 0 and charindex(rtrim(code), 'YZ') = 0 order by inumber
		insert #menu select * from sp_hmenu where menu = @menu
		select @total0 = @total0 + isnull(sum(amount), 0) from sp_dish where menu = @menu and sta ='3'
		select @total1 = @total1 + isnull(sum(amount), 0) from sp_dish where menu = @menu and sta ='5'
		select @tmptea2 = @tmptea2 + isnull(sum(amount), 0) from sp_hdish where menu = @menu and rtrim(code) = 'X'
		end
	end

delete #dish where name1 = '零头'
select @dsc_rate = dsc_rate, @srv_rate = serve_rate, @tax_rate = tax_rate from #menu

-- 套菜明细明细不打印
if @stdprint <> 'T'
	delete #dish where sta = 'M'
-- begin
if substring(@code, 1, 2) = '61'        -- --明细打单
	begin
	insert #bill(menu, inumber, code,  name1, name2, number, unit, amount, status, log_date, sta, sort, id_master)
		select distinct menu, min(inumber), code,  name1, name2, sum(number), unit, sum(amount), 0, getdate(), sta, min(inumber), id_master
		from #dish
		where  special <> 'X'
		group by menu, code,  name1, name2, unit, sta
		order by menu, code, name1, name2, unit, sta

	update #bill set price = round(amount / number, 2) where number <> 0
	--	--赠送特殊处理
	update #bill set name1 = substring(rtrim('[赠]' + name1), 1, 60), amount = 0 where sta = '3'
	--	--全免特殊处理
	update #bill set name1 = substring(rtrim('[免]' + name1), 1, 60), amount = 0 where sta = '5'

	-- 折扣
	if datalength(@menus) < 15
		begin
		-- 接打，如果没有点新菜，不要打印折扣, 但是折扣有修改还是要打印
		select @tmpdsc1 = sum(dsc) from #menu
		if @multi <> 'T' or  @inumber <> @dish_inumber or @tmpdsc1 <> @tmpdsc2
			insert #bill(menu, inumber, code, empno, name1,name2, number, unit, amount, status, log_date, sort, id_master)
				select a.menu, 0, '', '', '其中折扣[' + convert(char(2), convert(int, @dsc_rate * 100)) +'%]', 'Dsc', 1, '',
				sum(-1 *  a.dsc) + @total0 + @total1, 40, getdate(), 4000, 0
				from #menu a, pos_mode_name b where a.mode = b.code
				group by a.menu, b.name2, a.dsc_rate
		end
	else
		begin
		-- 联单结账, 每次都打印折扣
		insert #bill(menu, inumber, code, empno, name1, name2, number, unit, amount, status, log_date, sort, id_master)
			select a.menu, 0, '', '', a.tableno +'折扣'+'(' + isnull(rtrim(b.name2), ' ') + ')', 'Dsc', 1, '',
			-1 * sum(a.dsc) + @total0 + @total1, 40, a.date0, 4000, 0
			from #menu a, pos_mode_name b where a.mode = b.code
			group by a.menu, a.tableno, b.name2, a.date0
			order by a.menu, a.tableno, b.name2, a.date0
		end

	insert #bill(menu, inumber, code, empno, name1, name2, number, unit, amount, status, log_date, sort, id_master)
		select '', 0, '', '', '应收小计', 'Sum', 1, '', isnull(sum(amount), 0), 15, getdate(), 1500, 0
	from #bill a where a.status = 0 and  not code like '[YZ]%' and a.sta <>'M' --for baiyun 要计算茶位费

	-- 将服务费, 附加费合并后打印在小计后面
	-- 服务费
	select @tmpsrv2 = sum(srv) from #menu
	if exists(select 1 from #dish where charindex(rtrim(code), 'YZ') = 0)
		insert #bill(menu, inumber, code, empno, name1, name2, number, unit, amount, status, log_date, sort, id_master)
			select '', 0, '', '', '服务费[' + convert(char(2), convert(int, @srv_rate * 100)) +'%]', 'Serve', 1, '', round(isnull(sum(srv), 0),2), 20, getdate(), 2000, 0
			from #dish a  where charindex(rtrim(code), 'YZ') = 0
	else if @tmpsrv1 <> @tmpsrv2         -- 如果没有点菜，服务费有变化
		insert #bill(menu, inumber, code, empno, name1, name2, number, unit, amount, status, log_date, sort, id_master)
			select '', 0, '', '', '服务费[' + convert(char(2), convert(int, @srv_rate * 100)) +'%]', 'Serve', 1, '', round(@tmpsrv2 - @tmpsrv1, 2), 20, getdate(), 2000, 0

	-- 附加费
	select @tmptax2 = sum(tax) from #menu
	if exists(select 1 from #dish where charindex(rtrim(code), 'YZ') = 0)
		insert #bill(menu, inumber, code, empno, name1, name2, number, unit, amount, status, log_date, sort, id_master)
			select '', 0, '', '', '附加费[' + convert(char(2), convert(int, @tax_rate * 100)) +'%]', 'Tax', 1, '',round(isnull(sum(tax), 0),2), 30, getdate(), 3000, 0
			from #dish a  where charindex(rtrim(code), 'YZ') = 0
	else if @tmptax1 <> @tmptax2         -- 如果没有点菜，税有变化
		insert #bill(menu, inumber, code, empno, name1, name2, number, unit, amount, status, log_date, sort, id_master)
			select '', 0, '', '', '附加费[' + convert(char(2), convert(int, @tax_rate * 100)) +'%]', 'Tax', 1, '',round(@tmptax2 - @tmptax1,2), 30, getdate(), 3000, 0

	end
else if substring(@code, 1, 2) = '62'   -- -- 汇总账单
	begin
	-- 汇总打印
	insert #bill(menu, inumber, code, empno, name1, number, unit, amount, status, log_date, sort, id_master)
		select a.menu, 0, b.code, '01', b.descript, 1, '01',  sum(amount), 0, getdate(), 0, 0
		from #dish a, pos_deptcls b
		where  a.code like rtrim(b.deptpat) + '%'
		group by a.menu, b.code, b.descript
	end
else if substring(@code, 1, 2) = '65'   -- -- 发票
	begin
	insert #bill(menu, inumber, code, empno, name1, number, unit, amount, status, log_date, sort, id_master)
		select '', 0, '', '', '餐饮费', 1, '', sum(amount), 0, getdate(), 0, 0
		from #dish
	end

-- 套菜
update #bill set name1 = '--' + rtrim(name1) where sta ='M'
-- 套菜单价金额不打印
if @stdprice <> 'T'
	update #bill set price = 0, amount = 0 where sta ='M'

-- 茶位费修改，接打时打印差额
if @multi = 'T' and @tmptea1 <> @tmptea2 and not exists(select 1 from #dish)
	insert #bill(menu, inumber, code, empno, name1, number, unit, amount, status, log_date, sort,id_master)
		select '', 0, 'X', '', '茶位费 Tea Charge', 1, '', isnull(@tmptea2 - @tmptea1, 0), 0, getdate(), 0,0


if @paid = 'T'   	-- 结帐，合计
	begin
	-- 接打，如果没有点新菜，不要打印折扣
	if @multi <> 'T' or  @inumber <> @dish_inumber or @tmptea1 <> @tmptea2
		insert #bill(menu, inumber, code, empno, name1, name2, number, unit, amount, status, log_date, sort, id_master)
				select '', 0, '', '', '合计', 'Tatol', 1, '', isnull(sum(amount), 0), 60, getdate(), 6000, 0
			from #menu
	-- 付款
	if @today = 'T'
		begin
		insert #checkout(paycode, amount, remark)
			select paycode, isnull(sum(amount), 0), '定金['+rtrim(foliono)+']'
			from pos_pay where charindex(menu, @menus) > 0 and charindex(sta , '2') > 0
			group by paycode, foliono   order by paycode, foliono
		insert #checkout(paycode, amount, remark)
			select paycode, isnull(sum(amount), 0), isnull(accnt, '')
			from pos_pay where charindex(menu, @menus) > 0 and charindex(sta , '3') > 0
			group by paycode, accnt, roomno  order by paycode, accnt, roomno
		end
	else
		begin
		insert #checkout(paycode, amount, remark)
			select paycode, isnull(sum(amount), 0), '定金['+rtrim(foliono)+']'
			from pos_hpay where charindex(menu, @menus) > 0 and charindex(sta , '2') > 0
			group by paycode, foliono  order by paycode, foliono
		insert #checkout(paycode, amount, remark)
			select paycode, isnull(sum(amount), 0), isnull(accnt, '')
			from pos_hpay where charindex(menu, @menus) > 0 and charindex(sta , '3') > 0
			group by paycode, accnt, roomno  order by paycode, accnt, roomno
		end

	declare c_paymth cursor for
		select a.paycode, a.amount, a.remark, b.deptno8
		from #checkout a, pccode b
		where a.amount <> 0 and a.paycode = b.pccode
		order by a.amount desc
	open c_paymth

	fetch c_paymth into @paycode, @ld_amount, @remark, @distribute
	while @@sqlstatus = 0
		begin
		select @transfer = ''
		select @deptno2 = deptno2 from pccode where pccode = @paycode
		select @paymth = @paymth + @deptno2 + convert(varchar(10), @ld_amount)
		if @remark <> '' and @remark not like '定金%' and @deptno2 like 'TO%'
			select @transfer =  @remark + '-'+ a.roomno + ' ' + b.name  from master a, guest b
				 where a.accnt = rtrim(@remark) and a.haccnt = b.no
		else if rtrim(@remark) like 'AR%'   and @deptno2 like 'TO%'     -- 转AR显示余额
			select @sbal = '(余额:' + convert(char(10), credit - charge)+')' from master a, guest b
				 where a.accnt = rtrim(@remark) and a.haccnt = b.no
		else if @remark <> ''
			select @transfer = @remark
		if rtrim(@transfer) is not null
			select @paymth = @paymth + ' ' +  @transfer
		select @paymth = @paymth + ","
		fetch c_paymth into @paycode, @ld_amount, @remark, @distribute
		end
	close c_paymth
	deallocate cursor c_paymth

	-- 其中付款
	insert #bill(menu, inumber, code, empno, name1, name2, number, unit, amount, status, log_date, sort, id_master)
		select '', 0, '', '', '其中:' + substring(@paymth, 1, datalength(@paymth) - 1) + '  ('+ convert(char(8),getdate(),8)+')', 'Include:' + substring(@paymth, 1, datalength(@paymth) - 1) + '  ('+ convert(char(8),getdate(),8)+')',
		1, '', 1, 70, getdate(), 7000, 0
	-- 其中转账帐号余额
	insert #bill(menu, inumber, code, empno, name1, number, unit, amount, status, log_date, sort, id_master)
		select '', 0, '', '',  isnull(@sbal, '') + '  ('+ convert(char(8),getdate(),8)+')', 1, '', 1, 80, getdate(), 8000, 0
	end
else		-- 未结帐，累计(number中存放的是原始金额)
	begin
	-- 接打，如果没有点新菜，不要打印折扣, 如果茶位费有变化要打印合计
	if @multi <> 'T' or  @inumber <> @dish_inumber or @tmpdsc1 <> @tmpdsc2  or @tmptea1 <> @tmptea2
		insert #bill(menu, inumber, code, empno, name1, name2, number, unit, amount, status, log_date, sort, id_master)
			select '', 0, '', '', '总计', 'Tatol', 1, '', isnull(sum(amount), 0), 50, getdate(), 5000, 0
			from #menu

	-- 最低消费 & 去零
	select @total1 = amount from #bill where status = 50

	if @total1 < @total2
		update #bill set name1 = rtrim(name1) + '(含最低消费' + convert(varchar(6), convert(integer, @total2 - @total1)) + '元)',
		amount = @total2 where status = 50
	else
		begin
		select @dec_length = a.dec_length, @dec_mode = a.dec_mode
			from pos_pccode a, sp_menu b
			where b.menu = substring(@menus, 1, 10) and b.pccode = a.pccode
		if @dec_mode = '0'
			select @total1 = round(@total1, @dec_length)
		else if @dec_mode = '1'
			begin
			if @dec_length = 1
				select @total1 = round(@total1 - 0.0500, @dec_length)
			else if @dec_length = 0
				select @total1 = round(@total1 - 0.5000, @dec_length)
			else if @dec_length = -1
				select @total1 = round(@total1 - 5.0000, @dec_length)
			end
		else if @dec_mode = '2'
			begin
			if @dec_length = 1
				select @total1 = round(@total1 + 0.0499, @dec_length)
			else if @dec_length = 0
				select @total1 = round(@total1 + 0.4999, @dec_length)
			else if @dec_length = -1
				select @total1 = round(@total1 + 4.9999, @dec_length)
			end

		update #bill set amount = @total1 where status = 50
		end
	end

-- 处理明细
delete #bill where amount = 0 and charindex(sta, '35M') = 0

update #bill set number = 1 where number = 0

select @ii = 1
while @ii <= @hline and @multi = 'T'	-- 处理接打, 插空行
	begin
		insert bill_data(pc_id, inumber) 	select @pc_id, 0
		select @ii = @ii + 1
	end

-- bill_data.sort 用于排序
if substring(@code, datalength(rtrim(@code)) -1, 2) = '_e'       --英文帐单
	insert bill_data(pc_id,inumber,code,descript,descript1,unit,number,price,charge,credit,empno,logdate, sort)
	select @pc_id, inumber, substring(code, 1, 1) + substring(code, 5, 4), isnull(rtrim(name2), ''), '', unit, number, price, amount,0,empno,log_date, substring('00000'+rtrim(convert(char(5), sort)),datalength('00000'+rtrim(convert(char(5), sort))) - 4, 5) + '-' + convert(char(4), id_master)
		from #bill where status < 70  order by status, menu, inumber, code
else
	insert bill_data(pc_id,inumber,code,descript,descript1,unit,number,price,charge,credit,empno,logdate, sort)
	select @pc_id, inumber, substring(code, 1, 1) + substring(code, 5, 4), isnull(rtrim(name1), ''), '', unit, number, price, amount,0,empno,log_date, substring('00000'+rtrim(convert(char(5), sort)),datalength('00000'+rtrim(convert(char(5), sort))) - 4, 5) + '-' + convert(char(4), id_master)
		from #bill where status < 70  order by status, menu, inumber, code


-- 合计，服务费，折扣等数量不需打印
update bill_data set descript1 = isnull(ltrim(convert(char(10), number)), '') where pc_id = @pc_id
update bill_data set descript1 = '' where   pc_id = @pc_id and code > '99999'  or code < '0'

-- -- 如果是结账打单就要处理合计
if @paid = 'T'
	begin
--	select @amount = convert(decimal(10,2),amount) from #bill where status = 60
	select @amount = convert(decimal(10,2),sum(amount)) from #menu
	exec p_cyj_transfer_decimal @amount, @samount output
	if substring(@code, datalength(rtrim(@code)) -1, 2) = '_e'       --英文帐单
		update bill_data set sum1 = 'Sum: '+@samount,sum2=convert(char(10), @amount) from bill_data where pc_id = @pc_id
	else
		update bill_data set sum1 = '合计: '+@samount,sum2=convert(char(10), @amount) from bill_data where pc_id = @pc_id
-- 其中付款
	update bill_data set sum3 = name1 from bill_data,#bill where status = 70  and pc_id = @pc_id
-- 其中转帐帐户余额
	update bill_data set sum4 = name1  from #bill where status = 80   and pc_id = @pc_id
	select @tmpdsc1 = payamount, @tmpdsc2 = oddamount from pos_menu_bill where menu = substring(@menus, 1, 10)
	if @tmpdsc2 <> 0 and  @tmpdsc2 is not  null
		update bill_data set sum6 = '实收 ' + convert(char(10), @tmpdsc1) + '  找零 ' + convert(char(6), @tmpdsc2) where pc_id = @pc_id
	end

declare
	@ls_pccodes			varchar(255),
	@ls_descripts1		varchar(255),
	@ls_descripts2		varchar(255),
	@ls_pccode			char(3),
	@ls_descript1		char(10),
	@ls_descript2		char(10),
	@li_tables			int,
	@li_guest			int,
	@ls_tableno			varchar(255),
	@date0				datetime,
	@empno3				char(10),
	@pccode				char(3),
	@pcdes				char(20),
	@tableno				char(5)

select @ls_menus = @menus, @li_tables = 0, @li_guest = 0, @ls_tableno = '', @ls_pccodes = '', @ls_descripts1 = '', @ls_descripts2 = ''
while datalength(@ls_menus) > 1
	begin
	select @menu = substring(@ls_menus, 1, 10), @ls_menus = substring(@ls_menus, 12, 255)
	if @today = 'T'

		begin
		select @ls_pccode = a.pccode, @ls_descript1 = b.descript1, @ls_descript2 = isnull(b.descript2, ''), @date0 = date0,@empno3 = empno3,
			@li_tables = @li_tables + a.tables, @li_guest = @li_guest + a.guest, @ls_tableno = @ls_tableno + a.tableno + '-' +b.descript1
			from sp_menu a, pos_tblsta b
--			where a.tableno = b.tableno and menu = @menu
-- 可以输入自定义台号
			where a.tableno *= b.tableno and menu = @menu
		end
	else

		begin
		select @ls_pccode =a.pccode, @ls_descript1 = b.descript1, @ls_descript2 = isnull(b.descript2, ''), @date0 = date0,@empno3 = empno3,
			@li_tables = @li_tables + a.tables, @li_guest = @li_guest + a.guest, @ls_tableno = @ls_tableno + a.tableno + '-' +b.descript1
			from sp_hmenu a, pos_tblsta b
--			where a.tableno = b.tableno and menu = @menu
-- 可以输入自定义台号
			where a.tableno *= b.tableno and menu = @menu
	end
	if charindex(@ls_pccode, @ls_pccodes) = 0
		select @ls_pccodes = @ls_pccodes + @ls_pccode + ',', @ls_descripts1 = @ls_descripts1 + @ls_descript1 + ','
	if @ls_descript2 <> ''
		select @ls_descripts2 = @ls_descripts2 + @ls_descript2 + ','
	end

if datalength(ltrim(@ls_pccodes)) > 0
	select @ls_pccodes = ltrim(substring(@ls_pccodes, 1, datalength(@ls_pccodes) - 1))
if datalength(ltrim(@ls_descript1)) > 0
	select @ls_descripts1 = ltrim(substring(@ls_descripts1, 1, datalength(@ls_descripts1) - 1))
if datalength(ltrim(@ls_tableno)) > 0
	select @ls_tableno = ltrim(substring(@ls_tableno, 1, datalength(@ls_tableno) - 1))
if datalength(ltrim(@ls_descripts2)) > 0
	select @ls_descripts2 = ltrim(substring(@ls_descripts2, 1, datalength(@ls_descripts2) - 1))

select @pcdes = descript from pos_pccode where pccode = @ls_pccode

update bill_data set char1=substring(@menus,1,50), char2=convert(char(9), @date0, 11)+convert(char(8), @date0, 8), char3=@ls_tableno, char4=convert(char(5),@li_guest)+'#'+convert(char(5),@li_tables), char5=@empno3,char6=rtrim(@pcdes)
 where pc_id = @pc_id
select * into #bill_data from bill_data where pc_id = @pc_id
delete bill_data where pc_id = @pc_id
insert into bill_data select * from #bill_data order by sort
return 0

;