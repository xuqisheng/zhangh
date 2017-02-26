
if  exists(select * from sysobjects where name = 'p_gl_audit_rmpost_added')
	drop proc p_gl_audit_rmpost_added
;
create proc p_gl_audit_rmpost_added
	@modu_id					char(2), 
	@pc_id					char(4), 
	@mdi_id					integer, 
	@shift					char(1), 
	@empno					char(10), 
	@accnt					char(10), 
	@operation				char(3) = 'SN'			
as
--------------------------------------------------------------------------------
-- 结帐房费加收 
--
-- @operation	第一位:S:带Select返回值  R:重新计算房费  T退出
--					第二位:N自动补过房费,P提前过当天房费,D:日租
--					第三位:w_or_h,仅日租才有
--------------------------------------------------------------------------------
declare
	@w_or_h					integer,						-- 1:全天  2:半天 
	@bdate					datetime,
	@half_time				datetime,
	@whole_time				datetime,
	@sta						char(1), 
	@rmposted				char(1), 
	@rmpoststa				char(1), 
	@today_arr				char(1), 
	@citime					datetime,
	@coperation				char(2), 
	--
	@selemark				char(17), 
	@rmpostdate				datetime,
	@rtreason				char(3), 
	@to_accnt				char(10), 
	@today					datetime,
	@mode						char(10),
	@amount					money, 
	@roomno					char(5), 
	@class					char(1),
	@ratecode				char(10), 
	@quantity				money,
	@rmrate					money, 
	@qtrate					money, 
	@setrate					money, 
	@charge1					money, 
	@charge2					money, 
	@charge3					money, 
	@charge4					money, 
	@charge5					money, 
	@package_c				money, 
	@ret						integer, 
	@msg						varchar(60),
	@ref2						char(50),
	@fir						varchar(60), 
	@name						varchar(50), 
	@pccode					char(5),
	@argcode					char(3),
	@package					char(4),
	@rule_calc				char(10),
	--
	@srqs						char(18),
	@tranlog					char(10),
	@extrainf				char(30),
	@pos						integer,
	@ent1						integer,
	@ent2						integer,
	@auto_post				char(1)

declare  -- for cms
	@groupno				char(10),
	@cusno				char(10),
	@agent				char(10),
	@source				char(10),
	@cmscode				char(10)

--
delete rmpostpackage where pc_id = @pc_id and mdi_id = @mdi_id
delete rmpostvip where pc_id = @pc_id and mdi_id = @mdi_id
--
select @ret = 0, @msg = '', @w_or_h = 0,@auto_post = 'F'
select @bdate = bdate1, @rmpostdate = dateadd(dd, 1, rmpostdate) from sysdata
select @roomno = roomno, @class = class, @groupno = groupno, @ratecode = ratecode, @rtreason = rtreason, @sta = sta, @rmposted = rmposted, @rmpoststa = rmpoststa, @citime = citime
	from master where accnt = @accnt 
-- 为夜间稽核后入住的客人自动加收房费
if @operation like '_N%'
	begin
	select @half_time = convert(datetime, convert(char(10), @bdate, 111) + ' ' + value)
		from sysoption where catalog = 'ratemode' and item = 't_half_rmrate'
	select @whole_time = convert(datetime, convert(char(10), @bdate, 111) + ' ' + value)
		from sysoption where catalog = 'ratemode' and item = 't_whole_rmrate'
	if @rmposted ! = 'T'
		begin
		select @auto_post = 'T'
		if @citime < @whole_time
			begin
			select @today_arr = 'N', @w_or_h = 1, @coperation = 'FN', @mode = 'B' + @roomno, @quantity = 1
			select @pccode = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccode_B'), '001')
			end
		else if @citime < @half_time
			begin
			select @today_arr = 'N', @w_or_h = 2, @coperation = 'FN', @mode = 'b' + @roomno, @quantity = 0.5
			select @pccode = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccode_b'), '001')
			end
		end
	end
-- 提前过当天房费
else if @operation like '_P%'
	begin
	if @rmpoststa = '1'
		select @ret = 1, @msg = @roomno + '今天的房费已过'
	else
		begin
		select @today_arr = 'F', @w_or_h = 1, @coperation = 'FN', @mode = 'J' + @roomno, @quantity = 1
		select @pccode = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccode'), '000')
		end
	end
else
	begin
	select @today_arr = 'D', @w_or_h = convert(integer, substring(@operation, 3, 1)), @coperation = 'FD'
	if @w_or_h = 1
		begin
		select @mode = 'N' + @roomno, @quantity = 1
		select @pccode = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccode_N'), '002')
		end
	else
		begin
		select @mode = 'P' + @roomno, @quantity = 0.5
		select @pccode = isnull((select value from sysoption where catalog = 'audit' and item = 'room_charge_pccode_P'), '002')
		end
	end
