// -----------------------------------------------------------------------------
//	BOS 报表
//		
//			p_gds_bos_dish_sale
//			p_gds_bos_shop_rep
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
// BOS 销售报表
// -----------------------------------------------------------------------------
if exists ( select * from sysobjects where name = 'p_gds_bos_dish_sale' and type ='P')
	drop proc p_gds_bos_dish_sale;
create proc p_gds_bos_dish_sale
	@begin_		datetime,
	@end_			datetime,
	@site			varchar(255),
	@class		varchar(255),
	@sort			varchar(255),
	@provider	varchar(255)
as
create table #sale(
	pccode		char(5)					not null,
   site     	char(5)     			not null,
   code     	char(8)     			not null,
	number      money  default 0 		not null,
	fee			money	default 0 		not null,
	fee_base	   money	default 0 	   not null,
	fee_serve	money	default 0 	   not null,
	fee_tax  	money	default 0 	   not null,
	fee_disc 	money	default 0 	   not null,
	amount0		money default 0  		not null
)

select @sort=rtrim(@sort), @provider=rtrim(@provider), @site=rtrim(@site), @class=rtrim(@class)

insert #sale 
	select b.pccode,b.site0,a.code,sum(a.number),sum(a.fee),sum(a.fee_base),sum(a.fee_serve),sum(a.fee_tax),sum(a.fee_disc),sum(a.amount0)
		from bos_hdish a,bos_hfolio b,bos_plu c
			where a.foliono=b.foliono and b.sta='O'
				and a.sta='I' and b.pccode=c.pccode 
				and a.code=c.code and b.pccode='50'
				and (@begin_ is null or b.bdate1>=@begin_)
				and (@end_ is null or b.bdate1<=@end_)
				and ( @site is null or charindex(rtrim(b.site0),@site)>0 )
				and ( @class is null or charindex(rtrim(c.class),@class)>0 )
				and ( @sort is null or charindex(rtrim(c.sort),@sort)>0 )
				and ( @provider is null or charindex(c.provider,@provider)>0 )
		group by b.pccode,b.site0,a.code

select a.code,b.name,e.descript,b.standent,b.unit,a.number,price0=a.amount0/a.number,a.amount0,
		price=a.fee/a.number,a.fee,dist=a.fee-a.amount0,f.descript,provider=' '+c.accnt+'-'+c.name,sort=d.sort+'-'+d.name
	from #sale a, bos_plu b, bos_provider c, bos_sort d, basecode e,bos_site f
		where a.pccode=b.pccode and a.code=b.code and b.provider*=c.accnt and a.number<>0
			and b.pccode=d.pccode and b.sort=d.sort and e.cat='bos_plu_class' and b.class=e.code and a.site=f.site 
return 0
;


// ------------------------------------------------------------------------------------
// 商场报表 -- 新侨饭店
//			1.	单一费用码
//			2. 注意合并结账		
// ------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "p_gds_bos_shop_rep" and type = "P")
   drop proc p_gds_bos_shop_rep;
create proc    p_gds_bos_shop_rep
	@pccode		char(5),
	@posno		char(2),
	@begin		datetime,
	@end			datetime,
	@empno		char(10),
	@shift		char(1)
as

// ------------------------------------------------
// 1. begin
// ------------------------------------------------
// 输出表
create table #goutput (
	posno		char(2)				not null,
	name		varchar(20)			not null,
	site		char(5)				not null,
	sitedes	varchar(20)			null,
	base		money	default 0	not null,
	srv		money	default 0	not null,	// 服务费
	tax		money	default 0	not null,	
	dsc0		money	default 0	not null,	// 事前折扣
	fee		money	default 0	not null,
	rmb		money	default 0	not null,
	chk		money	default 0	not null,
	crd1		money	default 0	not null,
	crd2		money	default 0	not null,
	toa		money	default 0	not null,
	tor		money	default 0	not null,
	oth		money	default 0	not null,
	tl			money	default 0	not null,	// 净收入
	dsc		money	default 0	not null,	// 事后折扣
	ent	 	money	default 0	not null,
	ttl		money	default 0	not null,	// 总收入
	ref		varchar(30)			null
)
// 有合并结账的单据
create table #setnumb(setnumb char(10) not null)

if rtrim(@posno) is null	
	select @posno = ''
insert #goutput (posno,name,site,sitedes)
	select @posno, '', site, descript from bos_site where pccode=@pccode and tag<>'部'
	union select @posno, '', 'XXXXX', '合并结账' 
	

