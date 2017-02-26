/* 判断某帐目是否可冲销或转出 */

if exists(select * from sysobjects where name = 'p_gl_accnt_crradjt')
	drop proc p_gl_accnt_crradjt;

create proc p_gl_accnt_crradjt		/*输入帐户确保存在*/
	@accnt			char(10), 
	@number			integer, 
	@operation		char(2), 			/* 'CL'冲帐, 'LT'行转 */
	@shift			char(1), 
	@empno			char(10),
	@crradjt			char(60) out
as
declare
	@bdate			datetime, 
	@bdate1			datetime, 
	@cshift			char(1), 
	@cempno			char(10),
	@billno			char(10), 
	@tag				char(1), 
	@modu_id			char(2)

select @bdate1 = bdate1 from sysdata
select @crradjt = crradjt, @bdate = bdate, @billno = billno, @modu_id = modu_id, @cshift = shift, @cempno = empno
	from account where accnt = @accnt and number = @number
if @@rowcount = 0
	select @crradjt = '你要操作的账目不存在'
else if @operation = 'CL'
	begin
	select @tag = tag from package_detail where account_accnt = @accnt and account_number = @number
	if @billno like 'B%'
		select @crradjt = '已结的账不能冲'
	else if @billno like 'T%'
		select @crradjt = '已转的账不能冲'
	else if @billno like 'C%'
		select @crradjt = '已冲的账不能再冲'
	else if @crradjt in ('LT', 'CT')
		select @crradjt = '转来的账不能冲'
	else if datediff(dd, @bdate, @bdate1) <>  0
		select @crradjt = '只能冲当天输入的账'
	else if not (@modu_id ='02')
		select @crradjt = '只能冲前台系统输入的账'
	else if @shift <> @cshift or @empno <> @cempno
		select @crradjt = '只能冲本人本班输入的账'
	else if @tag in ('1', '2')
		select @crradjt = 'Package已经被使用,不能冲'
	else if @crradjt in ('', 'AD', 'SP')
		begin
		if @crradjt = 'AD'
			select @crradjt = 'CA'
		else if @crradjt = 'SP'
			select @crradjt = 'CA'
		else
			select @crradjt = 'C'
		return 0
		end
	end
else if @operation = 'LT'
	begin
	if @billno like 'B%'
		select @crradjt = '已结的账不能转'
	else if @billno like 'T%'
		select @crradjt = '已转的账不能再转'
	else if @billno like 'C%'
		select @crradjt = '已冲的账不能转'
	else if @crradjt in ('', 'AD', 'SP', 'CT', 'LT')
		begin
		if @crradjt = 'AD'
			select @crradjt = 'LA'
		else if @crradjt = 'SP'
			select @crradjt = 'LS'
		else if @crradjt = 'LT'
			select @crradjt = 'LL'
		else if @crradjt = 'CT'
			select @crradjt = 'LC'
		else
			select @crradjt = 'LT'
		return 0
		end
	end 
return 1
;

