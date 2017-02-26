
/* 
	SPO 结帐 

*/

if exists(select * from sysobjects where name = 'p_cyj_spo_checkout' and type = 'P')
	drop proc p_cyj_spo_checkout;

create proc p_cyj_spo_checkout
	@pc_id	char(4), 
	@modu_id	char(2), 
	@shift	char(1), 
	@empno	char(3), 
	@menus	char(255), 
   @retmode	char(1)
as
declare
	@menu			char(10), 
	@menu1		char(10), 
   @ret			integer, 
   @msg			char(60), 
   @lastnum		integer, 
   @lastnum1	integer, 
   @number		integer, 
	@bdate		datetime,	 	/*营业日期*/
	@today		datetime,	 	/*帐务发生时间*/
	@paycode		char(3), 		/*内部码*/
	@pccode		char(3), 		/*营业厅码*/
	@package		char(3), 		/*包价代码*/
	@name1		varchar(20), 
	@name2		varchar(30), 
	@special		char(1), 
	@debit		money, 		/* 借方 */
   @credit		money, 		/* 贷方 */
	@descript1	char(3), 
	@tag1			char(3), 
	@remark		char(15), 
	@accnt		char(7), 
	@guestid		char(7), 
	@roomno		varchar(20),
	@amount		money, 
	@selemark	char(13), 
	@lastnumb	integer, 
	@inbalance	money,
	@cardno		char(7),
	@sdate		datetime,
	@edate		datetime
	

select @bdate = bdate1 from sysdata
select @ret = 0, @msg = '结帐成功', @roomno=''
/*	重算借方数 */
//exec p_gh_pos_update_master @menus, 'YES'

/* 事务开始   */
begin tran
save tran p_cyj_spo_checkout_s
select @menu = substring(@menus, 1, 10)
update pos_menu set menu = menu where charindex(menu, @menus) > 0
if datalength(rtrim(@menus)) / 11 <> (select count(1) from pos_menu where charindex(menu, @menus) > 0 and paid = '0')
	select @ret = 1, @msg = '主单号不存在, 或状态有误'
else if exists(select code from pos_dish where charindex(menu, @menus) > 0 and charindex('～',  remark) > 0)
	select @ret = 1, @msg = '只有在所有计时项目停止后才能结帐'
//else if exists(select 1 from pos_dish where charindex(menu,@menus)>0 // gds 
//	and charindex(sta,'0357')>0 and hx_tag>0 and (not exists(select 1 from pos_hxsale where pos_dish.menu=pos_hxsale.menu and pos_dish.id=pos_hxsale.id)))
//	select @ret = 1, @msg = '有海鲜菜没有输入明细配菜 !'
else
	begin
   select @pccode = pccode + 'A', @package = ' ' + pccode from pos_menu where menu = @menu
   update pos_dish set menu = menu where charindex(menu, @menus) > 0
	select @debit = isnull(sum(amount), 0) from pos_dish
	 where charindex(menu, @menus) > 0 and not code like ' %' and charindex(sta,'0357')>0
   select @debit = @debit + isnull(sum(amount), 0) from pos_checkout where pc_id = @pc_id and menu = @menu and paycode is null
   /*	读取现付款金额, 进行判断*/
	select @credit = isnull(sum(amount), 0) from pos_dish
	 where charindex(menu, @menus) > 0 and code like ' %'
   select @credit = @credit + isnull(sum(amount), 0) from pos_checkout where pc_id = @pc_id and menu = @menu and paycode is not null
   if @debit <> @credit 
      select @ret = 1, @msg = '借贷不平, 请检查'
   if @ret = 0
		begin
		declare c_checkout cursor for
//			select paycode, number, remark, amount, menu1 
			select paycode,  remark, amount, menu1 
			from pos_checkout where pc_id = @pc_id and menu = @menu
		open c_checkout
