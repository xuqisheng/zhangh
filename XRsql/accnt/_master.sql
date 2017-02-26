//==========================================================================
//Table : master
//
//diffrent from v5
//	modify:
//		accnt, groupno				char(7) -> char(10)
//		ratemode						--> package
//		tranlog						--> ratecode
//		src							char(1) -> char(3)
//		srqs		   				-->varchar(30)
//	delete:
//		ooroomno
//		oclass
//		class
//		archive		char(1)		default 'Y',/* ������־ */
//		pcrec		   char(7)	null,		/*  ������־�˺�  */
//		phonesta	   char(1)		null,		/* �ֻ��ȼ� */
//		vodsta	   char(1)		null,		/* �ֻ��ȼ� */
//		locksta		char(1)		default 'Y',/* �ʺſ���״̬(�綳������) */
//		ref			varchar(80)		null,		/* ��ע */
//		exp_m			money				null,
//		exp_dt		datetime			null,
//		exp_s			varchar(10)		null,
//
//	add:
//		share
//		from guest table : ���ɡ�ǩ֤������ȥ�ء�
//
//
//==========================================================================
//
//
//==========================================================================


if exists(select * from sysobjects where name = "master" and type="U")
	drop table master;
create table master
(
	accnt		   char(10)						not null,	/* �ʺ�:����(�����ɼ�˵����)  */
	haccnt		char(7)		default '' 	not null,	/* ���͵�����  */
	groupno		char(10)		default '' 	not null,	/* �����ź�  */
	type		   char(3)		default ''	not null,	/* ��������(cf. typim,block,pickup)  */
   otype       char(3)     default ''	not null,  	/* ����ǰ�ķ�������  */
	up_type		char(3)     default ''	null,  		/* ���ĸ�������������  */
	up_reason	char(3)     default ''	not null,  	/* ����ԭ��  */
	rmnum			int			default 0	not null,
	ormnum		int			default 0	not null,
	roomno		char(5)		default ''	not null,  	/* ���� */
	oroomno     char(5)     default ''	not null,  	/* ����ǰ�ķ��� */
	bdate		   datetime	   				not null,	/* ��ס�����Ӫҵ����=business date */
	sta			char(1)						not null,   /* �ʺ�״̬(��˵����˵����) */
	osta        char(1)     default ''	not null,   /* ����ǰ���ʺ�״̬ */
	ressta      char(1)     default ''	not null,   /* ����ʱ�����״̬,�����������ʲ��ָ���ԭ״̬ */
	exp_sta		char(1)		default '' 	null,			/*  ���巿�ķ���  */										---
	sta_tm		char(1)		default '' 	not null,	/* �ʺ�״̬(������) */
	rmpoststa	char(1)		default '' 	not null,	/* �����ֶ�:������ʱ�� */									---
	rmposted	   char(1)		default "F"	not null,	/* ����ס�����Ƿ�������� */
	tag0		   char(1)		default '' 	null,
	arr			datetime	   				not null,	/* ��������=arrival */
	dep			datetime	   				not null,	/* �������=departure */
   resdep      datetime    				null,       /* ����ʱ������뿪����,������������ */
	oarr        datetime    				null,
	odep        datetime    				null,

	agent			char(7)		default '' 	not null,
	cusno			char(7)		default '' 	not null,
	source		char(7)		default '' 	not null,

	class		   char(1)		default '' 	not null,	/* ���: ''-fit, g-grp, m-meet, a-armst */
	src			char(3)		default '' 	not null,	/* ��Դ */
	market		char(3)		default '' 	not null,	/* �г��� */
	restype		char(3)		default '' 	not null,	/* Ԥ����� */
	channel		char(3)		default '' 	not null,	/* ���� */
	
	share		   char(1)		default '' 	not null,	/* �Ƿ����ͬס   */
	gstno		   int			default 1 	not null,   /* ���� */
	children		int			default 0	not null,	/* С�� */
	rmreason	   char(1)		default ''	not null,	/* �������� */

	ratecode    char(10)    default '' 	not null,	/* ������  */
	packages		char(20)		default ''	not null,	/* ����  */
	fixrate	   char(1)		default 'F'	not null,	/* �̶����� */
	rmrate		money			default 0	not null,	/* ���䱨�� */
	qtrate		money			default 0	not null,	/* Э�鷿�䱨�� */
	setrate		money			default 0	not null,	/* ���Żݼ��Ż�����һ�����ʵ�ʷ��� */
	rtreason	   char(3)		default ''	not null,	/* �����Ż�����(cf.rtreason.dbf) */
	discount	   money			default 0	not null,	/* �Żݶ� */
	discount1	money			default 0	not null,	/* �Żݱ��� */
	addbed	   money			default 0 	not null,	/* �Ӵ�����  */
	addbed_rate	money			default 0 	not null,	/* �Ӵ��� */
	crib	   	money			default 0 	not null,	/* Ӥ�������� */
	crib_rate	money			default 0 	not null,	/* Ӥ�����۸� */

	paycode		char(4)		default ''	not null,	/* ���㷽ʽ */
	limit		   money			default 0 	not null,	/* �޶�(������) */
	credcode		varchar(20)	default ''	not null,	/* ���ÿ����� */
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
	applname    varchar(30)    			null,       /* ������/ί���� */
	applicant	varchar(60)	default ''	not null,	/* ��λ/ί�е�λ */
	araccnt		varchar(7)	default ''	not null,	/* AR�ʺ�(��City ledger,travel agency������) */
	phone    	varchar(16)    			null,       /* ��ϵ�绰�� */

	visaid		char(1)		default ''	null,			/* ǩ֤��� */
	visabegin	datetime						null,		   /* ǩ֤���� */
	visaend		datetime						null,		   /* ǩ֤��Ч�� */
	visano		varchar(20)					null,  		/* ǩ֤���� */
	visaunit		char(4)						null,    	/* ǩ֤���� */
   rjplace     char(3)     				null,       /* �뾳�ڰ� */
	rjdate		datetime						null,		   /* �뾳���� */
	wherefrom	char(6)		default ''	not null,	/* �ε��� */
	whereto		char(6)		default ''	not null,	/* �ε�ȥ */
	purpose		char(3)		default ''	not null,	/* ���� */

	arrdate		datetime						null,			/* ������Ϣ */
	arrinfo		varchar(30)					null,
	depdate		datetime						null,       /* �뿪��Ϣ */
	depinfo		varchar(30)					null,

	extra			char(15)		default ''	not null,	/* ������Ϣ : ����ӡ����\�绰��vod�����ܡ�
																		internet��������ˡ�walkin��exp_s������  */

	charge		money		default 0		not null,
	credit 		money		default 0		not null,
	accredit		money		default 0		not null,	/* ���� */

	lastnumb	   int		default 0		not null,	/* account��number������ */
	lastinumb	int		default 0		not null,	/* account��inumber������ */

	srqs		   varchar(30)	default ''	not null,	/* ����Ҫ�� */
	amenities  	varchar(30)	default ''	not null,	/* ���䲼�� */
	saccnt		char(10)		default ''	not null, 	/* �ͷ����� */
	pcrec			char(10)		default ''	not null, 	/* ���� */
	pcrec_pkg	char(10)		default ''	not null, 	/* Package Routing */
	resno			varchar(10)	default ''	not null, 	/* Ԥ����� */
	crsno			varchar(20)	default ''	null, 		/* ��������Ԥ����� */

	resby			char(10)		default ''	not null,	/* Ԥ��Ա��Ϣ */
	restime		datetime						null,			
	ciby			char(10)		default ''	not null,	/* �Ǽ�Ա��Ϣ */
	citime		datetime						null,
	coby			char(10)		default ''	not null,	/* ����Ա��Ϣ */
	cotime		datetime						null,
	depby			char(10)		default ''	not null,	/* �˷�Ա��Ϣ */
	deptime		datetime						null,			
	cby			char(10)						not null,	/* �����޸�����Ϣ */
	changed		datetime						not null,	

	logmark     int    default 0 			not null
)
exec sp_primarykey master,accnt
create unique index  master on master(accnt)
create index  groupno on master(groupno,accnt)
create index  index3 on master (roomno)
create index  index4 on master (sta)
create index  arr    on master (arr)
;


