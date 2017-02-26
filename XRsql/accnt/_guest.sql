//==========================================================================
//	Table : guest  -- ��ʷ����
//
//		basecode:	gsttype, interest, language, 
//
//		table :
//				title, guest, guest_log, guest_del
//==========================================================================


// --------------------------------------------------------------------------
//  basecode : gsttype  -- ��ʷ���������
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='gsttype')
	delete basecode_cat where cat='gsttype';
insert basecode_cat select 'gsttype', '��ʷ�������', 'Guest Type', 3;
delete basecode where cat='gsttype';
insert basecode(cat,code,descript,descript1) select 'gsttype', '0', '��ͨ����', 'Normal Guest';
insert basecode(cat,code,descript,descript1) select 'gsttype', '1', '���', 'Frequent Guest';
insert basecode(cat,code,descript,descript1) select 'gsttype', '2', '�����', 'Vip Card Guest';



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
create unique index index1 on title(code)
;
insert title(code,descript,descript1,grp) select 'RAC','���м�','Rack','IND'
insert title(code,descript,descript1,grp) select 'PAK','���ۿ���','Package','IND'
;


// -------------------------------------------------------------------------------------
//	��ʷ����
// -------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "guest")
	drop table guest;
create table  guest
(
	no    		char(7)		 						not null,		/* ������:�����Զ����� */
	sno         varchar(15)		default ''		not null,   	/* �ͻ��� ��λ�Զ��� */

	name		   varchar(50)	 						not null,	 	/* ����: ���� */
	fname       varchar(30)		default ''		not null, 		/* Ӣ���� */
	lname			varchar(30)		default '' 		not null,		/* Ӣ���� */
	name2		   varchar(50)		default '' 		not null,		/* �������� */
	name3		   varchar(50)		default '' 		not null,		/* �������� */
	sex			char(1)			default 'M'		not null,      /* �Ա�:M,F */
	lang			char(1)			default 'C'		not null,		/* ���� */
	title			char(3)			default ''		not null,		/* �ƺ� */
	salutation	varchar(60)		default ''		not null,		/* �ƺ� */

	type			char(3)			default ''		not null,		/* ���� -- n��ͨ/b������/c�ָ�/r���� */
	class			char(3)			default ''		not null,		/* ��� */
	vip			char(1)			default '0'		not null,  		/* vip */
	keep			char(1) 			default 'F'  	not null,  		/* ���� */

	birth       datetime								null,         	/* ���� */		
	birthplace  char(6)			default ''		not null,      /* ���� ���� */
	race			char(2)			default ''		not null, 		/* ���� */
	occupation	char(2)			default ''		not null,		/* ְҵ */
	country		char(3)			default ''		not null,	  /* ���� */
	nation		char(3)			default ''		not null,	  /* ���� */

   idcls       char(3)     	default ''		not null,     	/* ����֤����� */
	ident		   char(20)	   	default ''		not null,     	/* ����֤������ */
	cusno			char(7)			default ''		not null,		/* ��λ�� */
	unit        varchar(60)		default ''		not null,		/* ��λ */
	address	   varchar(60)		default ''		not null,		/* סַ */
	address1	   varchar(60)		default ''		not null,		/* סַ */
	zip			varchar(6)		default ''		not null,		/* �������� */
	handset		varchar(20)		default ''		not null,		/* �ֻ� */
	phone			varchar(20)		default ''		not null,		/* �绰 */
	fax			varchar(20)		default ''		not null,		/* ���� */
	wetsite		varchar(30)		default ''		not null,		/* ��ַ */
	email			varchar(30)		default ''		not null,		/* ���� */
	qq				varchar(30)		default ''		not null,		/* qq, msn, icq */

	visaid		char(1)			default ''		null,			/* ǩ֤��� */
	visabegin	datetime								null,		   /* ǩ֤���� */
	visaend		datetime								null,		   /* ǩ֤��Ч�� */
	visano		varchar(20)							null,  		/* ǩ֤���� */
	visaunit		char(4)								null,    	/* ǩ֤���� */
   rjplace     char(3)     						null,       /* �뾳�ڰ� */
	rjdate		datetime								null,		   /* �뾳���� */

   srqs        varchar(30)		default ''		not null,       /* ����Ҫ�� */
   feature		varchar(30)		default ''		not null,       /* ����ϲ��1 */
	rmpref		varchar(20)		default ''		not null,       /* ����ϲ��2 */
   interest		varchar(30)		default ''		not null,       /* ��Ȥ���� */
   refer      	varchar(250) 	default ''		not null,       /* ����ϲ�� */
	extrainf		varchar(30)	 	default '' 		not null, 		 /* for gaoliang */ 
   remark      text 									null,				/* ��ע */
	override		char(1)     	default 'F'		not null,		/* ���Գ���� */

	code1			char(10)			default ''		not null, 	/* ������ */
	code2			char(3)			default ''		not null, 	/* ������ */
	code3			char(3)			default ''		not null, 	/* ���� */
	code4			char(3)			default ''		not null, 	/* ���� */
	code5			char(3)			default ''		not null, 	/* ���� */

   saleid      char(12)      	default ''		not null,	/* ����Ա */

	araccnt1		char(7)     	default ''		not null,	/* Ӧ���ʺ� */
	araccnt2		char(7)     	default ''		not null,	/* Ӧ���ʺ� */

	fv_date		datetime								null,			/* �״ε��� */
	fv_room		char(5)			default ''		not null,
	fv_rate		money				default 0		not null,
	lv_date		datetime								null,			/* �ϴε��� */
	lv_room		char(5)			default ''		not null,
	lv_rate		money				default 0		not null,

   i_times     int 				default 0 		not null,   /* ס����� */
   x_times     int 				default 0 		not null,   /* ȡ��Ԥ������ */
   n_times     int 				default 0 		not null,   /* Ӧ��δ������ */
   l_times     int 				default 0 		not null,   /* �������� */
   i_days      int 				default 0 		not null,   /* ס������ */
   tl          money 			default 0 		not null, 	/* ������  */
   rm          money 			default 0 		not null, 	/* ��������*/
   rm_b        money 			default 0 		not null, 	/* ������������*/
   rm_e        money 			default 0 		not null, 	/* ����ǽ�������*/
   fb          money 			default 0 		not null, 	/* ��������*/
   en          money 			default 0 		not null, 	/* ��������*/
   ot          money 			default 0 		not null, 	/* ��������*/

   crtby       char(10)								not null,	/* ���� */
	crttime     datetime 		default getdate()	not null,
   cby         char(10)								not null,	/* �޸� */
	changed     datetime 		default getdate()	not null,
	logmark     int 				default 0 		not null
)
exec sp_primarykey guest,no
create unique index index1 on guest(no)
create index index2 on guest(name)
create index index3 on guest(address)
create index index4 on guest(ident)
create index index5 on guest(i_times)
create index index6 on guest(i_days)
create index index7 on guest(tl)
create index index8 on guest(rm)
create index index9 on guest(fb)
create index index10 on guest(en)
create index index11 on guest(ot)
create index index17 on guest(sno)
;

