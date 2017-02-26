/************************************************************/
/* ��SQLΪ ����ϵͳ FOR V50 �� ���ӽṹ							 */
/*************************************************************/

/* ��ѽ��ɼ�¼�� */

if  exists(select * from sysobjects where name = "sp_tax" and type ="U")
	  drop table sp_tax;

create table sp_tax
(
	cardno		char(10)		default '' 			not null,			/*��Ա����*/
	type			char(2)		default '01' 		not null,			/*���1 -- ��ѣ�2 -- ���ѣ�3 -- �·�*/
	sdate			datetime		default getdate() not null, 			/*��Ч�ڵĿ�ʼʱ��*/
	edate			datetime		default getdate() not null, 			/*��Ч�ڵĽ���ʱ��*/
	amount		money			default 0 not null, 					 	/*���*/
	logdate		datetime		null,   						/*����ʱ��*/
	empno			char(3)		default	''	not null,	/*����Ա*/
	menu			char(10)		default	''	not null,	/*����*/

)
exec sp_primarykey sp_tax,cardno,menu
create unique index index1 on sp_tax(cardno,menu)
;


/* �������� */

if  exists(select * from sysobjects where name = "sp_place_sort" and type ="U")
	  drop table sp_place_sort;

create table sp_place_sort
(	
	sort				char(2)		default '' 			not null,		/*���*/
	name				char(30)		default '' 			not null,		/*����*/
	pccode			char(30)		default '' 			not null,		/*chgcod.pccode*/
	period			int			default 30			not null,			/*��ʾ��ʱ���,�ƴε�λ������*/
	time				int			default 60			not null,		//��ʱ����
	bmp				varchar(255)	default ''		null
)
exec sp_primarykey sp_place_sort,sort
create unique index index1 on sp_place_sort(sort)
;

//INSERT INTO sp_place_sort VALUES (	'01',	'��ë��',	'14',	30);
//INSERT INTO sp_place_sort VALUES (	'02',	'������',	'14',	60);
//INSERT INTO sp_place_sort VALUES (	'03',	'ƹ����',	'14',	60);
//INSERT INTO sp_place_sort VALUES (	'04',	'����',	'14',	60);


/* ���ش���� */

if  exists(select * from sysobjects where name = "sp_place" and type ="U")
	  drop table sp_place;

create table sp_place
(	
	sort				char(2)		default '' 			not null,			/*���*/
	code				char(5)		default '' 			not null,			/*���ֳ��غź�*/
	placecode		char(5)		default '' 			not null,			/*ͳ�Ƴ��غ�*/
	name				char(30)		default '' 			not null,			/*����*/
	ename				char(40)		default ''		 	not null, 			/**/
	descript			char(100)	default '' 			not null, 			/*����*/
	sta				char(1)		default '' 			not null,
	plucode			char(15)		default ''			not null,			/*��Ӧsp_plu.code, ��dish����*/
)
exec sp_primarykey sp_place,code
create unique index index1 on sp_place(code)
;

INSERT INTO sp_place VALUES (	'01',	'001',	'001',	'��ë�򳡵�1',	'',	'',	'',	'44014001');
INSERT INTO sp_place VALUES (	'01',	'002',	'002',	'��ë�򳡵�2',	'',	'',	'',	'44014001');
INSERT INTO sp_place VALUES (	'02',	'003',	'003',	'ƹ������1',	'',	'',	'',	'44014004');
INSERT INTO sp_place VALUES (	'02',	'004',	'004',	'ƹ������2',	'',	'',	'',	'44014004');
INSERT INTO sp_place VALUES (	'03',	'005',	'005',	'���򳡵�A',	'',	'',	'',	'44014002');
INSERT INTO sp_place VALUES (	'03',	'006',	'006',	'���򳡵�B',	'',	'',	'',	'44014002');
INSERT INTO sp_place VALUES (	'04',	'007',	'007',	'�������1',	'',	'',	'',	'44014003');
INSERT INTO sp_place VALUES (	'04',	'008',	'008',	'�������2',	'',	'',	'',	'44014003');
INSERT INTO sp_place VALUES (	'04',	'009',	'009',	'�������3',	'',	'',	'',	'44014003');

/*����״̬��Ϣ*/

