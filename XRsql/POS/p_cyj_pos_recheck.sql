drop proc p_cyj_pos_recheck;
create proc p_cyj_pos_recheck
	@menu		char(10),
	@empno2	char(10) = ''
as
--------------------------------------------------------------------------------------
--
-- pos 重新结帐 : 追回重结
-- 转前台不用pccode用pos_pccode.chgcod
--	清空 pos_menu_bill.payamount, oddamount
-- 转前台时要判断是否采用接口方式
--------------------------------------------------------------------------------------
declare
	@paid						char(1),
	@current_menu			char(10),
	@empno					char(10),
	@menu_remark			char(20),
	@refer					char(20),
	@lastnum					integer,
	@nnumber					integer,
	@number					integer,
	@paycode					char(15),
	@shift					char(1),
	@pccode					char(3),
	@chgcod					char(5),
	@package					char(3),
	@tag1						char(3),
	@tag3						char(3),
	@amount					money,
	@amount1					money,
	@amount2					money,
	@amount3					money,
	@amount4					money,
	@amount5					money,
	@charge					money,
	@pc_id					char(4),
	@selemark				char(13),
	@accnt					char(20),
	@guestid					char(7),
	@bdate					datetime,
	@ret						integer,
   @msg						char(60),
	@count					integer,
	@pcrec					char(10),
	@menu_min				char(10),
	@remark					char(40),
	@option 					char(5),
	@sta	 					char(5),
	@postoption 			char(1),			--	是否采用pos_int_pccode
	@interface				char(10),			-- 是否采用接口方式
	@foliono					char(20),
	@quantity				money,
	@vipnumber				int,
	@hotelid					varchar(20),	-- 成员酒店号
	@log_date				datetime,		-- 服务器时间
	@vipbalance				money,
	@ref						char(20),
	@pcdes					varchar(32),
   @subaccnt   			int,						-- 用于AR帐的分帐号
	@credt_option			char(1),          -- 定金的核销方式，1 - 通过 Pos_dish 核销处理；否则传统的pos_pay处理
	@menu0					char(10),
	@inumber					integer,
	@bank						char(3),
	@lic_buy_1 				char(255),
	@lic_buy_2 				char(255),
	@accnt_bank				char(10),
	@package_1				char(1),				-- 是否用过package
	@posting_1				char(1)           -- 是否执行了自动转账

select @ret = 0 , @msg = '', @log_date = getdate()

select @interface = rtrim(ltrim(value)) from sysoption where catalog = 'pos' and item ='using_interface'
if @@rowcount = 0
select @interface = 'F'

select @lic_buy_1 = value from sysoption where catalog = 'hotel' and item = 'lic_buy.1'
select @lic_buy_2 = value from sysoption where catalog = 'hotel' and item = 'lic_buy.2'
select @credt_option = value from sysoption where catalog = 'pos' and item = 'res_credit_use'

begin tran
save  tran t_check
if exists(select 1 from pos_menu where menu = @menu and sta <> '3')
	begin
	select @ret = 1, @msg = '不是结账状态'
	goto gout
	end

select @pcrec = pcrec, @current_menu = menu, @menu_remark = remark, @shift = shift, @empno = empno3,
	@bdate = bdate, @pc_id = pc_id	from pos_menu where menu = @menu

if rtrim(ltrim(@pcrec)) <> null
	begin
	select @menu_min = min(menu) from pos_menu where pcrec = @pcrec
	declare c_menu cursor for
		select menu from pos_menu where pcrec =  @pcrec
	end
else
	begin
	select @menu_min = @menu
	declare c_menu cursor for
		select menu from pos_menu where menu = @menu
	end
-- 联单pccode去最小餐单的pccode，因为结账是的pccode就是取最小的
select @pccode = pccode, @package = ' ' + pccode from pos_menu where menu = @menu_min


declare c_pay cursor for
	select number, paycode, - amount, accnt, remark, foliono, - quantity,menu0,inumber,bank,sta from pos_pay
		where menu = @current_menu and charindex(sta, '23') >0 and charindex(crradjt, 'C #CO') = 0
