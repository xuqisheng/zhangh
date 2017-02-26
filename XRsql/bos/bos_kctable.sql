// ------------------------------------------------------------------------------
//		BOS ���������
//
//			bos_pccode
//
//			bos_provider			
//
//			bos_site
//			bos_site_sort
//
//			bos_kcmenu
//			bos_kcdish
//			bos_store
//			bos_hstore
//
//			bos_detail
//			bos_hdetail
//			bos_tmpdetail 
// ------------------------------------------------------------------------------
//		����  &  ���� ����������-- ���������޸ĳɱ��� !
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------
//	bos_pccode	:  BOS Ӫҵ�㶨��
// ------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "bos_pccode")
	drop table bos_pccode;
create table bos_pccode
(
	pccode		char(5)					not null,
	descript		varchar(24)				not null,
	descript1	varchar(24)				not null,
	sortlen		int default 2 			not null,	// ���������ĳ���
	site			int default 0  		not null,  	// �Ƿ��еص�Ĺ���: 0-��; 1-�ͷ�; 2-����
	jxc			int default 0  		not null,  	// �Ƿ��н��������: 0-no, 1-yes
	smode			char(1)	default '%' not null,	// �����   -- ȴʡֵ
	svalue		money		default 0 	not null,
	tmode			char(1)	default '%' not null,	// ���ӷ�
	tvalue		money		default 0 	not null,
	dmode			char(1)	default '%' not null,	// �ۿ�
	dvalue		money		default 0 	not null,
	site0			char(5)	 				not null,	// ȴʡ�ĵص�
	tag			char(1)	default ''	not null,	// S=shop
	chgcod		char(5)					not null,		//  code in pccode
	flag			char(10)	default '00' not null,	-- ����ģʽ ��һλ=����� �ڶ�λ=�ۿ� 0-���㲻�������ӷ�, 1-����������ӷ�
	sequence		int		default 0	not null
)
exec sp_primarykey bos_pccode, pccode
create unique index index1 on bos_pccode(pccode)
create unique index index2 on bos_pccode(chgcod)
;
//insert bos_pccode
//	select pccode, descript1, descript2, 2, 0, 0,'%',0,'%',0,'%',0,pccode,'' from chgcod 
//		where charindex(modu, '03/09/06')>0 and servcode is null;
//select * from bos_pccode;


// ------------------------------------------------------------------------------------
// bos_provider ----- ��Ӧ�̴���
// ------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "bos_provider")
	drop table bos_provider;
create table bos_provider
(
	accnt			char(7)		not null,			//�ʺ�:����
	sta			char(1)		not null,			//״̬ I, O, 
	nation      char(3) 		not null,       	//����
	name			varchar(50)	not null,			//����
	address  	varchar(60)	null,					//��ַ
	phone			varchar(30)	null,					//�绰
	fax  			varchar(20)	null,					//����
	zip  			char(10)		null,					//�ʱ�
	c_name		varchar(40)	null,					//��ϵ��
	intinfo		varchar(50)	null,					//��������Ϣ
	class			char(1)		null,					//����:
	locksta     char(1)     null,       		//����״̬
	limit			money			default 0 	not null,	//�޶�(������)
	arr			datetime		null,					//��Ч����
	dep			datetime		null,					//��Ч����,������Ϊֹ
   mkt     		char(5)     null,       		//�г���
	pccodes		varchar(20)	default '' not null,  //�����뷶Χ
	resby			char(10)		not null,					//�����˹���
	reserved		datetime	default getdate() not null, //����ʱ��,��ϵͳʱ��,�����޸�
	cby			char(10)		null,							//�޸��˹���
	changed		datetime		null,							//�޸�ʱ��
	ref			varchar(90)	null,							//��ע
	exp_m			money				null,
	exp_dt		datetime			null,
	exp_s			varchar(10)		null,
	logmark     int default 0 not null
);
exec sp_primarykey bos_provider,accnt
create unique index index1 on bos_provider(accnt)
create index index2 on bos_provider(name)
;


//------------------------------------------------------------------------------
// �ص��� -- �ֿ⣬��̨���������� ��
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'bos_site')
	drop table bos_site;
create table  bos_site (
	pccode	char(5)			not null,
	tag		char(2)			not null, 			// ���:��(�ֿ�) - ��(��̨) - ��(�ڲ�����)
	site		char(5)			not null,  			// --- ע�⣺ �ڲ����ű����� pccode �޹أ�����
	descript		varchar(24)		not null,		//  	�п��ֿܷ��༭���ܸ��ã�
	descript1	varchar(24)		not null			//		��ʱ���ͳһ�����ڲ�ͬ��pccode �У�site һ��
)
exec sp_primarykey bos_site,site
create unique index site on bos_site(site);
insert bos_site select pccode, '��', pccode, descript, descript1 from bos_pccode;