//		fetch c_checkout into @descript1, @number, @remark, @amount, @menu1
		fetch c_checkout into @descript1, @remark, @amount, @menu1
		while (@@sqlstatus = 0)
			begin
      	if @descript1 is null
				// 抹零头
				begin
				select @name1 = name1,  @name2 = name2,  @special = special from pos_plu where pccode = substring(@pccode, 1, 2) and code = @remark
				if @@rowcount = 0
					begin
					select @ret = 1, @msg = '零头（或最低消费）代码“' + @remark + '”不存在'
	         	break
					end
				else if @special <> 'X'
					begin
					select @ret = 1, @msg = '零头（或最低消费）代码“' + @remark + '”的类型不是特殊类'
	         	break
					end
 				select @lastnum = lastnum + 1 from pos_menu where menu = @menu1
				insert pos_dish(menu, id, code, number, number0, number1, name1, name2, special, amount, amount0, amount1, sta, empno, bdate, date, remark)
				select @menu1, @lastnum, @remark, 1, 0, 0, @name1, @name2, @special, @amount, @amount, 0, 'A', @empno, @bdate, getdate(), ''
				update pos_menu set charge = charge + @amount, lastnum = @lastnum where menu = @menu1
				end
			else
				begin
 				select @lastnum = lastnum + 1 from pos_menu where menu = @menu
				select @name1 = descript2, @paycode = paycode, @tag1 = descript1
					from paymth where descript1 = @descript1
				if @@rowcount = 0
					begin
					select @ret = 1, @msg = '付款代码“' + @descript1 + '”不存在'
	         	break
					end
				// 付款
	      	if rtrim(@remark) is not null and @tag1 like 'TO%'
					begin
					select @selemark = 'a' + menu , @today = getdate() from pos_menu where menu = @menu
					select @accnt = substring(@remark, 1, 7), @guestid = isnull(substring(@remark, 9, 7), '')
				   exec @ret = p_gl_accnt_post_charge @selemark, 0, 0, @modu_id, @pc_id, @shift, @empno, @accnt, @guestid, '', @pccode, @package, @amount, NULL, @today, NULL, 'IN', 'R', '', 'I', @msg out
					if @ret != 0
						break
					else
						begin
						select @roomno = roomno from master where accnt = @accnt
						if @@rowcount = 0
							select @roomno = ''
						else
							select @roomno = @roomno + '-' + @remark, @name1 = @name1 + '(' + @roomno + ')'
						end
					end
				// 冲减预付款
//				else if @number != 0
//					begin
//					select @remark = '定金' + @remark
//					update pos_accredit set tag = '9', dish_menu = @menu, dish_id = @lastnum, 
//						empno2 = @empno, bdate2 = @bdate, shift2 = @shift, log_date2 = getdate()
//						where resno = @menu1 and number = @number
//					end
				insert pos_dish(menu, id, code, number, number0, number1, name1, amount, amount0, amount1, empno, bdate, date, remark)
					select @menu, @lastnum, ' ' + @paycode + @descript1 + @shift, 1, 0, 0, @name1, @amount, @amount, 0, @empno, @bdate, getdate(), @remark
				update pos_menu set setmodes = @descript1 + char(ascii(setmodes) - ascii(setmodes) + ascii('*')), lastnum = @lastnum
				 where menu = @menu
				end
//			fetch c_checkout into @descript1, @number, @remark, @amount, @menu1
			fetch c_checkout into @descript1, @remark, @amount, @menu1
			end
		close c_checkout
		deallocate cursor c_checkout
		select @lastnum = lastnum from pos_menu where menu = @menu
		while datalength(rtrim(@menus)) > 11
			begin
				select @menu1 = substring(@menus, 12, 10)
				select @lastnum1 = lastnum + 1, @lastnum = @lastnum + 1 from pos_menu where menu = @menu1
				select @amount = isnull(sum(amount), 0) from pos_dish
					where menu = @menu1 and not code like ' %' and charindex(sta,'0357')>0
				select @amount = @amount - isnull(sum(amount), 0) from pos_dish
					where menu = @menu1 and code like ' %'
				insert pos_dish(menu, id, code, number, number0, number1, name1, amount, amount0, amount1, sta, empno, bdate, date, remark)
					select @menu, @lastnum, '    ---' + @shift, 1, 0, 0, '合并结帐',  - @amount,  - @amount, 0, 'A', @empno, @bdate, getdate(), @menu1
				insert pos_dish(menu, id, code, number, number0, number1, name1, amount, amount0, amount1, sta, empno, bdate, date, remark)
					select @menu1, @lastnum1, '    ---' + @shift, 1, 0, 0, '合并结帐', @amount, @amount, 0, 'A', @empno, @bdate, getdate(), @menu
				update pos_menu set sta = '3', paid = '1', empno3 = @empno, remark = @menu + '---' + remark, lastnum = @lastnum1
					where menu = @menu1
---//		会费纪录标记已结
				update pos_tax set sta = '3' where menu = @menu1
				select @menus = substring(@menus, 12, datalength(@menus) - 11)
			end
		if @ret = 0
			begin
			// gds add 2001/06 
			declare @refer varchar(20), @ipos int
			select @refer = isnull(rtrim(refer), '') from pos_menu where menu = @menu
			select @ipos = charindex('|', @refer)
			if @ipos > 0 
				select @refer = substring(@refer, 1, @ipos - 1)
			if @roomno <> ''
				select @refer = @refer + '|' + @roomno

			update pos_menu set sta = '3', paid = '1', empno3 = @empno, lastnum = @lastnum, refer=@refer
			 where menu = @menu
			delete pos_tblav where menu=@menu
         delete pos_checkout where pc_id = @pc_id and menu = @menu
---//		会费纪录标记已结
			update pos_tax set sta = '3' where menu = @menu
			select @ret = 0
		   end
	   end
   end

// vipcard : arr , dep
select @cardno = cardno, @sdate = sdate, @edate = edate from pos_tax where charindex(menu, @menus ) > 0
update crdsta set arr = @sdate, dep = @edate where no = @cardno

if @ret <> 0 
   rollback tran p_cyj_spo_checkout_s
commit tran
if @retmode <> 'R'
   select @ret, @msg
return @ret
;
