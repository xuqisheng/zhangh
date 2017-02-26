// ��Ҷһ���ر�

//exec sp_rename fec_def, a_fec_def;

// ��Ҷһ��Ƽ�
if exists(select * from sysobjects where name = "fec_def")
   drop table fec_def;
create table fec_def
(
	code				char(3)					not null,				//����
	descript			char(30)					not null,				//��������
	descript1		char(30)					null,						//Ӣ������
	disc				money		default 0 	not null,				//����Ϣ
	base				money		default 100 not null,				//����
	price_in			money		default 0 	not null,				//�����
	price_out		money		default 0 	not null,				//������
	price_cash		money		default 0 	not null, 				//�ֳ���
	cby				char(10)	default ''	not null,
	changed			datetime					null,
	logmark			int		default 0	not null
)
exec   sp_primarykey fec_def, code
create unique index index1 on fec_def(code)
;

if exists(select * from sysobjects where name = "fec_def_log")
   drop table fec_def_log;
create table fec_def_log
(
	code				char(3)					not null,				//����
	descript			char(30)					not null,				//��������
	descript1		char(30)					null,						//Ӣ������
	disc				money		default 0 	not null,				//����Ϣ
	base				money		default 100 not null,				//����
	price_in			money		default 0 	not null,				//�����
	price_out		money		default 0 	not null,				//������
	price_cash		money		default 0 	not null, 				//�ֳ���
	cby				char(10)	default ''	not null,
	changed			datetime					null,
	logmark			int		default 0	not null
)
exec   sp_primarykey fec_def_log, code, logmark
create unique index index1 on fec_def_log(code, logmark)
;

//insert fec_def select * , '', getdate(), 0 from a_fec_def;

// ��Ҷһ���ˮ��
if exists(select * from sysobjects where name = "fec_folio")
   drop table fec_folio;
create table fec_folio
(
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
exec   sp_primarykey fec_folio, foliono
create unique index index1 on fec_folio(foliono)
;
if exists(select * from sysobjects where name = "fec_folio_log")
   drop table fec_folio_log;
create table fec_folio_log
(
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
exec   sp_primarykey fec_folio_log, foliono, logmark
create unique index index1 on fec_folio_log(foliono, logmark)
;

// ��Ҷһ���ˮ�� - ��ʷ��¼
if exists(select * from sysobjects where name = "fec_hfolio")
   drop table fec_hfolio;
create table fec_hfolio
(
	foliono			char(10)					not null,				// ������ˮ��
	sta				char(1)					not null,				// I, X
	sno				varchar(12)				null,						// �ֹ�����
	tag				char(1)	default '1'	not null,  				// 1=�ⲿ, 0=�ڲ�
	bdate				datetime					not null,
	gstid				char(7) default ''	null,
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
exec   sp_primarykey fec_hfolio, foliono
create unique index index1 on fec_hfolio(foliono)
create index index2 on fec_hfolio(bdate)
create index index3 on fec_hfolio(name)
create index index4 on fec_hfolio(roomno)
;
