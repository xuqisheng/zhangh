--------------------------------------------------------------------------------
--
-- ���������������ṹ
--
--------------------------------------------------------------------------------

/*	��˲˵����� */

create table pos_menu
(
	tag					char(1)		default ""	not null,	/*�������,"0"���,"1"����,"2"����,"3"������,"4������,"5"������*/
	tag1					char(1)		default ""	not null,	/*����*/
	tag2					char(1)		default ""	not null,	/*����*/
	tag3					char(1)		default ""	not null,	/*���� -- ���� T*/
	source				char(3)		default ""	not null,	/*��Դ*/
	market				char(3)		default ""	not null,	/*�г�*/
	menu					char(10)		default ""	not null,	/*�˵���*/
	tables				integer		default 1	not null,	/*����*/
	guest					integer		default 1	not null,	/*������*/
	date0					datetime		default getdate()	not null,	/*����ʱ��*/
	bdate					datetime		default getdate()	not null,	/*�Ͳ�ʱ��*/
	shift					char(1)		default "1"	not null,
	deptno				char(2)		default ""	not null,	/*���ź�*/
	pccode				char(3)		default ""	not null,	/*����*/
	posno					char(2)		default ""	not null,	/*�������*/
	tableno				char(6)		null,			/*����,������,��Ϊ����Ⱥ�еĵ�һ��*/
	mode					char(3)		not null,			/*ģʽ*/
	dsc_rate				money			default 0	not null,	/*�Żݷ���*/
	reason				char(3)		default ""	not null,	/*�Ż�����*/
	tea_rate				money			default 0	not null,	/*��λ��*/
	serve_rate			money			default 0	not null,	/*�������*/
	tax_rate				money			default 0	not null,	/*���ӷ���*/
	srv					money			default 0 	not null,   /*�����*/
	dsc					money			default 0 	not null,   /*�ۿ�*/
	tax					money			default 0 	not null,   /*˰*/
	amount				money			default 0	not null,	/*���ѽ��*/
	amount0				money			default 0	not null,	/*Ԥ��*/
	amount1				money			default 0	not null,	/*Ԥ��*/
	empno1				char(10)		default ''  not null,							/*����Ա, ����Ϊ������*/
	empno2				char(10)		default ''  not null,							/*����, ����Ϊ�ĵ���*/
	empno3				char(10)		default ''  not null,		/*����Ա, ����Ϊ����Ա*/
	sta					char(1)		default '2' not null,	/*״̬,"1"Ԥ��,"2"�Ǽ�,"3"����,"4"����,"5"�ؽ�,"7"ɾ��*/
	paid					char(1)		default "0"	not null,	/*����״̬,"0"δ��,"1"�ѽ�,"2"����*/
	setmodes				char(4)		default ''  not null,							/*���һ�θ��ʽ,���λΪ*��ʾ��ʸ���*/
	cusno					char(10)		default ''  not null,							/*������λ��*/
	haccnt				char(10)		default ''  not null,							/*���˺�*/
	foliono				varchar(20)	null,							/*�ֹ�����*/
	remark				varchar(80)	null,							/*��ע*/
	roomno				char(5)		default ''  not null,							/**/
	accnt					char(10)		default ''  not null,							/**/
	lastnum				integer		default 0	not null,	/*��ϸ���д�*/
	pcrec					char(10)		default ''  not null,							/*����*/
	pc_id					char(8)		default ''  not null,							/*���һ�β�����IP��ַ,ֻ��δ�ᵥ��Ч*/
	timestamp			timestamp	not null,					/*ʱ���*/
   saleid            char(10)    default '' not null,		/*����Ա	*/
	resno					char(10)		default '' not null,			/*Ԥ����*/
	cardno				char(10)		default '' not null,			/*����*/
	checkid				char(20)		default '' not null,			/*��Ʊ��*/
	logmark				integer		default 0  not null,
	cby        			char(10)    NULL,								/*�޸���*/
   changed    			datetime    NULL)								/*�޸�ʱ��*/		
;
exec sp_primarykey pos_menu,menu
create unique index index1 on pos_menu(menu)
;

select * into pos_menu_log from pos_menu
exec sp_primarykey pos_menu_log,menu,logmark
create unique index index1 on pos_menu_log(menu,logmark)
;


