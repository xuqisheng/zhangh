if exists(select * from sysobjects where name = 'p_gds_bos_ar_rep')
	drop proc p_gds_bos_ar_rep;

create proc p_gds_bos_ar_rep
	@accnt		char(10),
	@begin_		datetime,
	@end_			datetime,
	@moduno		char(2),			                  
	@pccode		char(5)			              
as

declare 	@arname		varchar(50)
select @arname=b.name from master a,guest b where a.accnt=@accnt and a.haccnt=b.no
if @@rowcount=0  or rtrim(@arname) is null
	select @arname='NULL'

create table #setnumb(
	accnt			char(10)					not null
)
create table #folio(
	accnt			char(10)					not null
)
create table #sale(
	accnt			char(10)					not null,
   arname     	varchar(50) default ''   null,
   code     	char(8)     			not null,
   name     	varchar(50) default ''   null,
	number      money default 0 		not null,
	price      	money default 0 		not null,
	pfee			money	default 0 		not null,
	disc 			money	default 0 	   not null,
	fee			money default 0  		not null
)

insert #setnumb select distinct ref1
	from account 
	where accnt = @accnt and modu_id = @moduno and pccode = @pccode
		and bdate>=@begin_ and bdate<=@end_
insert #folio select distinct foliono 
	from bos_hfolio
	where setnumb in (select accnt from #setnumb)

insert #sale(accnt,arname,code,name,number,price,pfee,disc,fee)
	select @accnt,@arname,a.code,'',sum(a.number),0,sum(a.pfee),0,sum(a.fee)
		from bos_hdish a, bos_hfolio b, #folio c
			where a.foliono=b.foliono and b.foliono=c.accnt 
				and a.sta='I'
		group by a.code

                   
delete #sale where number=0 and fee=0 and pfee=0
update #sale set name=a.name from bos_plu a
	where a.pccode=@pccode and a.code=#sale.code
update #sale set price=round(pfee/number,2) where number<>0
update #sale set disc=round((pfee-fee)*100/pfee,2) where pfee<>0 and pfee<>fee

                   
select arname, code, name, number, price, pfee, disc, fee from #sale order by code

return 0;