// ------------------------------------------------
// 2. sum 
// ------------------------------------------------
declare 	@bdate		datetime
select @bdate = bdate1 from sysdata
if @bdate=@begin and @bdate=@end 
	begin
	insert #setnumb select setnumb from bos_folio 
		where sta='O' group by setnumb having count(1)>1
	// ------------------------------------------------
	// 本日  -- 单独结账
	// ------------------------------------------------
	// fee_base
	update #goutput set base = base + isnull((select sum(a.fee_base) from bos_folio a 
		where a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// fee_srv
	update #goutput set srv = srv + isnull((select sum(a.fee_serve) from bos_folio a 
		where a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// fee_tax
	update #goutput set tax = tax + isnull((select sum(a.fee_tax) from bos_folio a 
		where a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// fee_dsc0
	update #goutput set dsc0 = dsc0 + isnull((select sum(a.fee_disc) from bos_folio a 
		where a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// fee
	update #goutput set fee = fee + isnull((select sum(a.fee) from bos_folio a 
		where a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// rmb
	update #goutput set rmb = rmb + isnull((select sum(b.amount) from bos_folio a, bos_account b, pccode c
		where a.setnumb=b.setnumb  and a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and b.code=c.pccode and c.deptno='A'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// chk
	update #goutput set chk = chk + isnull((select sum(b.amount) from bos_folio a, bos_account b, pccode c
		where a.setnumb=b.setnumb  and a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and b.code=c.pccode and c.deptno='B'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// crd1
	update #goutput set crd1 = crd1 + isnull((select sum(b.amount) from bos_folio a, bos_account b, pccode c
		where a.setnumb=b.setnumb  and a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and b.code=c.pccode and c.deptno='C'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// crd2
	update #goutput set crd2 = crd2 + isnull((select sum(b.amount) from bos_folio a, bos_account b, pccode c
		where a.setnumb=b.setnumb  and a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and b.code=c.pccode and c.deptno='D'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// toa
	update #goutput set toa = toa + isnull((select sum(b.amount) from bos_folio a, bos_account b, pccode c
		where a.setnumb=b.setnumb  and a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and b.code=c.pccode and c.deptno='I' and b.accnt<>'1950006'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// tor
	update #goutput set tor = tor + isnull((select sum(b.amount) from bos_folio a, bos_account b, pccode c
		where a.setnumb=b.setnumb  and a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and b.code=c.pccode and (c.deptno='J' or b.accnt='1950006')
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// dsc
	update #goutput set dsc = dsc + isnull((select sum(b.amount) from bos_folio a, bos_account b
		where a.setnumb=b.setnumb  and a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and b.code='993'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// ent
	update #goutput set ent = ent + isnull((select sum(b.amount) from bos_folio a, bos_account b
		where a.setnumb=b.setnumb  and a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and b.code='994'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// oth
	update #goutput set oth = oth + isnull((select sum(b.amount) from bos_folio a, bos_account b, pccode c
		where a.setnumb=b.setnumb  and a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and b.code=c.pccode and not (c.deptno in ('A','B','C','D','I','J') or b.code='993' or b.code='994')
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)	
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	
	// ------------------------------------------------
	// 本日  -- 合并结账
	// ------------------------------------------------
	// fee_base
	update #goutput set base = base + isnull((select sum(a.fee_base) from bos_folio a 
		where a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// fee_srv
	update #goutput set srv = srv + isnull((select sum(a.fee_serve) from bos_folio a 
		where a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// fee_tax
	update #goutput set tax = tax + isnull((select sum(a.fee_tax) from bos_folio a 
		where a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// fee_dsc0
	update #goutput set dsc0 = dsc0 + isnull((select sum(a.fee_disc) from bos_folio a 
		where a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// fee
	update #goutput set fee = fee + isnull((select sum(a.fee) from bos_folio a 
		where a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// rmb
	update #goutput set rmb = rmb + isnull((select sum(b.amount) from bos_folio a, bos_account b, pccode c
		where a.setnumb=b.setnumb  and a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and b.code=c.pccode and c.deptno='A'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// chk
	update #goutput set chk = chk + isnull((select sum(b.amount) from bos_folio a, bos_account b, pccode c
		where a.setnumb=b.setnumb  and a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and b.code=c.pccode and c.deptno='B'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// crd1
	update #goutput set crd1 = crd1 + isnull((select sum(b.amount) from bos_folio a, bos_account b, pccode c
		where a.setnumb=b.setnumb  and a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and b.code=c.pccode and c.deptno='C'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// crd2
	update #goutput set crd2 = crd2 + isnull((select sum(b.amount) from bos_folio a, bos_account b, pccode c
		where a.setnumb=b.setnumb  and a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and b.code=c.pccode and c.deptno='D'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// toa
	update #goutput set toa = toa + isnull((select sum(b.amount) from bos_folio a, bos_account b, pccode c
		where a.setnumb=b.setnumb  and a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and b.code=c.pccode and c.deptno='I' and b.accnt<>'1950006'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// tor
	update #goutput set tor = tor + isnull((select sum(b.amount) from bos_folio a, bos_account b, pccode c
		where a.setnumb=b.setnumb  and a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and b.code=c.pccode and (c.deptno='J' or b.accnt='1950006')
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// dsc
	update #goutput set dsc = dsc + isnull((select sum(b.amount) from bos_folio a, bos_account b
		where a.setnumb=b.setnumb  and a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and b.code='993'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// ent
	update #goutput set ent = ent + isnull((select sum(b.amount) from bos_folio a, bos_account b
		where a.setnumb=b.setnumb  and a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and b.code='994'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// oth
	update #goutput set oth = oth + isnull((select sum(b.amount) from bos_folio a, bos_account b, pccode c
		where a.setnumb=b.setnumb  and a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and b.code=c.pccode and not (c.deptno in ('A','B','C','D','I','J') or b.code='993' or b.code='994')
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)	
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	
	end
