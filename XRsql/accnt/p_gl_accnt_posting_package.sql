
if  exists(select * from sysobjects where name = 'p_gl_accnt_posting_package')
	drop proc p_gl_accnt_posting_package;

create proc p_gl_accnt_posting_package
	@pc_id				char(4), 
	@mdi_id				integer, 
	@modu_id				char(2), 
	@shift				char(1), 
	@empno				char(10), 
	@accnt				char(10), 
	@pccode				char(5) out, 
	@amount				money out, 
	@package_d			money	out,
	@package_c			money	out,
	@package_a			money	out,
	@bdate				datetime, 
	@log_date			datetime, 
	@ref1					char(10),			-- 单号 
	@ref2					varchar(50),		-- 摘要 
	@date					datetime, 
	@msg					varchar(60) out

as
-- 当前SQL有两个部分：一个用来将Package加入(由过房费时调用)；一个用来使用Package(由普通入账调用) 
declare
	@ret					integer, 
	@overflow			money,
	@log_time			char(8), 
	@caccnt				char(10), 
	@croomno				char(5),
	@ccode				char(8), 
	@pos_pccode			char(5), 
	@pcrec_pkg			char(10), 
	@rule_calc			char(10), 
	@roomno				char(5),
	@cpccodes			varchar(255),
	@pccodes				char(7),
	@deptno1				char(8),
	@lastinumb			integer, 
	@sequence			integer, 
	@cnumber				integer, 
	@cquantity			integer, 
	@camount				money,
	@ccredit				money,
	@ccharge				money,
	@rm_pccode			char(5),
	@rm_pccode_B		char(5),
	@rm_pccode_N		char(5),
	@rm_pccode_b		char(5),
	@rm_pccode_P		char(5),
	@bf_accnt			char(10),
	@bf_pccodes			varchar(255),
	@charge				money,
	@argcode				char(3),				-- 改编码(打印在账单的代码) 
	@groupno				char(10), 
	@lastnumb			integer,
	@balance				money,
	@catalog				char(3),
	@ref					char(24),			-- 费用描述 
	@floor				char(1),
	@packcode			varchar(5),			-- {package code ><} 
	@ref2_set			varchar(50)


select @ref2 = rtrim(@ref2), @overflow = @amount, @ret = 0, @log_time = convert(char(8), @log_date, 108), @pos_pccode = ''
select @pcrec_pkg = rtrim(pcrec_pkg), @roomno = roomno, @groupno = groupno, @catalog = market
	from master where accnt = @accnt
select @deptno1 = deptno1, @argcode = argcode, @ref = descript from pccode where pccode = @pccode
select @pccodes = '%' + rtrim(@pccode) + '%'
select @deptno1 = '%' + rtrim(@deptno1) + '*%'
select @rm_pccode = value from sysoption where catalog = 'audit' and item = 'room_charge_pccode'
select @rm_pccode_B = value from sysoption where catalog = 'audit' and item = 'room_charge_pccode_B'
select @rm_pccode_N = value from sysoption where catalog = 'audit' and item = 'room_charge_pccode_N'
select @rm_pccode_b = value from sysoption where catalog = 'audit' and item = 'room_charge_pccode_b'
select @rm_pccode_P = value from sysoption where catalog = 'audit' and item = 'room_charge_pccode_P'
if @ref2 is null
	select @ref2 = ''

begin tran
save tran p_gl_accnt_package_posting_s1
-- 房费
if @pccode = @rm_pccode or @pccode = @rm_pccode_B or @pccode = @rm_pccode_N or @pccode = @rm_pccode_b or @pccode = @rm_pccode_P
	begin
	declare c_package1 cursor for
		select b.accnt, b.pccodes, a.number, a.rule_calc, a.quantity, a.amount, a.credit, a.code 
			from rmpostpackage a, package b
			where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.accnt = @accnt and a.code = b.code
			order by number
	open c_package1
	fetch c_package1 into @bf_accnt, @bf_pccodes, @cnumber, @rule_calc, @cquantity, @camount, @ccredit, @packcode 
	while @@sqlstatus = 0
		begin