--
if @w_or_h > 0
	begin
	exec @ret = p_gl_audit_rmpost_calculate @rmpostdate, @accnt, @w_or_h, @rmrate out, @qtrate out, @setrate out, 
		@charge1 out, @charge2 out, @charge3 out, @charge4 out, @charge5 out, @coperation, @pc_id, @mdi_id
	select @package_c = isnull((select sum(amount) from rmpostpackage
		where pc_id = @pc_id and mdi_id = @mdi_id and accnt = @accnt and rule_calc like '1%'), 0)
	select @selemark = 'A', @today = getdate(), @amount = @charge1 - @charge2 + @charge3 + @charge4 + @charge5, 
--	select @package_c = isnull((select sum(amount) from rmpostpackage
--		where pc_id = @pc_id and mdi_id = @mdi_id and accnt = @accnt and (rule_calc like '10%' or rule_calc like '01%')), 0)
--	select @selemark = 'A', @today = getdate(), @amount = @charge1 - @charge2 + @charge3 + @charge4 + @charge5 + @package_c, 
		@ref2 = substring(@roomno + space(5), 1, 5) + '(' + convert(char(10), getdate(), 111) + ')'
	begin tran
	save  tran p_gl_audit_rmpost_added_s
	if @class = 'F'
		exec @ret = p_gl_accnt_posting @selemark, @modu_id, @pc_id, @mdi_id, @shift, @empno, @accnt, 0, @pccode, '', 
			@quantity, @amount, @charge1, @charge2, @charge3, @charge4, @charge5, @ratecode, @ref2, @today, @rtreason, @mode, 'IRYY', 0, @to_accnt, @msg out
	else
		select @amount = 0

--add by tcr for cms 2004.6.28
	if @groupno <> ''
		select @cmscode = cmscode,@cusno = cusno,@agent = agent,@source = source from master where accnt = @groupno
	else
		select @cmscode = cmscode,@cusno = cusno,@agent = agent,@source = source from master where accnt = @accnt

	if rtrim(@cmscode) is not null and @amount > 0
		begin
		if @accnt <> @to_accnt and @to_accnt<>'' and @to_accnt is not null
			insert cms_rec(auto,accnt,name,number,type,roomno,cusno,agent,source,arr,dep,rmrate,exrate,dsrate,rmsur,rmtax,
								w_or_h,mode,ratecode,cmscode,cmsunit,cmstype,cmsvalue,cms0,cms,ref,bdate,post,postdate,cby,changed,market,to_accnt,logmark)
				select 'T',@accnt, b.name,c.lastnumb,a.type,a.roomno, @cusno,@agent,@source,a.arr,a.dep,@charge1 - @charge2, 0,-1*@charge2,@charge3,0,
						@quantity, @mode,a.ratecode,@cmscode,'','',0,0,0,@groupno,@rmpostdate,@empno,getdate(),@empno,getdate(),a.market,@to_accnt,0
				from master a,guest b,master c where a.accnt = @accnt and c.accnt=@to_accnt and a.haccnt = b.no
		else 
			insert cms_rec(auto,accnt,name,number,type,roomno,cusno,agent,source,arr,dep,rmrate,exrate,dsrate,rmsur,rmtax,
								w_or_h,mode,ratecode,cmscode,cmsunit,cmstype,cmsvalue,cms0,cms,ref,bdate,post,postdate,cby,changed,market,to_accnt,logmark)
				select 'T',@accnt, b.name,a.lastnumb,a.type,a.roomno, @cusno,@agent,@source,a.arr,a.dep,@charge1 - @charge2, 0,-1*@charge2,@charge3,0,
						@quantity, @mode,a.ratecode,@cmscode,'','',0,0,0,@groupno,@rmpostdate,@empno,getdate(),@empno,getdate(),a.market,@accnt,0
				from master a,guest b where accnt = @accnt and a.haccnt = b.no
		end
