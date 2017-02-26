------------------------------------------------------------------------------------
--
--	����һ��Ĵ�������û����ȷ�����ı�ṹ�������ļ���    cyj 20050922
--
------------------------------------------------------------------------------------

/*	Ӫҵ���,����ÿ��Ӫҵ����շѲ��� */

create table pos_pccode
(
	pccode			char(3)		not null,						/*����*/
	descript			char(16)		not null,						/*Ӫҵ�����������*/
	descript1		varchar(32)		 null,						/*Ӫҵ���Ӣ������*/
	teaup				char(1)		default 'T' not null,		/*�Ƿ����ò�λ��*/
	name				char(8)		default '��λ��' not null,	/*��λ����*/
	mode				char(3)		default '' null,				/*ȱʡģʽ����*/
	serve_rate		money			default 0 not null,			/*�������*/		
	tax_rate			money			default 0 not null,			/*���ӷ���*/
	tea_charge1		money			default 0 not null,			/*����*/
	tea_charge2		money			default 0 not null,			/*�в��*/
	tea_charge3		money			default 0 not null,			/*����*/
	tea_charge4		money			default 0 not null,			/*ҹ���*/
	tea_charge5		money			default 0 not null,			/*����*/
	dec_length		integer		default 2 not null,			/*����С��λ��*/
	dec_mode			char(1)		default '0' not null,		/*Ĩ�㷽ʽ*/
	dec_id			int			default 0 not null,			/*��ͷȥ��, pos_plu.id*/
	daokou			char(1)		default 'F' not null,		/*����,"T"/"F",��Ӫҵ�ձ���ȡʳƷ����ѵ�1/2,���ۼ�ʳƷ*/
	menu_dw_menu	char(30)    default 'd_cq_newpos_menu',   /*��w_cyj_pos_menu�и�pccode��Ӧ��dw_menu */ 
	menu_dw_dish	char(30)    default 'd_cq_newpos_dish',   /*��w_cyj_pos_menu�и�pccode��Ӧ��dw_dish */ 
	tblmap_dw_menu	char(30)    default 'd_cq_newpos_menu',  /*��w_cyj_pos_menu�и�pccode��Ӧ��dw_menu */ 
	tblmap_dw_dish	char(30)    default 'd_cq_newpos_dish',  /*��w_cyj_pos_menu�и�pccode��Ӧ��dw_dish */ 
	ground_bmp		char(50)		default '' not null,       /*̨λͼ2��̨λ�ֲ�ͼ*/
	quantity			int			default 0  not null,       /*����*/
	overquan			int			default 0  not null,       /*��Ԥ����*/
	placecode		char(5)		default ''  null,   		   /*�ص���*/
	deptno			char(5)		default '' not null,		   /*������*/
	language			char(10)		default 'chinese' not null, /*���֣������˵�����Ĭ������*/
	remark			varchar(255) default '' null
   flag1          char(1)      NULL,
   printname1     char(3)      NULL,
   flag2          char(1)      NULL,
   printname2     char(3)      NULL,
   flag3          char(1)      NULL,
   printname3     char(3)      NULL

)
exec sp_primarykey pos_pccode,pccode
create unique index index1 on pos_pccode(pccode)
;

/*վ�㶨��*/
CREATE TABLE pos_station 
(
	pc_id		 				char(4)		default '' not null,	
	descript					char(30)		default '' not null,
	descript1				char(30)		default '' not null,
	pccodes 					varchar(250)	default '' not null,
	printers					varchar(120)	default '' not null,
	tag 						char(4)		default '' not null,
	tag1 						char(1)		default 'F'not null,
	tag2 						char(1)		default 'F'not null,
	tag3 						char(1)		default 'F'not null,
	tag4 						char(1)		default 'F'not null,
	printname 				char(3)		default '' not null,				/*�����嵥��ӡ��*/
	flag						char(1)		default 'F'not null,				/*�Ƿ�ʹ�ó�����ӡ����*/
	printname1 				char(3)		default '' not null,				/*���˲���ӡ��*/
	flag1						char(1)		default 'F'not null,				/*�Ƿ�ʹ�ó�����ӡ����*/
	printname2 				char(3)		default '' not null,				/*��ʦ����ӡ��*/
	flag2						char(1)		default 'F'not null,				/*�Ƿ�ʹ�ó�����ӡ����*/
	login_win				varchar(30)		default '' not null,			/*��������¼����*/
	podex_com				char(1)		default '' not null ,         /*��Ǯ��Ĵ��ںţ��ո�Ϊû�� */
   emp_com    				char(1)      NULL
);