if exists(select * from sysobjects where name = "sp_plaav" and type ="U")
	  drop table sp_plaav;

create table sp_plaav
(
	menu				char(10)		not null,								/*������*/
	placecode		char(5)		not null,								/*���غ�*/
	inumber			integer		default 0  not null,					
	empno				char(3)		default '' not null,					/*����Ա*/
	bdate				datetime		not null,								/*����*/
	shift				char(1)		not null,								/*���*/
	sta				char(1)		not null,								/*״̬: R -- Ԥ����O -- ά�ޣ�X -- ȡ��; I -- ʹ��; D -- ����, G -- Ԥ��ת�Ǽ�*/
	stime				datetime		default	getdate()	not null,	/*��ʼʱ��*/
	etime				datetime		null		,								/*��ֹʱ��*/
	amount			money			default 0   not null,				/*�����*/
	dishtype			char(1)		default 'F' not null,				/*����dish���˱�־*/
	dnumber			int			default 0   not null,				/*���˺�dish.id,inumber*/	
	resno				char(10)		default ''	null
)
exec sp_primarykey sp_plaav, menu, placecode, inumber
create unique index index1 on sp_plaav(menu, placecode, inumber)
;
select * into sp_hplaav from sp_plaav where 1=2;
create unique index index1 on sp_hplaav(menu, placecode, inumber)
;

/*����ʹ�ü򵥼�¼��Ϣ*/

if exists(select * from sysobjects where name = "sp_pla_use" and type ="U")
	  drop table sp_pla_use;

create table sp_pla_use
(
	placecode		char(5)		not null,								/*���غ�*/
	no					char(10)		not null,
	inumber			integer		not null,
	sno				char(20)		not null,								/*��������*/
	empno				char(3)		default '' not null,					/*����Ա*/
	sta				char(1)		default '' not null,
	bdate				datetime		not null,								/*����*/
	stime				datetime		default	getdate()	not null,	/*��ʼʱ��*/
	etime				datetime		null		,								/*��ֹʱ��*/
	amount			money			default 0   not null					/*�����*/
)
;
create unique index index1 on sp_pla_use(no,inumber,bdate)
;


if exists(select * from sysobjects where name = "sp_vipcard" and type ="U")
	  drop table sp_vipcard;

create table sp_vipcard
(
	no					char(10)		default '' not null,					/*����*/
	card_type		char(1)		default ''	not null,				//������
	type				char(1)		default '' not null,					//�Ǵα��,�Ƿ�ǴΣ�1-N��2-���ܴ���,3-�ֳ��ؼǴ�
	allow_times		money 		default 0  not null,					//����ʹ���ܴ���(��Լ��ܴ�������Ч)
	use_times		money 		default	0 not null,					//�Ѿ�ʹ�õĴ���(��Լ��ܴ�������Ч)
	pccodes			char(255)	default ''	not null,				//�ÿ���������ЩӪҵ��
	places			char(255)	default	''	not null,				//�ÿ���������Щ����
	bdate				datetime		not null,	
	empno				char(10)		default '' not null
	
)
;
create unique index index1 on sp_vipcard(no)
;

if exists(select * from sysobjects where name = "sp_place_times" and type ="U")
	  drop table sp_place_times;

create table sp_place_times
(
	no					char(10)		default '' not null,					/*����*/
	inumber			integer		default 0	not null,
	sort				char(2)		default '' not null,					//���غ�
	begin_date		datetime			not null,	
	end_date			datetime			not null,
	allow_times		money 		default 0  not null,					//����ʹ���ܴ���(��Լ��ܴ�������Ч)
	use_times		money 		default	0 not null,					//�Ѿ�ʹ�õĴ���(��Լ��ܴ�������Ч)
	type				char(1)		default '' not null,					//�ǲ����Żݵı��
	
	
)
;
create unique index index1 on sp_place_times(no,inumber,sort)
;

/*����ά�޵���Ϣ*/

if exists(select * from sysobjects where name = "sp_plaooo" and type ="U")
	  drop table sp_plaooo;

