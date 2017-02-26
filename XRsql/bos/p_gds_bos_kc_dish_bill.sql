// ------------------------------------------------------------------------------
//		bos 物流单据账单
// ------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_gds_bos_kc_dish_bill')
	drop proc p_gds_bos_kc_dish_bill;
create proc  p_gds_bos_kc_dish_bill
	@folio		char(10)
as

create table  #goutput (
	folio		char(10)			not null,
	code		char(8)			not null,
	name		varchar(18)		null,
	unit		varchar(4)		null,
	number	money	default 0 not null,
	price		money	default 0 not null,
	amount	money	default 0 not null,
	ref		varchar(20)		null,
	price1	money	default 0 not null,
	amount1	money	default 0 not null,
	profit	money	default 0 not null
)

insert #goutput
	select bos_kcdish.folio,bos_kcdish.code,
				bos_plu.name,bos_plu.unit,bos_kcdish.number,bos_kcdish.price,   
				bos_kcdish.amount,bos_kcdish.ref,bos_kcdish.price1,bos_kcdish.amount1,bos_kcdish.profit
		from bos_plu,bos_kcdish,bos_kcmenu
		where bos_plu.code = bos_kcdish.code
				and bos_plu.pccode = bos_kcmenu.pccode
				and bos_kcdish.folio = bos_kcmenu.folio
				and bos_kcdish.folio = @folio
		order by bos_kcdish.code

declare @inn int
select @inn = count(1) from #goutput
while @inn < 5
	begin
	insert #goutput (folio, code) values ('---', '---')
	select @inn = @inn + 1
	end
select folio,code,name,unit,number,price,amount,ref,price1,amount1,profit from #goutput order by code desc
return 0
;