exec sp_primarykey pos_station,pc_id
create unique index index1 on pos_station(pc_id)

;


/*	���� */
create table pos_tblsta
(
	tableno		char(6)		not null,							/*����*/
	type			char(3)		null,									/*���*/
	pccode		char(3)		not null,							/*Ӫҵ��*/
	descript1	char(10)		null,									/*����*/
	descript2	char(20)		null,									/*����*/
	maxno			integer		default	0	not null,			/*ϯλ��*/
	sta			char(1)		default	'N'	not null,      /*N: ��ռ��S:����ƴ̨*/
	mode			char(1)		default	'0'	not null,		/*�������ģʽ*/
	amount		money			default	0	not null,			/*������ѽ��*/
	min_id		int			default	0	not null,			/*������Ѳ���˺�pos_plu.id*/
	area			char(2)     default '' not null,				/*�������ڳ�����ӡ*/
	regcode		char(2)     default '' not null,				/*��������PDA���*/
	x				int			default 0  not null,	
	y				int			default 0  not null,	
	width			int			default 0  not null,	
	height		int			default 0  not null,
	tag			char(1)		default '0' not null,        	/*0: ��̨, 1: ����, R: �ͷ��Ͳ�ר��*/	
	mapcode		char(3)		default '' not null,				/*��λ�ֲ�ͼ���*/
   modi        char(1)                  null,				/*�Ƿ�ά��*/
   reason      char(30)                 null,				/*ά������*/
   placecode   char(5)                  null
)
exec sp_primarykey pos_tblsta,tableno
create unique index index1 on pos_tblsta(tableno)
create index index2 on pos_tblsta(pccode, tableno)
;

/*pos_dept����Ա������basecode = 'pos_depart' */
/*	����Ա,ֵ̨Ա,��ʦ�Ĺ��Ŷ��� */

create table pos_empno
(
	pccode	char(3)		null,			/*Ӫҵ��*/
	deptno	char(2)		not null,	/*����*/
	empno		char(10)		not null,	/*����*/
	name		char(20)		not null		/*����*/
)
exec sp_primarykey pos_empno,empno
create unique index index1 on pos_empno(empno)
;




/*	ģʽ���뼰���� */
create table pos_mode_name
(
	code			char(3)		not null,	/*����*/
	name1			char(20)		not null,	/*��������*/
	name2			char(30)		null,			/*Ӣ������*/
	descript		char(255)	null,			/*����*/
	descript1	char(255)	null			/*����*/
)
exec sp_primarykey pos_mode_name,code
create unique index index1 on pos_mode_name(code)
;

/*	�Ż�ģʽ,�����ģʽ,���ӷ�ģʽ���뼰���� */
create table pos_mode_descript
(
	type			char(1)		not null,	/*����*/
	code			char(1)		not null,	/*����*/
	name1			char(40)		not null,	/*��������*/
	name2			char(40)		null			/*Ӣ������*/
)
exec sp_primarykey pos_mode_descript,type,code
create unique index index1 on pos_mode_descript(type,code)
insert pos_mode_descript values('1','A','ģʽ�Żݣز˵��Ż�','')
insert pos_mode_descript values('1','B','ģʽ�Żݣ��˵��Ż�','')
insert pos_mode_descript values('1','C','��ģʽ�Ż�Ϊ׼','')
insert pos_mode_descript values('1','D','�Բ˵��Ż�Ϊ׼','')
insert pos_mode_descript values('1','E','�Խϴ���Ż�Ϊ׼','')
insert pos_mode_descript values('1','F','�Խ�С���Ż�Ϊ׼','')
insert pos_mode_descript values('1','G','���Ż�','')
//
insert pos_mode_descript values('2','A','��ģʽ�������Ϊ׼','')
insert pos_mode_descript values('2','B','�Բ˵��������Ϊ׼','')
insert pos_mode_descript values('2','C','�Խϴ�ķ������Ϊ׼','')
insert pos_mode_descript values('2','D','�Խ�С�ķ������Ϊ׼','')
insert pos_mode_descript values('2','E','��ģʽ�������Ϊ׼(�Żݷ����)','')
insert pos_mode_descript values('2','F','�Բ˵��������Ϊ׼(�Żݷ����)','')
insert pos_mode_descript values('2','G','�Խϴ�ķ������Ϊ׼(�Żݷ����)','')
insert pos_mode_descript values('2','H','�Խ�С�ķ������Ϊ׼(�Żݷ����)','')
insert pos_mode_descript values('2','I','�Żݷ����','')
//
insert pos_mode_descript values('3','A','��ģʽ���ӷ���Ϊ׼','')
insert pos_mode_descript values('3','B','�Բ˵����ӷ���Ϊ׼','')
insert pos_mode_descript values('3','C','�Խϴ�ĸ��ӷ���Ϊ׼','')
insert pos_mode_descript values('3','D','�Խ�С�ĸ��ӷ���Ϊ׼','')
insert pos_mode_descript values('3','E','��ģʽ���ӷ���Ϊ׼(�Żݸ��ӷ�)','')
insert pos_mode_descript values('3','F','�Բ˵����ӷ���Ϊ׼(�Żݸ��ӷ�)','')
insert pos_mode_descript values('3','G','�Խϴ�ĸ��ӷ���Ϊ׼(�Żݸ��ӷ�)','')
insert pos_mode_descript values('3','H','�Խ�С�ĸ��ӷ���Ϊ׼(�Żݸ��ӷ�)','')
insert pos_mode_descript values('3','I','�Żݸ��ӷ�','')
;

