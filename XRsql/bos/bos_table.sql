/*

 bosϵͳ �� �ڶ�����ϵͳ �� ��������ϵͳ  ���� 
 modu = '09'
 �ͷ����ģ��������� �����˲��ô�ģ��
				2001/05/10			

bos_folio			���õ�
bos_hfolio
bos_dish
bos_hdish

bos_account			����
bos_haccount
bos_partout

bos_reason			�Ż�����
bos_partfolio		ǰ̨��

bos_plu				����
bos_sort

bos_posdef			վ�㶨��
bos_station

bos_mode_name		ģʽ

bos_tblsta			�ص�
bos_tblav

bos_empno			����

bos_itemdef			���붨��

bos_extno			�������ķֻ�
bos_tmpdish			����������ʱ��

bosjie; ybosjie
bosdai; ybosdai

*/


/*
	bos���û��ܱ�
*/
if exists(select * from sysobjects where name = "bos_folio" and type="U")
	drop table bos_folio;

create table bos_folio
(
	log_date    datetime    default getdate()   not null,   /*�������*/
	bdate    	datetime   	not null,	/*�����������޸�Ӫҵ��,��������folionoʶ��*/
	bdate1      datetime   	null    ,	/*�������ʻ򱻳���Ӫҵ��*/
	foliono		char(10)	   not null,	/*���к�*/
	sfoliono		varchar(10)	default '' null,
	site			char(5)	   null,			/*�ص�*/
	sta			char(1)		not null,	/*״̬,"M"�ֹ�����δ��,"P",�绰ת��δ��, "H",�绰ת��δ��,"O"�ѽ�,"C"����,"X"����,"T"ֱ����̨��*/
   setnumb     char(10)    null    ,   /*�������*/ 
	modu			char(2)		not null,	/*ģ���*/
	pccode		char(5)		not null,	/*������*/
	name	   	char(24)		null,			/*����������*/
	posno       char(3)     not null,
	mode	      char(3)		null,			/* ϵͳ��*/

	fee			money	default 0 		not null,   /*�����ܶ�*/
	fee_base	   money	default 0 	   not null,	/*������*/
	fee_serve	money	default 0 	   not null,	/*�����*/
	fee_tax  	money	default 0 	   not null,	/*���ӷ�*/
	fee_disc 	money	default 0 	   not null,	/*�ۿ۷�*/

	serve_type 	char(1)	default '0' not null,	/*����ѷ�ʽ   0:���� 1:���*/
	serve_value money		default 0   not null,	/*�������ֵ*/
	tax_type  	char(1)	default '0' not null,	/*���ӷѷ�ʽ   0:���� 1:���*/
	tax_value  	money		default 0   not null,	/*���ӷ���ֵ*/
	disc_type   char(1)	default '0' not null,	/*�Żݷ�ʽ   0:���� 1:���*/
	disc_value	 money	default 0 	not null,	/*�Żݱ���*/
	reason		char(3)					null,			/*�Ż�ԭ��*/

	pfee		   money	default 0 	   not null,   /*ԭ�����ܶ�*/
	pfee_base	money	default 0 	   not null,	/*ԭ������*/
	pfee_serve	money	default 0 	   not null,	/*ԭ�����*/
	pfee_tax 	money	default 0 	   not null,	/*ԭ���ӷ�*/

	refer		   varchar(40)	   null,			/*��ע -- ���Էŵ绰���� */
	empno1		char(10)			not null,	/*¼����޸Ĺ���*/
	shift1		char(1)			not null,	/*���*/
	empno2		char(10)			null,			/*���ʻ��������*/
	shift2		char(1)			null,			/*���*/
	checkout	   char(4)			null,			/*����������־λ*/
	site0	   	char(5) default '' not null,			/**/
	chgcod		char(5) default '' not null
)
exec sp_primarykey bos_folio,foliono
create unique index index1 on bos_folio(foliono)
create unique index index2 on bos_folio(setnumb,foliono)
create index index3 on bos_folio(sta);

