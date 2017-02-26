// ------------------------------------------------------------------------
//	 update sysdata
// ------------------------------------------------------------------------ 
if exists (select 1 from sysobjects where name = 'p_crs_update_sysdata'  and type = 'P')
	drop procedure p_crs_update_sysdata;

create  procedure p_crs_update_sysdata   
as 
begin 
	declare
		@bdate			datetime,
		@yer				char(1),
		@no_days			integer,
		@rang1			char(3),
		@rang2			char(3) 

	update sysdata set bdate1 = dateadd(day, 1, bdate)
--	update sysdata set bdate1 = getdate()
	select @bdate = bdate, @yer = yer from sysdata
	if substring(convert(char(10), @bdate, 1), 1, 5) = '12/31'
	begin
		if @yer = '9'
			update sysdata set yer = '0'
		else
			update sysdata set yer = convert(char(1), convert(int, yer) + 1)
		update sysdata set rang1 = '000', rang2 = '400', rng1base = 0, rng2base = 0,rng3base = 800000, rng4base = 950000, hisbase = 0, bbase = 0, gstid = 0 
	end
	else
	begin
		select @no_days = datediff(day, convert(datetime, convert(char(4), datepart(yy, bdate))+'/01/01'), bdate),@rang1 = rang1, @rang2 = rang2 from sysdata
		if @no_days >= convert(int, @rang1)
			update sysdata set rang1 = right(convert(char(4), @no_days + 1001), 3), rng1base = 0
		if @no_days + 400 >= convert(int, @rang2)
			update sysdata set rang2 = convert(char(3), @no_days + 401), rng2base = 0
	end
	update sysdata set msgbase = datepart(yy, bdate1) % 100 * 100000000.0 + datepart(mm, bdate1) * 1000000.0 + datepart(dd, bdate1) * 10000.0 + 1
	update sysdata set billbase = datepart(yy, bdate1) % 100 * 100000000.0 + datepart(mm, bdate1) * 1000000.0 + datepart(dd, bdate1) * 10000.0 + 1

	update sysdata set bdate = bdate1, rmposted = 'F'

end
;