/*	ģʽ���� */
create table pos_mode_def
(
	code					char(3)		not null,						/*ģʽ����*/
	type					char(1)		not null,						/* 1.�Ż� 2.����� 3.���ӷ� */
	deptcode				char(4)		not null,						/*Ӫҵ�����(0201.02)*/
	plucode				char(15)		not null,						/*�˵�����(A.A01.A010001)*/
	rate					money			default 0 not null,						/*Ԥ�ȱ���*/
	reason				char(2)		default '' not null,			/*Ԥ������*/
	mode					char(1)		not null							/*�ٴ�ģʽ
				1. �Ż�
					A.ģʽ�Żݣز˵��Ż�[price=price0*(1-discount)*(1-fee_rate)]
					B.ģʽ�Żݣ��˵��Ż�[price=price0*(1-discount-fee_rate)]
					C.��ģʽ�Ż�Ϊ׼[price=price0*(1-discount)]
					D.�Բ˵��Ż�Ϊ׼[price=price0*(1-fee_rate)]
					E.�Խϴ���Ż�Ϊ׼[price=price0*(1-max(discount,fee_rate))]
					F.�Խ�С���Ż�Ϊ׼[price=price0*(1-min(discount,fee_rate))]
					G.���Ż�[price=price0]
				2. �����
					A.��ģʽ�������Ϊ׼[serve_charge0=price0*serve_rate,serve_charge=price0*serve_rate]
					B.�Բ˵��������Ϊ׼[serve_charge0=price0*menu_rate,serve_charge=price0*menu_rate]
					C.�Խϴ�ķ������Ϊ׼[serve_charge0=price0*max(serve_rate,menu_rate),serve_charge=price0*max(serve_rate,menu_rate)]
					D.�Խ�С�ķ������Ϊ׼[serve_charge0=price0*min(serve_rate,menu_rate),serve_charge=price0*min(serve_rate,menu_rate)]
					E.��ģʽ�������Ϊ׼(�Żݷ����)[serve_charge0=price0*serve_rate,serve_charge=price*serve_rate]
					F.�Բ˵������Ϊ׼��(�Żݷ����)[serve_charge0=price0*menu_rate,serve_charge=price*menu_rate]
					G.�Խϴ�ķ������Ϊ׼(�Żݷ����)[serve_charge0=price0*max(serve_rate,menu_rate),serve_charge=price*max(serve_rate,menu_rate)]
					H.�Խ�С�ķ������Ϊ׼(�Żݷ����)[serve_charge0=price0*min(serve_rate,menu_rate),serve_charge=price*min(serve_rate,menu_rate)]
					I.�Żݷ����[serve_charge0=price0*menu_rate,serve_charge=0]
				3. ���ӷ�
					A.��ģʽ���ӷ���Ϊ׼[tax_charge0=price0*tax_rate,tax_charge=price0*tax_rate]
					B.�Բ˵����ӷ���Ϊ׼[tax_charge0=price0*menu_rate,tax_charge=price0*menu_rate]
					C.�Խϴ�ĸ��ӷ���Ϊ׼[tax_charge0=price0*max(tax_rate,menu_rate),tax_charge=price0*max(tax_rate,menu_rate)]
					D.�Խ�С�ĸ��ӷ���Ϊ׼[tax_charge0=price0*min(tax_rate,menu_rate),tax_charge=price0*min(tax_rate,menu_rate)]
					C.��ģʽ���ӷ���Ϊ׼(�Żݸ��ӷ�)[tax_charge0=price0*tax_rate,tax_charge=price*tax_rate]
					D.�Բ˵����ӷ�Ϊ׼��(�Żݸ��ӷ�)[tax_charge0=price0*menu_rate,tax_charge=price*menu_rate]
					G.�Խϴ�ĸ��ӷ�Ϊ׼��(�Żݸ��ӷ�)[tax_charge0=price0*max(tax_rate,menu_rate),tax_charge=price*max(tax_rate,menu_rate)]
					H.�Խ�С�ĸ��ӷ�Ϊ׼��(�Żݸ��ӷ�)[tax_charge0=price0*min(tax_rate,menu_rate),tax_charge=price*min(tax_rate,menu_rate)]
					I.�Żݸ��ӷ�[tax_charge0=price0*menu_rate,tax_charge=0]*/
)
exec sp_primarykey pos_mode_def,code,type,deptcode,plucode
create unique index index1 on pos_mode_def(code,type,deptcode,plucode)
;