open c_menu
fetch c_menu into @current_menu
while @@sqlstatus =0
	begin
	select @charge = 0

	if exists(select 1 from pos_tblav where menu = @current_menu and pos_tblav.inumber = 0)
		update pos_tblav set sta = '7' where menu = @current_menu and pos_tblav.inumber = 0
	else
		insert pos_tblav (menu, inumber,tableno, bdate, shift, sta, pcrec)
			select @current_menu,0,tableno,@bdate,@shift,'7', isnull(pcrec, '') from pos_menu where menu = @current_menu

	open c_pay
	fetch c_pay into @number, @paycode, @amount, @accnt,@remark, @foliono, @quantity,@menu0,@inumber,@bank,@sta
	while @@sqlstatus =0
		begin
		select @nnumber = max(number) + 1 from pos_pay where menu = @current_menu
		select @tag1 = deptno2 from pccode where pccode = @paycode
		select @accnt_bank = ''
		if exists(select 1 from sysoption where catalog ='ar' and item ='creditcard' and charindex(value,'TtYy')>0)
			begin
			if exists(select 1 from bankcard where pccode = @paycode)        -- 付款码判断是否自动转ar
				and (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
				begin
				if @bank is null or @bank =''
					select @bank = min(bankcode) from bankcard where pccode = @paycode
				select @accnt_bank = accnt from bankcard where pccode = @paycode and bankcode = @bank
				end
			end
		if rtrim(@accnt) is not null and (@tag1 like "TO%" or @accnt_bank >'')  and charindex(rtrim(@interface), 'NnFf')>0
			begin
			select @guestid = isnull(substring(@remark, charindex('-', @remark) + 1, 7), '')
			if rtrim(@guestid) is null
				select @subaccnt = 1
			else
				begin
				select @subaccnt = subaccnt from subaccnt where type = "5" and accnt = @accnt and haccnt = @guestid
				if @@rowcount = 0
					select @subaccnt = 1
				end
-----处理餐厅和费用码一对多时的转前台问题, pos_int_pccode.class='2' 为 费用码对照记录
			select @postoption = rtrim(value) from sysoption where catalog = 'pos' and item = 'using_pos_int_pccode'
			if charindex(rtrim(@postoption), 'tTyY') > 0
				begin
				select @chgcod = pccode from pos_int_pccode where class ='2' and shift = @shift and pos_pccode = @pccode
				if rtrim(@chgcod) is null or @chgcod = ''
					begin
					select @ret = 1, @msg = '该餐厅('+@pccode+')<'+@shift+'班>对应的费用码没有定义'
					close c_pay
					close c_menu
					deallocate cursor c_pay
					deallocate cursor c_menu
					goto gout
					end
				end
-----处理餐厅和费用码一对多时的转前台问题, pos_int_pccode.class='2' 为 费用码对照记录

			if charindex('@',@remark) >0              -- 用过package
				select @package_1 = 'Y'
			else
				select @package_1 = 'N'
			if charindex('$',@remark) >0              -- 执行了自动转账
				select @posting_1 = 'Y'
			else
				select @posting_1 = 'N'

			select @option	 = 'IR' + @package_1 + @posting_1

			select @selemark = 'a' , @amount1= -1 * amount0,@amount2=-1 * dsc,@amount3=-1 * srv,@amount4=-1 * tax,@amount5=-1 * amount1 from pos_menu where menu = @current_menu
			exec @ret = p_gl_accnt_posting     @selemark, '04',@pc_id,3, @shift, @empno, @accnt,@subaccnt, @chgcod, '',1, @amount,@amount, @amount2,@amount3,@amount4,@amount5,@current_menu, '', @bdate, '', @guestid, @option, 0, '', @msg output
--			exec @ret = p_gl_accnt_posting     @selemark, '04',@pc_id,3, @shift, @empno, @accnt,@subaccnt, @chgcod, '',1, @amount,@amount1,@amount2,@amount3,@amount4,@amount5,@menu,@foliono, @today, '', @guestid, @option, 0, '', @msg out
			if @ret != 0
				begin
				select @ret = 1, @msg = rtrim(@msg) +'-cyj'
				goto gout
				end
			end
		insert into pos_pay(menu,number,inumber,paycode,accnt,roomno,foliono,amount,sta,crradjt,reason,empno,bdate,shift,log_date,remark, menu0, quantity)
			select menu,@nnumber,@number,paycode,accnt,roomno,foliono,- amount,sta,'CO',reason,@empno,@bdate,@shift,@log_date,remark, menu0, @quantity
			from pos_pay where menu = @current_menu and number = @number
		update pos_pay set crradjt = 'C ' where menu = @current_menu and number = @number

		-- 使用贵宾卡积分付款 
		if @tag1 = 'PTS'  
			begin
			select @hotelid = isnull((select value from sysoption where catalog = 'hotel' and item = 'hotelid'), '')
			select @ref = convert(char(10), @nnumber), @pcdes = rtrim(@pcdes) + ' - PosRechk'
			exec @ret = p_gds_vipcard_posting '', '04', @pc_id, 0, @shift, @empno, @foliono, @hotelid, @bdate, '-', @amount, @amount, 0, 0, 0, @quantity, '', @menu, @ref, @menu, @pcdes,'R', @ret output, @msg output
			end
		--如果是定金或其他券，处理pos_dish
		if rtrim(@menu0) >'' and @inumber > 0
			begin
			if exists(select 1 from pos_dish where menu = @menu0 and flag19<>'F')
				update pos_dish set flag19_use = '' where menu = @menu0 and flag19<>'F'
			else
				update pos_hdish set flag19_use = '' where menu = @menu0 and flag19<>'F'
			if @credt_option <> '1'     -- 传统定金在pos_pay中
				update pos_pay set menu0 = '',inumber=0 where menu = @menu0 and number = @inumber and sta ='1'
			end
		fetch c_pay into @number, @paycode, @amount, @accnt, @remark, @foliono, @quantity,@menu0,@inumber,@bank,@sta
		end
	close c_pay

	select @number = inumber, @charge = amount - dsc + srv + tax from pos_dish where menu = @current_menu and sta ='A'
	if @@rowcount = 1
		begin
		select @lastnum = lastnum from pos_menu where menu = @current_menu
		update pos_dish set sta = '1' where menu = @current_menu and inumber = @number
		insert pos_dish(menu,inumber,plucode,sort,id, code, number, name1, name2, unit, amount,dsc,srv,tax, special, sta, empno, bdate, remark)
			select menu, @lastnum + 1,plucode,sort,id, code, - number, name1, name2, unit, - amount,- dsc,  - srv, - tax, special, '2', @empno, bdate, remark
			from pos_dish where menu = @current_menu and inumber = @number
		update pos_dish set sta = '1' where menu = @current_menu and sta ='A'
		update pos_menu set amount = amount - @charge, lastnum = @lastnum + 1 where menu = @current_menu
		end
	--update pos_pay set menu0 = '', inumber = 0 where menu0 = @current_menu
	if exists(select 1 from pos_pay where menu0 = @current_menu and charindex(sta, '23') >0 and charindex(crradjt, 'C #CO') = 0)
		begin
		select @ret = 1, @msg = '包含的定金已经被冲预付，请撤消冲预付'
		goto gout
		end
	update pos_menu set setmodes = '*', paid = '0', sta = '5', empno3 = @empno, empno2 = @empno2 where menu = @current_menu
	update pos_menu set cby = @empno,changed = @log_date, logmark = logmark+ 1 where menu = @current_menu
	delete pos_detail_jie where menu = @current_menu
	delete pos_detail_dai where menu = @current_menu
	fetch c_menu into @current_menu
	end
close c_menu
deallocate cursor c_pay
deallocate cursor c_menu

--	清空现金付款和找零信息 pos_menu_bill.payamount, oddamount
update pos_menu_bill set payamount=0,oddamount=0 from pos_menu_bill a , pos_menu b where b.menu=@menu and (a.menu=b.menu or a.menu=b.pcrec)
gout:
if @ret <> 0
	rollback tran
commit t_check
select @ret, @msg;