if exists(select * from sysobjects where name = "master_till" and type="U")
	drop table master_till;
select * into master_till from master where 1=2;
exec sp_primarykey master_till,accnt
create unique index  master_till on master_till(accnt)
create index  groupno on master_till(groupno,accnt)
create index  index3 on master_till (roomno)
create index  index4 on master_till (sta)
create index  arr    on master_till (arr)
;


if exists(select * from sysobjects where name = "master_last" and type="U")
	drop table master_last;
select * into master_last from master where 1=2;
exec sp_primarykey master_last,accnt
create unique index  master_last on master_last(accnt)
create index  groupno on master_last(groupno,accnt)
create index  index3 on master_last (roomno)
create index  index4 on master_last (sta)
create index  arr    on master_last (arr)
;


if exists(select * from sysobjects where name = "hmaster" and type="U")
	drop table hmaster;
select * into hmaster from master where 1=2;
exec sp_primarykey hmaster,accnt
create unique index  hmaster on hmaster(accnt)
create index  groupno on hmaster(groupno,accnt)
create index  index3 on hmaster (roomno)
;


if exists(select * from sysobjects where name = "master_log" and type="U")
	drop table master_log;
select * into master_log from master where 1=2;
exec sp_primarykey master_log, accnt, logmark
create unique index master_log on master_log(accnt, logmark)
;