/*
	��λ�ֲ�ͼ����
*/
create table  pos_mapcode (
	code			char(3)		default ''	not null,	/*����*/
	descript		char(20)		default ''	not null,	/*����*/
	ground_bmp	char(50)		default ''  not null    /*̨λͼ2��̨λ�ֲ�ͼ*/
	);
exec sp_primarykey pos_mapcode,code
;

/*
	��ʱ�շѶ���
*/
create table pos_timecode
(
	timecode			char(3)				not null,
	descript       char(20)          not null
)
exec sp_primarykey pos_timecode,timecode
create unique index index1 on pos_timecode(timecode)

;

/*
	��ʱ�շѶ�����ϸ����
*/
create table pos_time_code
(
	timecode			char(3)				not null,
	number  		   integer			   not null,
   bdate          char(5)           not null,
   edate          char(5)           not null,
   minute         integer           not null,
   amount         money             not null
)
exec sp_primarykey pos_time_code,timecode,number
create unique index index1 on pos_time_code(timecode,number)
;


/*
	���͵�˵�
*/

create table  pos_menu_std (
		menu			char(10)	 not null,						/*����*/
		name1			varchar(30)	default ''	not null,	/*������*/
		name2			varchar(50)	default ''	not null,	/*������*/
		price			money			not null,
		cusno			char(7)		default ''  not null,	/*cusinf.no*/
		gstid			char(7)		default ''  not null,	/*hgstinf.no*/
		id				int			default 0 	not null,	/*�����㣬���Ѿ��������*/
		remark		varchar(100)	null							/*��ע*/
		);
exec sp_primarykey pos_menu_std,menu
;

/*
	���͵�˵���ϸ����
*/
create table  pos_dish_std (
	menu			char(10)	 not null,						/*����*/
	id				int		 not null,						/*��Ψһ��*/
	name1			varchar(30)	default ''	not null,	/*������*/
	name2			varchar(50)	default ''	not null,	/*������*/
	unit			char(4)		default ''	not null,	/*������λ*/
	number		money			not null,					/*����*/
	price			money			not null						/*���*/
	);
exec sp_primarykey pos_dish_std,menu,id
;

drop  TABLE pos_detail_jie ;
CREATE TABLE pos_detail_jie 
(
    date    datetime NOT NULL,
    deptno  char(2)  NOT NULL,
    posno   char(2)  NOT NULL,
    pccode  char(3)  NOT NULL,
    shift   char(1)  NOT NULL,
    empno   char(10) NOT NULL,
    menu    char(10) NOT NULL,
    code    char(15) NOT NULL,
    id      int      NOT NULL,
    type    char(5)  DEFAULT ''	 NOT NULL,
    name1   char(20) NOT NULL,
    name2   char(20) NULL,
    number  money    DEFAULT 0	 NOT NULL,
    amount0 money    DEFAULT 0	 NOT NULL,
    amount1 money    DEFAULT 0	 NOT NULL,
    amount2 money    DEFAULT 0	 NOT NULL,
    amount3 money    DEFAULT 0	 NOT NULL,
    serve0  money    DEFAULT 0	 NOT NULL,
    serve1  money    DEFAULT 0	 NOT NULL,
    serve2  money    DEFAULT 0	 NOT NULL,
    serve3  money    DEFAULT 0	 NOT NULL,
    tax0    money    DEFAULT 0	 NOT NULL,
    tax1    money    DEFAULT 0	 NOT NULL,
    tax2    money    DEFAULT 0	 NOT NULL,
    tax3    money    DEFAULT 0	 NOT NULL,
    reason1 char(3)  NULL,
    reason2 char(3)  NULL,
    reason3 char(3)  DEFAULT ''	 NOT NULL,
    special char(1)  NULL,
    tocode  char(3)  DEFAULT ''	 NOT NULL
);
create unique index index1 on pos_detail_jie(date,menu,code,id, type,reason3);