//------------------------------------------------------------------------------
// �ص���ۻ����壺����õص��ܹ�����ʲô��Ʒ 
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'bos_site_sort')
	drop table bos_site_sort;
create table  bos_site_sort (
	site		char(5)			not null,
	sort		varchar(20)	default '%' not null
);
exec sp_primarykey bos_site_sort,site,sort
create unique index site on bos_site_sort(site,sort)
;
insert bos_site_sort select site,'%' from bos_site;

//------------------------------------------------------------------------------
//		
//		��Ʒ������������  ------- ��ǰ
//		��������: ��<��>��, ���, ����, �̴�, ����
//
//		����ĵ��ݺ����ɵ��Ե��ź��ֹ��������
//			����ֻ�ܡ��������͡��������ա������Բ���ҪLOG�ֶ�
//			��������ʱ,�ı�״̬,���������ֶμ���;
//
//------------------------------------------------------------------------------

// ����
if exists (select 1 from sysobjects where name = 'bos_kcmenu')
	drop table bos_kcmenu
;
create table  bos_kcmenu (
	folio		char(10)			not null,				// ���Ե���(����+��ˮ��)
	pccode 	char(5)			not null,
	sfolio	varchar(20),								// �ֹ�����
	site0		char(5)			not null,				// ԭʼ�ص�
	site1		char(5)	default '' not null,  		// �ص�
	act_date	datetime			not null,				// ҵ��������
	bdate		datetime			not null,				// Ӫҵ����
	flag		char(2)			not null,				// ��������: ��<��>��, ���, ����, �̴�, ����
	sta		char(1)			not null,				// ״̬== I, X, O, D
	tag1		char(2)			null,						// ���ԭ��
	tag2		char(2)			null,						// �����ֶ�
	tag3		char(10)			null,						// �����ֶ�
	tag4		char(10)			null,						// �����ֶ�
	amount	money	default 0 not null,				// �ܽ��
	refer		varchar(50)		null,						// ��ע
	sby		char(10)			null,						// ���
	sdate		datetime			null,
	cby		char(10)			not null,				// ����
	cdate		datetime	default getdate()	not null,
	dby		char(10)			null,						// ����	
	ddate		datetime			null,
	dreason	varchar(20)		null,						// ����ԭ��
	pc_id		char(4)			null,						// ��ռ��־
	logmark	int default 0	not null
)
exec sp_primarykey bos_kcmenu, folio
create unique index fno on bos_kcmenu(folio)
create index sfno on bos_kcmenu(sfolio)
create index cby on bos_kcmenu(cby, folio)
create index bdate on bos_kcmenu(bdate, folio)
create index actdate on bos_kcmenu(act_date, folio)
;

//------------------------------------------------------------------------------
// ��ϸ����  -- Ҫ��ͬ���ݣ�����Ψһ
//				����������µ�
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'bos_kcdish')
	drop table bos_kcdish
;
create table  bos_kcdish (
	folio		char(10)			not null,				// ���Ե���(����+��ˮ��)
	code		char(8)			not null,				// ����
	name		varchar(18)		null,						
	number	money	default 0 not null,				// ����
	price		money	default 0 not null,				// ����
	amount	money	default 0 not null,				// �ɱ����
	price1	money	default 0 not null,				// ���۵���
	amount1	money	default 0 not null,				// ���۽��
	profit	money	default 0 not null,				// �������
	ref		varchar(20)		null						// ��ע
)
exec sp_primarykey bos_kcdish, folio, code
create unique index code on bos_kcdish(folio,code)
;
// ----------> �ϰ汾�Ľṹ�޸� sql ����
//exec sp_rename 'bos_kcdish.number0', price1;
//exec sp_rename 'bos_kcdish.price0', amount1;
//exec sp_rename 'bos_kcdish.amount0', profit;


//------------------------------------------------------------------------------
//	��������¼����  ---  ʵʱ��Ϣ
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'bos_store')
	drop table bos_store