/*
	bos��ʷ���û��ܱ�
*/
if exists(select * from sysobjects where name = "bos_hfolio" and type="U")
	drop table bos_hfolio;

create table bos_hfolio
(
	log_date    datetime    default getdate()   not null,   /*�������*/
	bdate    	datetime   	not null,	/*�����������޸�Ӫҵ��,��������folionoʶ��*/
	bdate1      datetime   	null    ,	/*�������ʻ򱻳���Ӫҵ��*/
	foliono		char(10)	   not null,	/*���к�*/
	sfoliono		varchar(10)	default '' null,
	site			char(5)	   null,			/*�ص�*/
	sta			char(1)		not null,	/*״̬,"M"�ֹ�����δ��,"P",�绰ת��δ��, "H",�绰ת��δ��,"O"�ѽ�,"C"����, "T"ֱ����̨��*/
   setnumb     char(10)    null    ,   /*�������*/ 
	modu			char(2)		not null,	/*ģ���*/
	pccode		char(5)		not null,	/*������*/
	name	   	char(24)		null,			/*����������*/
	posno       char(3)     not null,
	mode	      char(3)		null,			/* ϵͳ��*/

	fee			money	default 0 		not null,   /*�����ܶ�*/
	fee_base	   money	default 0 	   not null,	/*������*/
	fee_serve	money	default 0 	   not null,	/*�����*/
	fee_tax  	money	default 0 	   not null,	/*���ӷ�*/
	fee_disc 	money	default 0 	   not null,	/*�ۿ۷�*/

	serve_type 	char(1)	default '0' not null,	/*����ѷ�ʽ   0:���� 1:���*/
	serve_value money		default 0   not null,	/*�������ֵ*/
	tax_type  	char(1)	default '0' not null,	/*���ӷѷ�ʽ   0:���� 1:���*/
	tax_value  	money		default 0   not null,	/*���ӷ���ֵ*/
	disc_type   char(1)	default '0' not null,	/*�Żݷ�ʽ   0:���� 1:���*/
	disc_value	 money	default 0 	not null,	/*�Żݱ���*/
	reason		char(3)					null,			/*�Ż�ԭ��*/

	pfee		   money	default 0 	   not null,   /*ԭ�����ܶ�*/
	pfee_base	money	default 0 	   not null,	/*ԭ������*/
	pfee_serve	money	default 0 	   not null,	/*ԭ�����*/
	pfee_tax 	money	default 0 	   not null,	/*ԭ���ӷ�*/

	refer		   varchar(40)	   null,			/*��ע*/
	empno1		char(10)			not null,	/*¼����޸Ĺ���*/
	shift1		char(1)			not null,	/*���*/
	empno2		char(10)			null,			/*���ʻ��������*/
	shift2		char(1)			null,			/*���*/
	checkout	   char(4)			null,			/*����������־λ*/
	site0	   	char(5) default '' not null,			/**/
	chgcod		char(5) default '' not null
)
exec sp_primarykey bos_hfolio,foliono
create unique index index1 on bos_hfolio(foliono)
create unique index index2 on bos_hfolio(setnumb,foliono)
create index index4 on bos_hfolio(bdate1);
create index index3 on bos_hfolio(sta);

/*
	bos������ϸ��
*/
if exists(select * from sysobjects where name = "bos_dish" and type="U")
	drop table bos_dish;

