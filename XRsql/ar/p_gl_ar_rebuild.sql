/* 维护一AR帐号的发生额等 */

if exists(select * from sysobjects where name = 'p_gl_ar_rebuild')
	drop proc p_gl_ar_rebuild;

create proc p_gl_ar_rebuild
	@accnt				char(10),
	@retmode				char(1),
	@msg					varchar(70) output
as
declare
	@class				char(3),
	@balance				money  ,
	@accredit			money  ,
	@lastnumb			integer,
	@maxnumber			integer,
	@lastinumb			integer,
	@clastnumb			integer,
	@clastinumb			integer,
	@ar_inumber			integer,
	@ar_pnumber			integer,
	@cnumber				integer,
	@car_number			integer,
	@car_inumber		integer,
	@car_pnumber		integer,
	@cargcode			char(3),
	@ctofrom				char(2),
	@caccntof			char(10),
	@ccharge				money,
	@ccharge0			money,
	@ccharge9			money,
	@charge				money,
	@charge0				money,
	@charge9				money,
	@icharge				money,
	@icharge0			money,
	@icharge9			money,
	@pcharge				money,
	@pcharge0			money,
	@pcharge9			money,
	@last_charge		money,
	@last_charge0		money,
	@last_charge9		money,
	@ccredit				money,
	@ccredit0			money,
	@ccredit9			money,
	@credit				money,
	@credit0				money,
	@credit9				money,
	@icredit				money,
	@icredit0			money,
	@icredit9			money,
	@pcredit				money,
	@pcredit0			money,
	@pcredit9			money,
	@last_credit		money,
	@last_credit0		money,
	@last_credit9		money,
	@ctable				char(10),
	@itable				char(10),
	@ptable				char(10),
	@car_tag				char(1),
	@car_subtotal		char(1),
	@bdate1				datetime,
	@cbdate				datetime,
	@sqlmark				integer,
	@ret					integer

select @bdate1 = bdate1 from sysdata
select @balance = 0, @ret = 0, @msg = ''
select @charge = 0, @credit = 0, @charge0 = 0, @credit0 = 0, @charge9 = 0, @credit9 = 0, @last_charge = 0, @last_credit = 0, @last_charge0 = 0, @last_credit0 = 0, @last_charge9 = 0, @last_credit9 = 0
select @icharge = 0, @icredit = 0, @icharge0 = 0, @icredit0 = 0, @icharge9 = 0, @icredit9 = 0, @pcharge = 0, @pcredit = 0, @pcharge0 = 0, @pcredit0 = 0, @pcharge9 = 0, @pcredit9 = 0
select @lastnumb = lastnumb, @lastinumb = lastinumb from ar_master where accnt = @accnt
// 维护Account, Har_account
declare c_ar_account cursor for
	select bdate, number, argcode, charge, credit, charge9, credit9, tofrom, accntof, ar_tag, ar_subtotal, ar_number, ar_inumber, ar_pnumber, 'ar_account'
		from ar_account where ar_accnt = @accnt
		union select bdate, number, argcode, charge, credit, charge9, credit9, tofrom, accntof, ar_tag, ar_subtotal, ar_number, ar_inumber, ar_pnumber, 'har_account'
		from har_account where ar_accnt = @accnt
		order by ar_inumber, ar_pnumber desc