;
create table  bos_store (
	id			char(6)		not null,
	pccode	char(5)		not null,
	site		char(5)		not null,			// �����
	code		char(8)		not null,			// ����
	number0	money	default 0	not null,	// ���ڽ���
	amount0	money	default 0 	not null,	// 
	sale0		money	default 0 	not null,	// 
	profit0	money	default 0 	not null,	// 
	number1	money	default 0	not null,	// ���
	amount1	money	default 0 	not null,	// 
	sale1		money	default 0 	not null,	// 
	profit1	money	default 0 	not null,	// 
	number2	money	default 0	not null,	// ���
	amount2	money	default 0 	not null,	// 
	sale2		money	default 0 	not null,	// 
	profit2	money	default 0 	not null,	// 
	number3	money	default 0	not null,	// �̴�
	amount3	money	default 0 	not null,	// 
	sale3		money	default 0 	not null,	// 
	profit3	money	default 0 	not null,	// 
	number4	money	default 0	not null,	// ����
	amount4	money	default 0 	not null,	// 
	sale4		money	default 0 	not null,	// 
	profit4	money	default 0 	not null,	// 
	number5	money	default 0	not null,	// ����
	amount5	money	default 0 	not null,	// 
	sale5		money	default 0 	not null,	// 
	disc		money	default 0 	not null,	// 
	profit5	money	default 0 	not null,	// 
	number6	money	default 0	not null,	// ����
	amount6	money	default 0 	not null,	// 
	sale6		money	default 0 	not null,	// 
	profit6	money	default 0 	not null,	// 
	number7	money	default 0	not null,	// ���ɱ���
	amount7	money	default 0 	not null,	// 
	sale7		money	default 0 	not null,	// 
	profit7	money	default 0 	not null,	// 
	number8	money	default 0	not null,	// �����ۼ�
	amount8	money	default 0 	not null,	// 
	sale8		money	default 0 	not null,	// 
	profit8	money	default 0 	not null,	// 
	number9	money	default 0	not null,	// ���
	amount9	money	default 0 	not null,	// 
	sale9		money	default 0 	not null,	// 
	profit9	money	default 0 	not null,	// 
	price0	money	default 0 	not null,	// ����
	price1	money	default 0 	not null		// �ۼ�
)
exec sp_primarykey bos_store, pccode,site,code
create unique index siteno on bos_store(pccode,site,code)
;

//------------------------------------------------------------------------------
//	��������¼����  ---  ��ʷ��Ϣ
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'bos_hstore')
	drop table bos_hstore
;
create table  bos_hstore (
	id			char(6)		not null,
	pccode	char(5)		not null,
	site		char(5)		not null,			// �����
	code		char(8)		not null,			// ����
	number0	money	default 0	not null,	// ���ڽ���
	amount0	money	default 0 	not null,	// 
	sale0		money	default 0 	not null,	// 
	profit0	money	default 0 	not null,	// 
	number1	money	default 0	not null,	// ���
	amount1	money	default 0 	not null,	// 
	sale1		money	default 0 	not null,	// 
	profit1	money	default 0 	not null,	// 
	number2	money	default 0	not null,	// ���
	amount2	money	default 0 	not null,	// 
	sale2		money	default 0 	not null,	// 
	profit2	money	default 0 	not null,	// 
	number3	money	default 0	not null,	// �̴�
	amount3	money	default 0 	not null,	// 
	sale3		money	default 0 	not null,	// 
	profit3	money	default 0 	not null,	// 
	number4	money	default 0	not null,	// ����
	amount4	money	default 0 	not null,	// 
	sale4		money	default 0 	not null,	// 
	profit4	money	default 0 	not null,	// 
	number5	money	default 0	not null,	// ����
	amount5	money	default 0 	not null,	// 
	sale5		money	default 0 	not null,	// 
	disc		money	default 0 	not null,	// 
	profit5	money	default 0 	not null,	// 
	number6	money	default 0	not null,	// ����
	amount6	money	default 0 	not null,	// 
	sale6		money	default 0 	not null,	// 
	profit6	money	default 0 	not null,	// 
	number7	money	default 0	not null,	// ���ɱ���
	amount7	money	default 0 	not null,	// 
	sale7		money	default 0 	not null,	// 
	profit7	money	default 0 	not null,	// 
	number8	money	default 0	not null,	// �����ۼ�
	amount8	money	default 0 	not null,	// 
	sale8		money	default 0 	not null,	// 
	profit8	money	default 0 	not null,	// 
	number9	money	default 0	not null,	// ���
	amount9	money	default 0 	not null,	// 
	sale9		money	default 0 	not null,	// 
	profit9	money	default 0 	not null,	// 
	price0	money	default 0 	not null,	// ����
	price1	money	default 0 	not null		// �ۼ�
)
exec sp_primarykey bos_hstore,id,pccode,site,code
create unique index siteno on bos_hstore(id,pccode,site,code)
;


//------------------------------------------------------------------------------
//		��Ʒ������ϸ�� --- ��ǰ
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'bos_detail')
	drop table bos_detail;