create table bos_dish
(
	foliono		char(10)	   not null,	/*bos_folio��*/
	id          int         not null,   /*���к�*/       
	sta			char(1)		not null,		/*״̬,'M'��;"C"����*/
	log_date    datetime    default getdate()   not null,   /*�������*/
	bdate    	datetime   	not null,	/*�����������޸�Ӫҵ��,��������folionoʶ��*/
	bdate1      datetime   	null    ,	/*�������ʻ򱻳���Ӫҵ��*/
	pccode		char(5)		not null,	/*������*/
   code     	char(8)     not null,   /*������ϸ��*/ 
	name	   	varchar(18)	null,			/*��������*/
	price       money       not null,   /*����*/  
	number      money  default 0 not null,   /*����*/
	unit        char(4)     null,   		/*��λ*/  

	fee			money	default 0 		not null,   /*�����ܶ�*/
	fee_base	   money	default 0 	   not null,	/*������*/
	fee_serve	money	default 0 	   not null,	/*�����*/
	fee_tax  	money	default 0 	   not null,	/*���ӷ�*/
	fee_disc 	money	default 0 	   not null,	/*�ۿ۷�*/

	serve_type 	char(1)	default '0' not null,	/*����ѷ�ʽ   0:���� 1:���*/
	serve_value money		default 0   not null,	/*�������ֵ*/
	tax_type  	char(1)	default '0' not null,	/*���ӷѷ�ʽ   0:���� 1:���*/
	tax_value  	money		default 0   not null,	/*���ӷ���ֵ*/
	disc_type   char(1)	default '0' not null,	/*�Żݷ�ʽ   0:���� 1:���*/
	disc_value	 money	default 0 	not null,	/*�Żݱ���*/
	reason		char(3)					null,			/*�Ż�ԭ��*/

	pfee		   money	default 0 	   not null,   /*ԭ�����ܶ�*/
	pfee_base	money	default 0 	   not null,	/*ԭ������*/
	pfee_serve	money	default 0 	   not null,	/*ԭ�����*/
	pfee_tax 	money	default 0 	   not null,	/*ԭ���ӷ�*/

	refer		   varchar(80)	   null,		/*��ע -- �����绰��˵�� */
	empno1		char(10)		not null,	/*¼����޸Ĺ���*/
	shift1		char(1)		not null,	/*���*/
	empno2		char(10)		null,		/*���ʻ��������*/
	shift2		char(1)		null,		/*���*/
	amount0		money default 0  not null
)
exec sp_primarykey bos_dish,foliono,id
create unique index index1 on bos_dish(foliono,id)
create index index2 on bos_dish(sta);


/*
	bos��ʷ������ϸ��
*/
if exists(select * from sysobjects where name = "bos_hdish" and type="U")
	drop table bos_hdish;

create table bos_hdish
(
	foliono		char(10)	   not null,	/*bos_folio��*/
	id          int         not null,   /*���к�*/       
	sta			char(1)		not null,		/*״̬,'M'��;"C"����*/
	log_date    datetime    default getdate()   not null,   /*�������*/
	bdate    	datetime   	not null,	/*�����������޸�Ӫҵ��,��������folionoʶ��*/
	bdate1      datetime   	null    ,	/*�������ʻ򱻳���Ӫҵ��*/
	pccode		char(5)		not null,	/*������*/
   code     	char(8)     not null,   /*������ϸ��*/ 
	name	   	varchar(18)	null,			/*��������*/
	price       money       not null,   /*����*/  
	number      money  default 0 not null,   /*����*/
	unit        char(4)     null,   		/*��λ*/  

	fee			money	default 0 		not null,   /*�����ܶ�*/
	fee_base	   money	default 0 	   not null,	/*������*/
	fee_serve	money	default 0 	   not null,	/*�����*/
	fee_tax  	money	default 0 	   not null,	/*���ӷ�*/
	fee_disc 	money	default 0 	   not null,	/*�ۿ۷�*/

	serve_type 	char(1)	default '0' not null,	/*����ѷ�ʽ   0:���� 1:���*/
	serve_value money		default 0   not null,	/*�������ֵ*/
	tax_type  	char(1)	default '0' not null,	/*���ӷѷ�ʽ   0:���� 1:���*/
	tax_value  	money		default 0   not null,	/*���ӷ���ֵ*/
	disc_type   char(1)	default '0' not null,	/*�Żݷ�ʽ   0:���� 1:���*/
	disc_value	 money	default 0 	not null,	/*�Żݱ���*/
	reason		char(3)					null,			/*�Ż�ԭ��*/

	pfee		   money	default 0 	   not null,   /*ԭ�����ܶ�*/
	pfee_base	money	default 0 	   not null,	/*ԭ������*/
	pfee_serve	money	default 0 	   not null,	/*ԭ�����*/
	pfee_tax 	money	default 0 	   not null,	/*ԭ���ӷ�*/

	refer		   varchar(80)	   null,		/*��ע -- �����绰��˵�� */
	empno1		char(10)		not null,	/*¼����޸Ĺ���*/
	shift1		char(1)		not null,	/*���*/
	empno2		char(10)		null,		/*���ʻ��������*/
	shift2		char(1)		null,		/*���*/
	amount0		money default 0  not null
)
exec sp_primarykey bos_hdish,foliono,id
create unique index index1 on bos_hdish(foliono,id)
create index index2 on bos_hdish(sta);