--end add

	if @ret = 0
		begin
		-- 半夜加收房费的，Package当天生效
		if @operation like '_N%'
			update rmpostpackage set starting_date = dateadd(dd, -1, starting_date), closing_date = dateadd(dd, -1, closing_date)
		-- 将Package需要反映在Account中的费用入帐
		declare c_rmpostpackage cursor for
			select pccode, argcode, amount, quantity, rule_calc, code
			from rmpostpackage where pc_id = @pc_id and mdi_id = @mdi_id and accnt = @accnt order by number
		open c_rmpostpackage
		fetch c_rmpostpackage into @pccode, @argcode, @amount, @quantity, @rule_calc, @package
		while @@sqlstatus = 0
			begin
			if @rule_calc like '1%'
				begin
				select @msg = ''
				exec @ret = p_gl_accnt_posting @selemark, @modu_id, @pc_id, @mdi_id, @shift, @empno, @accnt, 0, @pccode, @argcode, 
					@quantity, @amount, 0, 0, 0, 0, 0, @ratecode, '', @today, @rtreason, @package, 'IRNY', 0, null, @msg out
				end
			if @ret != 0
				break
			fetch c_rmpostpackage into @pccode, @argcode, @amount, @quantity, @rule_calc, @package
			end
		close c_rmpostpackage
		deallocate cursor c_rmpostpackage
	--
		if @ret = 0 
	--			-- HZDS GaoLiang 1999/10/21 
			begin
--				select @srqs = srqs, @tranlog = tranlog from master where accnt = @accnt
--	--			if charindex('VV', @srqs) > 0
--	--				begin
--	--				if exists(select 1 from rmpostvip where pc_id = @pc_id and cusid = @tranlog and charindex(@accnt, accnts) > 0)
--	--					begin
--	--					select @pos = charindex('VV', @srqs)
--	--					update master set srqs = substring(@srqs, 1, @pos - 1) + substring(@srqs, @pos + 4, 18), logmark = logmark + 1 where accnt = @accnt
--	--					select @ent1 = number1, @ent2 = number2 from rmpostvip where pc_id = @pc_id and cusid = @tranlog
--	--					select @extrainf = extrainf from cusdef where cusid = @tranlog
--	--					select @pos = charindex('|', @extrainf)
--	----					if @pos = 0
--	----						select @pos = 1
--	--					update cusdef set extrainf = rtrim(convert(char(5), @ent1)) + '/' + rtrim(convert(char(5), @ent2)) + substring(@extrainf, @pos, 30)
--	--						where cusid = @tranlog
--	--					end
--	--				end
--			update master set rmposted = 'T' where accnt = @accnt
			select @name = b.name, @fir = b.street from master a, guest b where a.accnt = @accnt and a.haccnt *= b.no
-- 防止房租预审后执行“提前过当天房费”
			if @today_arr in ('F') and exists (select 1 from rmpostbucket where rmpostdate = @rmpostdate and accnt = @accnt and today_arr = @today_arr)
				delete rmpostbucket where rmpostdate = @rmpostdate and accnt = @accnt and today_arr = @today_arr
			insert rmpostbucket
				(accnt, roomno, src, class, name, fir, groupno, headname, type, market, ratecode, packages, paycode, rmrate, qtrate, setrate, 
				charge1, charge2, charge3, charge4, charge5, package_c, rtreason, gstno, arr, dep, today_arr, w_or_h, posted, rmpostdate, logmark, empno, shift)
				select @accnt, roomno, src, class, @name, @fir, groupno, '', type, market, ratecode, packages, paycode, @rmrate, @qtrate, @setrate, 
				@charge1, @charge2, @charge3, @charge4, @charge5, @package_c, rtreason, gstno, arr, dep, @today_arr, @w_or_h, 'T', @rmpostdate, logmark, '', ''
				from master where accnt = @accnt
			update rmpostbucket set headname = '['+rtrim(b.name)+'][来源-'+b.src+', 类别-'+b.class+']' 
				from master a, guest b where rmpostbucket.rmpostdate = @rmpostdate and rmpostbucket.groupno = a.accnt and a.haccnt = b.no
			update rmpostbucket set headname = '[散客, 长住房, 自用房等]'
				where rmpostdate = @rmpostdate and groupno = ''

			-- 入账房费信息提示 2006.3.14 simon -> ! 开头 
			select @msg = substring('!自动加收房费%1^'+@roomno+' '+@name+space(30),1,30) + convert(char(20), @charge1-@charge2+@charge3+@charge4+@charge5)
			end
		end
	if @ret != 0
		rollback tran p_gl_audit_rmpost_added_s
	else if @operation like '_N%'						
		update master set rmposted = 'T' where accnt = @accnt
--		select @msg = '电脑自动加收房费, 请核对'		-- msg 已经为入账信息，不变化了。 simon 
	else if @operation like '_P%'
		update master set rmposted = 'T', rmpoststa = '1' where accnt = @accnt
	commit tran
	end

--夜审后到店的客人，凌晨加收房费的时候如果有包价，则包价的使用时间要调整
if @auto_post = 'T'
	begin
	update package_detail set starting_date = bdate,closing_date = dateadd(dd,1,bdate) where accnt = @accnt
	--FHB Added At 20091104 For package_detail To pos_package_detail
	end

if @operation like 'S%'
	select @ret, @msg, @to_accnt
return @ret
;