-- 外加的早餐也要反映到package_detail & 调整帐户
--		if @rule_calc like '0%'
--			begin
			-- 
			if not rtrim(@bf_pccodes) is null and rtrim(@bf_pccodes) <> '.'
				begin
				exec @ret = p_gl_accnt_update_balance @accnt, '', 0, 0, '', '', 0, @lastinumb out, 0, '', @msg out
				if @ret ! = 0
					goto RETURN_1
				if @ccredit = 0
					select @bf_pccodes = '.'
				insert package_detail (accnt, number, roomno, code, descript, descript1, pccodes, pos_pccode, bdate, starting_date, closing_date, starting_time, closing_time, quantity, credit, posted_accnt, posted_roomno, posted_number, tag)
					select @accnt, @lastinumb, roomno, code, descript, descript1, @bf_pccodes, pos_pccode, @bdate, starting_date, closing_date, starting_time, closing_time, @cquantity, @ccredit, @accnt, @roomno, @lastinumb, '0'
					from rmpostpackage where pc_id = @pc_id and mdi_id = @mdi_id and accnt = @accnt and number = @cnumber
				-- 如果存在调整账户，则将扣减的房费保存到早餐调整账户中
				if not rtrim(@bf_accnt) is null
					begin
					select @charge = - @camount
					exec @ret = p_gl_accnt_update_balance @bf_accnt, @pccode, @charge, 0, '', '', 
						@lastnumb out, 0, @balance out, '', @msg out
					if @ret ! = 0
						goto RETURN_1
					select @floor = substring(extra, 2, 1) from master where accnt = @accnt
					select @ref2_set = '{' + rtrim(@packcode) + '>} ' + @ref2
					insert account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
						quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
						crradjt, waiter, tag, reason, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, accntof)
						values(@bf_accnt, 0, @lastnumb, @lastnumb, @modu_id, @log_date, @bdate, @date, @pccode, @argcode, 
						@cquantity, @charge, 0, 0, 0, @charge, 0, 0, 0, 0, 0, @balance, @shift, @empno,
						'', '', @catalog, '', @ref, @ref1, @ref2_set, @roomno, @groupno, ' pkg_c   ' + @floor, '', 0, @accnt)
					end
				--
				select @package_c = @package_c + @ccredit, @package_a = @package_a + @camount
				end
--			end
		fetch c_package1 into @bf_accnt, @bf_pccodes, @cnumber, @rule_calc, @cquantity, @camount, @ccredit, @packcode 
		end
	close c_package1
	deallocate cursor c_package1
	end
