------------------------------------------------------------------------------
--������ӡ��ṹ����
--1.��ӡ����վ��Ķ���(�����Ƚ϶�,�����Ƚ϶������ʺ�ʹ��,ͨ�������ֻ��һ��)
--2.��ӡ���Ķ���(������ӡ�����Ƶ�����,IP��ַ��)
--3.��������(һ��������Ӧһ����ӡ��,һ�����ô�ӡ��,һ����ӡ����վ��)
--4.���׳�������(�ĸ���������ĸ��˶�Ӧ�ļ�������)
------------------------------------------------------------------------------


--��ӡ����վ�㶨��

create table pos_pserver
(
	code			char(3)		not null,	/*����վ��Ĵ���*/
	descript 	char(40)		not null,	/*��������*/
	descript1	char(40)		null,			/*Ӣ������*/
	pc_id			char(4)		not null		/*����վ���IP*/
)
exec sp_primarykey pos_pserver,code
create unique index index1 on pos_pserver(code)

;

--��ӡ������

create table pos_printer
(
	code			char(3)			not null,				/*��ӡ������*/
	descript 	char(40)			not null,				/*��������*/
	descript1	char(40)			null,						/*Ӣ������*/
	name			char(100) 		not null,				/*ϵͳ��ӡ������*/
	pc_id			char(15)   	 	null,						/*��ӡ����Ӧ��ӡ��������IP*/
	oid			char(50)			null,						/*��ӡ������Դ��Ϣ*/
	sta			char(1)			null,						/*��ӡ����ǰ״̬,1-����,2-ȱֽ,3-��������*/
	sta1			char(1)			null,						/*��ӡ����ǰ״̬ˢ��*/
	set0			char(1)			default 'T' not null,/*�Ƿ������ӡ*/
	set1			char(1)			default 'T' not null,/*�Ƿ��ӡ����*/
	set2			char(1)     	default 'T' not null,/*�����Ƿ���ɫ����*/
	set3			char(1)			default 'T' not null,/*�Ƿ�����������ʾ*/
	set4			char(1)			default 'T' not null,/*�Ƿ��ӡ�˼�*/
	set5			char(1)			default 'T' not null,/*��������*/
	set6			char(1)     	default 'T' not null,/*��������*/
	set7			char(1)			default 'T' not null,/*��������*/
	set8			char(1)     	default 'T' not null,/*��������*/
	set9			char(1)			default 'T' not null,/*��������*/
	value_nr       char(20)  	DEFAULT ''	NOT NULL,
   value_paperoff char(20)  	DEFAULT '' 	NOT NULL,
   value_off      char(20)  	DEFAULT '' 	NOT NULL,
   linktype       char(1)   	DEFAULT '1' NOT NULL,
	printer			char(3)		default '' 	not null,
	pcode				char(3)		default '' 	not null,
	dish_chk			char(4)		default ''	not null  /*�������˵�PC_ID*/
   value_printing char(20)  	NULL,                 /*���ڴ�ӡ״̬*/
   comm           char(2)   	NULL                  /*�������ԵĴ���*/
	
)
exec sp_primarykey pos_printer,code
create unique index index1 on pos_printer(code)

;

--��������


--���׳�������

create table pos_prnscope
(
	pccode		char(3)		default '' not null,	/*��pos_pccode��Ӧ�Ĳ���pccode*/
	plucode  	char(2)		default '' not null,	/*�˱���*/
	plusort		char(4)		default '' not null,	/*�����*/
	id				integer		default 0  not null,	/*�˵�ID��*/
	kitchens		char(20)		default '' not null,	/*����Ӧ�ĳ���,����Ϊ���(***#***#***#)*/
	pluid			integer		default 0  not null  /*���׺�*/
)
exec sp_primarykey pos_prnscope,pluid, pccode,plusort,id
create unique index index1 on pos_prnscope(pluid, pccode,plusort,id)
;


/*���嵥  ��ǰʣ������ = number + number2 - number1 */
if exists(select * from sysobjects where name = "pos_assess" and type ="U")
	drop table pos_assess