/*
	�������Ľ�����ʱ�����
*/

if exists(select * from sysobjects where name = "bos_partout" and type="U")
	drop table bos_partout;

create table bos_partout
(
	log_date    datetime    default getdate()   not null,   /*�������*/
	bdate    	datetime   	not null,				/*Ӫҵʱ��*/
	setnumb     char(10)    null    ,   			/*�������*/
	code		   char(5)		not null,				/*�ڲ���*/
	code1	 	   char(5)		not null,				/*�ⲿ��*/
	reason	   char(3)		default '' not null,	/*�ۿۿ������*/
	name		   char(24)	   null,		   			/*����������*/
	amount		money	default 0 not null,			/*���*/
	empno		   char(10)		not null,				/*����*/
	shift		   char(1)		not null,				/*���*/
	room		   char(5)		null,						/*ת�ʷ���*/
	accnt		   char(10)		null,						/*ת���ʺ�*/
	tranlog     char(10)    null,						/*Э����*/
	cusno       char(7)     null,						/*��λ��*/
	cardtype     char(10)     null,						/*����*/
	cardno      char(20)     null,						/*����*/
	quantity		money	default 0 not null,			/*����*/			
	ref			varchar(100)	null,
	modu			char(2)		null,
	checkout	   char(4)		null						/*����������־λ*/
)
exec sp_primarykey bos_partout,checkout,code
create unique index index1 on bos_partout(checkout,code);



/*
	�������Ŀ����
*/

if exists(select * from sysobjects where name = "bos_account" and type="U")
	drop table bos_account;

create table bos_account
(
	log_date    datetime    default getdate()   not null,   /*�������*/
	bdate    	datetime   	not null,				/*Ӫҵʱ��*/
	setnumb     char(10)    null    ,   			/*�������*/
	code		   char(5)		not null,				/*�ڲ���*/
	code1	 	   char(5)		not null,				/*�ⲿ��*/
	reason	   char(3)		default '' not null,	/*�ۿۿ������*/
	name		   char(24)	   null,		   			/*����������*/
	amount		money	default 0 not null,			/*���*/
	empno		   char(10)		not null,				/*����*/
	shift		   char(1)		not null,				/*���*/
	room		   char(5)		null,						/*ת�ʷ���*/
	accnt		   char(10)		null,						/*ת���ʺ�*/
	tranlog     char(10)    null,						/*Э����*/
	cusno       char(7)     null,						/*��λ��*/
	cardtype     char(10)     null,						/*����*/
	cardno      char(20)     null,						/*����*/
	quantity		money	default 0 not null,			/*����*/			
	ref			varchar(100)	null,
	modu			char(2)		null,
	checkout	   char(4)		null						/*����������־λ*/
)
exec sp_primarykey bos_account,setnumb,code
create unique index index1 on bos_account(setnumb,code);