select * into pos_hmenu from pos_menu
EXEC sp_primarykey pos_hmenu, menu
CREATE UNIQUE NONCLUSTERED INDEX index1   ON dbo.pos_hmenu(menu)
CREATE NONCLUSTERED INDEX index2    ON dbo.pos_hmenu(bdate)
CREATE NONCLUSTERED INDEX index3    ON dbo.pos_hmenu(bdate,pccode)
CREATE NONCLUSTERED INDEX index_haccnt    ON dbo.pos_hmenu(haccnt)
CREATE NONCLUSTERED INDEX index_cusno     ON dbo.pos_hmenu(cusno)
;

select * into pos_tmenu from pos_menu
exec sp_primarykey pos_tmenu,menu
create unique index index1 on pos_tmenu(menu)
;


/* �����ϸ�˵� */

if  exists(select * from sysobjects where name = "pos_dish" and type ="U")
	 drop table pos_dish
;
create table pos_dish
(
	menu			char(10)		not null,					/*�˵���*/
	inumber		integer		not null,					/*��ϸ���д�*/
	plucode		char(2)		not null,					/*�˱���*/
	sort			char(4)		not null,					/*����*/
	code			char(6)		not null,					/*�˺�*/
	id				int			not null,					/*������*/
	printid		int			default 0	not null,	/*��ӡ����Ψһ��*/
	name1			varchar(30)	default ''	not null,	/*������*/
	name2			varchar(50)	default ''	not null,	/*������*/
	unit			char(4)		default ''	not null,	/*������λ*/
	number		money			default 0   not null,	/*����*/
	price			money			default 0   not null,	/*����*/
	amount		money			default 0   not null,	/*���*/
	pinumber		integer		default 1   not null,	/*��Ӧ�˼���� pos_price.inumber*/
	pamount		money			default 0   not null,	/*�ɱ����*/
	empno			char(10)		null,							/*����Ա����*/
	bdate			datetime		not null,
	date0			datetime		default getdate()	not null,	/*����(��)ʱ��*/
	date1			datetime		null, 							 	/*�ղ�ʱ��, ��ʱ�˵Ŀ�ʼʱ��*/
	date2			datetime		null,   								/*����ʱ��, ��ʱ�˵Ľ���ʱ��*/
	special		char(1)		default	''		not	null,		/*�����ۿ����־, T:�����ۿ�, X: ������, S:��ʱ��*/
	sta			char(1)		default	'0'	not	null,		/*״̬*/
	flag			varchar(30)	default	''		not 	null,		/*����̬*/   /* 21=�ͳ���ǡ�28=�����ϡ�29=�˼۱��޸Ĺ���30=��ӡ���*/
	flag19		char(1)		default	''				null,		/*��Ӧ���׵�flag19*/	
	flag19_use	char(20)		default  ''				null,		/*ʹ�ü�¼*/		
	reason		char(3)		default	''		not 	null,		/*�Ż�ԭ��*/
	remark		varchar(50)	default	''		not 	null,		/*��ע*/
	id_cancel	integer		default	0	not null,					/*������Ӧ��ϸ*/ 
	id_master	integer		default	0	not null,					/*��ϸ����׼��ָ��*/
	empno1		char(10)		default	''	not null,					/*����Ա��ʦ��ʦ*/
	empno2		char(10)		default	''	not null,					/*����Ա*/
	empno3		char(10)		default	''	not null,					/*���ĵ���,���˵����ۿ۵�*/
	orderno		varchar(10)	default  '' not null,					/*С����*/
	srv			money			default 0 	not null,         /*�����*/
	srv0			money			default 0 	not null,         /*�����-ԭֵ*/
	srv_dsc		money			default 0 	not null,         /*�����-�ۿ�*/
	dsc			money			default 0 	not null,         /*�ۿ�*/
	tax			money			default 0 	not null,         /*˰*/
	tax0			money			default 0 	not null,         /*˰-ԭֵ*/
	tax_dsc		money			default 0 	not null,         /*˰-�ۿ�*/
	tableno		char(6)		default	''	not null,			/*̨��*/
	siteno		char(2)		default	''	not null,			/*��λ��*/
	outno		   char(2)		default	''	not null,			/*�������,��Ҫ�������ͳ��˴���*/
	kitchen		char(20)		default  '' null,					/*����*/
	cook1			varchar(50)	default	''	null,					/*����*/
	kit_ref		varchar(30) default ''  null,					/*����ָ��*/
	cook			varchar(50)	default	''	null					/*���Ҫ��*/
	
)
exec sp_primarykey pos_dish,menu,inumber
create unique index index1 on pos_dish(menu,inumber)
;

if  exists(select * from sysobjects where name = "pos_hdish" and type ="U")
	 drop table pos_hdish