create table sp_plaooo
(
	menu				char(10)		not null,								/*���Ե���*/
	inumber			int			default 0  not null,					/*��ˮ��*/
	sno				char(10)		not null,								/*ά�޵���*/
	placecode		char(5)		not null,								/*���غ�*/
	empno				char(3)		default '' not null,					/*ά��Ա*/
	bdate				datetime		not null,								/*��������*/
	shift				char(1)		not null,								/*���*/
	sta				char(1)		default 'O' not null,				/*״̬��O - ά��; D - �޸�*/
	logdate			datetime		not null,								/*ʱ��*/
	stime				datetime		default	getdate()	not null,	/*��ʼʱ��*/
	etime				datetime		null										/*��ֹʱ��*/
)
exec sp_primarykey sp_plaooo, menu,inumber
create unique index index1 on sp_plaooo(menu, inumber)
;
select * into sp_hplaooo from sp_plaooo where 1=2;
create unique index index1 on sp_hplaooo(menu, inumber)
;
/*	Ԥ������ */

if  exists(select * from sysobjects where name = "sp_reserve" and type ="U")
	drop table sp_reserve
;
create table sp_reserve
(
	resno					char(10)				not null,
	tag					char(1)				not null,	/*�Ͳ����*/
	bdate					datetime				not null,	/*�Ͳ����� -- ��Ӧ��������*/
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
	pccode				char(2)				not null,	/*����*/
	tableno				char(4)				null,			/*����,������,��Ϊ����Ⱥ�еĵ�һ��*/
	paymth				char(1) default '0' not null, /*֧����ʽ*/
	mode					char(3)				null,			/*ģʽ*/
	sta					char(1)				not null,	/*״̬,"1"Ԥ��,"2"ȷ��,"7"�Ǽ�*/
	cusno					char(7)				null,			/*������λ��*/
	haccnt				char(7)				null,			/*���˺�*/
	tranlog				char(10)				null,			/*Э���*/
	menu_header			text					null,			/*��ʽ����*/
	menu_detail			text					null,			/*��ʽ����*/
	menu_footer			text					null,			/*��ʽ����*/
	remark				text					null,			/*��ע*/
	menu					char(10)				null,			/*�ǼǺ�Ĳ˵���*/
	amount				money default 0	null,			/*���ѽ��*/
	doc					varchar(250)		null,			/*ole �ĵ�*/
	empno					char(3)				not null,	/*����Ա*/
	date					datetime	default getdate()	not null,	/*����ʱ��*/
	email					char(30)	default '' not null,	/**/
	unitto	 			char(40) default '' null,		/*�ͷ���λ*/
	araccnt				char(7)	default '' null,     /*�����˺�*/
	accnt					char(10)	default '' null,     /*ȫ��Ԥ���˺�*/
	flag					char(10)	default '' null,     /*����̬*/ 
	logmark				int	   default 0      ,
   saleid            char(3)  default '' not null ,     /*����Ա*/            
	systype				char(2)	default '' not null,
	cardno				char(10)	default ''	not null
)
exec sp_primarykey sp_reserve,  resno
create unique index index1 on sp_reserve(menu, resno)
create index index2 on sp_reserve(bdate, resno)
create index index3 on sp_reserve(name, bdate)
;
if not exists(select 1 from pos_reserve where resno = 'R999999999')
	insert into pos_reserve (	resno	,tag,	bdate,date0,shift,name,	unit,phone,tables,guest,standent,stdunit,deptno,pccode,mode,sta,empno,date,email,flag, logmark)
values('R999999999', '1', '1994/06/30', '1994/06/30','1', 'CYJ','WestLake', '88231199',1, 10, 2000, '1','','10','000','1','CYJ',getdate(),'','',1 )
;
if  exists(select * from sysobjects where name = "sp_hreserve" and type ="U")
	drop table sp_hreserve;

select * into sp_hreserve from sp_reserve where 1=2;

exec sp_primarykey sp_hreserve, resno
create unique index index1 on sp_hreserve(resno)
create index index2 on sp_hreserve(bdate, resno)
create index index3 on sp_hreserve(name, bdate)
;



/* �����ϸ�˵� */

if  exists(select * from sysobjects where name = "sp_dish" and type ="U")
	 drop table sp_dish
