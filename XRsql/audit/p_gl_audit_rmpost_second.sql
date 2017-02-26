
if  exists(select * from sysobjects where name = 'p_gl_audit_rmpost_second')
	drop proc p_gl_audit_rmpost_second;
create proc p_gl_audit_rmpost_second
	@modu_id				char(2), 
	@shift				char(1), 
	@empno				char(10), 
	@operation			char(1)				
as
-------------------------------------------------------------
-- 实过房租 
--
-- @operation  S:SELECT返回, 由w_gl_audit_rmpost调用
--					R:RETURN返回, 由w_gl_audit_auditprg调用 
-------------------------------------------------------------
declare
	@lic_buy_1			varchar(255),
	@lic_buy_2			varchar(255),
	@pc_id				char(4), 
	@mdi_id				integer, 
	@selemark			char(17), 
	@accnt				char(10), 
	@roomno				char(5), 
	@class				char(1), 
	@ratecode			char(10), 
	@today				datetime, 
	@rmpostdate			datetime, 
	@ret					integer, 
	@msg					varchar(60), 
	@quantity			money,
	@charge1				money, 
	@charge2				money, 
	@charge3				money, 
	@charge4				money, 
	@charge5				money, 
	@rtreason			char(3), 
	@package				char(10),
	@pccode				char(5),
	@argcode				char(3),
	@rmpccode			char(5),
	@column				integer,
	@count				integer,
	@amount				money,
	@rule_calc			char(10),
	@mode					char(10),
	@ref2					char(50), 
	@w_or_h				integer,
	--
	@srqs					char(18),
	@tranlog				char(10),
	@extrainf			char(30),
	@pos					integer,
	@ent1					integer,
	@ent2					integer,
	@errorlog			varchar(255),
	-- Tcr Cms 
	@groupno				char(10),
	@cusno				char(10),
	@agent				char(10),
	@source				char(10),
	@cmscode				char(10),
	@to_accnt			char(10),
	@setrate				money

select @shift = '3', @today = getdate(), @pc_id = '9999', @mdi_id = 0
select @rmpostdate = dateadd(dd, 1, rmpostdate) from sysdata
select @rmpccode = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccode'), '000')
select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
select @selemark = 'A' + convert(char(10), @rmpostdate, 111)
declare c_rmpostpackage cursor for
	select a.pccode, a.argcode, a.amount, a.quantity, a.rule_calc, ' ' + a.code, b.commission
	from rmpostpackage a, pccode b
	where a.pc_id = @pc_id and a.mdi_id = @mdi_id and a.accnt = @accnt and a.pccode = b.pccode order by a.number
declare c_rmpostbucket cursor for
	select a.accnt, a.roomno, a.class, a.groupno, a.ratecode, a.charge1 - a.charge2 + a.charge3 + a.charge4 + a.charge5,
	a.charge1, a.charge2, a.charge3, a.charge4, a.charge5,a.setrate, a.w_or_h, a.rtreason
	from rmpostbucket a where a.rmpostdate = @rmpostdate and a.posted != 'T' order by a.roomno, a.accnt
open c_rmpostbucket
fetch c_rmpostbucket into @accnt, @roomno, @class, @groupno, @ratecode, @amount, @charge1, @charge2, @charge3, @charge4, @charge5,@setrate, @w_or_h, @rtreason
while @@sqlstatus = 0
	begin
	begin tran 
	save tran p_gl_audit_rmpost_second_s1
	if @w_or_h = 1
		select @mode = 'J' + @roomno, @quantity = 1
	else
		select @mode = 'j' + @roomno, @quantity = 0.5
	select @ret = 0, @ref2 = substring(@roomno + space(5), 1, 5) + '(' + convert(char(10), @rmpostdate, 111) + ')'
