if exists(select * from sysobjects where name = "p_bill_print_exchange")
   drop proc p_bill_print_exchange
;
create proc p_bill_print_exchange
	@foliono			char(10)
as

------------------------------------------------------------
--		��ӡ��Ҷһ���
------------------------------------------------------------
create table #gout (
	foliono			char(10)					not null,				// ������ˮ��
	sta				char(1)					not null,				// I, X
	sno				varchar(12)				null,						// �ֹ�����
	tag				char(1)	default '1'	not null,  				// 1=�ⲿ, 0=�ڲ�
	bdate				datetime					not null,
	gstid				char(7)					null,
	roomno			char(5) default '' 	null,
	name				varchar(50)				not null,
	nation			char(3)					not null,
	idcls				char(3)					not null,
	ident				char(20)					not null,
	code				char(3)					not null,				// ����
	class				char(5) default 'CASH' not null, 			// CASH, CHECK
	amount0			money		default 0 	not null,				// ���
	disc				money		default 0 	not null,				// ����Ϣ
	amount			money		default 0 	not null,				// ����
	price				money		default 0 	not null,				// �����
	amount_out		money		default 0 	not null,				// �ҳ���
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