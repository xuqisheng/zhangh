//==========================================================================
//	Table : cusinf  -- ��λ����
//
//		basecode:	salegrp, cuscls1, cuscls2, cuscls3, cuscls4
//
//		table :
//				
//				saleid, cusinf, cusinf_log, cusinf_del,
//==========================================================================


// --------------------------------------------------------------------------
//  basecode : salegrp  -- ����Ա���
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='salegrp')
	delete basecode_cat where cat='salegrp';
insert basecode_cat select 'salegrp', '����Ա���', 'saler group', 1;
delete basecode where cat='salegrp';
insert basecode(cat,code,descript,descript1) select 'salegrp', 'A', '���۲�', 'Sales Department';
insert basecode(cat,code,descript,descript1) select 'salegrp', 'B', 'ǰ����', 'Front Office Department';
insert basecode(cat,code,descript,descript1) select 'salegrp', 'C', '����', 'Other';


// ----------------------------------------------------------------
// table :	saleid	= ����Ա 
// ----------------------------------------------------------------
//exec sp_rename saleid, a_saleid;
if exists(select 1 from sysobjects where name = "saleid")
	drop table saleid;
create table  saleid
(
	code    		char(10)						not null,
	descript    varchar(30)	default ''	not null,
	descript1   varchar(30)	default ''	not null,
	grp			char(3)						not null,		// ���
	empno			char(10)						not null			// ���Թ���
)
exec sp_primarykey saleid,code
create unique index index1 on saleid(code)
create unique index index2 on saleid(descript)
;
//insert saleid select code,descript,'',grpno,empno from a_saleid;
//drop table a_saleid;

// --------------------------------------------------------------------------
//  basecode : cuscls1  -- �ͻ�����λ���������-1
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='cuscls1')
	delete basecode_cat where cat='cuscls1';
insert basecode_cat select 'cuscls1', '�ͻ�����λ���������-1', 'Unit Class - 1', 3;
delete basecode where cat='cuscls1';
insert basecode(cat,code,descript,descript1) 
	select 'cuscls1', code, des, '' from cuscls;

// --------------------------------------------------------------------------
//  basecode : cuscls2  -- �ͻ�����λ���������-2
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='cuscls2')
	delete basecode_cat where cat='cuscls2';
insert basecode_cat select 'cuscls2', '�ͻ�����λ���������-2', 'Unit Class - 2', 3;
delete basecode where cat='cuscls2';
insert basecode(cat,code,descript,descript1) 
	select 'cuscls2', code, des, '' from cuscls1;

// --------------------------------------------------------------------------
//  basecode : cuscls3  -- �ͻ�����λ���������-3
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='cuscls3')
	delete basecode_cat where cat='cuscls3';
insert basecode_cat select 'cuscls3', '�ͻ�����λ���������-3', 'Unit Class - 3', 3;
delete basecode where cat='cuscls3';
insert basecode(cat,code,descript,descript1) 
	select 'cuscls3', code, des, '' from cuscls2;

// --------------------------------------------------------------------------
//  basecode : cuscls4  -- �ͻ�����λ���������-4
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='cuscls4')
	delete basecode_cat where cat='cuscls4';
insert basecode_cat select 'cuscls4', '�ͻ�����λ���������-4', 'Unit Class - 4', 3;
delete basecode where cat='cuscls4';
insert basecode(cat,code,descript,descript1) 
	select 'cuscls4', code, des, '' from cuscls3;



// ----------------------------------------------------------------
// 	table :	cusinf	�ͻ�(��λ)����
// ----------------------------------------------------------------
//	exec sp_rename cusinf, a_cusinf;
if exists(select * from sysobjects where name = "cusinf")
	drop table cusinf;