;
create table sp_dish
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
	number		money			not null,					/*����*/
	amount		money			not null,					/*���*/
	empno			char(10)		null,							/*����Ա����*/
	bdate			datetime		not null,
	date0			datetime		default getdate()	not null,	/*����(��)ʱ��*/
	date1			datetime		null, 							 	/*�ղ�ʱ��, ��ʱ�˵Ŀ�ʼʱ��*/
	date2			datetime		null,   								/*����ʱ��, ��ʱ�˵Ľ���ʱ��*/
	special		char(1)		default	''		not	null,		/*�����ۿ����־, T:�����ۿ�, X: ������, S:��ʱ��*/
	sta			char(1)		default	'0'	not	null,		/*״̬*/
	flag			char(10)		default	''		not 	null,		/*����̬*/   /* c:���ϴ�����, d:ȱ��, o:�ѳ���, r:���ڼ�ʱ, s:ֹͣ��ʱ, t:����, m:�ײ�*/
	reason		char(3)		default	''		not 	null,		/*�Ż�ԭ��*/
	remark		varchar(30)	default	''		not 	null,		/*��ע*/
	id_cancel	integer		default	0	not null,					/*������Ӧ��ϸ*/ 
	id_master	integer		default	0	not null,					/*��ϸ����׼��ָ��*/
	empno1		char(10)		default	''	not null,					/*��ʦ��ʦ*/
	empno2		char(10)		default	''	not null,					/*����Ա*/
	empno3		char(10)		default	''	not null,					/*����Ա*/
	orderno		varchar(10)	default  '' not null,					/*С����*/
	srv			money			default 0 	not null,         /*�����*/
	dsc			money			default 0 	not null,         /*�ۿ�*/
	tax			money			default 0 	not null,         /*˰*/
	tableno		char(6)		default	''	not null,			/*̨��*/
	siteno		char(2)		default	''	not null				/*��λ��*/
)
exec sp_primarykey sp_dish,menu,inumber
create unique index index1 on sp_dish(menu,inumber)
;

if  exists(select * from sysobjects where name = "sp_hdish" and type ="U")
	 drop table sp_hdish
;
select * into sp_hdish from sp_dish
exec sp_primarykey sp_hdish,menu,inumber
create unique index index1 on sp_hdish(menu,inumber)
;

if  exists(select * from sysobjects where name = "sp_tdish" and type ="U")
	 drop table sp_tdish
;
select * into sp_tdish from sp_dish
exec sp_primarykey sp_tdish,menu,inumber
create unique index index1 on sp_tdish(menu,inumber)
;

/*	��˲˵����� */

if  exists(select * from sysobjects where name = "sp_menu" and type ="U")
	drop table sp_menu
;
create table sp_menu
(
	tag					char(1)		default ""	not null,	/*�������,"0"���,"1"����,"2"����,"3"������,"4������,"5"������*/
	tag1					char(1)		default ""	not null,	/*����*/
	tag2					char(1)		default ""	not null,	/*����*/
	tag3					char(1)		default ""	not null,	/*���� -- ���� T*/
	menu					char(10)		default ""	not null,	/*�˵���*/
	tables				integer		default 1	not null,	/*����*/
	guest					integer		default 1	not null,	/*������*/
	date0					datetime		default getdate()	not null,	/*����ʱ��*/
	bdate					datetime		default getdate()	not null,	/*�Ͳ�ʱ��*/
	shift					char(1)		default "1"	not null,
	deptno				char(2)		default ""	not null,	/*���ź�*/
	pccode				char(3)		default ""	not null,	/*����*/
	posno					char(2)		default ""	not null,	/*�������*/
	tableno				char(4)		null,			/*����,������,��Ϊ����Ⱥ�еĵ�һ��*/
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
	empno1				char(10)		null,							/*����Ա*/
	empno2				char(10)		null,							/*����*/
	empno3				char(10)		default '' not null,		/*����Ա*/
	sta					char(1)		default '2' not null,	/*״̬,"1"Ԥ��,"2"�Ǽ�,"3"����,"5"�ؽ�,"7"ɾ��*/
	paid					char(1)		default "0"	not null,	/*����״̬,"0"δ��,"1"�ѽ�,"2"����*/
	setmodes				char(4)		null,			/*���һ�θ��ʽ,���λΪ*��ʾ��ʸ���*/
	cusno					char(10)		null,			/*������λ��*/
	haccnt				char(10)		null,			/*���˺�*/
	tranlog				varchar(10)	null,			/*Э���*/
	foliono				varchar(20)	null,			/*�ֹ�����*/
	remark				varchar(40)	null,			/*��ע*/
	roomno				char(5)		null,			/**/
	accnt					char(10)		null,			/**/
	lastnum				integer		default 0	not null,	/*��ϸ���д�*/
	pcrec					char(10)		null,			/*����*/
	pc_id					char(8)		null,			/*���һ�β�����IP��ַ,ֻ��δ�ᵥ��Ч*/
	timestamp			timestamp	not null,	/*ʱ���*/
	guestid				char(10)		null	,		/*���˺�*/
   saleid            char(10)    default '' not null,
	empno1_name       char(8)     default '' not null,
	cardno				char(20)		default '' not null
)
exec sp_primarykey sp_menu,menu
create unique index index1 on sp_menu(menu)
create index index2 on sp_menu(cusno)
create index index3 on sp_menu(haccnt)
;

