IF OBJECT_ID('dbo.p_zk_auto_order_code') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.p_zk_auto_order_code
END;

create proc p_zk_auto_order_code
	
as
declare		@ret		int,
				@msg		varchar(60),
				@bdate	datetime,
				@value 		char(200)

select @value = value from sysoption where catalog = 'hotel' and item = 'auto_order_code'
select @bdate = dateadd(dd , -1 , bdate1) from sysdata

if charindex('country;',@value) > 0
	update countrycode set sequence = sequence + isnull((select count(1) from cus_xf c where rtrim(c.country) = rtrim(countrycode.code) and c.bdate = @bdate ),0) 

return 0
;

