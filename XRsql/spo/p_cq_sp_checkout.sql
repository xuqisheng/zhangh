drop  proc p_cq_sp_checkout;
create proc p_cq_sp_checkout
	@pc_id	char(4),
	@modu_id	char(2),
	@shift	char(1),
	@empno	char(10),
	@menus	char(255),
	@menu		char(10),
   @retmode	char(1),
   @option  char(5),
	@ret			int  output,
	@msg			char(60) output
as
declare
	--@menu			char(10),
	@sp_menus	char(255),
	@menu0		char(10),
	@menu1		char(10),
   @lastnum		integer,
   @lastnum1	integer,
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
	@toaccnt		char(15),
	@accnt		char(10),
	@guestid		char(7),
	@roomno		varchar(20),
	@amount		money,
	@amount0		money,
	@selemark	char(13),
	@lastnumb	integer,
	@ld_odd		money,
	@li_oddcode int,
	@plucode		char(2),
	@code			char(6),
	@sort			char(4),
	@bkfpay		char(5),
	@bkfaccnt	char(7),
   @mode       char(3),
   @amount1    money,
   @amount2    money,
   @amount3    money,
   @amount4    money,
   @amount5    money,
   @reason     char(3),
   @subaccnt   int,
	@cardno		char(10),
	@sdate		datetime,
	@edate		datetime,
	@remark		char(50),
	@accnt_bank	char(10),				-- 信用卡对应的ar帐号
	@lic_buy_1 	char(255),
	@lic_buy_2 	char(255),
	@bank			char(10),
	@foliono	   char(50)	,			-- 转前台时备注存入account.ref2
	@quantity	money,
	@ref			char(50)

select @sp_menus = @menus
select @bdate = bdate1 from sysdata
select @ret = 0, @msg = '结帐成功', @roomno='', @modu_id = '04'

select @lic_buy_1 = value from sysoption where catalog = 'hotel' and item = 'lic_buy.1'
select @lic_buy_2 = value from sysoption where catalog = 'hotel' and item = 'lic_buy.2'

if exists(select * from accthead where  exclpart <> '' and exclpart is not null)
   begin
	select @ret = 1
	goto loop1
	end
begin tran
save tran p_cq_sp_checkout_s
--if charindex(@menus, '##') = datalength(@menus) - 1
--	select @menu = substring(@menus, 1, charindex('##', @menus))
--select @menu = substring(@menus, 1, 10)
update sp_menu set menu= menu where charindex(menu, @menus) > 0
if datalength(rtrim(@menus)) / 11 <> (select count(1) from sp_menu where charindex(menu, @menus) > 0 and paid = '0')
	select @ret = 1, @msg = '主单号不存在, 或状态有误'
else if exists(select code from sp_dish where charindex(menu, @menus) > 0 and charindex('r',  flag) > 0)
	select @ret = 1, @msg = '只有在所有计时项目停止后才能结帐'
