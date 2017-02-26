if exists (select * from sysobjects where name ='p_gl_ar_cancel_apply' and type ='P')
	drop proc p_gl_ar_cancel_apply;
create proc p_gl_ar_cancel_apply
	@shift				char(1),
	@empno				char(10),
	@billno				char(10)
as
declare
	@billbase			char(7),
	@tag					char(1),
	@accnt				char(10),
	@number				integer,
	@inumber				integer,
	@pnumber				integer,
	@charge				money,
	@credit				money,
	@ret					integer,
	@msg					varchar(60)

select @ret=0, @msg=''
select @billbase = 'B' + substring(convert(char(10), billbase), 1, 5) + '%' from sysdata
if (select count(1) from accthead where canpartout ='T') = 0
	select @ret = 1, @msg = '夜间稽核处于关键区,暂时还不能撤除核销操作'
--if not @billno like @billbase  -- 2006.11.14 simon 
--	select @ret = 1, @msg = '只能撤消当天结的账'
if not exists(select 1 from ar_apply where billno = @billno)
	select @ret = 1, @msg = '没有单号为“%1”的核销操作可供撤除^' + @billno
if @ret = 1
	begin
	select @ret, @msg 
	return @ret
	end
//
declare c_cancel cursor for 
	select a.ar_tag, a.ar_accnt, a.ar_number, a.ar_inumber, a.ar_pnumber, b.amount, 0 from ar_account a, ar_apply b
	where b.billno = @billno and a.ar_accnt = b.d_accnt and a.ar_number = b.d_inumber
	union all select a.ar_tag, a.ar_accnt, a.ar_number, a.ar_inumber, a.ar_pnumber, 0, b.amount from ar_account a, ar_apply b
	where b.billno = @billno and a.ar_accnt = b.c_accnt and a.ar_number = b.c_inumber
begin tran
save tran cancel
-- 锁住相关账号
open c_cancel
fetch c_cancel into @tag, @accnt, @number, @inumber, @pnumber, @charge, @credit
while @@sqlstatus =  0
	begin
-- 新核销, 多个条件
	if @accnt != '' and @number != 0 and @inumber != 0
		begin
		update ar_account set charge9 = charge9 - @charge, credit9 = credit9 - @credit
			where ar_accnt = @accnt and (ar_number = @number or ar_number = @pnumber)
		update ar_detail set charge9 = charge9 - @charge, credit9 = credit9 - @credit
			where accnt = @accnt and number = @inumber
		if @@rowcount <> 1 
			begin
			select @ret=1, @msg='压缩过的核销帐务不能撤除'
			break
			end 
		end
	fetch c_cancel into @tag, @accnt, @number, @inumber, @pnumber, @charge, @credit
	end
close c_cancel
deallocate cursor c_cancel
if @ret=0
	begin
	delete ar_apply where billno = @billno
	update billno set empno2 = @empno, shift2 = @shift, date2 = getdate() where billno = @billno
	end
else
	rollback tran cancel 
commit tran
select @ret, @msg
return @ret
;
