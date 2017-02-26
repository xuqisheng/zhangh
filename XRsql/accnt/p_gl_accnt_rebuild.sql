/* 维护一帐号的发生额等，支持“帐务转储”（将已结账放到haccount） */

if exists(select * from sysobjects where name = 'p_gl_accnt_rebuild')
	drop proc p_gl_accnt_rebuild;

create proc p_gl_accnt_rebuild
	@accnt				char(10),
	@retmode				char(1),
	@msg					varchar(70) output
as
declare
	@class				char(3),
	@balance				money  ,
	@accredit			money  ,
	@lastnumb			integer,
	@lastinumb			integer,
	@clastnumb			integer,
	@clastinumb			integer,
	@cnumber				integer,
	@cargcode			char(3),
	@ctofrom				char(2),
	@caccntof			char(10),
	@ccharge				money,
	@charge				money,
	@last_charge		money,
	@ccredit				money,
	@credit				money,
	@last_credit		money,
	@ctable				char(10),
	@clog_date			datetime,
	@bdate1				datetime,
	@cbdate				datetime,
	@ret					integer

select @bdate1 = bdate1 from sysdata
select @balance = 0, @charge = 0, @credit = 0, @last_charge = 0, @last_credit = 0, @clastnumb = 0, @clastinumb = 0, @ret = 0, @msg = ''
select @lastnumb = lastnumb, @lastinumb = lastinumb from master where accnt = @accnt
-- 维护Account,Haccount
declare c_account cursor for
	select bdate, number, argcode, charge, credit, tofrom, accntof, log_date, 'account'
		from account where accnt = @accnt and number >= 0
		union select bdate, number, argcode, charge, credit, tofrom, accntof, log_date, 'haccount'
		from haccount where accnt = @accnt and number >= 0 order by log_date
open c_account
fetch c_account into @cbdate, @cnumber, @cargcode, @ccharge, @ccredit, @ctofrom, @caccntof, @clog_date, @ctable
while @@sqlstatus = 0
	begin
	if @cargcode > '9'
		begin
		select @credit = @credit + @ccredit
		if @cbdate < @bdate1
			select @last_credit = @last_credit + @ccredit
		end 
	else
		begin
		select @charge = @charge + @ccharge
		if @cbdate < @bdate1
			select @last_charge = @last_charge + @ccharge
		end
	--
	select @clastnumb = @clastnumb + 1, @balance = @balance + @ccharge - @ccredit
	if @ctable = 'account'
		update account set balance = @balance where accnt = @accnt and number = @cnumber
	else
		update haccount set balance = @balance where accnt = @accnt and number = @cnumber
-- GaoLiang 2005/10/26 考虑到新AR的需要account.number不再维护
--	if @cnumber <> @clastnumb
--		begin
--		if @ctable = 'account'
--			begin
--			update account set number = - @clastnumb where accnt = @accnt and number = @cnumber		/* 帐次 */
--			update account set pnumber = @clastnumb where accnt = @accnt and pnumber = @cnumber		/* 包的帐次 */
--			update account set inumber = @clastnumb where accnt = @accnt and inumber = @cnumber		/* 关联帐次 */
--			end
--		else
--			begin
--			update haccount set number = - @clastnumb where accnt = @accnt and number = @cnumber		/* 帐次 */
--			update haccount set pnumber = @clastnumb where accnt = @accnt and pnumber = @cnumber	/* 包的帐次 */
--			update haccount set inumber = @clastnumb where accnt = @accnt and inumber = @cnumber	/* 关联帐次 */
--			end
--		/* Package的帐次 */
--		update package_detail set account_number = @clastnumb where account_accnt = @accnt and account_number = @cnumber
--		if @ctofrom = 'TO'
--			begin
--				update account set inumber = @clastnumb
--					where accnt = @caccntof and inumber = @cnumber and tofrom = 'FM' and accntof = @accnt
--				if @@rowcount = 0
--					update haccount set inumber = @clastnumb
--					where accnt = @caccntof and inumber = @cnumber and tofrom = 'FM' and accntof = @accnt
--			end
--		end
	fetch c_account into @cbdate, @cnumber, @cargcode, @ccharge, @ccredit, @ctofrom, @caccntof, @clog_date, @ctable
	end
close c_account
deallocate cursor c_account
--update account set number = abs(number) where accnt = @accnt
--update haccount set number = abs(number) where accnt = @accnt
-- 维护Package_Detail
--declare c_package cursor for
--	select number from package_detail where accnt = @accnt order by number
--open c_package
--fetch c_package into @cnumber
--while @@sqlstatus = 0
--	begin
--	select @clastinumb = @clastinumb + 1
--	if @cnumber <> @clastinumb
--		update package_detail set number = @clastinumb where accnt = @accnt and number = @cnumber
--	fetch c_package into @cnumber
--	end
--close c_package
--deallocate cursor c_package
--
select @accredit = sum(amount) from accredit where accnt = @accnt and tag = '0'
-- 维护Master
begin tran
save tran p_gl_accnt_rebuild_s1
update master_till set charge = @last_charge, credit = @last_credit where accnt = @accnt
--update master set lastnumb = @clastnumb, lastinumb = @clastinumb, charge = @charge, credit = @credit, accredit = isnull(@accredit, 0)
--	where accnt = @accnt and lastnumb = @lastnumb
update master set charge = @charge, credit = @credit, accredit = isnull(@accredit, 0)
	where accnt = @accnt and lastnumb = @lastnumb
if @@rowcount = 0
	begin
	rollback tran p_gl_accnt_rebuild_s1
	select @ret = 1, @msg = '重建失败, 可能重建过程中有帐务发生'
	end
commit tran
if @retmode ='S'
	select @ret, @msg
return @ret
;