drop  TABLE pos_detail_dai ;
CREATE TABLE pos_detail_dai (
	date 				datetime		not null ,
	menu 				char(10)		not null ,
	paycode 			char(5)		not null ,
	amount 			money			not null ,
	reason3 			char(3)		not null 
);
create unique index index1 on pos_detail_dai(date,menu,paycode,reason3);


// --------------------------------------------------------------------------
// �ۺ���������跽��ϸͳ�ƣ�����Ϊ�м�ֵ����������ͳ�ƾ����ɱ������� 
// --------------------------------------------------------------------------
create table pos_detail_jie_link
(
	pc_id			char(4)	not	null,
   pccode		char(3)	not	null,			/*������*/
   shift			char(1)	not	null,			/*���*/
   empno			char(10)	not	null,			/*����*/
   menu			char(10)	not	null,			/*�˵���*/
	code			char(15)	not	null,			/*�˺�*/
	name1			char(20)	not	null,			/*����*/
	id				integer	not	null,			/*������*/
	type			char(5)	default	''	not	null,			/*ͳ������'�ո�'ԭ�ۻ��������ۿۣ�'DSC'.DSC�ۿۣ�'ENT'.ENT���*/
	amount0		money		default	0	not	null,			/*ԭ���*/
	amount1		money		default	0	not	null,			/*Ԥ���Żݽ��(���Ż�ģʽ�е��Ż�����)*/
	amount2		money		default	0	not	null,			/*�Żݽ��(���˵��е��Ż�����)*/
	amount3		money		default	0	not	null,			/*�Żݽ��(�������е��Ż�����)*/
	reason3		char(3)	default	''	not	null,			/*�������ۿۣ�DSC�ۿۣ�ENT������Ż�����*/
	special		char(1)	null,									/*��Ӧpos_plu��special*/
	tocode		char(3)	default	''	not	null,			/*��Ӧpos_itemdef��code*/
	date			datetime not null
)
exec sp_primarykey pos_detail_jie_link,pc_id,menu,code,id,type,reason3
create unique index index1 on pos_detail_jie_link(pc_id,menu,code,id,type,reason3)
;

CREATE TABLE pos_int_pccode (
	class 		char(1)		default ''	not null,
	pccode 		char(5)		default ''	not null,
	int_code 	char(5)		default ''	not null,
	name1 		char(20)		default ''	not null,
	name2 		char(30)		default ''	not null,
	shift 		char(1)		default ''	null,
	pos_pccode	char(3)		default ''	null,
	itemcode 	char(3)		default ''	null,
	start_time 	char(8)		default ''	null,
	end_tiem 	char(8)		default ''	null,
	end_time 	char(8)		default ''	null
);
exec sp_primarykey pos_int_pccode,class,pccode,shift,pos_pccode
create unique index index1 on pos_int_pccode(class,pccode,shift,pos_pccode)
;


if exists(select * from sysobjects where name = "pos_tblmap" and type ="U")
	 drop table pos_tblmap
;

create table pos_tblmap
(
	pc_id			char(4)		  default ''	not null,
	pccode		char(3)		  default ''	not null,
	tableno 		char(16)      default space(16) not null,
	descript		char(20)		  default ''	not null,
	menu			char(10)      default space(10) not null,
	sta			char(1)       default space(1) not null,
	bdate			datetime		  ,
	shift			char(1)		  not null,
	tables		integer			,
	guests		integer			,
	empno3		char(10)			,
	amount		money				,
	pcrec			char(10),	
	resno			char(10)        
)

;

/*����ǰ̨ϵͳ�������ᶨ��*/
insert into basecode_cat(cat, descript, descript1) select 'pos_trans_front', '����ǰ̨ϵͳ��������','Pos Front Transaction';
insert into basecode (cat,code,descript,descript1) select 'pos_trans_front', '1', '192.168.2.20:pos1','ǰ̨ϵͳ';
insert into basecode (cat,code,descript,descript1) select 'pos_trans_front', '2', '192.168.2.2:x50203','x50203ǰ̨ϵͳ';



