if exists(select 1 from sysobjects where name ='p_cyj_pos_get_mstinfo' and type ='P')
	drop  proc p_cyj_pos_get_mstinfo;
create proc p_cyj_pos_get_mstinfo
	@accnt 		char(10)
--------------------------------------------------------------------
-- x5 餐饮取前台账户余额、信用额数据
--------------------------------------------------------------------
as
declare
	@lic_buy_1	varchar(255),
	@lic_buy_2	varchar(255)

select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')

if substring(@accnt,1,1)='A' and charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0
	select sta,lastnumb,balance = charge+charge0-credit-credit0 ,accredit from ar_master where accnt = @accnt
else
	select sta,lastnumb,balance = charge-credit,accredit from master where accnt = @accnt

return 0;