create table cusinf
(
	no         		char(7)	    						not null,   // ���Ե�����
	sno         	varchar(15)	   default ''		not null,   // �ͻ��� ��λ�Զ���   
	sta				char(1)			default 'I' 	not null,	// ״̬- I(n), O(ff)
   name          	varchar(60)   	default ''		not null,  	// ��λ����
   name1         	varchar(60)   	default ''		not null, 
   name2         	varchar(60)   	default ''		not null, 
	type				char(3)			default ''		not null,	// ���� -- n��ͨ/b������/c�ָ�/r����
	class				char(1)			default 'C'		not null,	// ���: C=��˾��A=�����磻S=�������� --> �̶����룻
	class1			char(3)			default '0'		not null, 	// �������	0=��ʾû�ж��壻
	class2			char(3)			default '0'		not null,
	class3			char(3)			default '0'		not null,
	class4			char(3)			default '0'		not null,
	keep				char(1) 			default 'F'  	not null,  	// ���� 

   country       	char(3) 			default 'CHN'	not null,  	// ����
	birthplace  	char(6)			default ''		not null,	// ���� ����
	address			varchar(60)		default '' 		not null,	// ��ַ
	address1			varchar(60)		default ''		null,			// ��ַ
	zip				varchar(6)		default ''		not null,	// ��������
	phone				varchar(20)		default '' 		not null,
	fax				varchar(20)		default ''		not null,
	wetsite			varchar(30)		default ''		not null,	// ��ַ 
	email				varchar(30)		default ''		not null,	// ���� 
	qq					varchar(30)		default ''		not null,	// qq, msn, icq

	lawman			varchar(16)		default ''		null,			// ����������
	regno				varchar(20)		default ''		null,			// ��ҵ�ǼǺ�
   liason        	varchar(30)   	default ''		not null,     	// ��ϵ��
   liason1       	varchar(30)   	default ''		null,     	// ��ϵ��ʽ
   arr           	datetime      						null,  		// ��Ч����
   dep           	datetime      						null,			// ��ֹ����
	extrainf			varchar(30)	 	default '' 		not null,	// for gaoliang  
	comment			varchar(90)	 	default '' 		not null,	// ˵��
   remark      	text 									null,			// ��ע 
	override			char(1)     	default 'F'		not null,	// ���Գ���� 

	code1				char(10)			default ''		not null, 	// ������ 
	code2				char(3)			default ''		not null, 	// ������ 
	code3				char(3)			default ''		not null, 	// ���� 
	code4				char(3)			default ''		not null, 	// ���� 
	code5				char(3)			default ''		not null, 	// ���� 

   saleid      	char(10)      	default ''		not null,	// ����Ա 

	araccnt1			char(7)     	default ''		not null,	// Ӧ���ʺ� 
	araccnt2			char(7)     	default ''		not null,	// Ӧ���ʺ� 

	fv_date			datetime								null,			// �״ε��� 
	fv_room			char(5)			default ''		not null,
	fv_rate			money				default 0		not null,
	lv_date			datetime								null,			// �ϴε��� 
	lv_room			char(5)			default ''		not null,
	lv_rate			money				default 0		not null,

   i_times     	int 				default 0 		not null,   // ס����� 
   x_times     	int 				default 0 		not null,   // ȡ��Ԥ������ 
   n_times     	int 				default 0 		not null,   // Ӧ��δ������ 
   l_times     	int 				default 0 		not null,   // �������� 
   i_days      	int 				default 0 		not null,   // ס������ 
   tl          	money 			default 0 		not null, 	// ������  
   rm          	money 			default 0 		not null, 	// ��������
   rm_b        	money 			default 0 		not null, 	// ������������
   rm_e        	money 			default 0 		not null, 	// ����ǽ�������
   fb          	money 			default 0 		not null, 	// ��������
   en          	money 			default 0 		not null, 	// ��������
   ot          	money 			default 0 		not null, 	// ��������

   crtby       	char(10)								not null,	// ���� 
	crttime     	datetime 		default getdate()	not null,
   cby         	char(10)								not null,	// �޸� 
	changed     	datetime 		default getdate()	not null,
	logmark     	int 				default 0 		not null
)
exec sp_primarykey cusinf, no
create unique index index1 on cusinf(no)
create unique index index2 on cusinf(name)
create index index3 on cusinf(saleid)
create index index4 on cusinf(class)
create index index5 on cusinf(class1)
create index index6 on cusinf(class2)
create index index7 on cusinf(class3)
create index index8 on cusinf(sno)
;


// ----------------------------------------------------------------
// table :	cusinf_log	= log table for cusinf
// ----------------------------------------------------------------
if exists(select 1 from sysobjects where name = "cusinf_log")
	drop table cusinf_log;
select * into cusinf_log from cusinf where 1=2;
exec sp_primarykey cusinf_log, no, logmark
create unique index index1 on cusinf_log(no, logmark)
;


// ----------------------------------------------------------------
// table : cusinf_del	=	delete table for cusinf
// ----------------------------------------------------------------
if exists(select 1 from sysobjects where name = "cusinf_del")
	drop table cusinf_del;
select * into cusinf_del from cusinf where 1=2;
exec sp_primarykey cusinf_del, no
create unique index index1 on cusinf_del(no)
;

/*
insert cusinf 
  SELECT no,   
         sno,   
         sta,   
         name,'','',   
         '',   	-- type
         'C',   
         class,   
         class1,   
         class2,   
         class3,   
         'T',   -- keet
         nation,   
         '',   	-- birthplace
         isnull(address,''),'',
         isnull(zip,''),   
         isnull(phone,''),   
         isnull(fax,''),   
         isnull(wwwinfo,''),'','',
         lawman,   
         regno,   
         isnull(liason,''),   
         liason1,   
         arr,   
         dep,   
         '',   
         isnull(descript,''),   
         more,   
         'F', 
         '','','','','',
         saleid,   
         isnull(araccnt1,''),   
         isnull(araccnt2,''),
			null,'',0,   null,'',0,   

         i_times,   
         x_times,   
         n_times,   
         l_times,   
         i_days,   
         tl,   
         rm,   
         rm_b,   
         rm_e,   
         fb,   
         en,   
         ot,   
         cby,changed,cby,changed,logmark  
    FROM a_cusinf  ;

update cusinf set class='A' where name like '%��%';
update cusinf set class='S' where name like '%��%' or name like '%��%' or name like '%Я%' ;

*/