//==========================================================================
//	Table : guest  -- ��ʷ����
//
//		basecode:	guest_type, interest, language, 
//						salegrp, cuscls1, cuscls2, cuscls3, cuscls4, incomekey
//						guest_grade, religion, latency, blkcls, guest_sumtag 
//
//		table :
//				title, guest, guest_log, guest_del, saleid, master_income, blkmst,
//				guest_extra
//==========================================================================


// --------------------------------------------------------------------------
//  basecode : guest_class  -- ��ʷ���������
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='guest_class')
	delete basecode_cat where cat='guest_class';
insert basecode_cat select 'guest_class', '��ʷ�������', 'Guest Class', 1;
delete basecode where cat='guest_class';
insert basecode(cat,code,descript,descript1,sys) select 'guest_class', 'F', 'ɢ��', 'fit','T';
insert basecode(cat,code,descript,descript1,sys) select 'guest_class', 'G', '����', 'grp','T';
insert basecode(cat,code,descript,descript1,sys) select 'guest_class', 'C', '��˾', 'comp','T';
insert basecode(cat,code,descript,descript1,sys) select 'guest_class', 'A', '������', 'agent','T';
insert basecode(cat,code,descript,descript1,sys) select 'guest_class', 'S', '��������', 'source','T';


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


// --------------------------------------------------------------------------
//  basecode : guest_type  -- ��ʷ����������
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='guest_type')
	delete basecode_cat where cat='guest_type';
insert basecode_cat select 'guest_type', '��ʷ�������', 'Guest Class', 3;
delete basecode where cat='guest_type';
insert basecode(cat,code,descript,descript1,sys) select 'guest_type', 'N', '��ͨ', 'Normal','T';
insert basecode(cat,code,descript,descript1,sys) select 'guest_type', 'B', '������', 'Black','T';
insert basecode(cat,code,descript,descript1,sys) select 'guest_type', 'C', '�ָ�', 'Cashes','T';
insert basecode(cat,code,descript,descript1,sys) select 'guest_type', 'R', '����', 'Post','T';


// --------------------------------------------------------------------------
//  basecode : interest  -- ����
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='interest')
	delete basecode_cat where cat='interest';
insert basecode_cat select 'interest', '����', 'Interest', 3;
delete basecode where cat='interest';
insert basecode(cat,code,descript,descript1) select 'interest', 'TH', 'Ϸ��', 'Theatre';
insert basecode(cat,code,descript,descript1) select 'interest', 'TE', '����', 'Tennis';
insert basecode(cat,code,descript,descript1) select 'interest', 'GO', '�߶���', 'Golf';
insert basecode(cat,code,descript,descript1) select 'interest', 'MU', '�����', 'Museum';
insert basecode(cat,code,descript,descript1) select 'interest', 'SP', '�˶�', 'Sports';
insert basecode(cat,code,descript,descript1) select 'interest', 'DI', '��ʳ', 'Fine Dining';


// --------------------------------------------------------------------------
//  basecode : blkcls  -- ���������
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='blkcls')
	delete basecode_cat where cat='blkcls';
insert basecode_cat select 'blkcls', '���������', 'blkcls', 1;
delete basecode where cat='blkcls';
insert basecode(cat,code,descript,descript1) select 'blkcls', 'A', '���ʿ���', '���ʿ���_ENG';
insert basecode(cat,code,descript,descript1) select 'blkcls', 'B', '�����ʿ���', '�����ʿ���_ENG';
insert basecode(cat,code,descript,descript1) select 'blkcls', 'C', 'ͨ����', 'ͨ����_ENG';


// --------------------------------------------------------------------------
//  basecode : language  -- ����
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='language')
	delete basecode_cat where cat='language';
insert basecode_cat select 'language', '����', 'language', 1;
delete basecode where cat='language';
insert basecode(cat,code,descript,descript1) select 'language', 'C', '����', 'Chinese';
insert basecode(cat,code,descript,descript1) select 'language', 'E', 'Ӣ��', 'English';
insert basecode(cat,code,descript,descript1) select 'language', 'J', '����', 'Japanese';
insert basecode(cat,code,descript,descript1) select 'language', 'G', '����', 'German';
insert basecode(cat,code,descript,descript1) select 'language', 'K', '����', 'Korean';


// ------------------------------------------------------------------------------
//	guest title : ��ν
// ------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "title")
   drop table title;
create table title
(
	code			char(3)						not null,
	descript    char(20)						not null,
	descript1   varchar(30)	default ''	not null,
	grp			varchar(16)	default ''	not null,
	sequence		int		default 0		not null,
)
exec sp_primarykey title,code
create unique index index1 on title(code);
insert title(code,descript,descript1,grp) select 'RAC','���м�','Rack','IND'
insert title(code,descript,descript1,grp) select 'PAK','���ۿ���','Package','IND'
;

// --------------------------------------------------------------------------
//  basecode : guest_grade  -- �ͻ����õȼ�
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='guest_grade')
	delete basecode_cat where cat='guest_grade';
insert basecode_cat select 'guest_grade', '�ͻ����õȼ�', 'guest grade', 1;
delete basecode where cat='guest_grade';
insert basecode(cat,code,descript,descript1) select 'guest_grade', 'A', '���õȼ�1', '���õȼ�1_ENG';
insert basecode(cat,code,descript,descript1) select 'guest_grade', 'B', '���õȼ�2', '���õȼ�2_ENG';
insert basecode(cat,code,descript,descript1) select 'guest_grade', 'C', '���õȼ�3', '���õȼ�3_ENG';
insert basecode(cat,code,descript,descript1) select 'guest_grade', 'D', '���õȼ�4', '���õȼ�4_ENG';