;
create table pos_assess
(
	bdate			datetime		not null,
	id				int			not null,				 /*pos_plu.id*/
	unit			char(4)		null,						 /*��λ*/
	number		money			default 0 not null,   /*���տ�������*/  
	number1		money			default 0 not null,   /*������������*/  
	number2		money			default 0 not null,   /*��������*/  
	empno			char(10)		null,						 /*����Ա����*/
	logdate		datetime		null,						 /*����*/
	payout		char(1)		null						 /*T:����, ��������û������������Ա��ʱ����*/	
)
exec sp_primarykey pos_assess,bdate,id
create unique index index1 on pos_assess(bdate,id)
;

/* ������ӡ --  */

if exists(select * from sysobjects where name = "pos_dishcard" and type="U")
	 drop table pos_dishcard
;
create table pos_dishcard
(
	menu  		char(10)  		not null,  				// �˵���
	tableno		char(6)	 		not null,
	printid		integer   		not null,   			// ������ӡ������
  	inumber 		integer   		not null,   			// ���
  	id		 		integer   		not null,   			// �˺�
  	sta   		char(1)   		not null,       		// ״̬ - 
  	code  		char(15)  		not null,       		// ����
  	name1 		char(20)  		not null,       		// ������
  	name2 		char(30)  		null, 	      		// Ӣ��
  	unit    		char(4) 			null,       			// ��λ
  	price  		money   			null,        			// ����
  	number  		money   			default 1	not null,// ����

	p_number  	int				not null,				//��ӡ����
	p_number1 	int 				not null,         	//��ӡ����(�鿴)

  	empno  		char(10)  		null,       			// ����Ա
	date			datetime			not null,				// ʱ�� -- ͬһ�δ򵥵�ʱ��һ�£�����ͬʱ��ӡ
																	//    ���м�ķ��ఴclass 
  	changed 		char(1)  		default 'F' not null,// ��ӡ��־  T=�Ѿ���ӡ,F=δ��ӡ,
																	//H=��ʾ�ϲ���ӡ
																	//K=��ʦ����ӡ
																	//B=���˿ڴ�ӡ
	changed1 	char(1)  		default 'F' not null,// ��ӡ��־ (�鿴)
	times			integer			default 0	not null,// ��ӡ����  -- �����ش򣬵���Ҫ��Ȩ�� !
  	pc_id   		char(4) 			null,   					// ����վ��
	printer		char(20) 		default ''  not null,// ��ӡ��
	printer1		char(20) 		default ''  not null,// ��ӡ��(�鿴)

	refer			varchar(20)		null, 					// ��ӡ����˵��
	cook			varchar(100) 	default '' 	null,		// �������Ҫ��
	bdate			datetime			null,
	p_sort		char(3)			null,						//��ӡ����
	foliono		integer			default 0	null,		/*����ˮ�Ŵ�ӡʱԭ���Ĵ�ӡ��*/
	siteno		char(2)			default ''	not null, /*��λ��*/
	pdate			datetime			null 						/*��ӡʱ��*/

)
exec sp_primarykey pos_dishcard, printid,changed1
create unique index index11 on pos_dishcard(printid,changed1)
create index index2 on pos_dishcard(code)
create index index3 on pos_dishcard(date,menu)
;
if exists(select * from sysobjects where name = "pos_hdishcard" and type="U")
	 drop table pos_hdishcard;
select * into pos_hdishcard from pos_dishcard ;
exec sp_primarykey pos_hdishcard, bdate,printid,changed1
create index index3 on pos_hdishcard(bdate,printid,changed1)
;


