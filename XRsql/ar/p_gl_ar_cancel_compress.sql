if exists(select * from sysobjects where name = 'p_gl_ar_cancel_compress' and type='P')
	drop proc p_gl_ar_cancel_compress;
create proc p_gl_ar_cancel_compress
	@accnt					char(10), 
	@number					integer,
	@empno					char(10),
	@shift					char(1)

as
-- 撤销压缩 
declare
	@ret						integer, 
	@msg						char(60), 
	@tag						char(1), 
	@billno					char(10), 
	@log_date				datetime,						--发生时间
	@bdate					datetime,						--营业日期
	@old						varchar(60),
	@new						varchar(60)

select @ret = 0, @log_date = getdate(), @bdate = bdate1 from sysdata
--
if not exists(select 1 from ar_master where accnt = @accnt and sta='I') 
	begin
	select @ret = 1, @msg = '不能针对已经清户的帐户进行处理'
	goto RETURN_2
	end
select @tag = tag, @billno = ref1 from ar_detail where accnt = @accnt and number = @number
if isnull(@tag, '') <> 'Z'
	begin
	select @ret = 1, @msg = '指定的压缩账目无效, 不能被解压'
	goto RETURN_2
	end
if exists (select 1 from ar_account where ar_accnt = @accnt and ar_inumber = @number and ar_tag in ('A', 'T'))
	begin
	select @ret = 1, @msg = '指定的压缩账目已被转账、调整过, 不能被解压'
	goto RETURN_2
	end
if exists (select 1 from ar_apply where d_accnt = @accnt and d_number = @number) or
	exists (select 1 from ar_apply where c_accnt = @accnt and c_number = @number)
	begin
	select @ret = 1, @msg = '指定的压缩账目已被核销过, 不能被解压'
	goto RETURN_2
	end
--
begin tran
save tran cancel_compress
-- 锁住相关账号
update ar_master set sta = sta where accnt = @accnt
-- 恢复以前的明细
insert ar_detail select * from har_detail where accnt = @accnt and pnumber = @number
insert ar_account select b.* from ar_detail a, har_account b
	where a.accnt = @accnt and a.pnumber = @number and a.accnt = b.ar_accnt and a.number = b.ar_inumber
delete har_detail where accnt = @accnt and pnumber = @number
delete har_account from ar_detail a
	where a.accnt = @accnt and a.pnumber = @number and a.accnt = har_account.ar_accnt and a.number = har_account.ar_inumber
update ar_detail set pnumber = 0 where accnt = @accnt and pnumber = @number
-- 删除压缩账务
insert har_detail select * from ar_detail where accnt = @accnt and number = @number
insert har_account select * from ar_account where ar_accnt = @accnt and ar_inumber = @number
delete ar_detail where accnt = @accnt and number = @number
delete ar_account where ar_accnt = @accnt and ar_inumber = @number
--
RETURN_1:
if @ret != 0
	rollback tran cancel_compress
else
	begin
	update billno set empno2 = @empno, shift2 = @shift, date2 = @log_date where billno = @billno
	select @old = @billno + '[' + rtrim(convert(char(10), @number)) + ']', @new = ''
	insert into lgfl (columnname, accnt, old, new, empno, date)
		values ('a_decompress', @accnt, @old, @new, @empno, @log_date)
	end
commit tran
RETURN_2:
select @ret, @msg
return @ret
;