/*
	����������ʷ�����
*/

if exists(select * from sysobjects where name = "bos_haccount" and type="U")
	drop table bos_haccount;

create table bos_haccount
(
	log_date    datetime    default getdate()   not null,   /*�������*/
	bdate    	datetime   	not null,				/*Ӫҵʱ��*/
	setnumb     char(10)    null    ,   			/*�������*/
	code		   char(5)		not null,				/*�ڲ���*/
	code1	 	   char(5)		not null,				/*�ⲿ��*/
	reason	   char(3)		default '' not null,	/*�ۿۿ������*/
	name		   char(24)	   null,		   			/*����������*/
	amount		money	default 0 not null,			/*���*/
	empno		   char(10)		not null,				/*����*/
	shift		   char(1)		not null,				/*���*/
	room		   char(5)		null,						/*ת�ʷ���*/
	accnt		   char(10)		null,						/*ת���ʺ�*/
	tranlog     char(10)    null,						/*Э����*/
	cusno       char(7)     null,						/*��λ��*/
	cardtype     char(10)     null,						/*����*/
	cardno      char(20)     null,						/*����*/
	quantity		money	default 0 not null,			/*����*/			
	ref			varchar(100)	null,
	modu			char(2)		null,
	checkout	   char(4)		null						/*����������־λ*/
)
exec sp_primarykey bos_haccount,setnumb,code
create unique index index1 on bos_haccount(setnumb,code)
;

///*
//	�Ż�����
//*/
//if exists(select * from sysobjects where name = "bos_reason" and type ="U")
//	drop table bos_reason;
//create table bos_reason
//(
//	code		char(3)		not null,	/*����*/
//	key0		char(3)		not null,	/*refer to reason0*/
//	descript	varchar(16)		not null,	/*����*/
//	percent	money			not null,	/*����*/
//	day		money			default 0 	not null,
//	month		money			default 0 	not null,
//	year		money			default 0 	not null,
//)
//exec sp_primarykey bos_reason,code
//create unique index index1 on bos_reason(code)
//;
//insert bos_reason values ('01','A01','����Ż�',0,0,0,0)
//insert bos_reason values ('02','A02','����Ң�Ż�',0,0,0,0)
//;


/*
	��̨�ֹ��������,bos����ϸ���ձ�
*/
if exists(select * from sysobjects where name = "bos_partfolio" and type="U")
	drop table bos_partfolio;

create table bos_partfolio
(
	accnt        char(10) not null,     /*�˺�*/ 
	number       int     not null,     /*�ʴ�*/
	foliono      char(10) not null     /*bos_folio*/
);
exec sp_primarykey bos_partfolio,accnt,number 
create unique index index1 on bos_partfolio(accnt,number);
create unique index index2 on bos_partfolio(foliono);


/*
	bos�˵�
*/
if exists(select * from sysobjects where name = "bos_plu" and type ="U")
	drop table bos_plu;
create table bos_plu
(
	pccode   char(5)		not null,	/*Ӫҵ��*/
   code     char(8)     not null,   /*����*/
	name		varchar(18)		not null,	/*����*/
	ename		varchar(30)		null,			/*����*/
	helpcode	varchar(10)		null,			/*���Ƿ�*/
	standent	varchar(12)		null,			/*���,����!!!*/
	unit		char(4)		null,			/*��λ*/
	sort		char(4)		not null,	/*����*/
	hlpcode	varchar(8)		null,			/*�������Ƿ�*/
	price		money			not null,	/*�۸�*/
	menu		char(4)		not null,	/*��,��,��,ҹ�Ĺ���*/
   dscmark  char(1)     null,       /*�ۿ��������־*/
	surmark  char(1)     null,       /*T:���շ����,F:���շ����*/
	taxmark  char(1)     null,       /*T:���ո���˰,F:���ո���˰*/
	discmark char(1)     null,       /*T:�ɴ���,F:������*/
	provider	char(7)		default '' null,
	number	money	default 0 not null,  // ��������ͽ��
	amount	money default 0 not null,
	site		varchar(8) default '' null,  // ��ŵص�
	class		char(3)	 	not null			// ���
)
exec sp_primarykey bos_plu,pccode,code
create unique index index1 on bos_plu(pccode,code)
// create unique index index2 on bos_plu(pccode,name)
create index index3 on bos_plu(pccode,helpcode)
;