// ������ӡ��������ӡ,��¼���һ�δ�ӡ,�����ӡ��������,�ڱ��ô�ӡ���ϰѻ��������´�ӡһ��
CREATE TABLE pos_dishcard_buf 
(
    menu      char(10)     NOT NULL,
    tableno   char(6)      NOT NULL,
    printid   int          NOT NULL,
    inumber   int          NOT NULL,
    id        int          NOT NULL,
    sta       char(1)      NOT NULL,
    code      char(15)     NOT NULL,
    name1     char(20)     NOT NULL,
    name2     char(30)     NULL,
    unit      char(4)      NULL,
    price     money        NULL,
    number    money        DEFAULT 1	 NOT NULL,
    p_number  int          NOT NULL,
    p_number1 int          NOT NULL,
    empno     char(10)     NULL,
    date      datetime     NOT NULL,
    changed   char(1)      DEFAULT 'F' NOT NULL,
    changed1  char(1)      DEFAULT 'F' NOT NULL,
    times     int          DEFAULT 0	 NOT NULL,
    pc_id     char(4)      NULL,
    printer   char(20)     DEFAULT '' NOT NULL,      // ����ϴ��õ��Ĵ�ӡ��
    printer1  char(20)     DEFAULT '' NOT NULL,      // 
    refer     varchar(20)  NULL,
    cook      varchar(100) DEFAULT '' 	 NULL,
    bdate     datetime     NULL,
    p_sort    char(3)      NULL,
    foliono   int          DEFAULT 0	 NULL,
    siteno    char(2)      DEFAULT ''	 NOT NULL,
    pdate     datetime     NULL,
	 printer_err char(3)    default '' not null      // �����ϵĴ�ӡ��  
);
EXEC sp_primarykey 'pos_dishcard_buf', printid,changed1;
CREATE UNIQUE NONCLUSTERED INDEX index11
    ON pos_dishcard_buf(printid,changed1);
CREATE NONCLUSTERED INDEX index2
    ON pos_dishcard_buf(code);
CREATE NONCLUSTERED INDEX index3
    ON pos_dishcard_buf(date,menu)
;
if exists(select * from sysobjects where name = "pos_pdishcard" and type="U")
	 drop table pos_pdishcard;
select * into pos_pdishcard from pos_dishcard ;
exec sp_primarykey pos_pdishcard, printid,changed1
create index index3 on pos_pdishcard(printid,changed1)
;
/*-----��ӡ��ˮ�ſ���------*/
if exists(select * from sysobjects where name = "pos_fdishcard" and type="U")
	 drop table pos_fdishcard
;
create table pos_fdishcard
(
	foliono			integer			default 0	not null,		/*��ˮ��*/
	printid			integer			default ''	not null,		/*��ˮ�Ŷ�Ӧ�����д�ӡ�Ŵ�*/
	printer			char(3)			default ''	not null,		/*��Ӧ��ӡ��*/
	ptype				char(1)			default ''	not null,		/*��ӡ����*/
	times				integer			default 0	not null,		/*��ӡ����*/
	p_number			integer			default 0	not null,		/*��ӡ����*/
	date				datetime			null
	
)
;
exec sp_primarykey pos_fdishcard, foliono,printid
;
create unique index index1 on pos_fdishcard(foliono,printid)
;

insert into basecode_cat (cat,descript,descript1,len,flag,center)
select 'pos_print_sta','������ӡ��״̬', 'Pos Printer Status',1,'','F';
insert into basecode (cat,code,descript,descript1,sys,halt,sequence,grp,center)
select 'pos_print_sta','0','����','NR','T','F',100,'F','F';
insert into basecode (cat,code,descript,descript1,sys,halt,sequence,grp,center)
select 'pos_print_sta','1','ȱֽ','No Paper','T','F',200,'F','F';
insert into basecode (cat,code,descript,descript1,sys,halt,sequence,grp,center)
select 'pos_print_sta','2','�ѻ�','Off Line','T','F',300,'F','F';
insert into basecode (cat,code,descript,descript1,sys,halt,sequence,grp,center)
select 'pos_print_sta','9','����','Other','T','F',400,'F','F';

// �͵���ӡ���ż�¼�����ڲ�ѯ�Ƿ���©��
CREATE TABLE dbo.pos_ktprn 
(
    bdate   datetime NULL,
    menu    char(10) DEFAULT ''	 NOT NULL,
    code    char(10) DEFAULT ''	 NOT NULL,
    prnname char(30) DEFAULT ''	 NOT NULL,
    prntype char(10) DEFAULT ''	 NOT NULL,
    inumber int      DEFAULT 0	 NOT NULL,
    logdate datetime NULL
)
;
EXEC sp_primarykey 'dbo.pos_ktprn', bdate,menu,prnname,prntype,inumber,logdate
;
CREATE NONCLUSTERED INDEX index10
    ON dbo.pos_ktprn(bdate,menu,prnname,inumber)
;