// --------------------------------------------------------------------------
//  basecode : latency  -- Ǳ�ڿͻ����
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='latency')
	delete basecode_cat where cat='latency';
insert basecode_cat select 'latency', 'Ǳ�ڿͻ����', 'latency', 1;
delete basecode where cat='latency';
insert basecode(cat,code,descript,descript1,sys) select 'latency', '0', '��Ǳ�ڿͻ�', '��Ǳ�ڿͻ�_ENG','T';
insert basecode(cat,code,descript,descript1) select 'latency', 'A', 'Ǳ�ڿͻ�1', 'Ǳ�ڿͻ�1';
insert basecode(cat,code,descript,descript1) select 'latency', 'B', 'Ǳ�ڿͻ�2', 'Ǳ�ڿͻ�2';
insert basecode(cat,code,descript,descript1) select 'latency', 'C', 'Ǳ�ڿͻ�3', 'Ǳ�ڿͻ�3';
insert basecode(cat,code,descript,descript1) select 'latency', 'D', 'Ǳ�ڿͻ�4', 'Ǳ�ڿͻ�4';


// --------------------------------------------------------------------------
//  basecode : religion  -- �ڽ�
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='religion')
	delete basecode_cat where cat='religion';
insert basecode_cat select 'religion', '�ڽ�', 'religion', 1;
delete basecode where cat='religion';
insert basecode(cat,code,descript,descript1) select 'religion', '1', '������', '������_ENG';
insert basecode(cat,code,descript,descript1) select 'religion', '2', '���', '���_ENG';
insert basecode(cat,code,descript,descript1) select 'religion', '3', '��˹����', '��˹����_ENG';


// -------------------------------------------------------------------------------------
//	��ʷ���� -- �������˺͵�λ
// -------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "guest")
	drop table guest;