/*
	bos����
*/

if exists(select * from sysobjects where name = "bos_sort" and type ="U")
	drop table bos_sort;
create table bos_sort
(
	pccode		char(5)			not null,	/*Ӫҵ��*/
	sort			char(8)			not null,	/*���*/
	name			varchar(12)		not null,	/*����*/
	ename			varchar(20)		null,			/*����*/
	hlpcode		varchar(8)		null,			/*���Ƿ�*/
	surmark     char(1)     	null,       /*T:���շ����,F:���շ����*/
	taxmark     char(1)     	null,       /*T:���ո���˰,F:���ո���˰*/
	discmark    char(1)     	null,       /*T:�ɴ���,F:������*/
)
exec sp_primarykey bos_sort,pccode,sort
create unique index index1 on bos_sort(pccode,sort)
create unique index index2 on bos_sort(pccode,name)
;


/*
	�������,����ÿ���������Ͻ��Ӫҵ��
*/

if exists(select * from sysobjects where name = "bos_posdef" and type ="U")
	drop table bos_posdef;
create table bos_posdef
(
	posno			char(2)				not null,	/*��������*/
	modu			char(2)				not null,	/*ģ���*/
	mode			char(1)				not null,	/*0-all, 1-folio, 2-dish*/
	descript		varchar(20)			not null,	/*��������*/
	descript1	varchar(20)			not null,	/*��������*/
   pccodes		varchar(120)		null,	 	   /*Ӫҵ�㼯��*/		
	fax1			char(5)				null,			/*���ʹ���ķ����� ����*/
	fax2			char(5)				null,			/*���ʹ���ķ����� ����*/
	sites			varchar(100) default ''	not null,			/*��̨����*/
	def			char(1)		default 'F'			/*ȱʡ����*/
)
exec sp_primarykey bos_posdef,posno,modu
create unique index index1 on bos_posdef(posno,modu)
;
insert bos_posdef select '01', '03', '0', '�ͷ�����', '','','','', '','T'
insert bos_posdef select '02', '06', '0', '��������', '','','','', '','T'
insert bos_posdef select '03', '09', '0', '�̳�����', '','','','', '','T'
insert bos_posdef select '04', '66', '0', '��������', '','','','', '','T'
;

/*
	����վ��
*/
if exists(select * from sysobjects where name = "bos_station" and type ="U")
	drop table bos_station;
create table bos_station
(
	netaddress	char(4)		not null,	/*�����ַ*/
	posno			char(2)		not null,	/*������*/
   printer		char(1)		not null,	/*��δ�."T"/"F"*/
	adjuhead		int			default 0	not null,	/*��ӡ����*/
	adjurow		int			default 0	not null,	/*��ӡ����*/
)
exec sp_primarykey bos_station,netaddress,posno
create unique index index1 on bos_station(netaddress,posno)
;
insert bos_station(netaddress,posno,printer)
	values('1.01', '01', 'T')
;


/*
	ģʽ���뼰����
*/
if exists(select * from sysobjects where name = "bos_mode_name" and type ="U")
	drop table bos_mode_name;

create table bos_mode_name
(
	code			char(3)			not null,	/*����*/
	descript		varchar(20)		not null,	/*��������*/
	descript1	varchar(30)		null,			/*Ӣ������*/
	remark		varchar(255)	null,			/*����*/
)
exec sp_primarykey bos_mode_name,code
create unique index index1 on bos_mode_name(code)
;