else
	begin
	select @li_oddcode = convert(int,remark), @ld_odd = isnull(amount, 0)
		from pos_checkout where pc_id = @pc_id and menu= @menu and number = 0
	if @@rowcount = 0
		select @ld_odd = 0
	else
		begin
		select @name1 = name1,@name2 =name2, @special = special, @sort=sort,@code=code,@plucode = plucode from pos_plu_all where id = @li_oddcode
		if @@rowcount = 0
			select @ret = 1, @msg = '零头（或最低消费）代码“' + convert(char(10),@li_oddcode) + '”不存在'
		else if @special <> 'T'
			select @ret = 1, @msg = '零头（或最低消费）代码“' + convert(char(10),@li_oddcode) + '”的类型不是特殊类'
		end
	if @ret = 0
		begin
		select @remark = remark from sp_menu where menu = @menu
		select @pccode = pccode , @package = ' ' + pccode from sp_menu where menu = @menu
      select @chgcod = chgcod from pos_pccode where pccode=@pccode
		update sp_dish set menu = menu where charindex(menu, @menus) > 0
		select @debit = isnull(sum(amount - dsc + srv + tax), 0) from sp_dish
		 where charindex(menu, @menus) > 0  and charindex(sta,'03579')>0 and charindex(rtrim(code), 'YZ') = 0

		select @credit = isnull(sum(amount), 0) from sp_pay
		 where charindex(menu, @menus) > 0 and charindex(sta , '23' ) > 0 and charindex(crradjt, 'C CO') = 0
		if round(@debit + @ld_odd, 2) <> round(@credit, 2)
			select @ret = 1, @msg = '借'+convert(char(10),@debit+@ld_odd)+'贷'+convert(char(10),@credit)+'不平, 请检查'
		end
	if @ret = 0
		begin

		declare c_checkout cursor for
			select paycode, id, menu1, number, remark, amount
			from pos_checkout where menu = @menu and pc_id = @pc_id
		open c_checkout
		fetch c_checkout into @paycode, @inumber, @menu0, @number, @toaccnt, @amount
		while @@sqlstatus = 0
			begin
			if @number = 0
				begin
				select @lastnum = lastnum + 1 from sp_menu where menu = @menu
				insert sp_dish(menu, inumber, plucode,id, sort, code, number, name1, name2, special, amount,dsc,srv,tax,sta, empno, bdate, date0, remark)
				select @menu, @lastnum, @plucode, @li_oddcode,@sort,@code, 1, @name1, @name2, @special, @amount,0,0,0,'A', @empno, @bdate, getdate(), '零头'
				update sp_menu set amount = amount + @ld_odd, srv = srv + @ld_odd, lastnum = @lastnum where menu = @menu
				end
			if rtrim(ltrim(@menu0)) <> null and @number > 0
				begin

				select @inumber = number from sp_pay where menu0 = menu0 and inumber = @number
				update sp_pay set menu0 = @menu, inumber = @inumber where menu = @menu0  and number = @number
				end
			fetch c_checkout into @paycode, @inumber, @menu0, @number, @toaccnt, @amount
			end
		end
	if @ret = 0
		begin
		declare c_pay cursor for
			select paycode, number, remark, accnt, amount, foliono, quantity, cardno, bank, ref
			from sp_pay where menu = @menu  and charindex(sta, '23') >0 and charindex(crradjt, 'C #CO') = 0
		open c_pay
		fetch c_pay into @descript1, @number, @toaccnt, @bkfaccnt, @amount, @foliono, @quantity, @cardno, @bank, @ref
		while (@@sqlstatus = 0)
			begin
			select @lastnum = lastnum + 1 from sp_menu where menu = @menu
			select @name1 =descript, @paycode = deptno1, @tag1 = deptno2,@tag3 = deptno4
				from pccode where pccode = @descript1 and pccode>'900'
			if @@rowcount = 0
				begin
				select @ret = 1, @msg = '付款代码“' + @descript1 + '”不存在!'
				break
				end

				--new ar
			if (select value from sysoption where catalog = 'ar' and item = 'creditcard') = 'T'
				begin
				select @accnt_bank = ''
				if exists(select 1 from bankcard where pccode = @descript1)        -- 付款码判断是否自动转ar
					and (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
					begin
					select @accnt_bank = accnt from bankcard where pccode = @descript1 and bankcode = @bank
					if rtrim(@accnt_bank) is null
						begin
						select @ret = 1, @msg = @descript1 + ' 没有转账账号'
						goto loop1
						end
					if rtrim(@foliono) is null
						select @foliono = '卡号:' + isnull(rtrim(@cardno), '') 
					else
						select @foliono = '卡号:' + isnull(rtrim(@cardno), '') 
					end
					select @remark = @foliono
				end
			   --------------------
			if rtrim(@toaccnt) is  null and @tag1 like 'TO%'
				begin
				select @ret = 1, @msg = '没有转账账号'
				goto loop1
				end
			else if rtrim(@toaccnt) is not null and (@tag1 like 'TO%'  or @accnt_bank >'')
				begin
				select @selemark = 'a' + menu , @today = getdate(),@mode=mode,@amount1=amount0,@amount2=dsc,@amount3=srv,@amount4=tax,@amount5=amount1 from sp_menu where menu = @menu
            if @amount2 > 0
               select @reason = min(reason) from sp_dish where menu=@menu and dsc > 0



				select @accnt = substring(@toaccnt, 1, charindex('-', @toaccnt) - 1), @guestid = isnull(substring(@toaccnt, charindex('-', @toaccnt) + 1, 7), '')
				if rtrim(@guestid) is null
					select @subaccnt = 0
				else
					begin
					select @subaccnt = subaccnt from subaccnt where type = "5" and accnt = @accnt and haccnt = @guestid
					if @@rowcount = 0
						select @subaccnt = 0
					end
					exec @ret = p_gl_accnt_posting @selemark, @modu_id, @pc_id,3, @shift, @empno, @accnt,@subaccnt, @chgcod, '',1, @amount,@amount1,@amount2,@amount3,@amount4,@amount5,@menu,@remark, @today, '', @mode, @option, 0, '', @msg out































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


			if rtrim(@toaccnt) is not null and @tag3 = 'BR'
				begin
				select @selemark = 'a' + menu , @today = getdate() from sp_menu where menu = @menu
				select @accnt = substring(@toaccnt, 1, 10), @guestid = isnull(substring(@toaccnt, 11, 7), '')

				if @ret != 0
					break
				else
					begin
					select @roomno = roomno from master where accnt = @accnt
					if @@rowcount = 0
						select @roomno = ''
					else
						select @roomno = @roomno + '-' + @toaccnt, @name1 = @name1 + '(' + @roomno + ')'
					end
				end


			if rtrim(@bkfaccnt) is not null and @descript1 = @bkfpay
				begin
				select @amount0 = amount0 - amount1 from room_bkf where accnt = @bkfaccnt and bdate = @bdate
				if @@rowcount = 0
					begin
					select @amount0 = sum(amount0 - amount1) from room_bkf where groupno = @bkfaccnt and bdate = @bdate
					if @@rowcount = 0
						select @ret = 1, @msg = '账号有误'
					declare  c_bkf_group cursor for select accnt from room_bkf where groupno = @bkfaccnt and bdate= @bdate
					open c_bkf_group
					fetch c_bkf_group into @accnt
					while @@sqlstatus = 0 and @amount > 0
						begin
						if exists(select 1 from room_bkf where  accnt = @accnt and bdate =@bdate and  amount0 = amount1 )
							begin
							fetch c_bkf_group into @accnt
							continue
							end
						if exists(select 1 from room_bkf where  accnt = @accnt and bdate = @bdate and @amount > amount0 - amount1 )
							begin
							update room_bkf set amount1 = amount0 where accnt = @accnt and bdate = @bdate
							select @amount = @amount - amount0 from room_bkf where  accnt = @accnt and bdate = @bdate
							end
						else
							begin
							update room_bkf set amount1 = amount1 + @amount where accnt = @accnt and bdate = @bdate
							select @amount = 0
							end
						fetch c_bkf_group into @accnt
						end
					close c_bkf_group
					deallocate cursor c_bkf_group
					end
				if @amount > @amount0
					select @ret = 1, @msg = '早餐费超支'+convert(char(10), @amount - @amount0)
				update room_bkf set amount1 = amount1 + @amount where accnt = @bkfaccnt and bdate = @bdate
				end

			update sp_menu set setmodes = @descript1 + char(ascii(setmodes) - ascii(setmodes) + ascii('*')), lastnum = @lastnum
			 where menu = @menu
			fetch c_pay into @descript1, @number, @toaccnt, @bkfaccnt, @amount, @foliono, @quantity, @cardno, @bank, @ref
			end
		close c_pay
		deallocate cursor c_pay
		select @lastnum = lastnum from sp_menu where menu = @menu
		update sp_menu set sta = '3', paid = '1', empno3 = @empno, remark = @menu + '---合并' + remark
				where charindex(menu,@menus) > 0 and menu <> @menu

		if @ret = 0
			begin

			declare @refer varchar(20), @ipos int
			select @refer = isnull(rtrim(remark), '') from sp_menu where menu = @menu
			select @ipos = charindex('|', @refer)
			if @ipos > 0
				select @refer = substring(@refer, 1, @ipos - 1)
			if @roomno <> ''
				select @refer = @refer + '|' + @roomno

			update sp_menu set sta = '3', paid = '1', empno3 = @empno, lastnum = @lastnum, remark=@refer
			 where menu = @menu
			delete pos_tblav where menu=@menu
			select @ret = 0
			end
		end
	if (select count(1) from sp_menu where charindex(menu,@sp_menus) > 0) > 1 
		update sp_menu set pcrec = @menu where charindex(menu,@sp_menus) > 0
	--exec p_cyj_bar_pos_check_sale @menus
end
                                                                                                          
                                                                  
                                                                   


loop1:
if @ret <> 0
   rollback tran p_cq_sp_checkout_s
else
   begin

   delete herror_msg where pc_id=@pc_id and modu_id=@modu_id
   insert herror_msg(pc_id,modu_id,ret,msg) values (@pc_id,@modu_id,@ret,@msg+@toaccnt)
   end
commit tran
if @retmode <> 'R'
   select @ret, @msg
return @ret

;