create table  guest
(
	no    		char(7)		 						not null,		// ������:�����Զ����� 
	sta			char(1)			default 'I' 	not null,		// ״̬- I(n), O(ff), S(top), X(cancel)
	sno         varchar(15)		default ''		not null,   	// �ͻ��� ��λ�Զ��� 
	cno         varchar(20)		default ''		not null,   	// ��ͬ���� 

	hotelid		varchar(20)		default ''		not null,   	// Hotel ID.
	central		char(1)			default 'F'		not null,
	censeq		varchar(30)		default ''		not null,   	// Karis Seq.

	name		   varchar(50)	 						not null,	 	// ����: ���� 
	fname       varchar(30)		default ''		not null, 		// Ӣ���� 
	lname			varchar(30)		default '' 		not null,		// Ӣ���� 
	name2		   varchar(50)		default '' 		not null,		// �������� 
	name3		   varchar(50)		default '' 		not null,		// �������� 
	name4		   varchar(255)	default '' 		not null,		// �������� 
	class			char(1)			default ''		not null,		// ���: 'F'=���� G=���� C=��˾��A=�����磻S=�������� --> �̶����룻 
	type			char(1)			default 'N'		not null,		// ���� -- N=��ͨ/B=������/C=�ָ�/R=���� 
	grade			char(1)			default ''		not null,		// ���õȼ�
	latency		char(1)			default '0'		not null,		// Ǳ�ڿͻ� 0 - ��Ǳ�ڿͻ���������ʾ���

	class1		char(3)			default '0'		not null, 		// �������	0=��ʾû�ж��壻
	class2		char(3)			default '0'		not null,
	class3		char(3)			default '0'		not null,
	class4		char(3)			default '0'		not null,
	src			char(3)			default ''		not null,		// ������Դ
	market		char(3)			default ''		not null,		// �г�����
	vip			char(3)			default '0'		not null,  		// vip 
	keep			char(1) 			default 'F'  	not null,  		// ���� 
	belong		varchar(15) 	default ''  	not null,  		// �������� -- ���������Ҫ�����ı��͵���������

	sex			char(1)			default '1'		not null,      // �Ա�:M,F 
	lang			char(1)			default 'C'		not null,		// ���� 
	title			char(3)			default ''		not null,		// �ƺ� 
	salutation	varchar(60)		default ''		not null,		// �ƺ� 

	birth       datetime								null,         	// ���� 		
	race			char(2)			default ''		not null, 		// ����
	religion		char(2)			default ''		not null, 		// �ڽ�
	occupation	char(2)			default ''		not null,		// ְҵ 
	nation		char(3)			default ''		not null,	  // ���� 

   idcls       char(3)     	default ''		not null,     	// ����֤����� 
	ident		   char(20)	   	default ''		not null,     	// ����֤������ 
	idend			datetime								null,		   	// ֤����Ч��			-- New
	cusno			char(7)			default ''		not null,		// ��λ�� 
	unit        varchar(60)		default ''		not null,		// ��λ 

	cardcode		varchar(10)		default ''		not null,		// ���ÿ���
	cardno		varchar(20)		default ''		not null,		// ���ÿ���
	cardlevel	varchar(3)		default ''		not null,		// ����

	country		char(3)			default ''		not null,	   // ���� 
	state			char(3)			default ''		not null,	   // ���� 
	town			varchar(40)		default ''		not null,		// ����
	city  		char(6)			default ''		not null,      // ����
	street	   varchar(100)		default ''		not null,		// סַ 
	zip			varchar(6)		default ''		not null,		// �������� 
	mobile		varchar(20)		default ''		not null,		// �ֻ� 
	phone			varchar(20)		default ''		not null,		// �绰 
	fax			varchar(20)		default ''		not null,		// ���� 
	wetsite		varchar(60)		default ''		not null,		// ��ַ 
	email			varchar(60)		default ''		not null,		// ���� 

	country1		char(3)			default ''		not null,	   // ���� 
	state1		char(3)			default ''		not null,	   // ���� 
	town1			varchar(40)		default ''		not null,		// ����
	city1  		char(6)			default ''		not null,      // ����
	street1	   varchar(100)		default ''		not null,		// סַ 
	zip1			varchar(6)		default ''		not null,		// �������� 
	mobile1		varchar(20)		default ''		not null,		// �ֻ� 
	phone1		varchar(20)		default ''		not null,		// �绰 
	fax1			varchar(20)		default ''		not null,		// ���� 
	email1		varchar(60)		default ''		not null,		// ���� 

	visaid		char(3)			default ''		null,			// ǩ֤��� 
	visaend		datetime								null,		   // ǩ֤��Ч�� 
	visano		varchar(20)							null,  		// ǩ֤���� 
	visaunit		char(4)								null,    	// ǩ֤���� 
   rjplace     char(3)     						null,       // �뾳�ڰ� 
	rjdate		datetime								null,		   // �뾳���� 

   srqs        varchar(30)		default ''		not null,   // ����Ҫ�� 
	amenities  	varchar(30)		default ''		not null,	// ���䲼��
   feature		varchar(30)		default ''		not null,   // ����ϲ��1 
	rmpref		varchar(20)		default ''		not null,   // ����ϲ��2 
   interest		varchar(30)		default ''		not null,   // ��Ȥ���� 

	lawman		varchar(16)		default ''		null,			// ����������
	regno			varchar(20)		default ''		null,			// ��ҵ�ǼǺ�
	bank			varchar(50)		default ''		null,			// ��������
	bankno		varchar(20)		default ''		null,			// �����ʺ�
	taxno			varchar(20)		default ''		null,			// ˰��
   liason      varchar(30)   	default ''		not null,   // ��ϵ��
   liason1     varchar(30)   	default ''		null,     	// ��ϵ��ʽ
	extrainf		varchar(30)	 	default '' 		not null, 	// for gaoliang  
   refer1     	varchar(250) 	default ''		not null,   // �ͷ�ϲ��
   refer2     	varchar(250) 	default ''		not null,   // ����ϲ��
   refer3     	varchar(250) 	default ''		not null,   // ����ϲ�� 
   comment    	varchar(100) 	default ''		not null,   // ˵��
   remark      text 									null,			// ��ע 
	override		char(1)     	default 'F'		not null,	// ���Գ���� 

   arr         datetime      						null,  		// ��Ч����
   dep         datetime      						null,			// ��ֹ����

	code1			char(10)			default ''		not null, 	// ������ 
	code2			char(10)			default ''		not null, 	// ������ 
	code3			char(10)			default ''		not null, 	// ���� 
	code4			char(10)			default ''		not null, 	// ���� 
	code5			char(10)			default ''		not null, 	// ���� 

	iata			varchar(30)		default ''		not null, 	// ������
	flag			varchar(50)		default ''		not null, 

   saleid      char(12)      	default ''		not null,	// ����Ա 

	araccnt1		char(10)     	default ''		not null,	// Ӧ���ʺ� 
	araccnt2		char(10)     	default ''		not null,	// Ӧ���ʺ� 
	master		char(7)     	default ''		not null,	// ���ʺ� 

	fv_date		datetime								null,			// �״ε��� 
	fv_room		char(5)			default ''		not null,
	fv_rate		money				default 0		not null,
	lv_date		datetime								null,			// �ϴε��� 
	lv_room		char(5)			default ''		not null,
	lv_rate		money				default 0		not null,

   i_times     int 				default 0 		not null,   // ס����� 
   x_times     int 				default 0 		not null,   // ȡ��Ԥ������ 
   n_times     int 				default 0 		not null,   // Ӧ��δ������ 
   l_times     int 				default 0 		not null,   // �������� 
   i_days      int 				default 0 		not null,   // ס������ 

   fb_times1    int 				default 0 		not null,   // �������� 
   en_times2    int 				default 0 		not null,   // ���ִ��� 

   rm          money 			default 0 		not null, 	// ��������
   fb          money 			default 0 		not null, 	// ��������
   en          money 			default 0 		not null, 	// ��������
   mt          money 			default 0 		not null, 	// ��������
   ot          money 			default 0 		not null, 	// ��������
   tl          money 			default 0 		not null, 	// ������  

-- Ԥ���ֶ�
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_dt3		datetime			null,
	exp_dt4		datetime			null,
	exp_dt5		datetime			null,
	exp_dt6		datetime			null,
	exp_s1		varchar(10)		null,
	exp_s2		varchar(10)		null,
	exp_s3		varchar(10)		null,
	exp_s4		varchar(30)		null,
	exp_s5		varchar(30)		null,
	exp_s6		varchar(50)		null,

   crtby       char(10)								not null,	// ���� 
	crttime     datetime 		default getdate()	not null,
   cby         char(10)								not null,	// �޸� 
	changed     datetime 		default getdate()	not null,
	logmark     int 				default 0 		not null
)
exec sp_primarykey guest,no
create unique index index1 on guest(no)
create index index2 on guest(name)
create index name2 on guest(name2)
create index name3 on guest(name3)
create index index3 on guest(street)
create index index4 on guest(ident)
create index index5 on guest(i_times)
create index index6 on guest(i_days)
create index index7 on guest(tl)
create index index8 on guest(rm)
create index index9 on guest(fb)
create index index10 on guest(en)
create index index11 on guest(ot)
create index index17 on guest(sno)
create index index18 on guest(changed)
;