open c_ar_account
fetch c_ar_account into @cbdate, @cnumber, @cargcode, @ccharge, @ccredit, @ccharge9, @ccredit9, @ctofrom, @caccntof, @car_tag, @car_subtotal, @car_number, @car_inumber, @car_pnumber, @ctable
select @sqlmark = @@sqlstatus
while @sqlmark = 0
	begin
	select @pcredit = @pcredit + @ccredit, @pcredit9 = @pcredit9 + @ccredit9
	select @pcharge = @pcharge + @ccharge, @pcharge9 = @pcharge9 + @ccharge9
	if @car_tag in ('z')
		select @icredit0 = @icredit0 + @ccredit, @icredit9 = @icredit9 + @ccredit9, @icharge0 = @icharge0 + @ccharge, @icharge9 = @icharge9 + @ccharge9,
			@ccharge = 0, @ccredit = 0, @ccharge0 = 0, @ccredit0 = 0, @ccharge9 = 0, @ccredit9 = 0
	else if @car_subtotal = 'T'
		select @ccharge = 0, @ccredit = 0, @ccharge0 = 0, @ccredit0 = 0, @ccharge9 = 0, @ccredit9 = 0
	else if @car_tag in ('A', 't')
		select @ccharge0 = @ccharge, @ccredit0 = @ccredit, @ccharge = 0, @ccredit = 0
	else
		select @ccharge0 = 0, @ccredit0 = 0
	-- 
	select @credit = @credit + @ccredit, @credit0 = @credit0 + @ccredit0, @credit9 = @credit9 + @ccredit9
	select @charge = @charge + @ccharge, @charge0 = @charge0 + @ccharge0, @charge9 = @charge9 + @ccharge9
	select @icredit = @icredit + @ccredit, @icredit0 = @icredit0 + @ccredit0, @icredit9 = @icredit9 + @ccredit9
	select @icharge = @icharge + @ccharge, @icharge0 = @icharge0 + @ccharge0, @icharge9 = @icharge9 + @ccharge9
	select @ar_inumber = @car_inumber, @ar_pnumber = @car_pnumber, @itable = @ctable, @ptable = @ctable
	if @cbdate < @bdate1
		begin
			select @last_credit = @last_credit + @ccredit, @last_credit0 = @last_credit0 + @ccredit0, @last_credit9 = @last_credit9 + @ccredit9
			select @last_charge = @last_charge + @ccharge, @last_charge0 = @last_charge0 + @ccharge0, @last_charge9 = @last_charge9 + @ccharge9
		end 
	//
	fetch c_ar_account into @cbdate, @cnumber, @cargcode, @ccharge, @ccredit, @ccharge9, @ccredit9, @ctofrom, @caccntof, @car_tag, @car_subtotal, @car_number, @car_inumber, @car_pnumber, @ctable
	select @sqlmark = @@sqlstatus
	if @sqlmark <> 0 or @car_pnumber <> @ar_pnumber						-- 
		begin
		if @ptable = 'ar_account'
			update ar_account set charge = @pcharge, credit = @pcredit, charge9 = @pcharge9, credit9 = @pcredit9 where ar_accnt = @accnt and ar_number = @ar_pnumber 
		else
			update har_account set charge = @pcharge, credit = @pcredit, charge9 = @pcharge9, credit9 = @pcredit9 where ar_accnt = @accnt and ar_number = @ar_pnumber 
		select @ptable = @ctable, @ar_pnumber = @car_pnumber, @pcredit = 0, @pcharge = 0, @pcredit9 = 0, @pcharge9 = 0
		end
	if @sqlmark <> 0 or @car_inumber <> @ar_inumber						-- 
		begin
		if @itable = 'ar_account'
			update ar_detail set charge = @icharge, credit = @icredit, charge0 = @icharge0, credit0 = @icredit0, charge9 = @icharge9, credit9 = @icredit9 where accnt = @accnt and number = @ar_inumber 
		else
			update har_detail set charge = @icharge, credit = @icredit, charge0 = @icharge0, credit0 = @icredit0, charge9 = @icharge9, credit9 = @icredit9 where accnt = @accnt and number = @ar_inumber 
		select @itable = @ctable, @ar_inumber = @car_inumber, @icredit = 0, @icharge = 0, @icredit0 = 0, @icharge0 = 0, @icredit9 = 0, @icharge9 = 0
		end
	end
close c_ar_account
deallocate cursor c_ar_account
//
select @accredit = sum(amount) from accredit where accnt = @accnt and tag = '0'
// 维护Ar_master
begin tran
save tran p_gl_ar_rebuild_s1
-- update ar_master_till set charge = @last_charge, credit = @last_credit where accnt = @accnt
update ar_master set charge = @charge + @charge0, credit = @credit + @credit0, accredit = isnull(@accredit, 0) where accnt = @accnt
select @clastnumb = isnull((select max(number) from ar_detail where accnt = @accnt), 0)
select @maxnumber = isnull((select max(number) from har_detail where accnt = @accnt), 0)
if @maxnumber > @clastnumb
	select @clastnumb = @maxnumber
select @clastinumb = isnull((select max(ar_number) from ar_account where ar_accnt = @accnt), 0)
select @maxnumber = isnull((select max(ar_number) from har_account where ar_accnt = @accnt), 0)
if @maxnumber > @clastinumb
	select @clastinumb = @maxnumber
update ar_master set lastnumb = isnull(@clastnumb, 0), lastinumb = isnull(@clastinumb, 0)
	where accnt = @accnt and lastnumb = @lastnumb and lastinumb = @lastinumb
if @@rowcount = 0
	begin
	rollback tran p_gl_ar_rebuild_s1
	select @ret = 1, @msg = '重建失败, 可能重建过程中有帐务发生'
	end
commit tran
if @retmode ='S'
	select @ret, @msg
return @ret
;
