// ------------------------------------------------------------------------------
//		bos 物流单据账单
// ------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'p_wz_bos_kc_dish_bill')
	drop proc p_wz_bos_kc_dish_bill;
create proc  p_wz_bos_kc_dish_bill
	@folio		char(10)
as
declare @inn int

create table  #woutput (
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

insert #woutput
	select b.folio,b.code,
				a.name,a.unit,b.number,b.price,   
				b.amount,b.ref,b.price1,b.amount1,b.profit
		from bos_plu a,bos_kcdish b,bos_kcmenu c
		where a.code = b.code
				and a.pccode = c.pccode
				and b.folio = c.folio
				and b.folio = @folio
		order by b.code


select @inn = count(1) from #woutput
while @inn < 5
	begin
	insert #woutput (folio, code) values ('---', '---')
	select @inn = @inn + 1
	end
select folio,code,name,unit,number,price,amount,ref,price1,amount1,profit from #woutput order by code desc
return 0
;