// -------------------------------------------------------------------------------------
//	��ʷ������־
// -------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "guest_log")
	drop table guest_log;
create table  guest_log
(
	no    		char(7)		 						not null,		// ������:�����Զ����� 
	sta			char(1)			default 'I' 	not null,		// ״̬- I(n), O(ff), S(top), X(cancel)
	sno         varchar(15)		default ''		not null,   	// �ͻ��� ��λ�Զ��� 
	cno         varchar(20)		default ''		not null,   	// ��ͬ���� 

	hotelid		varchar(20)		default ''		not null,   	// Hotel ID.
	central		char(1)			default 'F'		not null,
	censeq		varchar(30)		default ''		not null,   	// Karis Seq.

	name		   varchar(50)	 						not null,	 	// ����: ���� 
	fname       varchar(30)		default ''		not null, 		// Ӣ���� 
	lname			varchar(30)		default '' 		not null,		// Ӣ���� 
	name2		   varchar(50)		default '' 		not null,		// �������� 
	name3		   varchar(50)		default '' 		not null,		// �������� 
	name4		   varchar(255)	default '' 		not null,		// �������� 
	class			char(1)			default ''		not null,		// ���: 'F'=���� G=���� C=��˾��A=�����磻S=�������� --> �̶����룻 
	type			char(1)			default 'N'		not null,		// ���� -- N=��ͨ/B=������/C=�ָ�/R=���� 
	grade			char(1)			default ''		not null,		// ���õȼ�
	latency		char(1)			default '0'		not null,		// Ǳ�ڿͻ� 0 - ��Ǳ�ڿͻ���������ʾ���

	class1		char(3)			default '0'		not null, 		// �������	0=��ʾû�ж��壻
	class2		char(3)			default '0'		not null,
	class3		char(3)			default '0'		not null,
	class4		char(3)			default '0'		not null,
	src			char(3)			default ''		not null,		// ������Դ
	market		char(3)			default ''		not null,		// �г�����
	vip			char(3)			default '0'		not null,  		// vip 
	keep			char(1) 			default 'F'  	not null,  		// ���� 
	belong		varchar(15) 	default ''  	not null,  		// �������� -- ���������Ҫ�����ı��͵���������

	sex			char(1)			default '1'		not null,      // �Ա�:M,F 
	lang			char(1)			default 'C'		not null,		// ���� 
	title			char(3)			default ''		not null,		// �ƺ� 
	salutation	varchar(60)		default ''		not null,		// �ƺ� 

	birth       datetime								null,         	// ���� 		
	race			char(2)			default ''		not null, 		// ����
	religion		char(2)			default ''		not null, 		// �ڽ�
	occupation	char(2)			default ''		not null,		// ְҵ 
	nation		char(3)			default ''		not null,	  // ���� 

   idcls       char(3)     	default ''		not null,     	// ����֤����� 
	ident		   char(20)	   	default ''		not null,     	// ����֤������ 
	idend			datetime								null,		   	// ֤����Ч��			-- New
	cusno			char(7)			default ''		not null,		// ��λ�� 
	unit        varchar(60)		default ''		not null,		// ��λ 

	cardcode		varchar(10)		default ''		not null,		// ���ÿ���
	cardno		varchar(20)		default ''		not null,		// ���ÿ���
	cardlevel	varchar(3)		default ''		not null,		// ����

	country		char(3)			default ''		not null,	   // ���� 
	state			char(3)			default ''		not null,	   // ���� 
	town			varchar(40)		default ''		not null,		// ����
	city  		char(6)			default ''		not null,      // ����
	street	   varchar(100)		default ''		not null,		// סַ 
	zip			varchar(6)		default ''		not null,		// �������� 
	mobile		varchar(20)		default ''		not null,		// �ֻ� 
	phone			varchar(20)		default ''		not null,		// �绰 
	fax			varchar(20)		default ''		not null,		// ���� 
	wetsite		varchar(60)		default ''		not null,		// ��ַ 
	email			varchar(60)		default ''		not null,		// ���� 

	country1		char(3)			default ''		not null,	   // ���� 
	state1		char(3)			default ''		not null,	   // ���� 
	town1			varchar(40)		default ''		not null,		// ����
	city1  		char(6)			default ''		not null,      // ����
	street1	   varchar(100)		default ''		not null,		// סַ 
	zip1			varchar(6)		default ''		not null,		// �������� 
	mobile1		varchar(20)		default ''		not null,		// �ֻ� 
	phone1		varchar(20)		default ''		not null,		// �绰 
	fax1			varchar(20)		default ''		not null,		// ���� 
	email1		varchar(60)		default ''		not null,		// ���� 

	visaid		char(3)			default ''		null,			// ǩ֤��� 
	visaend		datetime								null,		   // ǩ֤��Ч�� 
	visano		varchar(20)							null,  		// ǩ֤���� 
	visaunit		char(4)								null,    	// ǩ֤���� 
   rjplace     char(3)     						null,       // �뾳�ڰ� 
	rjdate		datetime								null,		   // �뾳���� 

   srqs        varchar(30)		default ''		not null,   // ����Ҫ�� 
	amenities  	varchar(30)		default ''		not null,	// ���䲼��
   feature		varchar(30)		default ''		not null,   // ����ϲ��1 
	rmpref		varchar(20)		default ''		not null,   // ����ϲ��2 
   interest		varchar(30)		default ''		not null,   // ��Ȥ���� 

	lawman		varchar(16)		default ''		null,			// ����������
	regno			varchar(20)		default ''		null,			// ��ҵ�ǼǺ�
	bank			varchar(50)		default ''		null,			// ��������
	bankno		varchar(20)		default ''		null,			// �����ʺ�
	taxno			varchar(20)		default ''		null,			// ˰��
   liason      varchar(30)   	default ''		not null,   // ��ϵ��
   liason1     varchar(30)   	default ''		null,     	// ��ϵ��ʽ
	extrainf		varchar(30)	 	default '' 		not null, 	// for gaoliang  
   refer1     	varchar(250) 	default ''		not null,   // �ͷ�ϲ��
   refer2     	varchar(250) 	default ''		not null,   // ����ϲ��
   refer3     	varchar(250) 	default ''		not null,   // ����ϲ�� 
   comment    	varchar(100) 	default ''		not null,   // ˵��
   remark      text 									null,			// ��ע 
	override		char(1)     	default 'F'		not null,	// ���Գ���� 

   arr         datetime      						null,  		// ��Ч����
   dep         datetime      						null,			// ��ֹ����

	code1			char(10)			default ''		not null, 	// ������ 
	code2			char(10)			default ''		not null, 	// ������ 
	code3			char(10)			default ''		not null, 	// ���� 
	code4			char(10)			default ''		not null, 	// ���� 
	code5			char(10)			default ''		not null, 	// ���� 

	iata			varchar(30)		default ''		not null, 	// ������
	flag			varchar(50)		default ''		not null, 

   saleid      char(12)      	default ''		not null,	// ����Ա 

	araccnt1		char(10)     	default ''		not null,	// Ӧ���ʺ� 
	araccnt2		char(10)     	default ''		not null,	// Ӧ���ʺ� 
	master		char(7)     	default ''		not null,	// ���ʺ� 

	fv_date		datetime								null,			// �״ε��� 
	fv_room		char(5)			default ''		not null,
	fv_rate		money				default 0		not null,
	lv_date		datetime								null,			// �ϴε��� 
	lv_room		char(5)			default ''		not null,
	lv_rate		money				default 0		not null,

   i_times     int 				default 0 		not null,   // ס����� 
   x_times     int 				default 0 		not null,   // ȡ��Ԥ������ 
   n_times     int 				default 0 		not null,   // Ӧ��δ������ 
   l_times     int 				default 0 		not null,   // �������� 
   i_days      int 				default 0 		not null,   // ס������ 

   fb_times1    int 				default 0 		not null,   // �������� 
   en_times2    int 				default 0 		not null,   // ���ִ��� 

   rm          money 			default 0 		not null, 	// ��������
   fb          money 			default 0 		not null, 	// ��������
   en          money 			default 0 		not null, 	// ��������
   mt          money 			default 0 		not null, 	// ��������
   ot          money 			default 0 		not null, 	// ��������
   tl          money 			default 0 		not null, 	// ������  

-- Ԥ���ֶ�
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_dt3		datetime			null,
	exp_dt4		datetime			null,
	exp_dt5		datetime			null,
	exp_dt6		datetime			null,
	exp_s1		varchar(10)		null,
	exp_s2		varchar(10)		null,
	exp_s3		varchar(10)		null,
	exp_s4		varchar(30)		null,
	exp_s5		varchar(30)		null,
	exp_s6		varchar(50)		null,

   crtby       char(10)								not null,	// ���� 
	crttime     datetime 		default getdate()	not null,
   cby         char(10)								not null,	// �޸� 
	changed     datetime 		default getdate()	not null,
	logmark     int 				default 0 		not null
)
exec sp_primarykey guest_log,no,logmark
create unique index index1 on guest_log(no, logmark)
;