// -------------------------------------------------------------------------------------
//	��ʷ������־
// -------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "guest_log")
	drop table guest_log;
select * into guest_log from guest where 1=2;
exec sp_primarykey guest_log,no,logmark
create unique index index1 on guest_log(no, logmark)
;


// -------------------------------------------------------------------------------------
//		��ɾ���Ŀ�ʷ����
// -------------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "guest_del")
	drop table guest_del;
select * into guest_del from guest where 1=2;
exec sp_primarykey guest_del,no
create unique index index1 on guest_del(no)
create index index2 on guest_del(name)
create index index17 on guest_del(sno)
;

/*
insert guest 
  SELECT no,   
         isnull(sno,''),   
         name,   
         '','','','',   
         sex,   
         'C',   
         '',   
         '',   
         inman,   
         '0',   
         vip,   
         'T',   
         birth,   
         isnull(birthplace,''),   
         race,   
         isnull(occupation,''),   
         nation,   
         nation,   
         idcls,   
         ident,   
         isnull(cusno,   ''),
         isnull(fir,   ''),
         isnull(address,''),   
         '',   
         isnull(zip,''),   
         '',   
         ename,   
         '','','','',   
         '',null,null,'','','',null,
         isnull(srqs,   ''),
         '',   
         '',   
         '',   
         isnull(ref,   ''),
         extrainf,   
         remark,   
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
         cby,   
         changed,   
         cby,   
         changed,   
         logmark  
    FROM hgstinf;


*/