if  exists(select * from sysobjects where name = "sp_hmenu" and type ="U")
	 drop table sp_hmenu
;
select * into sp_hmenu from sp_menu
exec sp_primarykey sp_hmenu,menu
create unique index index1 on sp_hmenu(menu)
create index index2 on sp_hmenu(cusno)
create index index3 on sp_hmenu(haccnt)
create index index4 on sp_hmenu(tranlog)
create index index5 on sp_hmenu(bdate)
;

if  exists(select * from sysobjects where name = "sp_tmenu" and type ="U")
	 drop table sp_tmenu
;
select * into sp_tmenu from sp_menu
exec sp_primarykey sp_tmenu,menu
create unique index index1 on sp_tmenu(menu)
;


if exists(select * from sysobjects where type ='U' and name = 'sp_menu_bill')
	drop table sp_menu_bill
;
create table sp_menu_bill
(
	menu			char(10) default ''  not null,				/*  */
	hline			int 		default 0   not null,				/* �Ѵ�ӡ�� */
	hpage			int 		default 0   not null,				/* �Ѵ�ӡҳ */
	inumber		int		default 0   not null,				/* �Ѵ�ӡ����� */
	hamount		money		default 0 	not null,				/*��¼�Ѵ�ӡ�Ľ��*/
	dsc			money		default 0   not null,				/*�ۿ�  */
	srv			money		default 0   not null,				/*�����  */
	tax			money		default 0   not null	,				/*˰  */
	bill			integer	default 0	not null
)
;
exec sp_primarykey sp_menu_bill,menu
create unique index index1 on sp_menu_bill(menu)
;
/*  ����  */

if exists(select * from sysobjects where type ='U' and name = 'sp_pay')
	drop table sp_pay
;
create table sp_pay
(
	menu			char(10)		not null,								/* ����,Ԥ���� */
	number		integer		default 1 not null,					/* ��� */
	inumber		integer		default 1 not null,					/* ������� */
	paycode		char(3)		not null,								/* ���ʽ */
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
	bank			char(10)		default''	not null,
	credit		money			default 0	not null,
	cardno		char(20)		default ''	not null,
	ref			char(40)		default ''	not null,
	quantity		money			default 0	not null
)
exec sp_primarykey sp_pay, menu,number
create unique index index1 on sp_pay(menu, number)
;

if  exists(select * from sysobjects where name = "sp_tpay" and type ="U")
	 drop table sp_tpay
;
select * into sp_tpay from sp_pay
exec sp_primarykey sp_tpay,menu,number
create unique index index1 on sp_tpay(menu,number)
;

if  exists(select * from sysobjects where name = "sp_hpay" and type ="U")
	 drop table sp_hpay
;
select * into sp_hpay from sp_pay
exec sp_primarykey sp_hpay,menu,number
create unique index index1 on sp_hpay(menu,number)
;


/*	Ԥ������ */

if  exists(select * from sysobjects where name = "sp_reserve" and type ="U")
	drop table sp_reserve