// -------------------------------------------------------------------------------------
//		��ɾ���Ŀ�ʷ����
// -------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "guest_del")
	drop table guest_del;
create table  guest_del
(
	no    		char(7)		 						not null,		// ������:�����Զ����� 
	sta			char(1)			default 'I' 	not null,		// ״̬- I(n), O(ff), S(top), X(cancel)
	sno         varchar(15)		default ''		not null,   	// �ͻ��� ��λ�Զ��� 
	cno         varchar(20)		default ''		not null,   	// ��ͬ���� 

	hotelid		varchar(20)		default ''		not null,   	// Hotel ID.
	central		char(1)			default 'F'		not null,
	censeq		varchar(30)		default ''		not null,   	// Karis Seq.

	name		   varchar(50)	 						not null,	 	// ����: ���� 
	fname       varchar(30)		default ''		not null, 		// Ӣ���� 
	lname			varchar(30)		default '' 		not null,		// Ӣ���� 
	name2		   varchar(50)		default '' 		not null,		// �������� 
	name3		   varchar(50)		default '' 		not null,		// �������� 
	name4		   varchar(255)	default '' 		not null,		// �������� 
	class			char(1)			default ''		not null,		// ���: 'F'=���� G=���� C=��˾��A=�����磻S=�������� --> �̶����룻 
	type			char(1)			default 'N'		not null,		// ���� -- N=��ͨ/B=������/C=�ָ�/R=���� 
	grade			char(1)			default ''		not null,		// ���õȼ�
	latency		char(1)			default '0'		not null,		// Ǳ�ڿͻ� 0 - ��Ǳ�ڿͻ���������ʾ���

	class1		char(3)			default '0'		not null, 		// �������	0=��ʾû�ж��壻
	class2		char(3)			default '0'		not null,
	class3		char(3)			default '0'		not null,
	class4		char(3)			default '0'		not null,
	src			char(3)			default ''		not null,		// ������Դ
	market		char(3)			default ''		not null,		// �г�����
	vip			char(3)			default '0'		not null,  		// vip 
	keep			char(1) 			default 'F'  	not null,  		// ���� 
	belong		varchar(15) 	default ''  	not null,  		// �������� -- ���������Ҫ�����ı��͵���������

	sex			char(1)			default '1'		not null,      // �Ա�:M,F 
	lang			char(1)			default 'C'		not null,		// ���� 
	title			char(3)			default ''		not null,		// �ƺ� 
	salutation	varchar(60)		default ''		not null,		// �ƺ� 

	birth       datetime								null,         	// ���� 		
	race			char(2)			default ''		not null, 		// ����
	religion		char(2)			default ''		not null, 		// �ڽ�
	occupation	char(2)			default ''		not null,		// ְҵ 
	nation		char(3)			default ''		not null,	  // ���� 

   idcls       char(3)     	default ''		not null,     	// ����֤����� 
	ident		   char(20)	   	default ''		not null,     	// ����֤������ 
	idend			datetime								null,		   	// ֤����Ч��			-- New
	cusno			char(7)			default ''		not null,		// ��λ�� 
	unit        varchar(60)		default ''		not null,		// ��λ 

	cardcode		varchar(10)		default ''		not null,		// ���ÿ���
	cardno		varchar(20)		default ''		not null,		// ���ÿ���
	cardlevel	varchar(3)		default ''		not null,		// ����

	country		char(3)			default ''		not null,	   // ���� 
	state			char(3)			default ''		not null,	   // ���� 
	town			varchar(40)		default ''		not null,		// ����
	city  		char(6)			default ''		not null,      // ����
	street	   varchar(100)		default ''		not null,		// סַ 
	zip			varchar(6)		default ''		not null,		// �������� 
	mobile		varchar(20)		default ''		not null,		// �ֻ� 
	phone			varchar(20)		default ''		not null,		// �绰 
	fax			varchar(20)		default ''		not null,		// ���� 
	wetsite		varchar(60)		default ''		not null,		// ��ַ 
	email			varchar(60)		default ''		not null,		// ���� 

	country1		char(3)			default ''		not null,	   // ���� 
	state1		char(3)			default ''		not null,	   // ���� 
	town1			varchar(40)		default ''		not null,		// ����
	city1  		char(6)			default ''		not null,      // ����
	street1	   varchar(100)		default ''		not null,		// סַ 
	zip1			varchar(6)		default ''		not null,		// �������� 
	mobile1		varchar(20)		default ''		not null,		// �ֻ� 
	phone1		varchar(20)		default ''		not null,		// �绰 
	fax1			varchar(20)		default ''		not null,		// ���� 
	email1		varchar(60)		default ''		not null,		// ���� 

	visaid		char(3)			default ''		null,			// ǩ֤��� 
	visaend		datetime								null,		   // ǩ֤��Ч�� 
	visano		varchar(20)							null,  		// ǩ֤���� 
	visaunit		char(4)								null,    	// ǩ֤���� 
   rjplace     char(3)     						null,       // �뾳�ڰ� 
	rjdate		datetime								null,		   // �뾳���� 

   srqs        varchar(30)		default ''		not null,   // ����Ҫ�� 
	amenities  	varchar(30)		default ''		not null,	// ���䲼��
   feature		varchar(30)		default ''		not null,   // ����ϲ��1 
	rmpref		varchar(20)		default ''		not null,   // ����ϲ��2 
   interest		varchar(30)		default ''		not null,   // ��Ȥ���� 

	lawman		varchar(16)		default ''		null,			// ����������
	regno			varchar(20)		default ''		null,			// ��ҵ�ǼǺ�
	bank			varchar(50)		default ''		null,			// ��������
	bankno		varchar(20)		default ''		null,			// �����ʺ�
	taxno			varchar(20)		default ''		null,			// ˰��
   liason      varchar(30)   	default ''		not null,   // ��ϵ��
   liason1     varchar(30)   	default ''		null,     	// ��ϵ��ʽ
	extrainf		varchar(30)	 	default '' 		not null, 	// for gaoliang  
   refer1     	varchar(250) 	default ''		not null,   // �ͷ�ϲ��
   refer2     	varchar(250) 	default ''		not null,   // ����ϲ��
   refer3     	varchar(250) 	default ''		not null,   // ����ϲ�� 
   comment    	varchar(100) 	default ''		not null,   // ˵��
   remark      text 									null,			// ��ע 
	override		char(1)     	default 'F'		not null,	// ���Գ���� 

   arr         datetime      						null,  		// ��Ч����
   dep         datetime      						null,			// ��ֹ����

	code1			char(10)			default ''		not null, 	// ������ 
	code2			char(10)			default ''		not null, 	// ������ 
	code3			char(10)			default ''		not null, 	// ���� 
	code4			char(10)			default ''		not null, 	// ���� 
	code5			char(10)			default ''		not null, 	// ���� 

	iata			varchar(30)		default ''		not null, 	// ������
	flag			varchar(50)		default ''		not null, 

   saleid      char(12)      	default ''		not null,	// ����Ա 

	araccnt1		char(10)     	default ''		not null,	// Ӧ���ʺ� 
	araccnt2		char(10)     	default ''		not null,	// Ӧ���ʺ� 
	master		char(7)     	default ''		not null,	// ���ʺ� 

	fv_date		datetime								null,			// �״ε��� 
	fv_room		char(5)			default ''		not null,
	fv_rate		money				default 0		not null,
	lv_date		datetime								null,			// �ϴε��� 
	lv_room		char(5)			default ''		not null,
	lv_rate		money				default 0		not null,

   i_times     int 				default 0 		not null,   // ס����� 
   x_times     int 				default 0 		not null,   // ȡ��Ԥ������ 
   n_times     int 				default 0 		not null,   // Ӧ��δ������ 
   l_times     int 				default 0 		not null,   // �������� 
   i_days      int 				default 0 		not null,   // ס������ 

   fb_times1    int 				default 0 		not null,   // �������� 
   en_times2    int 				default 0 		not null,   // ���ִ��� 

   rm          money 			default 0 		not null, 	// ��������
   fb          money 			default 0 		not null, 	// ��������
   en          money 			default 0 		not null, 	// ��������
   mt          money 			default 0 		not null, 	// ��������
   ot          money 			default 0 		not null, 	// ��������
   tl          money 			default 0 		not null, 	// ������  

-- Ԥ���ֶ�
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_dt3		datetime			null,
	exp_dt4		datetime			null,
	exp_dt5		datetime			null,
	exp_dt6		datetime			null,
	exp_s1		varchar(10)		null,
	exp_s2		varchar(10)		null,
	exp_s3		varchar(10)		null,
	exp_s4		varchar(30)		null,
	exp_s5		varchar(30)		null,
	exp_s6		varchar(50)		null,

   crtby       char(10)								not null,	// ���� 
	crttime     datetime 		default getdate()	not null,
   cby         char(10)								not null,	// �޸� 
	changed     datetime 		default getdate()	not null,
	logmark     int 				default 0 		not null
)
exec sp_primarykey guest_del,no
create unique index index1 on guest_del(no)
create index index2 on guest_del(name)
create index index17 on guest_del(sno)
;