create table  bos_detail (
	pccode 	char(5)			not null,
	site		char(5)			not null,				// �ص�
	code		char(8)			not null,				// ����
	id			char(6)			not null,				// ��������
	ii			int				not null,				// �������
	flag		char(2)			not null,				// �������� -- ��/��/��/��/��/��/��/��   -- + ��
	descript	varchar(20)		null,						// ����: ��-�����ͷ�/��-������
	folio		char(10)			not null,				// ���Ե���(����+��ˮ��)
	sfolio	varchar(20)		null,						// �ֹ�����
	fid		int	default 0	not null,			// �������
	rsite		char(5)	default '' not null,  		// ��صص�
	bdate		datetime			not null,				// Ӫҵ����
	act_date	datetime			not null,				// ҵ��������
	log_date	datetime			not null,				// ������������
	empno		char(10)			null,						// 

	number	money	default 0 not null,				// ����		-------- ��ǰҵ��
	amount0	money	default 0 not null,				// ����
	amount	money	default 0 not null,				// �ۼ�
	disc		money	default 0 not null,				// �ۿ�
	profit	money	default 0 not null,				// �������

	gnumber	money	default 0 not null,				// ����		---------  ���
	gamount0	money	default 0 not null,				// ����
	gamount	money	default 0 not null,				// �ۼ�
	gprofit	money	default 0 not null,				// �������

	price0	money	default 0 not null,				// ����
	price1	money	default 0 not null,				// �ۼ�
)
exec sp_primarykey bos_detail,pccode,site,code,ii
create unique index index1 on bos_detail(pccode,site,code,ii)
create index sfno on bos_detail(sfolio)
create index fno on bos_detail(folio)
create index bdate on bos_detail(bdate)
create index actdate on bos_detail(act_date)
create index code on bos_detail(code,folio)
create index empno on bos_detail(empno,folio)
;


//------------------------------------------------------------------------------
//		��Ʒ������ϸ�� --- ��ʷ
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'bos_hdetail')
	drop table bos_hdetail;
create table  bos_hdetail (
	pccode 	char(5)			not null,
	site		char(5)			not null,				// �ص�
	code		char(8)			not null,				// ����
	id			char(6)			not null,				// ��������
	ii			int				not null,				// �������
	flag		char(2)			not null,				// �������� -- ��/��/��/��/��/��/��/��   -- + ��
	descript	varchar(20)		null,						// ����: ��-�����ͷ�/��-������
	folio		char(10)			not null,				// ���Ե���(����+��ˮ��)
	sfolio	varchar(20)		null,						// �ֹ�����
	fid		int	default 0	not null,			// �������
	rsite		char(5)	default '' not null,  		// ��صص�
	bdate		datetime			not null,				// Ӫҵ����
	act_date	datetime			not null,				// ҵ��������
	log_date	datetime			not null,				// ������������
	empno		char(10)			null,						// 

	number	money	default 0 not null,				// ����		-------- ��ǰҵ��
	amount0	money	default 0 not null,				// ����
	amount	money	default 0 not null,				// �ۼ�
	disc		money	default 0 not null,				// �ۿ�
	profit	money	default 0 not null,				// �������

	gnumber	money	default 0 not null,				// ����		---------  ���
	gamount0	money	default 0 not null,				// ����
	gamount	money	default 0 not null,				// �ۼ�
	gprofit	money	default 0 not null,				// �������

	price0	money	default 0 not null,				// ����
	price1	money	default 0 not null,				// �ۼ�
)
exec sp_primarykey bos_hdetail,id,pccode,site,code,ii
create unique index index1 on bos_hdetail(id,pccode,site,code,ii)
create index sfno on bos_hdetail(sfolio)
create index fno on bos_hdetail(folio)
create index bdate on bos_hdetail(bdate)
create index actdate on bos_hdetail(act_date)
create index code on bos_hdetail(code,folio)
create index empno on bos_hdetail(empno,folio)
;


// ------------------------------------------------------------------------------
// ��ʱ�� === ��ϸ����Դ --- �������� �� ���۵��� 
// ------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'bos_tmpdetail' and type='U')
	drop table bos_tmpdetail;
create table bos_tmpdetail 
(
	modu_id	char(2)			not null,
	pc_id		char(4)			not null,
	folio		char(10)			not null,				// ���Ե���(����+��ˮ��)
	sfolio	varchar(20),								// �ֹ�����
	site		char(5)	default '' not null,  		// �ص�
	rsite		char(5)	default '' not null,  		// ��صص�
	act_date	datetime			not null,				// ҵ��������
	bdate		datetime			not null,				// Ӫҵ����
	flag		char(2)			not null,				// ��������: ��<��>��, ���, ����, �̴�, ����
	cby		char(10)			not null,				// ����
	cdate		datetime	default getdate()	not null,
	fid		int				not null,				// ��������=0  ���۵���=id
	code		char(8)			not null,				// ����
	number	money	default 0 not null,				// ����
	amount	money	default 0 not null,				// �ɱ����
	amount1	money	default 0 not null,				// ���۽��
	disc		money	default 0 not null,				// �ۿ�
	profit	money	default 0 not null,				// �������
	ref		varchar(20)		null						// ��ע
)
exec sp_primarykey bos_tmpdetail,modu_id,pc_id,folio,site,code,fid
create unique index index1 on bos_tmpdetail(modu_id,pc_id,folio,site,code,fid)
;