;
create table sp_reserve
(
	resno					char(10)				not null,
	tag					char(1)				not null,	/*�Ͳ����*/
	bdate					datetime				not null,	/*�Ͳ����� -- ��Ӧ��������*/
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
	reserveplu			text						null	,			/*Ԥ��ʱ��Ĳ�*/
	cardno				char(10)	default '' not null
)
exec sp_primarykey sp_reserve,  resno
create unique index index1 on sp_reserve(menu, resno)
create index index2 on sp_reserve(bdate, resno)
create index index3 on sp_reserve(name, bdate)
;
if not exists(select 1 from sp_reserve where resno = 'R999999999')
	insert into sp_reserve (	resno	,tag,	bdate,date0,shift,name,	unit,phone,tables,guest,standent,stdunit,deptno,pccode,mode,sta,empno,date,email,flag, logmark)
values('R999999999', '1', '1994/06/30', '1994/06/30','1', 'CYJ','WestLake', '88231199',1, 10, 2000, '1','','10','000','1','CYJ',getdate(),'','',1 )
;
if  exists(select * from sysobjects where name = "sp_hreserve" and type ="U")
	drop table sp_hreserve;
select * into sp_hreserve from sp_reserve where 1=2;
exec sp_primarykey sp_hreserve,  resno
create unique index index1 on sp_hreserve(menu, resno)
create index index2 on sp_hreserve(bdate, resno)
create index index3 on sp_hreserve(name, bdate)
;

if  exists(select * from sysobjects where name = "sp_reserve_log" and type ="U")
	drop table sp_reserve_log
;
select * into sp_reserve_log from sp_reserve
exec sp_primarykey sp_reserve_log,resno,logmark
create unique index index1 on sp_reserve_log(resno,logmark)
;

if exists(select * from sysobjects where name = "sp_operate" and type ="U")
	  drop table sp_operate;

CREATE TABLE sp_operate
 (
	class 			char(1)  default ''  not null,
	descript			char(20) default ''	not null,
	descript1 		char(40)	default ''	not null
)
;
create unique index index1 on sp_operate(class,descript)
;



if exists(select * from sysobjects where name = "sp_color_define" and type ="U")
	  drop table sp_color_define;

CREATE TABLE sp_color_define
 (
	number			integer	default 0	not null,
	color				char(20) default ''	not null,
	descript			char(40)	default ''	not null
)
;
create unique index index1 on sp_color_define(number)
;


//����
if exists(select * from sysobjects where name = "sp_dlmaster" and type ="U")
	  drop table sp_dlmaster;

create table sp_dlmaster
(
	empno				char(10)		default '' not null,					
	name				char(50)		default '' not null,
	skill				char(100)	default '' null,						//����
	remark			char(100)	default '' null,
	bdate				datetime		default '' not null
	
)
;
create unique index index1 on sp_dlmaster(empno)
;

//�����ƻ�
if exists(select * from sysobjects where name = "sp_guest" and type ="U")
	  drop table sp_guest;

create table sp_guest
(
	cardno			char(20)		default '' not null,	
	date0				datetime		not null,
	high				money			default	0 null,
	weight			money			default  0  null,
	ill				char(100)	default '' null,
	marry				char(1)		default 'F' null,
	content			text			default '' null,
	sta				char(1)		default '' not null,	 
	bdate				datetime		default '' not null
)
;
create unique index index1 on sp_guest(cardno)
;



//�����ƻ�
if exists(select * from sysobjects where name = "sp_plan" and type ="U")
	  drop table sp_plan;

create table sp_plan
(
	cardno			char(20)		default '' not null,	
	inumber			integer		default 0  not null,
	date0				datetime		not null,
	title				char(100)	default '' not null,
	intent         text        default		null,				//	ѵ��Ŀ��	
	content			text			default '' null,			//ָ������
	feel				text			default '' null,			//���Ҹо�
	mind				text			default '' null,        //�������
	master			char(10)		default '' not null,
	sta				char(1)		default '' not null,	 
	bdate				datetime		default '' not null,
	empno				char(10)		default '' not null
)
;
create unique index index1 on sp_plan(cardno,inumber)
;

//Ͷ��
if exists(select * from sysobjects where name = "sp_mind" and type ="U")
	  drop table sp_mind;

create table sp_mind
(
	class				char(20)		default '' not null,	
	date0				datetime		default '' not null,
	inumber			integer		default 0  not null,
	cardno			char(20)		default '' null,
	name				char(60)		default '' not null,
	content			text			default '' null,			//Ͷ������
	result			text			default '' null,			//���
	bdate				datetime		default '' not null,
	empno				char(10)		default '' not null
)
;
create unique index index1 on sp_mind(class,inumber)
;