// -------------------------------------------------------------------------------------
//	��������Ϣ -- ������Ϣ���� guest ����
// -------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "blkmst")
	drop table blkmst;
create table  blkmst
(
	no    		char(7)		 						not null,		// ������
	class			char(1)			default '' 		not null,		// ���������
	remark		varchar(255)	default ''		not null
)
exec sp_primarykey blkmst,no
create unique index index1 on blkmst(no)
;


// --------------------------------------------------------------------------
//  basecode : incomekey  -- �������
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='incomekey')
	delete basecode_cat where cat='incomekey';
insert basecode_cat select 'incomekey', '�������', 'incomekey', 10;
delete basecode where cat='incomekey';
insert basecode(cat,code,descript,descript1,sys) select 'incomekey', 'I_GUESTS', '��ס����', 'i_guests','T';
insert basecode(cat,code,descript,descript1,sys) select 'incomekey', 'I_TIMES', '��ס����', 'i_times','T';
insert basecode(cat,code,descript,descript1,sys) select 'incomekey', 'N_TIMES', 'noshow ����', 'noshow times','T';
insert basecode(cat,code,descript,descript1,sys) select 'incomekey', 'X_TIMES', 'ȡ������', 'cancel times','T';



// -------------------------------------------------------------------------------------
//		�ͻ�������Ϣ
//
//		���Ѽ�¼��ϵ: guest->master->master_income
//
// -------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "master_income")
	drop table master_income;