;
select * into pos_hdish from pos_dish
exec sp_primarykey pos_hdish,menu,inumber
create unique index index1 on pos_hdish(menu,inumber)
CREATE NONCLUSTERED INDEX index_menu ON dbo.pos_hdish(menu)
;

if  exists(select * from sysobjects where name = "pos_tdish" and type ="U")
	 drop table pos_tdish
;
select * into pos_tdish from pos_dish
exec sp_primarykey pos_tdish,menu,inumber
create unique index index1 on pos_tdish(menu,inumber)
;
if  exists(select * from sysobjects where name = "pos_order" and type ="U")
	drop table pos_order
;
create table pos_order
(
	pc_id			char(4)		not null,							/*�༭��վ��*/
	menu			char(10)		default '' not null,				/**/
	inumber		int			not null,							/*������� */	
	orderno		char(10)		not null,							/*order��*/
	id				int			not null,							/*��Ψһ��*/
	sort			char(4)		not null,							/*����*/
	code			char(6)		not null,							/*����*/
	pinumber		integer		default 0  not null,				/*�۸����*/
	unit			char(4)		not null,							/*��λ*/
	price			money			not null,						/*����*/	
	number		money			not null,						/*����*/
	amount		money			not null,						/*���*/
	name1			char(30)		not null,
	name2			char(50)		not null,
	sta			char(1)		null,								/*״̬ */
	flag			varchar(30)	default ''	not null,  		/*��ʶ�� ��pos_plu�ı�ʶ��Ӧ;�ײ�������dishʱҪ����pos_dish_pcid*/
	special		char(1)		null,								/*��־*/
	empno1		char(10)		null,								/*��ʦ����ʦ*/
	empno2		char(10)		null,								/*����Ա*/
	inumber1		int			default 0 not null,			/*�������룬�ײ���ϸ����*/
	tableno		char(6)		default '' not null,			/*̨��*/
	siteno		char(2)		default '' not null,			/*λ��*/
	outno		   char(2)		default	''	not null,			/*�������,��Ҫ�������ͳ��˴���*/
	cook			varchar(200)		null,						/*����������*/
	remark		char(30)		null,								/*��ע*/
	kitchen		char(20)		null,								/*��������*/
	kit_ref		varchar(30) null								/*����ָ��*/						
)
exec sp_primarykey pos_order,pc_id,inumber
create unique index index1 on pos_order(pc_id,inumber)
;

/*  �˵����ݴ�ӡ��¼  */

if exists(select * from sysobjects where type ='U' and name = 'pos_menu_bill')
	drop table pos_menu_bill
;
create table pos_menu_bill
(
	menu			char(10) default ''  not null,				/*  */
	hline			int 		default 0   not null,				/* �Ѵ�ӡ�� */
	hpage			int 		default 0   not null,				/* �Ѵ�ӡҳ */
	inumber		int		default 0   not null,				/* �Ѵ�ӡ����� */
	hamount		money		default 0 	not null,				/*��¼�Ѵ�ӡ�Ľ��*/
	dsc			money		default 0   not null,				/*�ۿ�  */
	srv			money		default 0   not null,				/*�����  */
	tax			money		default 0   not null,				/*˰  */
	bill			int		default 0   not null,				/*  */
	payamount	money		default 0   not null,				/* ʵ�� */
	oddamount	money		default 0   not null					/* ���� */
)
;
exec sp_primarykey pos_menu_bill,menu
create unique index index1 on pos_menu_bill(menu)
;

/*  ����  */

if exists(select * from sysobjects where type ='U' and name = 'pos_pay')
	drop table pos_pay
;
create table pos_pay
(
	menu			char(10)		not null,								/* ����,Ԥ���� */
	number		integer		default 1 not null,					/* ��� */
	inumber		integer		default 1 not null,					/* ������� */
	paycode		char(5)		not null,								/* ���ʽ */
	accnt			char(10)		default ''  not null,				/* ת���˺� */
	roomno		char(5)		default ''  not null,				/* ת�˷��� */
	foliono		char(20)		default ''  not null,				/* ���� */
	amount		money			default 0   not null,				/* ��� */
	sta			char(1)		default '0' not null,				/* ״̬: 0 -- ���� 2 - ʹ�ö��� 3 - ���˿� */
	crradjt		char(2)		default 'NR' not null,				/* ״̬: NR-- ������ C -- ���壬 CO -- ��, �����ؽ�*/
	reason		char(3)		default '0' not null,				/* �Ż�ԭ�� */
	empno			char(10)		not null,								/* ����  */
	bdate			datetime		not null,								/* Ӫҵ���� */
	shift			char(1)		not null,								/* ��� */
	log_date		datetime		default getdate() not null,		/* ʱ�� */
	remark		char(60)		default '' not null,					/* ��ע */
	menu0			char(10)		default '' not null,					/* ����ĵ���Ԥ���ţ���ʹ�ö���ĵ���Ԥ���� */
	bank			char(10)		default '' not null,					/* ���ÿ��������� */
	credit		money			default 0  not null,					/* ���� */
	cardno		char(20)		default '' not null,					/* ���� */
	ref			char(40)		default '' not null,					/* ��ע */
	quantity		money			default 0  not null					/* ���� */
)
exec sp_primarykey pos_pay, menu,number
create unique index index1 on pos_pay(menu, number)
;

