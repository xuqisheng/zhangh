if exists(select * from sysobjects where name = 'p_gl_ar_apply' and type='P')
	drop proc p_gl_ar_apply;

create proc p_gl_ar_apply
	@pc_id					char(4), 
	@mdi_id					integer, 
	@shift					char(1), 
	@empno					char(10)
as
--  新核销(支持只有借方或贷方的核销)  
declare
	@ret						integer, 
	@msg						char(60), 
	@log_date				datetime,
	@bdate					datetime,
	@sum_credit				money, 
	@sum_charge				money, 
	@sum_amount				money, 
	@credit					money, 
	@charge					money, 
	@d_tag					char(1), 
	@d_accnt					char(10), 
	@d_number				integer, 
	@d_inumber				integer, 
	@d_pnumber				integer, 
	@c_tag					char(1), 
	@c_accnt					char(10), 
	@c_number				integer, 
	@c_inumber				integer, 
	@c_pnumber				integer, 
	@billno					char(10), 
	@number					integer,
	@accnt					char(10),
	@c_status				integer,
	@d_status				integer

select @log_date = getdate(), @bdate = bdate1, @ret = 0 from sysdata
-- 检查审核账目
if exists (select 1 from ar_detail a, account_temp b where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected = 1 
	and a.accnt = b.accnt and a.number = b.number and a.audit = '0')
	begin
	select @ret = 1, @msg = '只有审核过的账目才能核销'
	goto RETURN_2
	end
-- 检查核销账目
select @sum_charge = count(1)
	from ar_detail a, account_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected = 1 and a.accnt = b.accnt and a.number = b.number
	and round(a.charge + a.charge0 - a.charge9, 2) != 0
select @sum_credit = count(1)
	from ar_detail a, account_temp b
	where b.pc_id = @pc_id and b.mdi_id = @mdi_id and b.selected = 1 and a.accnt = b.accnt and a.number = b.number
	and round(a.credit + a.credit0 - a.credit9, 2) != 0
if @sum_charge = 0 and @sum_credit = 0
	begin
	select @ret = 1, @msg = '没有账目可供核销'
	goto RETURN_2
	end
-- 检查核销金额
select @sum_charge = sum(round(charge, 2)), @sum_credit = sum(round(credit, 2))
	from account_temp where pc_id = @pc_id and mdi_id = @mdi_id and selected = 1
select @sum_charge=isnull(@sum_charge,0), @sum_credit=isnull(@sum_credit,0)
if @sum_charge <> @sum_credit
	begin
	select @ret = 1, @msg = '核销金额与付款总额不一致'
	goto RETURN_2
	end

-- -- 核销
-- declare c_charge cursor for 
-- 	select a.ar_tag, a.ar_accnt, a.ar_number, a.ar_inumber, a.ar_pnumber, b.charge from ar_account a, account_temp b
-- 	where b.pc_id = @pc_id and b.mdi_id = - @mdi_id and b.selected = 1 and a.ar_accnt = b.accnt and a.ar_number = b.number
-- 	order by b.charge
-- declare c_credit cursor for 
-- 	select a.ar_tag, a.ar_accnt, a.ar_number, a.ar_inumber, a.ar_pnumber, b.credit from ar_account a, account_temp b
-- 	where b.pc_id = @pc_id and b.mdi_id = - @mdi_id and b.selected = 1 and a.ar_accnt = b.accnt and a.ar_number = b.number
-- 	order by b.credit
-- begin tran
-- save tran apply
-- exec p_GetAccnt1 @type = 'BIL', @accnt = @billno out
-- select @billno = 'B' + substring(@billno, 2, 9)
-- -- 锁住相关账号
-- open c_credit
-- fetch c_credit into @c_tag, @c_accnt, @c_number, @c_inumber, @c_pnumber, @credit
-- select @c_status = @@sqlstatus
-- open c_charge
-- fetch c_charge into @d_tag, @d_accnt, @d_number, @d_inumber, @d_pnumber, @charge
-- select @d_status = @@sqlstatus
-- while @d_status =  0
-- 	begin
-- 	if @charge != 0
-- 		begin
-- 		while @c_status =  0
-- 			begin
-- 			if @credit != 0
-- 				begin
-- 				if (@credit > @charge and @charge > 0) or @charge < 0
-- 					begin
-- 					update ar_account set charge9 = charge9 + @charge where ar_accnt = @d_accnt and ar_number = @d_number
-- 					update ar_detail set charge9 = charge9 + @charge where accnt = @d_accnt and number = @d_inumber
-- 					update ar_account set credit9 = credit9 + @charge where ar_accnt = @c_accnt and ar_number = @c_number
-- 					update ar_detail set credit9 = credit9 + @charge where accnt = @c_accnt and number = @c_inumber
-- 					insert ar_apply (d_accnt, d_number, d_inumber, c_accnt, c_number, c_inumber, amount, billno, log_date, bdate, shift, empno)
-- 						select @d_accnt, @d_inumber, @d_number, @c_accnt, @c_inumber, @c_number, @charge, @billno, @log_date, @bdate, @shift, @empno
-- 					select @credit = @credit - @charge
-- 					break
-- 					end
-- 				else
-- 					begin
-- 					update ar_account set charge9 = charge9 + @credit where ar_accnt = @d_accnt and ar_number = @d_number
-- 					update ar_detail set charge9 = charge9 + @credit where accnt = @d_accnt and number = @d_inumber
-- 					update ar_account set credit9 = credit9 + @credit where ar_accnt = @c_accnt and ar_number = @c_number
-- 					update ar_detail set credit9 = credit9 + @credit where accnt = @c_accnt and number = @c_inumber
-- 					insert ar_apply (d_accnt, d_number, d_inumber, c_accnt, c_number, c_inumber, amount, billno, log_date, bdate, shift, empno)
-- 						select @d_accnt, @d_inumber, @d_number, @c_accnt, @c_inumber, @c_number, @credit, @billno, @log_date, @bdate, @shift, @empno
-- 					select @charge = @charge - @credit
-- 					end
-- 				end
-- 			fetch c_credit into @c_tag, @c_accnt, @c_number, @c_inumber, @c_pnumber, @credit
-- 			select @c_status = @@sqlstatus
-- 			end
-- 		end
-- 	fetch c_charge into @d_tag, @d_accnt, @d_number, @d_inumber, @d_pnumber, @charge
-- 	select @d_status = @@sqlstatus
-- 	end
-- close c_charge
-- close c_credit
-- deallocate cursor c_charge
-- deallocate cursor c_credit
-- -- 事后检查
-- select @sum_amount = sum(amount) from ar_apply where billno = @billno
-- if @sum_amount <> @sum_charge or @sum_amount <> @sum_credit
-- 	select @ret = 1, @msg = '核销错误%1^'+convert(char(10), @sum_amount)+convert(char(10), @sum_charge)
 