/*
	�ص�
*/
if exists(select * from sysobjects where name = "bos_tblsta" and type ="U")
	drop table bos_tblsta;
//create table bos_tblsta
//(
//	tableno		char(4)		not null,							/*����*/
//	type			char(3)		null,									/*���*/
//	pccode		char(3)		not null,							/*Ӫҵ��*/
//	descript1	char(10)		null,									/*����1*/
//	descript2	char(10)		null,									/*����2*/
//	maxno			integer		default	0	not null,			/*ϯλ��*/
//	sta			char(1)		default	'N'	not null,
//	mode			char(1)		default	'0'	not null,		/*�������ģʽ*/
//	amount		money			default	0	not null,			/*������ѽ��*/
//	code			char(15)		default '' not null				/*��ͷȥ��*/
//)
//exec sp_primarykey bos_tblsta,tableno
//create unique index index1 on bos_tblsta(tableno)
//create index index2 on bos_tblsta(pccode, tableno)
//;

/*
	ϯλ״̬��
*/
if exists(select * from sysobjects where name = "bos_tblav" and type ="U")
	drop table bos_tblav;
//create table bos_tblav
//(
//	menu				char(10)		not null,								/*������*/
//	tableno			char(4)		not null,								/*����*/
//	id					integer		default 0 not null,
//	bdate				datetime		not null,								/*����*/
//	shift				char(1)		not null,								/*���*/
//	sta				char(1)		not null,								/*״̬*/
//	begin_time		datetime		default	getdate()	not null,	/*��ʱ��ʼʱ��*/
//	end_time			datetime		null										/*��ʱ��ֹʱ��*/
//)
//exec sp_primarykey bos_tblav,menu,tableno,id
//create unique index index1 on bos_tblav(menu,tableno,id)
//;

/*
	BOS ���Ŷ���
*/
if exists(select * from sysobjects where name = "bos_empno" and type ="U")
	drop table bos_empno;
create table bos_empno
(
	empno		char(10)		not null,	/*����*/
	name		char(20)		not null,	/*����*/
)
exec sp_primarykey bos_empno,empno
create unique index index1 on bos_empno(empno)
;

/*
	BOS ���˽��������
*/
if exists(select * from sysobjects where name = "bos_itemdef" and type ="U")
	drop table bos_itemdef;
create table bos_itemdef
(
	posno		char(2)			not null,	/*������   ZZ = �ͷ����Ŀ������˶��塶ϵͳ�ڶ���*/
	define	varchar(20)		null			/*����ʾ�Ķ���*/
)
exec sp_primarykey bos_itemdef,posno
create unique index index1 on bos_itemdef(posno)
;


/*
	�������ķֻ��趨
*/
if exists(select * from sysobjects where name = "bos_extno" and type ="U")
	drop table bos_extno;
create table bos_extno
(
	code		char(8)			not null,
	posno		char(2)			not null
)
exec sp_primarykey bos_extno,code
create unique index index1 on bos_extno(code)
;

/*
	bos ��ʱ��
*/
if exists(select * from sysobjects where name = "bos_tmpdish" and type="U")
	drop table bos_tmpdish;

create table bos_tmpdish
(
	modu_id		char(2)		not null,
	pc_id			char(4)		not null,
	id          int         not null,      /*���к�*/
	sta			char(1)		not null,		/*״̬,'I'=���� 'M'=�� "C"=���� */
   code     	char(8)     not null,   /*������ϸ��*/ 
	name	   	varchar(18)	null,			/*��������*/
	price       money       not null,   /*����*/  
	number      money  default 0 not null,   /*����*/
	unit        char(4)     null,   		/*��λ*/  
	pfee_base	money	default 0 	   not null,	/*ԭ������*/
	serve_type 	char(1)	default '0' not null,	/*����ѷ�ʽ   0:���� 1:���*/
	serve_value money		default 0   not null,	/*�������ֵ*/
	tax_type  	char(1)	default '0' not null,	/*���ӷѷ�ʽ   0:���� 1:���*/
	tax_value  	money		default 0   not null,	/*���ӷ���ֵ*/
	disc_type   char(1)	default '0' not null,	/*�Żݷ�ʽ   0:���� 1:���*/
	disc_value	 money	default 0 	not null		/*�Żݱ���*/
)
exec sp_primarykey bos_tmpdish,modu_id, pc_id, id
create unique index index1 on bos_tmpdish(modu_id, pc_id, id)
;

