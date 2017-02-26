if exists(select 1 from sysobjects where name='p_cyj_pos_checkout' and type ='P')
	drop proc p_cyj_pos_checkout;
create proc p_cyj_pos_checkout 
	@pc_id	char(4), 
	@modu_id	char(2), 
	@shift	char(1), 
	@empno	char(10), 
	@menus	char(255), 
   @retmode	char(1),
   @option  char(5),
	@ret			int  output,
	@msg			char(60) output
as
--------------------------------------------------------------------------------------------------------
-- 
--	POS 结帐 
--	结帐临时表pos_checkout中放零头和冲定金内容, 零头要插入pos_pay, 冲定金更新定金行的menu0,inumber
--	有零头修改pos_menu的srv, 否则 amount <> amount0 + srv - dsc + tax
-- 转前台时不用pccode 取用pos_pccode.chgcode, 或者通过pos_int_pccode取费用码
-- 转前台有两种模式：直转和接口方式 sysoption : pos, using_interface, 接口分foxhis,nofoxhis
--------------------------------------------------------------------------------------------------------
declare
	@menu			char(10), 
	@menu0		char(10), 
	@menu1		char(10), 
	@menu_min	char(10), 
	@pcrec		char(10), 
   @lastnum		integer, 
   @number		integer, 
   @inumber		integer, 
	@bdate		datetime,	 	            
	@today		datetime,	 	                
	@paycode		char(5), 		          
	@pccode		char(3),
   @chgcod     char(5), 		      
	@package		char(3), 		            
	@name1		varchar(20), 
	@name2		varchar(30), 
	@special		char(1), 
	@debit		money, 		          
   @credit		money, 		          
	@descript1	char(5), 
	@tag1			char(3), 
   @tag3       char(3),                   
	@toaccnt		char(20), 
	@accnt		char(10), 
	@guestid		char(7), 
	@roomno		varchar(20),
	@amount		money, 
	@amount0		money, 
	@selemark	char(27), 
	@ld_odd		money,		            
	@li_oddcode int,	              
	@plucode		char(2),                
	@code			char(6),                
	@sort			char(4),                
	@bkfpay		char(3),		                
	@bkfaccnt	char(7),
   @mode       char(3),
   @amount1    money,
   @amount2    money,		              
   @amount3    money,
   @amount4    money,
   @amount5    money,
   @reason     char(3),
   @subaccnt   int,						-- 用于AR帐的分帐号
   @foliono	   char(20),				-- 转前台时备注存入account.ref2
   @cardno	   char(20),				-- 卡号
 	@refer 		varchar(20), 
	@ipos 		int,
	@tmp_menus	char(255),
	@postoption	char(10),				-- 是否转前台时启用pos_int_pccode
	@interface	char(10),				-- 是否转前台时启用餐饮接口
	@quantity	money,
	@vipnumber	int, 
	@hotelid		varchar(20),			-- 成员酒店号 
	@log_date	datetime,				-- 服务器时间 
	@vipbalance	money,
	@ref			char(20),
	@pcdes		varchar(32),
	@exclpart 	char(8),
	@shift_menu	char(1),					-- 根据预设时段算出开单班别
	@date0		datetime,				-- 开单时间
	@sta			char(1),
	@sftoption	char(1),
	@credt_option	char(1),          -- 定金的核销方式，1 - 通过 Pos_dish 核销处理；否则传统的pos_pay处理
	@accnt_bank	char(10),				-- 信用卡对应的ar帐号
	@lic_buy_1 	char(255),
	@lic_buy_2 	char(255),
	@bank			char(10),
	@ref2			char(40),
	@ref2_a		char(50)

select @log_date = getdate()
select @bdate = bdate1 from sysdata
select @ret = 0, @msg = '结帐成功', @roomno='', @modu_id = '04', @tmp_menus = @menus

select @lic_buy_1 = value from sysoption where catalog = 'hotel' and item = 'lic_buy.1'
select @lic_buy_2 = value from sysoption where catalog = 'hotel' and item = 'lic_buy.2'
select @credt_option = value from sysoption where catalog = 'pos' and item = 'res_credit_use'
select @interface = rtrim(ltrim(value)) from sysoption where catalog = 'pos' and item ='using_interface'

begin tran
save tran p_cyj_pos_checkout_s

select @exclpart = exclpart from accthead 
if not rtrim(@exclpart) is null
	begin
	select @ret = 1, @msg = '正在稽核独占部分, 请稍候'
	goto loop1
	end

if exists(select 1 from pos_menu where charindex(menu, @menus) > 0 and sta ='3' )
	begin
	select @ret = 1, @msg = "结账单中有已结账"
	goto loop1
	end
