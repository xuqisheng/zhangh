if  exists(select * from sysobjects where name = "p_hry_get_mstinfo")
	drop proc p_hry_get_mstinfo;
create proc p_hry_get_mstinfo
	@accnt 		char(10)
as
declare
	@lic_buy_1	varchar(255),
	@lic_buy_2	varchar(255)

select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')

if substring(@accnt,1,1)='A' and charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0
	select sta,lastnumb,balance = charge+charge0-credit-credit0 from ar_master where accnt = @accnt
else
	select sta,lastnumb,balance = charge-credit from master where accnt = @accnt

return 0
;