if  exists(select * from sysobjects where name = "pos_tpay" and type ="U")
	 drop table pos_tpay
;
select * into pos_tpay from pos_pay
exec sp_primarykey pos_tpay,menu,number
create unique index index1 on pos_tpay(menu,number)
;

if  exists(select * from sysobjects where name = "pos_hpay" and type ="U")
	 drop table pos_hpay
;
select * into pos_hpay from pos_pay
exec sp_primarykey pos_hpay,menu,number
create unique index index1 on pos_hpay(menu,number)
;


/*
	ϯλ״̬��
*/
if exists(select * from sysobjects where name = "pos_tblav" and type ="U")
	 drop table pos_tblav;

create table pos_tblav
(
	menu				char(10)		not null,								/*������*/
	tableno			char(6)		not null,								/*����*/
	inumber			integer		default 0  not null,
	empno				char(10)		default '' not null,					/*ֵ̨Ա*/
	bdate				datetime		not null,								/*����*/
	shift				char(1)		not null,								/*���*/
	sta				char(1)		not null,								/*״̬ 0 : ȡ�� 1 : Ԥ�� 7 : ��̨ */
	begin_time		datetime		default	getdate()	not null,	/*���ְ��Ὺʼ��ʱʱ��*/
	end_time			datetime		null,										/*���ְ����ʱ��ֹʱ��*/
	pcrec				char(10)		null,										/*������*/
	amount			money			default	0				not null		/*���*/
)
exec sp_primarykey pos_tblav, menu, tableno, inumber
create unique index index1 on pos_tblav(menu, tableno, inumber)
;


/* �ײ�,��׼�˵���� */

if exists(select 1 from sysobjects where name='pos_std' and type='U')
   drop table pos_std;
create table pos_std
(
	plucode		char(2)		not null,					/* �˱��� */
	std_id		int			not null,					/* ��׼�˴��� */
	id				int			not null,       			/* ������ϸ�˴��� */
	number		money			default 1 not null,		/* ������ϸ������ */
	unit			char(4)		default  '' not null,	/* ������ϸ�˵�λ */
	price			money			default 0 not null,		/* ������ϸ�˵��� */
	sequence		int			default 0 not null,		/* ��� */
	sort			char(1)		default '1' not null,	/* ���� */
	pinumber		int			default 0 not null		/* pos_price.inumber */
)
;
exec sp_primarykey pos_std,plucode,std_id,id
create unique index index1 on pos_std(plucode,std_id,id);

/*
	ȱ�����ֱ���ļ�¼
*/
if  exists(select * from sysobjects where name = "pos_nodish" and type ="U")
	drop table pos_nodish
;
create table  pos_nodish (
	bdate			datetime			default getdate()	not null,
	id				int				default 0 	not null,						/*pos_plu.id*/
	code			char(6)			default '' 	not null,
	name1			char(30)			default ''	not null,		
	name2			char(50)			default ''	not null,
	unit			char(4)			default ''  not null,
	number		money				default 0   not null							/*����*/			
	);
exec sp_primarykey pos_nodish,bdate,id
create unique index index1 on pos_nodish(bdate, id)
;

/*
  ��ʱ���״��
*/
create table pos_plu_temp
(
	plucode				char(2)		not null,
	sort					char(4)		not null,
	id						int			not null,
	name1					char(30)		not null,
	helpcode				char(10)		not null,
	unit					char(4)		not null,
	price					money default 0		not null
)

exec sp_primarykey pos_plu_temp,id
create unique index index1 on pos_plu_temp(id)
create unique index index2 on pos_plu_temp(name1)
;
// ������ʱ��¼��ű�����ͷ
CREATE TABLE pos_checkout (
	pc_id 			char(8)		not null,
	menu 				char(10)	default ''	not null,
	menu1 			char(10)	default ''	not null,
	id 				int		default 0	not null,
	number 			int		default 0	not null,
	paycode 			char(5)	null,
	amount 			money		default 0	not null,
	remark 			char(15) null
)
;