if exists ( select * from sysobjects where name = 'bosjie' and type ='U')
	drop table bosjie;
create table bosjie
(
   date          datetime default getdate(),
   shift         char(1)  default '' not null,
	empno         char(10)  default '' not null,
	code          char(5)  default '' not null,
	descript      char(24)  default '' not null,
	fee_bas       money    default 0  not null,
	fee_sur       money    default 0  not null,
	fee_tax       money    default 0  not null,
	fee_dsc	      money    default 0  not null,
	fee_ent	      money    default 0  not null,
	fee_ttl	      money    default 0  not null,
	fee_basm      money    default 0  not null,
	fee_surm      money    default 0  not null,
	fee_taxm      money    default 0  not null,
	fee_dscm      money    default 0  not null,
	fee_entm      money    default 0  not null,
	fee_ttlm      money    default 0  not null,
	daymark       char(1)  default '' not null
)
exec sp_primarykey bosjie,shift,empno,code
create unique index index1 on bosjie(shift,empno,code)
;

if exists ( select * from sysobjects where name = 'ybosjie' and type ='U')
   drop table ybosjie;
create table ybosjie
(
   date          datetime default getdate(),
   shift         char(1)  default '' not null,
	empno         char(10)  default '' not null,
	code          char(5)  default '' not null,
	descript      char(24)  default '' not null,
	fee_bas       money    default 0  not null,
	fee_sur       money    default 0  not null,
	fee_tax       money    default 0  not null,
	fee_dsc	     money    default 0  not null,
	fee_ent	     money    default 0  not null,
	fee_ttl	     money    default 0  not null,
	fee_basm      money    default 0  not null,
	fee_surm      money    default 0  not null,
	fee_taxm      money    default 0  not null,
	fee_dscm      money    default 0  not null,
	fee_entm      money    default 0  not null,
	fee_ttlm      money    default 0  not null,
	daymark       char(1)  default '' not null
)
exec sp_primarykey ybosjie,date,shift,empno,code;
create unique index index1 on ybosjie(date,shift,empno,code);

if exists ( select * from sysobjects where name = 'bosdai' and type ='U')
   drop table bosdai;
create table bosdai
(
   date          datetime default    getdate(),
   shift         char(1)  default '' not null,
	empno         char(10)  default '' not null,
	paycode       char(5)  default '' not null,
	paytail       char(1)  default '' not null,
	descript      char(24) default '' not null,
	creditd       money    default 0  not null,
	creditm       money    default 0  not null,
	daymark       char(1)  default '' not null
)
exec sp_primarykey bosdai,shift,empno,paycode,paytail
create unique index index1 on bosdai(shift,empno,paycode,paytail)
;

if exists ( select * from sysobjects where name = 'ybosdai' and type ='U')
   drop table ybosdai;
create table ybosdai
(
   date          datetime default    getdate(),
   shift         char(1)  default '' not null,
	empno         char(10)  default '' not null,
	paycode       char(5)  default '' not null,
	paytail       char(1)  default '' not null,
	descript      char(24) default '' not null,
	creditd       money    default 0  not null,
	creditm       money    default 0  not null,
	daymark       char(1)  default '' not null
)
exec sp_primarykey ybosdai,date,shift,empno,paycode,paytail
create unique index index1 on ybosdai(date,shift,empno,paycode,paytail)
;