if exists(select 1 from pos_menu where charindex(menu, @menus) > 0 and sta ='7' )
	begin
	select @ret = 1, @msg = "结账单中有已删除"
	goto loop1
	end

if datalength(rtrim(@menus)) / 11 <> (select count(1) from pos_menu where charindex(menu, @menus) > 0 and paid = '0')
	begin
	select @ret = 1, @msg = '主单号不存在, 或状态有误'
	goto loop1
	end

if exists(select code from pos_dish where charindex(menu, @menus) > 0 and charindex('r',  flag) > 0)
	begin
	select @ret = 1, @msg = '只有在所有计时项目停止后才能结帐'
	goto loop1
	end

-- 重算数据关系
declare c_menu cursor for
	select menu from pos_menu where charindex(menu,  @menus)>0
open c_menu
fetch c_menu into @menu
while @@sqlstatus = 0 
	begin
	exec p_cyj_pos_update_menu @pc_id,@menu,'S'
	fetch c_menu into @menu
	end
close c_menu
deallocate cursor c_menu

if charindex(@menus, '##') = datalength(@menus) - 1
	select @menu = substring(@menus, 1, charindex('##', @menus))
select @menu = substring(@menus, 1, 10)

update pos_menu set menu = menu where charindex(menu, @menus) > 0

delete pos_order  where charindex(menu, @menus) > 0  -- 清空点菜临时表

select @li_oddcode = convert(int,remark), @ld_odd = isnull(amount, 0) 
	from pos_checkout where pc_id = @pc_id and charindex(menu,  @menus)>0 and number = 0                                                    
if @@rowcount = 0 
	select @ld_odd = 0 
else
	begin
	select @name1 = name1,@name2 =name2, @special = special, @sort=sort,@code=code,@plucode = plucode from pos_plu_all where id = @li_oddcode
	if @@rowcount = 0
		begin
		select @ret = 1, @msg = '零头（或最低消费）代码“' + convert(char(10),@li_oddcode) + '”不存在'
		goto loop1
		end
	else if @special <> 'T'          
		begin
		select @ret = 1, @msg = '零头（或最低消费）代码“' + convert(char(10),@li_oddcode) + '”的类型不是特殊类'
		goto loop1
		end
	end

select @menu_min = min(menu) from pos_menu where charindex(menu, @menus)>0
select @pccode = pccode , @package = ' ' + pccode from pos_menu where menu = @menu_min
--select @chgcod = chgcod, @pcdes = descript from pos_pccode where pccode=@pccode
update pos_dish set menu = menu where charindex(menu, @menus) > 0
select @debit = isnull(sum(amount - dsc + srv + tax), 0) from pos_dish
 where charindex(menu, @menus) > 0  and charindex(sta,'03579')>0 and charindex(rtrim(code), 'YZ') = 0
									  
select @credit = isnull(sum(amount), 0) from pos_pay
 where charindex(menu, @menus) > 0 and charindex(sta , '23' ) > 0 and charindex(crradjt, 'C CO') = 0
if round(@debit + @ld_odd, 2) <> round(@credit, 2)
	begin
	select @ret = 1, @msg = '借'+convert(char(10),@debit+@ld_odd)+'贷'+convert(char(10),@credit)+'不平, 请检查!!'
	goto loop1
	end

-- 零头或定金																									
declare c_checkout cursor for
	select paycode, id, menu1, number, remark, amount
	from pos_checkout where charindex(menu,  @menus)>0  and pc_id = @pc_id
open c_checkout
fetch c_checkout into @paycode, @inumber, @menu0, @number, @toaccnt, @amount
while @@sqlstatus = 0 
	begin
	if @number = 0                  
		begin
		select @lastnum = lastnum + 1 from pos_menu where menu = @menu
		insert pos_dish(menu, inumber, plucode,id, sort, code, number, name1, name2, special, amount,dsc,srv,tax,sta, empno, bdate, date0, remark)
		select @menu, @lastnum, @plucode, @li_oddcode,@sort,@code, 1, @name1, @name2, @special, @amount,0,0,0,'A', @empno, @bdate, @log_date, '零头'
		update pos_menu set amount = amount + @ld_odd,lastnum = @lastnum where menu = @menu
		end
	
	fetch c_checkout into @paycode, @inumber, @menu0, @number, @toaccnt, @amount
	end

declare c_pay cursor for
	select paycode, number, remark, accnt, amount, foliono, quantity, cardno, bank,menu0,inumber, sta, ref
	from pos_pay where menu = @menu  and charindex(sta, '23') >0 and charindex(crradjt, 'C #CO') = 0
