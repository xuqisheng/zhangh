//********************��̨������Ҫ��ṹ����˵��***********************
--1.��̨��Ʒ�����
if exists(select * from sysobjects where name = "pos_st_class" and type ="U")
	drop table pos_st_class;
CREATE TABLE dbo.pos_st_class 
(
    code     char(12) NOT NULL,
    name     char(10) NOT NULL,
    eng_name char(60) DEFAULT '' NULL
);
EXEC sp_primarykey 'dbo.pos_st_class', code;

CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.pos_st_class(code);

CREATE UNIQUE NONCLUSTERED INDEX index2
    ON dbo.pos_st_class(name);

--2.��̨��ƷС���
if exists(select * from sysobjects where name = "pos_st_subclass" and type ="U")
	drop table pos_st_subclass;
CREATE TABLE dbo.pos_st_subclass 
(
    code      char(12) NOT NULL,
    name      char(16) NOT NULL,
    cseg      char(10) DEFAULT '' NOT NULL,  --�����������
    cname     char(10) DEFAULT '' NOT NULL,
    cstype    char(2)  DEFAULT '' NULL,
    eng_name  char(60) DEFAULT '' NULL,
    eng_cname char(60) DEFAULT '' NULL
);
EXEC sp_primarykey 'dbo.pos_st_subclass', code;


CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.pos_st_subclass(code);

--3.��̨��Ʒ��
if exists(select * from sysobjects where name = "pos_st_article" and type ="U")
	drop table pos_st_article;
CREATE TABLE dbo.pos_st_article 
(
    code        char(12) NOT NULL,
    name        char(40) NOT NULL,
    unit        char(6)  NOT NULL,
    price       money    DEFAULT 0 NOT NULL,
    max_quan    money    DEFAULT 0 NOT NULL,				--����
    min_quan    money    DEFAULT 0 NOT NULL,				--����
    sseg        char(12) DEFAULT '' NOT NULL,			
    sname       char(16) DEFAULT '' NOT NULL,
    cseg        char(12) DEFAULT '' NOT NULL,
    cname       char(10) DEFAULT '' NOT NULL,
    oactmode    char(10) DEFAULT 'RR 2' NOT NULL,
    actmode     char(10) DEFAULT 'RR 2' NOT NULL,
    helpcode    char(60) DEFAULT '' NOT NULL,			--���̨��һ��
    standent    char(16) DEFAULT '' NOT NULL,			--���̨��һ�¡����ȼӴ�
    band        char(10) DEFAULT '' NOT NULL,			--����
    warning     int      DEFAULT 0 NOT NULL,				--����
    lpno        int      DEFAULT 0 NOT NULL,				--�Ƚ��ȳ�����
    lprice      money    DEFAULT 0 NOT NULL,				--����
    unit2       char(6)  DEFAULT '' NOT NULL,			--����
    equn2       money    DEFAULT 0 NOT NULL,				--����
    minprice    money    DEFAULT 0 NOT NULL,				--����
    minsup      char(14) DEFAULT '' NOT NULL,			--����
    maxprice    money    DEFAULT 0 NOT NULL,				--����
    maxsup      char(14) DEFAULT '' NOT NULL,			--����
    avprice     money    DEFAULT 0  	 NOT NULL,		--����
    storage     char(2)  DEFAULT '' 	 NOT NULL,		--���á�������ABC���ࡿ
    quocode     char(3)  DEFAULT '0' NOT NULL,			--����
    csnumber    money    DEFAULT 0 	 NOT NULL,
    csunit      char(4)  DEFAULT '' 	 NOT NULL,
    csbili      int      DEFAULT 0 	 NOT NULL,			--����
    cstype      char(2)  DEFAULT ''	 NOT NULL,			--�ɱ�����
    safe_quan   money    DEFAULT 0 	 NOT NULL,			--����
    valid       char(1)  DEFAULT '1' NOT NULL,			--��Ч�ԣ�1��Ч��0��Ч�����̨��һ�¡�
    ref         char(60) DEFAULT '' 	 NOT NULL,
    sale_price  money    DEFAULT 0 	 NOT NULL,				--����
    limitnumber money    DEFAULT 0 	 NOT NULL,    			--����
    eng_name    char(60) DEFAULT '' NULL,
    eng_sname   char(60) DEFAULT '' NULL,
    eng_cname   char(60) DEFAULT '' NULL
)

EXEC sp_primarykey 'dbo.pos_st_article', code;

CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.pos_st_article(code);
    
--4.�ɱ���
if exists(select * from sysobjects where name = "pos_pldef_price" and type ="U")
	drop table pos_pldef_price;
CREATE TABLE dbo.pos_pldef_price 
(
    pccode   char(3)  NOT NULL,
    id       int      DEFAULT 0	 NOT NULL,
    inumber  int      DEFAULT 0	 NOT NULL,
    artcode  char(12) DEFAULT ''	 NOT NULL,				--���ں�̨��Ʒ��
    unit     char(4)  DEFAULT ''	 NOT NULL,        --��Ʒ��λ
    descript char(40) DEFAULT '' NOT NULL,
    number   money    DEFAULT 0	 NOT NULL,					--ԭ���������
    article  char(12) DEFAULT '' NOT NULL,					--���ڰ�̨������artcodeֻȡ��һ
    csunit   char(4)  DEFAULT '' NOT NULL,					--ԭ�ϵ�λ
    price    money    DEFAULT 0 NOT NULL,						--ԭ�ϵ���
    rate     money    DEFAULT 0 NOT NULL,						--������
    condid   int      DEFAULT 0  NULL								--������
);
EXEC sp_primarykey 'dbo.pos_pldef_price', id,inumber,artcode,article;
CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.pos_pldef_price(id,inumber,artcode,article);
    