create table  master_income
(
	accnt				char(10)							not null,
	master			char(10)			default''	not null,
	pccode			char(5)			default ''	not null,
	item				varchar(10)		default ''	not null,
	amount1			money		default 0			not null,
	amount2			money		default 0			not null
)
exec sp_primarykey master_income,accnt,pccode,item
create unique index index1 on master_income(accnt,pccode,item)
;


// -------------------------------------------------------------------------------------
//	��ʷ����������Ϣ
// -------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "guest_extra")
	drop table guest_extra;
create table  guest_extra
(
	no    		char(7)		 						not null,
	item			char(10)								not null,	// ��Ϣ�ؼ��� ratecode,posmode
	value       varchar(30)							not null		// ȡֵ
)
exec sp_primarykey guest_extra,no,item,value
create unique index index1 on guest_extra(no,item,value)
;



// -------------------------------------------------------------------------------------
//	��ʷ���� ��� -- �������˺͵�λ
//	
//		from x50204, delete the table 
// -------------------------------------------------------------------------------------
//if exists(select * from sysobjects where name = "hguest")
//	drop table hguest;
//create table  hguest
//(
//	no    		char(7)		 						not null,		// ������:�����Զ����� 
//	sta			char(1)			default 'I' 	not null,		// ״̬- I(n), O(ff), S(top), X(cancel)
//	sno         varchar(15)		default ''		not null,   	// �ͻ��� ��λ�Զ��� 
//	name		   varchar(50)	 						not null,	 	// ����: ���� 
//	fname       varchar(30)		default ''		not null, 		// Ӣ���� 
//	lname			varchar(30)		default '' 		not null,		// Ӣ���� 
//	name2		   varchar(50)		default '' 		not null,		// �������� 
//	name3		   varchar(50)		default '' 		not null,		// �������� 
//	name4		   varchar(255)	default '' 		not null,		// �������� 
//
//	class			char(1)			default ''		not null,		// ���: 'F'=���� G=���� C=��˾��A=�����磻S=�������� --> �̶����룻 
//	type			char(1)			default 'N'		not null,		// ���� -- N=��ͨ/B=������/C=�ָ�/R=���� 
//
//	class1		varchar(3)			default '0'		not null, 		// �������	0=��ʾû�ж��壻
//	class2		varchar(3)			default '0'		not null,
//	class3		varchar(3)			default '0'		not null,
//	class4		varchar(3)			default '0'		not null,
//	vip			char(3)				default '0'		not null,  		// vip 
//
//	sex			char(1)				default '1'		not null,      // �Ա�:M,F 
//	birth       datetime								null,         	// ����
//	nation		varchar(3)			default ''		not null,	  // ���� 
//
//	country		char(3)			default ''		not null,	   // ���� 
//	state			char(3)			default ''		not null,
//	town			varchar(40)		default ''		not null,		// ����
//	city  		varchar(6)			default ''		not null,      // ���� ���� 
//	street	   varchar(100)			default ''		not null,		// סַ 
//
//   idcls       varchar(3)     	default ''		not null,     	// ����֤����� 
//	ident		   varchar(20)	   	default ''		not null,     	// ����֤������ 
//	cusno			varchar(7)			default ''		not null,		// ��λ�� 
//	unit        varchar(60)			default ''		not null,		// ��λ 
//   liason      varchar(30)   		default ''		not null,   // ��ϵ��
//   saleid      varchar(12)      	default ''		not null		// ����Ա 
//)
//exec sp_primarykey hguest,no
//create unique index index1 on hguest(no)
//create index index2 on hguest(name)
//create index index3 on hguest(street)
//create index index4 on hguest(ident)
//create index index5 on hguest(sno)
//create index index6 on hguest(class)
//create index index7 on hguest(country)
//create index index8 on hguest(saleid)
//create index index9 on hguest(unit)
//create index index11 on hguest(class1)
//create index index12 on hguest(class2)
//;