//����
if exists(select * from sysobjects where name = "sp_remind" and type ="U")
	  drop table sp_remind;

create table sp_remind
(
	menu				char(20)		default '' not null,	
	inumber			integer		default 0  not null,
	placecode		char(5)		default '' not null,
	stime				datetime		default 0  not null,
	etime				datetime		default '' not null,
	name				char(60)		default '' not null,
	empno				char(10)		default '' not null,
	times				integer		default 0  null
)
;
create unique index index1 on sp_remind(menu,inumber,placecode)
;

//�����
if exists(select * from sysobjects where name = "sp_locker" and type ="U")
	  drop table sp_locker;

create table sp_locker
(
	code				char(5)		default '' not null,	
	descript			char(10)		default ''   null,
	descript1		char(10)		default ''   null
)
;
create unique index index1 on sp_locker(code)
;

if exists(select * from sysobjects where name = "sp_rent" and type ="U")
	  drop table sp_rent;

create table sp_rent
(
	code				char(5)		default '' not null,    //�Ĵ�����
	inumber			integer		default 0  not null,
	cardno			char(20)		default '' not null,
	sex				char(1)		default '' not null,
	name				char(50)		default ''	not null,
	stime				datetime		not null,
	etime				datetime		not null,
	menu				char(10)		default '' not null,	
	amount			money			default 0 not null,
	pay				char(50)		default '' not null
)
;
create unique index index1 on sp_rent(code,inumber)
;


if exists(select * from sysobjects where name = "sp_analyse" and type ="U")
	  drop table sp_analyse;

create table sp_analyse
(
	id					integer				not null,
	descript			char(100)			not null,
	descript1		char(100)			not null,
	datawindow		char(50)				not null,
	parm				char(200)			null,
)
;
create unique index index1 on sp_analyse(descript)
;

////��ʹ�ó��ض���coach
//if exists(select * from sysobjects where name = "sp_vipcard_define" and type ="U")
//	  drop table sp_vipcard_define;
//
//create table sp_vipcard_define
//(
//	card_type		char(1)		default '' not null,					/*�����*/
//	class				char(1)		default '' not null,					//���������1-���������壬2-���ض���
//	inumber			integer		default 0	not null,
//	sort				char(2)		default '' not null,					//���غ�
//	allow_times		money 		default 0  not null,					//����ʹ�ô���
//	pccodes			char(255)	default '' not null,					//����ʹ�õ�Ӫҵ��Ŀ
//	places			char(255)	default '' not null					//����ʹ�õĿ���Ӫҵ��Ŀ
//	
//)
//;
//create unique index index1 on sp_vipcard_define(card_type,inumber)
//;
////�Żݲ�����ϸ
//if exists(select * from sysobjects where name = "sp_benefit_detail" and type ="U")
//	  drop table sp_benefit_detail;
//
//create table sp_benefit_detail
//(
//	card_type		char(1)		default '' not null,					/*�����*/
//	class				char(1)		default ''  not null,				//���Ա��
//	inumber			integer		default 0	not null,
//	sort				char(2)		default '' not null,					//���غ�
//	allow_times		money 		default 0  not null,					//����ʹ�ô���
//	
//	
//)
//;
//create unique index index1 on sp_benefit_detail(card_type,class,inumber)
//;
////�Żݲ��Զ���
//if exists(select * from sysobjects where name = "sp_vipcard_benefit" and type ="U")
//	  drop table sp_vipcard_benefit;
//
//create table sp_vipcard_benefit
//(
//	card_type		char(1)		default '' not null,					/*�����*/
//	class				char(1)		default ''  not null,				//���Ա��
//	inumber			integer		default 0	not null,
//	descript			char(60)		default '' not null,					//��������
//	descript1		char(60)		default '' not null,					//��������
//	begin_date		datetime		not null,
//	end_date			datetime		not null,
//	used				char(1)		default 'F' not null	,				//��ǰʹ�ñ��
//	alway				char(1)		default 'F' not null					//�Ƿ�һֻʹ�õı��
//	
//	
//)
//;
//create unique index index1 on sp_vipcard_benefit(card_type,class,inumber)
//;
//
//