else if @overflow > 0
	begin
	declare c_package2 cursor for
		select sequence = a.number, a.accnt, a.roomno, a.code, a.pccodes, a.pos_pccode, a.number, a.credit, a.charge, c.accnt, substring(b.extra, 2, 1), a.code 
			from package_detail a, master b, package c
			where b.pcrec_pkg = @pcrec_pkg and b.accnt != @accnt and b.accnt = a.accnt and a.tag < '2'
			and @log_date >= a.starting_date and @log_date <= a.closing_date
			and @log_time >= a.starting_time and @log_time <= a.closing_time
			and a.code = c.code
		union all
		select sequence = 0, a.accnt, a.roomno, a.code, a.pccodes, a.pos_pccode, a.number, a.credit, a.charge, c.accnt, substring(b.extra, 2, 1), a.code 
			from package_detail a, master b, package c
			where b.accnt = @accnt and b.accnt = a.accnt and a.tag < '2'
			and @log_date >= a.starting_date and @log_date <= a.closing_date
			and @log_time >= a.starting_time and @log_time <= a.closing_time
			and a.code = c.code
			order by sequence
	open c_package2
	fetch c_package2 into @sequence, @caccnt, @croomno, @ccode, @cpccodes, @pos_pccode, @cnumber, @ccredit, @ccharge, @bf_accnt, @floor, @packcode 
	while @@sqlstatus = 0 and @overflow != 0
		begin
		if @cpccodes = '*' or @cpccodes like @deptno1 or @cpccodes like @pccodes
			begin 
			exec @ret = p_gl_accnt_update_balance @caccnt, '', 0, 0, '', '', 0, @lastinumb out, 0, '', @msg out
			if @ret ! = 0
				goto RETURN_1
			if @ccredit - @ccharge > @overflow
				-- 一行没用完
				begin
				insert package_detail (accnt, number, roomno, code, descript, descript1, pccodes, bdate, starting_date, closing_date, starting_time, closing_time, charge, posted_accnt, posted_roomno, posted_number, tag)
					select @caccnt, @lastinumb, @croomno, @ccode, a.descript, a.descript1, @pccode, @bdate, @log_date, @log_date, @log_time, @log_time, @overflow, @accnt, @roomno, @cnumber, '9'
					from pccode a where a.pccode = @pccode
				if @@rowcount = 0
					begin
					select @ret = 1, @msg = 'Package_Detail表插入失败'
					goto RETURN_1
					end
				select @charge = @overflow
				-- 将扣减的房费保存到早餐调整账户中
				if not rtrim(@bf_accnt) is null
					begin
					exec @ret = p_gl_accnt_update_balance @bf_accnt, @pccode, @charge, 0, '', '', 
						@lastnumb out, 0, @balance out, '', @msg out
					if @ret ! = 0
						goto RETURN_1
					select @ref2_set = '{' + rtrim(@packcode) + '<}' + @ref2  + ' From ' + @roomno
					insert account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
						quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
						crradjt, waiter, tag, reason, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, accntof)
						values(@bf_accnt, 0, @lastnumb, @lastnumb, @modu_id, @log_date, @bdate, @date, @pccode, @argcode, 
						1, @charge, @charge, 0, 0, 0, 0, 0, 0, 0, 0, @balance, @shift, @empno,
						'', '', @catalog, '', @ref, @ref1, @ref2_set, @croomno, @groupno, ' pkg_d   ' + @floor, '', 0, @accnt)
					end
				--
				update package_detail set charge = charge + @overflow, tag = '1' where accnt = @caccnt and number = @cnumber
				select @overflow = 0
				end
			else
				-- 用完一行
				begin
				insert package_detail (accnt, number, roomno, code, descript, descript1, pccodes, bdate, starting_date, closing_date, starting_time, closing_time, charge, posted_accnt, posted_roomno, posted_number, tag)
					select @caccnt, @lastinumb, @croomno, @ccode, a.descript, a.descript1, @pccode, @bdate, @log_date, @log_date, @log_time, @log_time, @ccredit - @ccharge, @accnt, @roomno, @cnumber, '9'
					from pccode a where a.pccode = @pccode
				if @@rowcount = 0
					begin
					select @ret = 1, @msg = 'Package_Detail表插入失败'
					goto RETURN_1
					end
				-- 将扣减的房费保存到早餐调整账户中
				select @charge = @ccredit - @ccharge
				if not rtrim(@bf_accnt) is null
					begin
					exec @ret = p_gl_accnt_update_balance @bf_accnt, @pccode, @charge, 0, '', '', 
						@lastnumb out, 0, @balance out, '', @msg out
					if @ret ! = 0
						goto RETURN_1
					select @ref2_set = '{' + rtrim(@packcode) + '<}' + @ref2  + ' From ' + @roomno
					insert account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
						quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
						crradjt, waiter, tag, reason, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, accntof)
						values(@bf_accnt, 0, @lastnumb, @lastnumb, @modu_id, @log_date, @bdate, @date, @pccode, @argcode, 
						1, @charge, @charge, 0, 0, 0, 0, 0, 0, 0, 0, @balance, @shift, @empno,
						'', '', @catalog, '', @ref, @ref1, @ref2_set, @croomno, @groupno, ' pkg_d   ' + @floor, '', 0, @accnt)
					end
				--
				update package_detail set charge = credit, tag = '2' where accnt = @caccnt and number = @cnumber
				select @overflow = @overflow - (@ccredit - @ccharge)
				end
			if @@rowcount = 0
				begin
				select @ret = 1, @msg = 'Package_Detail表更新失败'
				goto RETURN_1
				end
			end
		else
			select @pos_pccode = ''
		fetch c_package2 into @sequence, @caccnt, @croomno, @ccode, @cpccodes, @pos_pccode, @cnumber, @ccredit, @ccharge, @bf_accnt, @floor, @packcode 
		end
	close c_package2
	deallocate cursor c_package2
	end