exec sp_primarykey pos_checkout,pc_id,menu,id;
create unique index index1 on pos_checkout(pc_id,menu,id)
;


// �������÷��ඨ��
CREATE TABLE pos_deptcls (
	code 			char(2),
	descript 	char(16),			// ����
	descript1 	char(32),			// Ӣ��
	deptpat 		char(30)
);
exec sp_primarykey pos_deptcls,code
create unique index index1 on pos_deptcls(code)
;

// �����������붨��
drop  TABLE pos_namedef ;
CREATE TABLE pos_namedef (
	deptno 	char(2),				 	//���ź�
	code 		char(3),					//
	descript char(12),				//����
	descript1 char(24)				//Ӣ��
);
exec sp_primarykey pos_namedef,deptno,code;
create unique index index1 on pos_namedef(deptno,code);

// ������Ҫ��
CREATE TABLE pos_order_cook (
	menu	 			char(10)  default ''	not null,				 
	inumber			integer 	 default 0	not null,			 // pos_order.inumber
	inumber0  		integer   default 0	not null,			 // 
	sta				char(1)   default '0'	not null,		 // 1 -  ORDER ; 0 - DISH
	id					integer   default 0	not null,			 //  pos_plu.id or pos_condst.condid
	type				char(1)   default '0'	not null,		 // 0 -  pos_plu ; 1 - pos_condst 
	descript  		char(24)  default ''	not null,			 // ����
	number			money   	 default 0	not null,			 // ����
	unit				char(4)	 default ''	not null,			 // 
	price				money		 default 0	not null,          // ����
	amount			money     default 0	not null,        	 // ���
	date0				datetime	 default getdate() null
);
exec sp_primarykey pos_order_cook,menu,inumber,inumber0,sta;
create unique index index1 on pos_order_cook(menu,inumber,inumber0,sta);

// ���ʹ�ü�¼
create table pos_bkfuse(
	bdate				datetime,
	roomno			char(6),
	accnt				char(10)   not null,
	inumber			int,
	pccode			char(3),     --  ������
	number			money     default 1 not null ,      -- ����
	empno				char(10)   not null,
	logdate			datetime   not null,
	amount   		money    NULL,
	pc_id    		char(4)  NULL,
	transfer 		char(1)  NULL
)
;
exec sp_primarykey pos_bkfuse,bdate,roomno,inumber;
create unique index index1 on pos_bkfuse(bdate,roomno,inumber);

// ���ʹ�ü�¼
create table pos_ybkfuse(
	bdate				datetime,
	roomno			char(6),
	accnt				char(10)   not null,
	inumber			int,
	pccode			char(3),     --  ������
	number			money     default 1 not null ,      -- ����
	empno				char(10)   not null,
	logdate			datetime   not null,
	amount   		money    NULL,
	pc_id    		char(4)  NULL,
	transfer 		char(1)  NULL
)
;
create unique index index1 on pos_ybkfuse(bdate,roomno,inumber);


// �͵�����״̬
create table pos_menu_op(
	menu				char(10)   default '' not null,
	pc_id				char(4)    default '' not null,
	optype			char(10)   default '' not null,      -- �������order :���,check ������
	empno				char(10)   not null,
	logdate			datetime   not null
)
;
exec sp_primarykey pos_menu_op,menu,pc_id,optype;
create unique index index1 on pos_menu_op(menu,pc_id,optype);


/*����ʱ��, ʱ��ζ���*/
CREATE TABLE pos_season (
	code 			char(3)    default '' not null,             // 
	descript 	char(30)   default '' not null,             // 
	descript1 	char(40)   default '' not null,             //
	begin_ 		datetime   default getdate() not null,      // ��Ч�ڿ�ʼʱ��  
	end_ 			datetime   default getdate() not null,      // ��Ч�ڽ���ʱ��  
	day 			char(250)  default '' not null,             // ��     
	week 			char(14)   default '' not null,             // ����
	shift			char(1)    default '' not null,             // �Ͷ�
	sequence 	char(5)    default '100' not null
);
create unique index index1 on pos_season(code);

/*����ʱ��, �˼۶���*/
CREATE TABLE pos_happytime (
	id				int     default 0  not null,	 				// ��ID	
	inumber		int     default 0  not null,              // pos_price.inumber
	code			char(3) default '' not null,					// pos_season.code
	price			money   default 0  not null,              // �˼�
);
create unique index index1 on pos_happytime(id,inumber,code);
