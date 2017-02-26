/* 维护定金 ---"提前结帐"字样在本程序中产生*/
if exists (select * from sysobjects where name = 'p_gl_audit_maintaccnt' and type ='P')
	drop proc p_gl_audit_maintaccnt;
create proc p_gl_audit_maintaccnt
	@ret					integer		out, 
	@msg					varchar(70)	out
as

declare
	@option				char(1),
	@accnt				char(10), 
	@number				integer, 
	@pccode				char(5), 
	@npccode				char(5), 
	@waiter				char(3), 
	@empno				char(10), 
	@bdate				datetime,
	@mcharge				money,
	@acharge				money,
	@mcredit				money,
	@acredit				money,
	@mlastnumb			integer,
	@alastnumb			integer,
	@mnumber				integer,
	@hnumber				integer,
	@failcount			integer

select @ret = 0, @msg = ''
select @bdate = bdate from sysdata 
-- maintain balance
select accnt, charge = sum(charge), credit = sum(credit), lastnumb = count(number), number = max(number)
	into #maintaccnt from account group by accnt
declare c_maint_balance cursor for
	select a.accnt, a.charge, isnull(b.charge, 0), a.credit, isnull(b.credit, 0), a.lastnumb, isnull(b.lastnumb, 0), isnull(b.number, 0)
	from master a, #maintaccnt b where a.accnt *= b.accnt
open c_maint_balance
fetch c_maint_balance into @accnt, @mcharge, @acharge, @mcredit, @acredit, @mlastnumb, @alastnumb, @mnumber
while @@sqlstatus = 0
	begin
	if @mcharge != @acharge or @mcredit != @acredit or @mlastnumb != @alastnumb or @mlastnumb != @mnumber
		begin
		select @acharge = @acharge + sum(charge), @acredit = @acredit + sum(credit), @alastnumb = @alastnumb + count(number), @hnumber = max(number)
			from haccount where accnt = @accnt
		if @hnumber > @mnumber
			select @mnumber = @hnumber
		if @mcharge != @acharge or @mcredit != @acredit or @mlastnumb != @alastnumb or @mlastnumb != @mnumber
			begin
			select @failcount = 0
			while @failcount < 3
				begin
				exec @ret = p_gl_accnt_rebuild @accnt, 'R', @msg output 
				if @ret = 0
					break
				else
					select @failcount = @failcount + 1
				end
			if @failcount = 3
				begin
				select @ret = 1, @msg = "重建帐号'" + @accnt + "'余额失败, 请稍后继续夜核"
				break 
				end
			end
		end
	fetch c_maint_balance into @accnt, @mcharge, @acharge, @mcredit, @acredit, @mlastnumb, @alastnumb, @mnumber
	end
close c_maint_balance
deallocate cursor c_maint_balance
return @ret
;