--5.����ҵ�񵥾�����
if exists(select * from sysobjects where name = "pos_st_documst" and type ="U")
	drop table pos_st_documst;
CREATE TABLE dbo.pos_st_documst 
(
    id       int         NOT NULL,
    lockmark char(4)     NULL,
    ostcode  char(3)     NULL,          --����
    istcode   char(3)     NOT NULL,		 --���
    vdate    datetime    NOT NULL,
    vtype    char(2)     NOT NULL,
    vno      int         DEFAULT 0 NULL,
    spcode   char(4)     NULL,
    invoice  char(10)    NULL,
    ref      varchar(60) DEFAULT '' NULL,
    vmark    char(2)     DEFAULT '' NOT NULL,    //�ڲ���־=''��ʾҵ�񵥾�;'A'- "OY"��¼���������ͽ��;'B' - "RR"�ڳ���ת��;'E':��δ��ת��,����ʷ�շ����е����ڳ�ת�뵥�ݡ�
    empno    char(10)     DEFAULT '' NOT NULL,	 --����Ա
    log_date datetime    DEFAULT getdate() NOT NULL,    --����
    logmark  int         DEFAULT 0 NOT NULL,				  --����
    empno0   char(10)     DEFAULT '' NOT NULL,           --�ջ��ˡ����á�
	 empno1   char(10)     DEFAULT '' NOT NULL,			  --�����ˡ����á�
    costitem char(5)     DEFAULT '' NOT NULL,           --�������ڳɱ�ϵͳ
    paymth   char(5)     DEFAULT '' NOT NULL,			  --���ʽ
    tag     char(1)     DEFAULT '' NOT NULL				  --������־
);

EXEC sp_primarykey 'dbo.pos_st_documst', vdate,vtype,vno,id;

CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.pos_st_documst(vdate,vtype,vno,id);

CREATE UNIQUE NONCLUSTERED INDEX index2
    ON dbo.pos_st_documst(id);

CREATE UNIQUE NONCLUSTERED INDEX index3
    ON dbo.pos_st_documst(vtype,vdate,vno,id);
    

--6.����ҵ�񵥾���ϸ
if exists(select * from sysobjects where name = "pos_st_docudtl" and type ="U")
	drop table pos_st_docudtl;
CREATE TABLE dbo.pos_st_docudtl         --���պ�̨ϵͳst_docu_dtl
(
    id        int      NOT NULL,
    subid     int      NOT NULL,
    code      char(12) NOT NULL,
    number    money    DEFAULT 0 NOT NULL,
    amount    money    DEFAULT 0 NOT NULL,
    price     money    DEFAULT 0 NOT NULL,
    validdate datetime DEFAULT getdate() NOT NULL,
    tax       money    DEFAULT 0 NOT NULL,												--���±���
    deliver   money    DEFAULT 0 NOT NULL,
    rebate    money    DEFAULT 0 NOT NULL,
    csaccnt   char(12) DEFAULT '' NOT NULL,
    prid      int      DEFAULT 0 NOT NULL,
    tag       char(1)  DEFAULT '' NOT NULL,
    productor char(60) DEFAULT '' NOT NULL,
    pdate     datetime DEFAULT getdate() NOT NULL,
    kpdays    char(10) DEFAULT '' NOT NULL,
    note      char(50) DEFAULT '' NOT NULL
);
EXEC sp_primarykey 'dbo.pos_st_docudtl', id,code,subid
;
CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.pos_st_docudtl(id,code,subid)
;
CREATE UNIQUE NONCLUSTERED INDEX index2
    ON dbo.pos_st_docudtl(id,subid)
;

--7.������̨�ս�״̬��¼
if exists(select * from sysobjects where name = "pos_store_checkout" and type ="U")
	drop table pos_store_checkout;
CREATE TABLE dbo.pos_store_checkout                --������̨����ת
(
    pc_id	char(4) default '' not null,
	 code 	char(2) default ''  NOT NULL,							--�ս��������Ĺ���ID
    descript	char(40)	default '' NOT NULL, 			--�ս��������Ĺ�������                 
    flag  char(1) NOT NULL										--�ɹ����ı�־
);

EXEC sp_primarykey 'dbo.pos_store_checkout', pc_id,code;
CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.pos_store_checkout( pc_id,code);


--8.����¼��
if exists(select * from sysobjects where name = "pos_store_stock" and type ="U")
	drop table pos_store_stock;
CREATE TABLE dbo.pos_store_stock                 --��Ʒʵʱ���� 
(
    istcode char(3)  NOT NULL,							--���ֿ����
    code    char(12)      NOT NULL, 					--��Ʒ����                  
    price  money NOT NULL,									--���ƽ����(���ݼ۸���Դ)
    number    money    NOT NULL,							--�������
	 amount    money    NOT NULL							--�����
);

EXEC sp_primarykey 'dbo.pos_store_stock', istcode,code;
CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.pos_store_stock(istcode,code);
    
--9.��̨�����
if exists(select * from sysobjects where name = "pos_store" and type ="U")
	drop table pos_store;
CREATE TABLE dbo.pos_store 
(
    code      char(3)   NOT NULL,         --��̨��
    descript  char(20)  NOT NULL,
    descript1 char(50)  NULL,
    pccodes   char(100) NOT NULL,					--��ӦӪҵ����
    empno     char(10)  DEFAULT ''	 NOT NULL,
    sup       char(6)   NULL,						  --����
    barcode   char(5)   NULL							--����
)
;
EXEC sp_primarykey 'dbo.pos_store', code
;
CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.pos_store(code)
;