open c_pay
fetch c_pay into @descript1, @number, @toaccnt, @bkfaccnt, @amount, @foliono, @quantity, @cardno, @bank,@menu0,@inumber, @sta, @ref2
while (@@sqlstatus = 0)
	begin
	select @name1 =descript, @paycode = deptno1, @tag1 = deptno2,@tag3 = deptno4
		from pccode where pccode = @descript1 and argcode>'9'
	if @@rowcount = 0
		begin
		select @ret = 1, @msg = '付款代码“' + @descript1 + '”不存在!'
		goto loop1
		end
   --核销明细, 月饼票、定金等
	if exists(select 1 from pccode where rtrim(pos_item) in (select rtrim(code) from basecode where cat = 'plu_flag19') and pccode = @descript1)
		begin
		if rtrim(ltrim(@menu0)) <> null and @number > 0                     
			begin
			if exists(select 1 from pos_dish where menu = @menu0  and flag19 <>'F')
				update pos_dish set flag19_use = @menu where menu = @menu0 and flag19 <>'F'
			else	
				update pos_hdish set flag19_use = @menu where menu = @menu0  and flag19 <>'F'
			end
		else
			begin
			select @ret = 1, @msg = '【'+@name1+'】需要进行核销,必须选择核销明细'
			goto loop1
			end
		end
	if @credt_option <> '1' and @sta = '2' -- 使用过定金
		begin
		update pos_pay set menu0 = @menu, inumber = @number where menu = @menu0  and number = @inumber and sta ='1'
		end

	select @accnt_bank = ''
	if exists(select 1 from sysoption where catalog ='ar' and item ='creditcard' and charindex(value,'TtYy')>0)
		begin
		if exists(select 1 from bankcard where pccode = @descript1)        -- 付款码判断是否自动转ar
			and (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
			begin
			if @bank is null or @bank ='' 
				select @bank = min(bankcode) from bankcard where pccode = @descript1
	
			select @accnt_bank = accnt from bankcard where pccode = @descript1 and bankcode = @bank
			if rtrim(@accnt_bank) is null
				begin
				select @ret = 1, @msg = @descript1 + ' 没有转账账号'
				goto loop1
				end
			if rtrim(@toaccnt) is  null          -- 没有转账帐号，赋值
				begin
				select @toaccnt  = substring(@accnt_bank + space(10), 1, 10) + '-'
				update pos_pay set accnt = @accnt_bank where menu = @menu  and number = @number
				end
			end
		end

	if rtrim(@toaccnt) is  null and @tag1 like 'TO%'
		begin
		select @ret = 1, @msg = '没有转账账号!!'
		goto loop1
		end
	else if rtrim(@toaccnt) is not null and (@tag1 like 'TO%' or @accnt_bank >'') and charindex(rtrim(@interface), 'FfNn')>0
		begin
		select @selemark = 'a', @today = @log_date,@mode=mode,@amount1=amount0,@amount2=dsc,@amount3=srv,@amount4=tax,@amount5=amount1 from pos_menu where menu = @menu
		if @amount2 > 0 
			select @reason = min(reason) from pos_dish where menu=@menu and dsc > 0
		select @accnt = substring(@toaccnt, 1, charindex('-', @toaccnt) - 1), @guestid = isnull(substring(@toaccnt, charindex('-', @toaccnt) + 1, 7), '')
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
			select @sftoption = rtrim(value) from sysoption where catalog = 'pos' and item = 'posting_front_shift'
			if charindex(rtrim(@sftoption), 'tTyY') > 0
				begin
				select @date0 = date0 from pos_menu where menu = @menu
				if not exists(select 1 from pos_int_pccode where class='2' and pos_pccode = @pccode and @date0 >convert(datetime, convert(char(10),@date0, 10)+' '+ start_time) and start_time is not null)
					select @shift_menu = max(shift) from pos_int_pccode where class='2' and pos_pccode = @pccode
				else
					select @shift_menu = shift from pos_int_pccode where class='2' and pos_pccode = @pccode
						and @date0 >convert(datetime, convert(char(10),@date0, 10)+' '+ start_time)
						and @date0 <=convert(datetime, convert(char(10),@date0, 10)+' '+ end_time)
				end
			if rtrim(@shift_menu) is null
				select @shift_menu = @shift

			select @chgcod = ''
			select @chgcod = pccode from pos_int_pccode where class ='2' and shift = @shift_menu and pos_pccode = @pccode
			if rtrim(@chgcod) is null or @chgcod = '' 
				select @chgcod = pccode from pos_int_pccode where class ='2' and ltrim(rtrim(shift)) = null and pos_pccode = @pccode

			if rtrim(@chgcod) is null or @chgcod = '' 
				begin
				select @ret = 1, @msg = '该餐厅('+@pccode+')<'+@shift_menu+'班>对应的费用码没有定义'
				goto loop1
				end
			end
		-----处理餐厅和费用码一对多时的转前台问题, pos_int_pccode.class='2' 为 费用码对照记录
		if not exists(select 1 from pccode where pccode = @chgcod)
			begin
			select @ret = 1, @msg = '不存在费用码' + @chgcod
			goto loop1
			end
		select @ref2_a = rtrim(@foliono) + rtrim(@ref2)
		exec @ret = p_gl_accnt_posting @selemark, @modu_id, @pc_id,3, @shift, @empno, @accnt,@subaccnt, @chgcod, '',1, @amount,@amount1,@amount2,@amount3,@amount4,@amount5,@menu,@ref2_a, @today, '', @guestid, @option, 0, '', @msg out
		if @ret != 0
			goto loop1
		else
			begin
			select @roomno = roomno from master where accnt = @accnt
			if @@rowcount = 0
				select @roomno = ''
			else
				select @roomno = @roomno + '-' + @toaccnt, @name1 = @name1 + '(' + @roomno + ')'
			end
		end
					 
-- 联单设置setmode  cyj 05.03.24
	if exists(select 1 from pos_menu where charindex(menu, @menus)>0 and substring(setmodes, 1, 1) ='*')
		update pos_menu set setmodes = '*' + @descript1  where charindex(menu, @menus)>0
	else
		update pos_menu set setmodes = @descript1  where charindex(menu, @menus)>0

	if substring(@option, 3, 1) = 'Y'
		update pos_pay set remark  = rtrim(remark) + '@' where menu = @menu and number = @number
	if substring(@option, 4, 1) = 'Y'
		update pos_pay set remark  = rtrim(remark) + '$' where menu = @menu and number = @number

	-- 使用贵宾卡积分付款
	if @tag1 = 'PTS' 
		begin
		select @hotelid = isnull((select value from sysoption where catalog = 'hotel' and item = 'hotelid'), '')
		select @ref = convert(char(10), @number), @pcdes = rtrim(@pcdes) + ' - Pos'
		exec @ret = p_gds_vipcard_posting '', '04', @pc_id, 0, @shift, @empno, @cardno, @hotelid, @bdate, '-', @amount, @amount, 0, 0, 0, @quantity, '', @menu, @ref, @menu, @pcdes,'R', @ret output, @msg output
		end
	   
	fetch c_pay into @descript1, @number, @toaccnt, @bkfaccnt, @amount, @foliono, @quantity, @cardno, @bank,@menu0,@inumber, @sta, @ref2
	end
close c_pay
deallocate cursor c_pay


-- 联单备注
while datalength(rtrim(@tmp_menus)) > 11
	begin
		select @menu1 = substring(@tmp_menus, 12, 10)
		select @amount = isnull(sum(amount), 0) from pos_dish
			where menu = @menu1 and not code like ' %' and charindex(sta,'03579')>0
		update pos_menu set remark = @menu + '---合并' + remark
			where menu = @menu1
		select @tmp_menus = substring(@tmp_menus, 12, datalength(@tmp_menus) - 11)
	end

select @refer = isnull(rtrim(remark), '') from pos_menu where menu = @menu
select @ipos = charindex('|', @refer)
if @ipos > 0 
	select @refer = substring(@refer, 1, @ipos - 1)
if @roomno <> ''
	select @refer = @refer + '|' + @roomno

update pos_menu set sta = '3', paid = '1', empno3 = @empno,empno2 = @empno, shift = @shift, remark=@refer
 where charindex(menu, @menus)>0
update pos_menu set logmark = isnull(logmark,0)+1,cby=@empno,changed=getdate()  where charindex(menu, @menus)>0 

delete pos_tblav where charindex(menu,@menus)>0
delete from pos_tblav where menu in(select resno from pos_menu where charindex(menu,@menus)>0 )   -- xia add 否则两个分别有预订号的，联单结账后，桌号餐位图看不到其中一桌了20080724


loop1:
if @ret <> 0 
   rollback tran p_cyj_pos_checkout_s
commit tran

delete herror_msg where pc_id=@pc_id and modu_id=@modu_id
insert herror_msg(pc_id,modu_id,ret,msg) values (@pc_id,@modu_id,@ret,@msg+@toaccnt)

if @retmode <> 'R'
   select @ret, @msg
return @ret;