// -----------------------------------------------------------------------
// guest_xfttl  
//
//	��������������ַ�ʽ�� 
// 
//		1 ÿ�������ö���У�������ʾ��ͬ����Ŀ - �ô���ͳ������ʾ�� 
//		2 ÿ����һ�У����õ���Ŀ���ò�ͬ���� - �ô��ǿ�����������ͳ����Ŀ
// -----------------------------------------------------------------------
if exists(select * from sysobjects where type ="U" and name = "guest_xfttl")
   drop table guest_xfttl;
create table guest_xfttl
(
	hotelid		varchar(20)		default '' not null,		-- �Ƶ����
	no				char(7)			default ''	not null,	-- ��������
	year			char(4)			default ''	not null,	-- ���
	tag			varchar(10)		default ''	not null,	-- ��Ŀ basecode (cat = guest_sumtag)
	ttl			money				default 0 not null,		-- �ϼ���
	m1				money				default 0 not null,
	m2				money				default 0 not null,
	m3				money				default 0 not null,
	m4				money				default 0 not null,
	m5				money				default 0 not null,
	m6				money				default 0 not null,
	m7				money				default 0 not null,
	m8				money				default 0 not null,
	m9				money				default 0 not null,
	m10			money				default 0 not null,
	m11			money				default 0 not null,
	m12			money				default 0 not null
);
exec sp_primarykey guest_xfttl, hotelid, no, year, tag
create unique index index1 on guest_xfttl(hotelid, no, year, tag)
;


// --------------------------------------------------------------------------
//  basecode : guest_sumtag  -- ��ʷ����������ͳ����Ŀ 
// --------------------------------------------------------------------------
delete basecode where cat='guest_sumtag';
delete basecode_cat where cat='guest_sumtag';
insert basecode_cat(cat,descript,descript1,len) select 'guest_sumtag', '��ʷ����������ͳ����Ŀ', 'Guest Summary Item', 10;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'guest_sumtag', 'RM', '����', 'Room','T',100;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'guest_sumtag', 'FB', '�ͷ�', 'F&b','T',200;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'guest_sumtag', 'OT', '����', 'Other','T',300;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'guest_sumtag', 'TTL', '������', 'Total','T',350;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'guest_sumtag', 'NIGHTS', '����', 'Nigths','T',400;