-- 新核销(支持只有借方或贷方的核销)
declare c_charge cursor for 
	select a.ar_tag, a.ar_accnt, a.ar_number, a.ar_inumber, a.ar_pnumber, b.charge from ar_account a, account_temp b
	where b.pc_id = @pc_id and b.mdi_id = - @mdi_id and b.selected = 1 and a.ar_accnt = b.accnt and a.ar_number = b.number
declare c_credit cursor for 
	select a.ar_tag, a.ar_accnt, a.ar_number, a.ar_inumber, a.ar_pnumber, b.credit from ar_account a, account_temp b
	where b.pc_id = @pc_id and b.mdi_id = - @mdi_id and b.selected = 1 and a.ar_accnt = b.accnt and a.ar_number = b.number
begin tran
save tran apply
exec p_GetAccnt1 @type = 'BIL', @accnt = @billno out
select @billno = 'B' + substring(@billno, 2, 9)
-- 借方
open c_charge
fetch c_charge into @d_tag, @d_accnt, @d_number, @d_inumber, @d_pnumber, @charge
while @@sqlstatus =  0
	begin
	if @charge != 0
		begin
		update ar_account set charge9 = charge9 + @charge where ar_accnt = @d_accnt and ar_number = @d_number
		update ar_detail set charge9 = charge9 + @charge where accnt = @d_accnt and number = @d_inumber
		insert ar_apply (d_accnt, d_number, d_inumber, c_accnt, c_number, c_inumber, amount, billno, log_date, bdate, shift, empno)
			select @d_accnt, @d_inumber, @d_number, '', 0, 0, @charge, @billno, @log_date, @bdate, @shift, @empno
		end
	fetch c_charge into @d_tag, @d_accnt, @d_number, @d_inumber, @d_pnumber, @charge
	end
-- 贷方
open c_credit
fetch c_credit into @c_tag, @c_accnt, @c_number, @c_inumber, @c_pnumber, @credit
while @@sqlstatus =  0
	begin
	if @credit != 0
		begin
		update ar_account set credit9 = credit9 + @credit where ar_accnt = @c_accnt and ar_number = @c_number
		update ar_detail set credit9 = credit9 + @credit where accnt = @c_accnt and number = @c_inumber
		insert ar_apply (d_accnt, d_number, d_inumber, c_accnt, c_number, c_inumber, amount, billno, log_date, bdate, shift, empno)
			select '', 0, 0, @c_accnt, @c_inumber, @c_number, @credit, @billno, @log_date, @bdate, @shift, @empno
		end
	fetch c_credit into @c_tag, @c_accnt, @c_number, @c_inumber, @c_pnumber, @credit
	end
close c_charge
close c_credit
deallocate cursor c_charge
deallocate cursor c_credit
-- 事后检查
select @charge = 0, @credit = 0
select @charge = sum(round(amount, 2)) from ar_apply where billno = @billno and rtrim(d_accnt) is not null
select @credit = sum(round(amount, 2)) from ar_apply where billno = @billno and rtrim(d_accnt) is null
select @charge=isnull(@charge, 0), @credit=isnull(@credit, 0)
if @charge <> @sum_charge 
	select @ret = 1, @msg = '核销错误%1^'+convert(char(10), @charge)+convert(char(10), @sum_charge)
else if @credit <> @sum_credit
	select @ret = 1, @msg = '核销错误%1^'+convert(char(10), @credit)+convert(char(10), @sum_credit)

--
RETURN_1:
if @ret != 0
	rollback tran apply
else
	insert billno (billno, accnt, bdate, empno1, shift1) 
		select @billno, min(accnt), @bdate, @empno, @shift
		from account_temp where pc_id = @pc_id and mdi_id = @mdi_id
commit tran
RETURN_2:
select @ret, @msg
return @ret
;
