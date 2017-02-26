if exists(select * from sysobjects where name = "p_bill_print_exchange")
   drop proc p_bill_print_exchange
;
create proc p_bill_print_exchange
	@foliono			char(10)
as

------------------------------------------------------------
--		打印外币兑换单
------------------------------------------------------------
create table #gout (
	foliono			char(10)					not null,				// 电脑流水号
	sta				char(1)					not null,				// I, X
	sno				varchar(12)				null,						// 手工单号
	tag				char(1)	default '1'	not null,  				// 1=外部, 0=内部
	bdate				datetime					not null,
	gstid				char(7)					null,
	roomno			char(5) default '' 	null,
	name				varchar(50)				not null,
	nation			char(3)					not null,
	idcls				char(3)					not null,
	ident				char(20)					not null,
	code				char(3)					not null,				// 代码
	class				char(5) default 'CASH' not null, 			// CASH, CHECK
	amount0			money		default 0 	not null,				// 金额
	disc				money		default 0 	not null,				// 扣贴息
	amount			money		default 0 	not null,				// 净额
	price				money		default 0 	not null,				// 买入价
	amount_out		money		default 0 	not null,				// 兑出币
	ref				varchar(100)			null,
	resby				char(10)					not null,
	reserved			datetime					not null,
	cby				char(10)					not null,
	changed			datetime					not null,
	logmark			int		default 0	not null
)

--
if exists(select 1 from fec_folio where foliono=@foliono)
	insert #gout select * from fec_folio where foliono=@foliono
else
begin
	insert #gout select * from fec_hfolio where foliono=@foliono
end

-- output
SELECT foliono, bdate, sta, sno, tag, bdate, gstid, roomno, name, idcls, ident, code, class, 
		amount0, disc, amount, price, amount_out, ref, resby, nation, reserved, cby, changed  
	from #gout

return 0
;