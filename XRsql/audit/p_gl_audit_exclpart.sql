IF OBJECT_ID('dbo.p_gl_audit_exclpart') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_gl_audit_exclpart
    IF OBJECT_ID('dbo.p_gl_audit_exclpart') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.p_gl_audit_exclpart >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.p_gl_audit_exclpart >>>'
END
;
create proc p_gl_audit_exclpart
	@pc_id			char(4),
	@empno			char(10),
	@ret				integer		out,
	@msg				varchar(70)	out

as
declare
	@savedays		integer,
	@bdate			datetime,
	@yer				char(1),
	@no_days			integer,
	@rang1			char(3),
	@rang2			char(3)

begin tran
save  tran p_gl_audit_exclpart_s1
update accthead set bdate = bdate
if exists ( select 1 from auth_runsta where not appid in ('6', 'V') and pc_id <> @pc_id and status = 'R')
	select @ret = 1, @msg = '还有站点在运行，请通知其退出。如果该站点实在无法退出，再次执行本过程即可'
if @ret <> 0
	rollback tran p_gl_audit_exclpart_s1
else
	begin
	update accthead set exclpart = @pc_id, baudit = 'F', canpartout = 'F', empno = @empno from sysdata
	update gate set exclpart = 'T', audit = 'T', copydone = 'F', dldone = 'F',  idd = 'F'
	end
commit tran
if @ret <> 0
	begin
	update auth_runsta set status = 'S' where not appid in ('6', 'V') and pc_id <> @pc_id and status = 'R'
	return @ret
	end

--  some checking here
update accthead set exclpart = @pc_id, baudit = 'F', canpartout = 'F', empno = @empno from sysdata
update gate set exclpart = 'T', audit = 'T', copydone = 'F', dldone = 'F',  idd = 'F'
--  conduct rmposting here
update rmsta set onumber = number
update master set sta_tm = sta
update ar_master set sta_tm = sta

delete hsmap
delete hsmap_new
delete hsmap_bu
delete hsmap_bu_cond
delete hsmap_des
delete hsmap_flr
delete hsmapsel

delete accnt_set
delete account_ar
delete account_temp
delete account_folder
delete selected_account
delete rmpostpackage
delete rmpostvip
delete action
delete allouts
delete alchkout
insert alchkout select accnt, sta, ' ', cby, getdate() from master where sta = 'O'
--  delete group rate table
delete grprate where not accnt in (select accnt from master)
--  删除过期的结账单号
select @savedays = isnull((select convert(integer, value) from sysoption where catalog = 'audit' and item = 'billno_savedays'), 0)
delete billno from sysdata a where datediff(dd, billno.bdate, a.bdate) >= @savedays
--  update business day
begin tran
update sysdata set bdate1 = dateadd(day, 1, bdate)

-- Save audit date
declare 	@gdate datetime, @s_time datetime, @e_time datetime
select @gdate = bdate from sysdata
delete audit_date where date = @gdate
select @s_time = isnull((select end_ from audit_date where datediff(dd,date,@gdate)=1), @gdate)
select @e_time = getdate()
insert audit_date(date,begin_,end_,empno) values(@gdate,@s_time,@e_time,@empno)

select @bdate = bdate, @yer = yer from sysdata
if substring(convert(char(10), @bdate, 1), 1, 5) = '12/31'
	begin
	if @yer = '9'
		update sysdata set yer = '0'
	else
		update sysdata set yer = convert(char(1), convert(int, yer) + 1)
	update sysdata set rang1 = '000', rang2 = '400', rng1base = 0, rng2base = 0,
		rng3base = 800000, rng4base = 950000,  bbase = 0, gstid = 0
	end
else
	begin
	select @no_days = datediff(day, convert(datetime, convert(char(4), datepart(yy, bdate))+'/01/01'), bdate),
		@rang1 = rang1, @rang2 = rang2 from sysdata
	if @no_days >= convert(int, @rang1)
		update sysdata set rang1 = right(convert(char(4), @no_days + 1001), 3), rng1base = 0
	if @no_days + 400 >= convert(int, @rang2)
		update sysdata set rang2 = convert(char(3), @no_days + 401), rng2base = 0
	end
update sysdata set msgbase = datepart(yy, bdate1) % 100 * 100000000.0 + datepart(mm, bdate1) * 1000000.0 + datepart(dd, bdate1) * 10000.0 + 1
--  结帐单号 GaoLiang 1999/07/01
update sysdata set billbase = datepart(yy, bdate1) % 100 * 100000000.0 + datepart(mm, bdate1) * 1000000.0 + datepart(dd, bdate1) * 10000.0 + 1

insert breakfast (date, lf, lg, lm, ll) select dateadd(day, 1, date), tf, tg, tm, tl from breakfast where date = @bdate
commit tran
return @ret



;
EXEC sp_procxmode 'dbo.p_gl_audit_exclpart','unchained'
;
IF OBJECT_ID('dbo.p_gl_audit_exclpart') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.p_gl_audit_exclpart >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.p_gl_audit_exclpart >>>'
;