--	if @accnt like 'A%' and (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
--		begin
--		select @msg = substring(b.name + space(50), 1, 50) + b.name2 from ar_master a, guest b
--			where a.accnt = @accnt and a.haccnt = b.no
--		exec @ret = p_gl_ar_posting @selemark, @modu_id, @pc_id, @mdi_id, @shift, @empno, @accnt, 0, @rmpccode, '', 
--			@quantity, @amount, @charge1, @charge2, @charge3, @charge4, @charge5, @ratecode, @ref2, @rmpostdate, @rtreason, @mode, 'IRYY', 0, @to_accnt out, @msg out
--		end
--	else
	-- 只有有房号的guest才入房费
	if @class = 'F'
		exec @ret = p_gl_accnt_posting @selemark, @modu_id, @pc_id, @mdi_id, @shift, @empno, @accnt, 0, @rmpccode, '', 
			@quantity, @amount, @charge1, @charge2, @charge3, @charge4, @charge5, @ratecode, @ref2, @rmpostdate, @rtreason, @mode, 'IRYY', 0, @to_accnt out, @msg out
	else
		select @amount = 0

	-- Tcr Cms
	if @groupno <> ''
		select @cmscode = cmscode, @cusno = cusno, @agent = agent, @source = source from master where accnt = @groupno
	else
		select @cmscode = cmscode, @cusno = cusno, @agent = agent, @source = source from master where accnt = @accnt

	if rtrim(@cmscode) is not null and @amount > 0
	begin
		if @accnt <> @to_accnt and @to_accnt is not null and @to_accnt <> ''
			insert cms_rec(auto, accnt, name, number, type, roomno, cusno, agent, source, arr, dep, rmrate, exrate, dsrate, rmsur, rmtax,
								w_or_h, mode, ratecode, cmscode, cmsunit, cmstype, cmsvalue, cms0, cms, ref, bdate, post, postdate, cby, changed, market, to_accnt, logmark)
				select 'T', @accnt,  b.name, c.lastnumb, a.type, a.roomno,  @cusno, @agent, @source, a.arr, a.dep, @setrate,  0, -1 * @charge2, @charge3, 0, 
						@quantity,  @mode, a.ratecode, @cmscode, '', '', 0, 0, 0, @groupno, @rmpostdate, @empno, getdate(), @empno, getdate(), a.market, @to_accnt, 0
				from master a, guest b, master c where a.accnt = @accnt and c.accnt = @to_accnt and a.haccnt = b.no
		else
			insert cms_rec(auto, accnt, name, number, type, roomno, cusno, agent, source, arr, dep, rmrate, exrate, dsrate, rmsur, rmtax, 
								w_or_h, mode, ratecode, cmscode, cmsunit, cmstype, cmsvalue, cms0, cms, ref, bdate, post, postdate, cby, changed, market, to_accnt, logmark)
				select 'T', @accnt,  b.name, a.lastnumb, a.type, a.roomno,  @cusno, @agent, @source, a.arr, a.dep, @setrate,  0, -1 * @charge2, @charge3, 0, 
						@quantity,  @mode, a.ratecode, @cmscode, '', '', 0, 0, 0, @groupno, @rmpostdate, @empno, getdate(), @empno, getdate(), a.market, @accnt, 0 
				from master a, guest b where accnt = @accnt and a.haccnt = b.no
	end 

	-- Cms
	if @ret = 0
		begin
		-- 将Package需要反映在Account中的费用入帐
		open c_rmpostpackage
		fetch c_rmpostpackage into @pccode, @argcode, @amount, @quantity, @rule_calc, @package, @column
		while @@sqlstatus = 0
			begin
			if @rule_calc like '1%'
				begin
				select @msg = '', @charge1 = 0, @charge2 = 0, @charge3 = 0, @charge4 = 0, @charge5 = 0
				if @column = 2
					select @charge2 = - @amount
				else if @column = 3
					select @charge3 = @amount
				else if @column = 4
					select @charge4 = @amount
				else if @column = 5
					select @charge5 = @amount
				else
					select @charge1 = @amount
				--
				if @accnt like 'A%' and (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
					begin
					select @msg = substring(b.name + space(50), 1, 50) + b.name2 from ar_master a, guest b
						where a.accnt = @accnt and a.haccnt = b.no
					exec @ret = p_gl_ar_posting @selemark, @modu_id, @pc_id, @mdi_id, @shift, @empno, @accnt, 0, @pccode, @argcode, 
						@quantity, @amount, @charge1, @charge2, @charge3, @charge4, @charge5, @ratecode, @ref2, @rmpostdate, @rtreason, @package, 'IRNY', 0, null, @msg out
					end
				else
					exec @ret = p_gl_accnt_posting @selemark, @modu_id, @pc_id, @mdi_id, @shift, @empno, @accnt, 0, @pccode, @argcode, 
						@quantity, @amount, @charge1, @charge2, @charge3, @charge4, @charge5, @ratecode, @ref2, @rmpostdate, @rtreason, @package, 'IRNY', 0, null, @msg out
				end
			if @ret != 0
				break
			fetch c_rmpostpackage into @pccode, @argcode, @amount, @quantity, @rule_calc, @package, @column
			end
		close c_rmpostpackage
		-- HZDS GaoLiang 1999/10/21 
--		select @srqs = srqs, @tranlog = tranlog from master where accnt = @accnt
--		if charindex('VV', @srqs) > 0
--			begin
--			if exists(select 1 from rmpostvip where pc_id = @pc_id and cusid = @tranlog and charindex(@accnt, accnts) > 0)
--				begin
--				select @pos = charindex('VV', @srqs)
--				update master set srqs = substring(@srqs, 1, @pos - 1) + substring(@srqs, @pos + 4, 18), logmark = logmark + 1 where accnt = @accnt
--				select @ent1 = number1, @ent2 = number2 from rmpostvip where pc_id = @pc_id and cusid = @tranlog
--				select @extrainf = extrainf from cusdef where cusid = @tranlog
--				select @pos = charindex('|', @extrainf)
----				if @pos = 0
----					select @pos = 1
--				update cusdef set extrainf = rtrim(convert(char(5), @ent1)) + '/' + rtrim(convert(char(5), @ent2)) + substring(@extrainf, @pos, 30)
--					where cusid = @tranlog
--				end
--			end
		if @ret = 0
			begin
			update rmpostbucket set posted = 'T', empno = @empno, shift = @shift, date = getdate()
				where rmpostdate = @rmpostdate and accnt = @accnt and posted != 'T'
			update master set rmposted = 'T', rmpoststa = '1' where accnt = @accnt
			if @@rowcount = 0
				update ar_master set rmposted = 'T', rmpoststa = '1' where accnt = @accnt
			end
		end
	if @ret != 0
		begin
		select @errorlog = @errorlog + '[' + @accnt + ']' + @msg + ' '
		rollback tran p_gl_audit_rmpost_second_s1
		end
	commit tran 
	fetch c_rmpostbucket into @accnt, @roomno, @class, @groupno, @ratecode, @amount, @charge1, @charge2, @charge3, @charge4, @charge5,@setrate, @w_or_h, @rtreason
	end
deallocate cursor c_rmpostpackage
close c_rmpostbucket
deallocate cursor c_rmpostbucket
-- 夜间稽核开始后才更改过房费标志，保证在此之前可以多次过房费
select @count = count(1) from rmpostbucket where posted != 'T' and rmpostdate = @rmpostdate
if @count > 0
	select @ret = 1   --- , @errorlog = '有' + ltrim(convert(char(5), @count)) + '个客人的房租入账失败，请检查'  -- 2005/3/2 这里的赋值会冲掉原来的错误提示，可惜。
else
	begin
	if @operation = 'R'
		begin
		begin tran
		update master set rmpoststa = '0' where rmpoststa = '1'
		update ar_master set rmpoststa = '0' where rmpoststa = '1'
		update sysdata set rmposted = 'T', rmpostdate = bdate, rpdate = @today, exposted = 'F'
		select @ret = 0, @errorlog = '成功'
		commit tran 
		end
	else
		-- 表示已经过过一次房租可以做夜审了
		update sysdata set rpdate = bdate
	end
if @operation = 'S'
	select @ret, @errorlog
return @ret
;