else
	begin
	insert #setnumb select setnumb from bos_hfolio 
		where sta='O' group by setnumb having count(1)>1
	// ------------------------------------------------
	// 历史  -- 单独结账
	// ------------------------------------------------
	// fee_base
	update #goutput set base = base + isnull((select sum(a.fee_base) from bos_hfolio a 
		where a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// fee_srv
	update #goutput set srv = srv + isnull((select sum(a.fee_serve) from bos_hfolio a 
		where a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// fee_tax
	update #goutput set tax = tax + isnull((select sum(a.fee_tax) from bos_hfolio a 
		where a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// fee_dsc0
	update #goutput set dsc0 = dsc0 + isnull((select sum(a.fee_disc) from bos_hfolio a 
		where a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// fee
	update #goutput set fee = fee + isnull((select sum(a.fee) from bos_hfolio a 
		where a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// rmb
	update #goutput set rmb = rmb + isnull((select sum(b.amount) from bos_hfolio a, bos_haccount b, pccode c
		where a.setnumb=b.setnumb and a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and b.code=c.pccode and c.deptno='A'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// chk
	update #goutput set chk = chk + isnull((select sum(b.amount) from bos_hfolio a, bos_haccount b, pccode c
		where a.setnumb=b.setnumb and a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and b.code=c.pccode and c.deptno='B'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// crd1
	update #goutput set crd1 = crd1 + isnull((select sum(b.amount) from bos_hfolio a, bos_haccount b, pccode c
		where a.setnumb=b.setnumb and a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and b.code=c.pccode and c.deptno='C'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// crd2
	update #goutput set crd2 = crd2 + isnull((select sum(b.amount) from bos_hfolio a, bos_haccount b, pccode c
		where a.setnumb=b.setnumb and a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and b.code=c.pccode and c.deptno='D'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// toa
	update #goutput set toa = toa + isnull((select sum(b.amount) from bos_hfolio a, bos_haccount b, pccode c
		where a.setnumb=b.setnumb and a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and b.code=c.pccode and c.deptno='I' and b.accnt<>'1950006'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// tor
	update #goutput set tor = tor + isnull((select sum(b.amount) from bos_hfolio a, bos_haccount b, pccode c
		where a.setnumb=b.setnumb and a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and b.code=c.pccode and (c.deptno='J' or b.accnt='1950006')
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// dsc
	update #goutput set dsc = dsc + isnull((select sum(b.amount) from bos_hfolio a, bos_haccount b
		where a.setnumb=b.setnumb and a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and b.code='993'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// ent
	update #goutput set ent = ent + isnull((select sum(b.amount) from bos_hfolio a, bos_haccount b
		where a.setnumb=b.setnumb and a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and b.code='994'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	// oth
	update #goutput set oth = oth + isnull((select sum(b.amount) from bos_hfolio a, bos_haccount b, pccode c
		where a.setnumb=b.setnumb and a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb not in (select setnumb from #setnumb)
			and b.code=c.pccode and not (c.deptno in ('A','B','C','D','I','J') or b.code='993' or b.code='994')
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)	
			and (@posno='' or a.posno=@posno) and a.site0=#goutput.site),0)
	
	// ------------------------------------------------
	// 历史  -- 合并结账
	// ------------------------------------------------
	// fee_base
	update #goutput set base = base + isnull((select sum(a.fee_base) from bos_hfolio a 
		where a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// fee_srv
	update #goutput set srv = srv + isnull((select sum(a.fee_serve) from bos_hfolio a 
		where a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// fee_tax
	update #goutput set tax = tax + isnull((select sum(a.fee_tax) from bos_hfolio a 
		where a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// fee_dsc0
	update #goutput set dsc0 = dsc0 + isnull((select sum(a.fee_disc) from bos_hfolio a 
		where a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// fee
	update #goutput set fee = fee + isnull((select sum(a.fee) from bos_hfolio a 
		where a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// rmb
	update #goutput set rmb = rmb + isnull((select sum(b.amount) from bos_hfolio a, bos_haccount b, pccode c
		where a.setnumb=b.setnumb and a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and b.code=c.pccode and c.deptno='A'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// chk
	update #goutput set chk = chk + isnull((select sum(b.amount) from bos_hfolio a, bos_haccount b, pccode c
		where a.setnumb=b.setnumb and a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and b.code=c.pccode and c.deptno='B'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// crd1
	update #goutput set crd1 = crd1 + isnull((select sum(b.amount) from bos_hfolio a, bos_haccount b, pccode c
		where a.setnumb=b.setnumb and a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and b.code=c.pccode and c.deptno='C'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// crd2
	update #goutput set crd2 = crd2 + isnull((select sum(b.amount) from bos_hfolio a, bos_haccount b, pccode c
		where a.setnumb=b.setnumb and a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and b.code=c.pccode and c.deptno='D'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// toa
	update #goutput set toa = toa + isnull((select sum(b.amount) from bos_hfolio a, bos_haccount b, pccode c
		where a.setnumb=b.setnumb and a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and b.code=c.pccode and c.deptno='I' and b.accnt<>'1950006'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// tor
	update #goutput set tor = tor + isnull((select sum(b.amount) from bos_hfolio a, bos_haccount b, pccode c
		where a.setnumb=b.setnumb and a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and b.code=c.pccode and (c.deptno='J' or b.accnt='1950006')
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// dsc
	update #goutput set dsc = dsc + isnull((select sum(b.amount) from bos_hfolio a, bos_haccount b
		where a.setnumb=b.setnumb and a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and b.code='993'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// ent
	update #goutput set ent = ent + isnull((select sum(b.amount) from bos_hfolio a, bos_haccount b
		where a.setnumb=b.setnumb and a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and b.code='994'
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	// oth
	update #goutput set oth = oth + isnull((select sum(b.amount) from bos_hfolio a, bos_haccount b, pccode c
		where a.setnumb=b.setnumb and a.bdate1>=@begin and a.bdate1<=@end and a.pccode=@pccode
			and a.sta='O' and a.setnumb in (select setnumb from #setnumb)
			and b.code=c.pccode and not (c.deptno in ('A','B','C','D','I','J') or b.code='993' or b.code='994')
			and (@empno='' or a.empno2=@empno) and (@shift='' or a.shift2=@shift)	
			and (@posno='' or a.posno=@posno)),0)  where site='XXXXX'
	
	end

// ------------------------------------------------
//	3. end 
// ------------------------------------------------
update #goutput set tl=rmb+chk+crd1+crd2+tor+toa+oth
update #goutput set ttl=tl+dsc+ent

//
if @posno = ''
	update #goutput set name='所有收银点'
else
	update #goutput set name=a.descript from bos_posdef a where #goutput.posno=a.posno

// 删除
if exists(select 1 from #goutput where site='XXXXX' and ttl = 0)
	delete #goutput where site='XXXXX'
if exists(select 1 from #goutput where site='50' and ttl = 0)
	delete #goutput where site='50'

//
insert #goutput select posno,name,'ZZZZZ','合  计',sum(base),sum(srv),sum(tax),
	sum(dsc0),sum(fee),sum(rmb),sum(chk),sum(crd1),sum(crd2),sum(toa),sum(tor),
	sum(oth),sum(tl),sum(dsc),sum(ent),sum(ttl),''
	from #goutput group by posno,name

select name,sitedes,base,srv,dsc0,fee,rmb,chk,crd1+crd2,toa,tor,oth,tl,dsc,ent,ttl from #goutput order by site
return 0
;
