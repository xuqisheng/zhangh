----------------------------------------------------------------------------------
--
--	����Ԥ�����ṹ
--
----------------------------------------------------------------------------------
create table pos_reserve_plu
(
	resno			char(10)			default ''  not null,
	plu_id		integer			default 0	not null,
	inumber		integer			default 0	not null,
	descript		char(30)			default ''	not null,
	number		money				default 0	not null,
	cook			char(255)		default ''	null,
	price_id		integer			default 0	not null,
	remark		char(255)		default ''	null
)
;
exec sp_primarykey pos_reserve_plu,resno,plu_id,inumber
create unique index index1 on pos_reserve_plu(resno,plu_id,inumber)
;
/*	Ԥ������ */

create table pos_reserve
(
	resno					char(10)				not null,
	tag					char(1)				not null,	/*�Ͳ����*/
	bdate					datetime				not null,	/*�������� -- ��Ӧ��������*/
	date0					datetime				not null,	/*�Ͳ�����,ʱ��*/
	shift					char(1)				not null,
	name					varchar(50)			null,       /*��ϵ��*/
	unit					varchar(60)			not null,	/*������λ*/
	phone					char(20)				null,
	tables				integer default 1	not null,	/*����*/
	guest					integer				not null,	/*������*/
	standent				money default 0	not null,   /*��׼*/
	stdunit				char(1)				null,       /*��׼��λ*/  
	stdno					char(2)				null,
	deptno				char(2)				not null,	/*���ź�*/
	pccode				char(3)				not null,	/*����*/
	tableno				char(4)				null,			/*����,������,��Ϊ����Ⱥ�еĵ�һ��*/
	paymth				char(1) default '0' not null, /*֧����ʽ*/
	mode					char(3)				null,			/*ģʽ*/
	sta					char(1)				not null,	/*״̬,"1"Ԥ��,"2"ȷ��,"7"�Ǽ�*/
	cusno					char(7)				null,			/*������λ��*/
	haccnt				char(10)				null,			/*���˺�*/
	tranlog				char(10)				null,			/*Э���*/
	menu_header			text					null,			/*��ʽ����*/
	menu_detail			text					null,			/*��ʽ����*/
	menu_footer			text					null,			/*��ʽ����*/
	remark				text					null,			/*��ע*/
	menu					char(10)				null,			/*�ǼǺ�Ĳ˵���*/
	amount				money default 0	null,			/*���ѽ��*/
	doc					varchar(250)		null,			/*ole �ĵ�*/
	empno					char(10)				not null,	/*����Ա*/
	date					datetime	default getdate()	not null,	/*����ʱ��*/
	email					char(30)	default '' not null,	/**/
	unitto	 			char(40) default '' null,		/*�ͷ���λ*/
	araccnt				char(10)	default '' null,     /*�����˺�*/
	accnt					char(10)	default '' null,     /*ȫ��Ԥ���˺�*/
	flag					varchar(50)	default '' null,     /*����̬*/ 
	logmark				int	   default 0      ,
   saleid            char(10)  default '' not null,     /*����Ա*/            
	reserveplu			text						null,				/*Ԥ��ʱ��Ĳ�*/
	meet					char(1)	default 'N'	not null,     /*��Ԥ���Ƿ��л�����Ϣ*/      -- 040524 add
	more					char(1)	default 'N'	not null,     /*��Ԥ���Ƿ�Ҫ�����*/        -- 040524 add
	meetname				varchar(60)	default 'N'	not null,  /*���飬�����*/   		     -- 040531 add
	ci_date				datetime,								     /*�Ǽ�����,��ʱ��*/	
	ciy					char(10) default '' not null,								     /*�Ǽ���*/	
	cby					char(10) default '' not null,									 /*�޸���*/	
	cg_date				datetime										  /*�޸�ʱ��*/	

)
exec sp_primarykey pos_reserve,  resno
create unique index index1 on pos_reserve(menu, resno)
create index index2 on pos_reserve(bdate, resno)
create index index3 on pos_reserve(name, bdate)
;

if  exists(select * from sysobjects where name = "pos_hreserve" and type ="U")
	drop table pos_hreserve;
select * into pos_hreserve from pos_reserve where 1=2;
exec sp_primarykey pos_hreserve,  resno
create unique index index1 on pos_hreserve(menu, resno)
create index index2 on pos_hreserve(bdate, resno)
create index index3 on pos_hreserve(name, bdate)
;

if  exists(select * from sysobjects where name = "pos_reserve_log" and type ="U")
	drop table pos_reserve_log
;
select * into pos_reserve_log from pos_reserve
exec sp_primarykey pos_reserve_log,resno,logmark
create unique index index1 on pos_reserve_log(resno,logmark)
;