else
	begin
	declare c_package3 cursor for
		select sequence = a.number, a.accnt, a.roomno, a.code, a.pccodes, a.pos_pccode, a.number, a.credit, a.charge, c.accnt, substring(b.extra, 2, 1), a.code 
			from package_detail a, master b, package c
			where b.pcrec_pkg = @pcrec_pkg and b.accnt != @accnt and b.accnt = a.accnt and a.tag in ('1', '2')
			and @log_date >= a.starting_date and @log_date <= a.closing_date
			and @log_time >= a.starting_time and @log_time <= a.closing_time
			and a.code = c.code
		union all
		select sequence = 0, a.accnt, a.roomno, a.code, a.pccodes, a.pos_pccode, a.number, a.credit, a.charge, c.accnt, substring(b.extra, 2, 1), a.code 
			from package_detail a, master b, package c
			where b.accnt = @accnt and b.accnt = a.accnt and a.tag in ('1', '2')
			and @log_date >= a.starting_date and @log_date <= a.closing_date
			and @log_time >= a.starting_time and @log_time <= a.closing_time
			and a.code = c.code
			order by sequence
	open c_package3
	fetch c_package3 into @sequence, @caccnt, @croomno, @ccode, @cpccodes, @pos_pccode, @cnumber, @ccredit, @ccharge, @bf_accnt, @floor, @packcode 
	while @@sqlstatus = 0 and @overflow != 0
		begin
		if @cpccodes = '*' or @cpccodes like @deptno1 or @cpccodes like @pccodes
			begin 
			exec @ret = p_gl_accnt_update_balance @caccnt, '', 0, 0, '', '', 0, @lastinumb out, 0, '', @msg out
			if @ret ! = 0
				goto RETURN_1
			if @ccharge + @overflow > 0
				-- 一行没恢复完
				begin
				insert package_detail (accnt, number, roomno, code, descript, descript1, pccodes, bdate, starting_date, closing_date, starting_time, closing_time, charge, posted_accnt, posted_roomno, posted_number, tag)
					select @caccnt, @lastinumb, @croomno, @ccode, a.descript, a.descript1, @pccode, @bdate, @log_date, @log_date, @log_time, @log_time, @overflow, @accnt, @roomno, @cnumber, '9'
					from pccode a where a.pccode = @pccode
				if @@rowcount = 0
					begin
					select @ret = 1, @msg = 'Package_Detail表插入失败'
					goto RETURN_1
					end
				-- 将扣减的房费保存到早餐调整账户中
				select @charge = @overflow
				if not rtrim(@bf_accnt) is null
					begin
					exec @ret = p_gl_accnt_update_balance @bf_accnt, @pccode, @charge, 0, '', '', 
						@lastnumb out, 0, @balance out, '', @msg out
					if @ret ! = 0
						goto RETURN_1
					select @ref2_set = '{' + rtrim(@packcode) + '<}' + @ref2 + ' From ' + @roomno
					insert account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
						quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
						crradjt, waiter, tag, reason, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, accntof)
						values(@bf_accnt, 0, @lastnumb, @lastnumb, @modu_id, @log_date, @bdate, @date, @pccode, @argcode, 
						1, @charge, @charge, 0, 0, 0, 0, 0, 0, 0, 0, @balance, @shift, @empno,
						'', '', @catalog, '', @ref, @ref1, @ref2_set, @croomno, @groupno, ' pkg_d   ' + @floor, '', 0, @accnt)
					end
				--
				update package_detail set charge = charge + @overflow, tag = '1' where accnt = @caccnt and number = @cnumber
				select @overflow = 0
				end
			else
				-- 恢复完一行
				begin
				insert package_detail (accnt, number, roomno, code, descript, descript1, pccodes, bdate, starting_date, closing_date, starting_time, closing_time, charge, posted_accnt, posted_roomno, posted_number, tag)
					select @caccnt, @lastinumb, @croomno, @ccode, a.descript, a.descript1, @pccode, @bdate, @log_date, @log_date, @log_time, @log_time, - @ccharge, @accnt, @roomno, @cnumber, '9'
					from pccode a where a.pccode = @pccode
				if @@rowcount = 0
					begin
					select @ret = 1, @msg = 'Package_Detail表插入失败'
					goto RETURN_1
					end
				-- 将扣减的房费保存到早餐调整账户中
				select @charge = - @ccharge
				if not rtrim(@bf_accnt) is null
					begin
					exec @ret = p_gl_accnt_update_balance @bf_accnt, @pccode, @charge, 0, '', '', 
						@lastnumb out, 0, @balance out, '', @msg out
					if @ret ! = 0
						goto RETURN_1
					select @ref2_set = '{' + rtrim(@packcode) + '<}' + @ref2 + ' From ' + @roomno
					insert account(accnt, subaccnt, number, inumber, modu_id, log_date, bdate, date, pccode, argcode, 
						quantity, charge, charge1, charge2, charge3, charge4, charge5, package_d, package_c, package_a, credit, balance, shift, empno,
						crradjt, waiter, tag, reason, ref, ref1, ref2, roomno, groupno, mode, mode1, pnumber, accntof)
						values(@bf_accnt, 0, @lastnumb, @lastnumb, @modu_id, @log_date, @bdate, @date, @pccode, @argcode, 
						1, @charge, @charge, 0, 0, 0, 0, 0, 0, 0, 0, @balance, @shift, @empno,
						'', '', @catalog, '', @ref, @ref1, @ref2_set, @croomno, @groupno, ' pkg_d   ' + @floor, '', 0, @accnt)
					end
				--
				update package_detail set charge = 0, tag = '0' where accnt = @caccnt and number = @cnumber
				select @overflow = @overflow + @ccharge
				end
			if @@rowcount = 0
				begin
				select @ret = 1, @msg = 'Package_Detail表更新失败'
				goto RETURN_1
				end
			end
		else
			select @pos_pccode = ''
		fetch c_package3 into @sequence, @caccnt, @croomno, @ccode, @cpccodes, @pos_pccode, @cnumber, @ccredit, @ccharge, @bf_accnt, @floor, @packcode 
		end
	close c_package3
	deallocate cursor c_package3
	end
RETURN_1:
if @ret != 0
	begin
	select @overflow = @amount, @pos_pccode = ''
   rollback tran p_gl_accnt_package_posting_s1
	end
commit tran 
select @package_d = @amount - @overflow, @amount = @overflow
if @amount !=0 and @pos_pccode != ''
	select @pccode = @pos_pccode
return @ret
;
