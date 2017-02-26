//==========================================================================
//Table : master
//
//			����Ա������� ?
//==========================================================================

//--------------------------------------------------------------------------
//		master, master_till, master_last, master_log
//		master_middle, master_del, hmaster
//		master_remark
//--------------------------------------------------------------------------

if exists(select * from sysobjects where name = "master" and type="U")
	drop table master;
create table master
(
	accnt		   char(10)						not null,	/* �ʺ�:����(�����ɼ�˵����)  */
	haccnt		char(7)		default '' 	not null,	/* ���͵�����  */
	groupno		char(10)		default '' 	not null,	/* �����ź�  */
	type		   char(5)		default ''	not null,	/* ��������(cf. typim,block,pickup)  */
   otype       char(5)     default ''	not null,  	/* ����ǰ�ķ�������  */
	up_type		char(5)     default ''	null,  		/* ���ĸ�������������  */
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

	artag1		char(3)		default '' 	not null,	/* ���� */
	artag2		char(3)		default '' 	not null,	/* ���� */
	
	share		   char(1)		default '' 	not null,	/* �Ƿ����ͬס   */
	gstno		   int			default 1 	not null,   /* ���� */
	children		int			default 0	not null,	/* С�� */
	rmreason	   char(1)		default ''	not null,	/* �������� */

	ratecode    char(10)    default '' 	not null,	/* ������  */
	packages		varchar(50)		default ''	not null,	/* ����  */
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

	paycode		char(6)		default ''	not null,	/* ���㷽ʽ */
	limit		   money			default 0 	not null,	/* �޶�(������) */
	credcode		varchar(20)	default ''	not null,	/* ���ÿ����� */
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
	applname    varchar(30)    			null,       /* ������/ί���� */
	applicant	varchar(60)	default ''	not null,	/* ��λ/ί�е�λ */
	araccnt		varchar(7)	default ''	not null,	/* AR�ʺ�(��City ledger,travel agency������) */
	phone    	varchar(16)    			null,       /* ��ϵ�绰�� */
	fax    		varchar(16)    			null,       /* fax */
	email    	varchar(30)    			null,       /* email */

	wherefrom	char(6)		default ''	not null,	/* �ε��� */
	whereto		char(6)		default ''	not null,	/* �ε�ȥ */
	purpose		char(3)		default ''	not null,	/* ���� */

	arrdate		datetime						null,			/* ������Ϣ */
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       /* �뿪��Ϣ */
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	/* ������Ϣ: 1-�����˻� 2-¥��  4-���� 5-���ܷ��� 
                                                   6-�绰 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money		default 0		not null,
	credit 		money		default 0		not null,
	accredit		money		default 0		not null,	/* ���� */

	lastnumb	   int		default 0		not null,	/* account��number������ */
	lastinumb	int		default 0		not null,	/* account��inumber������ */

	srqs		   varchar(30)	default ''	not null,	/* ����Ҫ�� */
	amenities  	varchar(30)	default ''	not null,	/* ���䲼�� */
	master		char(10)		default ''	not null, 	/* �ͷ����� */
	saccnt		char(10)		default ''	not null, 	/* �������� */
	blkcode		char(10)		default ''	not null, 	/* blkcode */
	oblkcode		char(10)		default ''	not null, 	/* blkcode */
	pcrec			char(10)		default ''	not null, 	/* ���� */
	pcrec_pkg	char(10)		default ''	not null, 	/* ���� gaoliang */
	resno			varchar(10)	default ''	not null, 	/* Ԥ����� */
	crsno			varchar(20)	default ''	null, 		/* ��������Ԥ����� */
	ref			varchar(255)	default ''	null, 		/* comment */
	comsg			varchar(255)	default ''	null, 		/* c/o msg */
	card			varchar(7)		default ''	not null,	/* ����� */
	saleid		varchar(10)		default ''	not null,	/* ����Ա */

	cmscode		varchar(10)		default ''	not null,	/* Ӷ���� */
	cardcode		varchar(10)		default ''	not null,	/* ��Ա������ */
	cardno		varchar(20)		default ''	not null,	/* ��Ա������ */

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

-- Ԥ���ֶ�
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,					-- cutoff date 
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,					-- �������� - ��Ӧ�����Ա���� profile 
	exp_s2		varchar(10)		null,					-- Ԥ����ϵ�� guest.haccnt
	exp_s3		varchar(10)		null,					-- ����Ԥ������
	exp_s4		varchar(10)		null,					-- 
	exp_s5		varchar(20)		null,					-- 
	exp_s6		varchar(60)		null,					-- 

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
create table master_till
(
	accnt		   char(10)						not null,	/* �ʺ�:����(�����ɼ�˵����)  */
	haccnt		char(7)		default '' 	not null,	/* ���͵�����  */
	groupno		char(10)		default '' 	not null,	/* �����ź�  */
	type		   char(5)		default ''	not null,	/* ��������(cf. typim,block,pickup)  */
   otype       char(5)     default ''	not null,  	/* ����ǰ�ķ�������  */
	up_type		char(5)     default ''	null,  		/* ���ĸ�������������  */
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

	artag1		char(3)		default '' 	not null,	/* ���� */
	artag2		char(3)		default '' 	not null,	/* ���� */
	
	share		   char(1)		default '' 	not null,	/* �Ƿ����ͬס   */
	gstno		   int			default 1 	not null,   /* ���� */
	children		int			default 0	not null,	/* С�� */
	rmreason	   char(1)		default ''	not null,	/* �������� */

	ratecode    char(10)    default '' 	not null,	/* ������  */
	packages		varchar(50)		default ''	not null,	/* ����  */
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

	paycode		char(6)		default ''	not null,	/* ���㷽ʽ */
	limit		   money			default 0 	not null,	/* �޶�(������) */
	credcode		varchar(20)	default ''	not null,	/* ���ÿ����� */
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
	applname    varchar(30)    			null,       /* ������/ί���� */
	applicant	varchar(60)	default ''	not null,	/* ��λ/ί�е�λ */
	araccnt		varchar(7)	default ''	not null,	/* AR�ʺ�(��City ledger,travel agency������) */
	phone    	varchar(16)    			null,       /* ��ϵ�绰�� */
	fax    		varchar(16)    			null,       /* fax */
	email    	varchar(30)    			null,       /* email */

	wherefrom	char(6)		default ''	not null,	/* �ε��� */
	whereto		char(6)		default ''	not null,	/* �ε�ȥ */
	purpose		char(3)		default ''	not null,	/* ���� */

	arrdate		datetime						null,			/* ������Ϣ */
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       /* �뿪��Ϣ */
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	/* ������Ϣ: 1-�����˻�  4-���� 5-���ܷ��� 
                                                   6-�绰 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money		default 0		not null,
	credit 		money		default 0		not null,
	accredit		money		default 0		not null,	/* ���� */

	lastnumb	   int		default 0		not null,	/* account��number������ */
	lastinumb	int		default 0		not null,	/* account��inumber������ */

	srqs		   varchar(30)	default ''	not null,	/* ����Ҫ�� */
	amenities  	varchar(30)	default ''	not null,	/* ���䲼�� */
	master		char(10)		default ''	not null, 	/* �ͷ����� */
	saccnt		char(10)		default ''	not null, 	/* �������� */
	blkcode		char(10)		default ''	not null, 	/* blkcode */
	oblkcode		char(10)		default ''	not null, 	/* blkcode */
	pcrec			char(10)		default ''	not null, 	/* ���� */
	pcrec_pkg	char(10)		default ''	not null, 	/* ���� gaoliang */
	resno			varchar(10)	default ''	not null, 	/* Ԥ����� */
	crsno			varchar(20)	default ''	null, 		/* ��������Ԥ����� */
	ref			varchar(255)	default ''	null, 		/* comment */
	comsg			varchar(255)	default ''	null, 		/* c/o msg */
	card			varchar(7)		default ''	not null,	/* ����� */
	saleid		varchar(10)		default ''	not null,	/* ����Ա */

	cmscode		varchar(10)		default ''	not null,	/* Ӷ���� */
	cardcode		varchar(10)		default ''	not null,	/* ��Ա������ */
	cardno		varchar(20)		default ''	not null,	/* ��Ա������ */

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

-- Ԥ���ֶ�
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,					-- �������� - ��Ӧ�����Ա���� profile 
	exp_s2		varchar(10)		null,					-- Ԥ����ϵ�� guest.haccnt
	exp_s3		varchar(10)		null,					-- ����Ԥ������
	exp_s4		varchar(10)		null,					-- 
	exp_s5		varchar(20)		null,					-- 
	exp_s6		varchar(60)		null,					-- 

	logmark     int    default 0 			not null
);
exec sp_primarykey master_till,accnt
create unique index  master_till on master_till(accnt)
;


if exists(select * from sysobjects where name = "master_last" and type="U")
	drop table master_last;
create table master_last
(
	accnt		   char(10)						not null,	/* �ʺ�:����(�����ɼ�˵����)  */
	haccnt		char(7)		default '' 	not null,	/* ���͵�����  */
	groupno		char(10)		default '' 	not null,	/* �����ź�  */
	type		   char(5)		default ''	not null,	/* ��������(cf. typim,block,pickup)  */
   otype       char(5)     default ''	not null,  	/* ����ǰ�ķ�������  */
	up_type		char(5)     default ''	null,  		/* ���ĸ�������������  */
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

	artag1		char(3)		default '' 	not null,	/* ���� */
	artag2		char(3)		default '' 	not null,	/* ���� */
	
	share		   char(1)		default '' 	not null,	/* �Ƿ����ͬס   */
	gstno		   int			default 1 	not null,   /* ���� */
	children		int			default 0	not null,	/* С�� */
	rmreason	   char(1)		default ''	not null,	/* �������� */

	ratecode    char(10)    default '' 	not null,	/* ������  */
	packages		varchar(50)		default ''	not null,	/* ����  */
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

	paycode		char(6)		default ''	not null,	/* ���㷽ʽ */
	limit		   money			default 0 	not null,	/* �޶�(������) */
	credcode		varchar(20)	default ''	not null,	/* ���ÿ����� */
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
	applname    varchar(30)    			null,       /* ������/ί���� */
	applicant	varchar(60)	default ''	not null,	/* ��λ/ί�е�λ */
	araccnt		varchar(7)	default ''	not null,	/* AR�ʺ�(��City ledger,travel agency������) */
	phone    	varchar(16)    			null,       /* ��ϵ�绰�� */
	fax    		varchar(16)    			null,       /* fax */
	email    	varchar(30)    			null,       /* email */

	wherefrom	char(6)		default ''	not null,	/* �ε��� */
	whereto		char(6)		default ''	not null,	/* �ε�ȥ */
	purpose		char(3)		default ''	not null,	/* ���� */

	arrdate		datetime						null,			/* ������Ϣ */
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       /* �뿪��Ϣ */
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	/* ������Ϣ: 1-�����˻�  4-���� 5-���ܷ��� 
                                                   6-�绰 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money		default 0		not null,
	credit 		money		default 0		not null,
	accredit		money		default 0		not null,	/* ���� */

	lastnumb	   int		default 0		not null,	/* account��number������ */
	lastinumb	int		default 0		not null,	/* account��inumber������ */

	srqs		   varchar(30)	default ''	not null,	/* ����Ҫ�� */
	amenities  	varchar(30)	default ''	not null,	/* ���䲼�� */
	master		char(10)		default ''	not null, 	/* �ͷ����� */
	saccnt		char(10)		default ''	not null, 	/* �������� */
	blkcode		char(10)		default ''	not null, 	/* blkcode */
	oblkcode		char(10)		default ''	not null, 	/* blkcode */
	pcrec			char(10)		default ''	not null, 	/* ���� */
	pcrec_pkg	char(10)		default ''	not null, 	/* ���� gaoliang */
	resno			varchar(10)	default ''	not null, 	/* Ԥ����� */
	crsno			varchar(20)	default ''	null, 		/* ��������Ԥ����� */
	ref			varchar(255)	default ''	null, 		/* comment */
	comsg			varchar(255)	default ''	null, 		/* c/o msg */
	card			varchar(7)		default ''	not null,	/* ����� */
	saleid		varchar(10)		default ''	not null,	/* ����Ա */

	cmscode		varchar(10)		default ''	not null,	/* Ӷ���� */
	cardcode		varchar(10)		default ''	not null,	/* ��Ա������ */
	cardno		varchar(20)		default ''	not null,	/* ��Ա������ */

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

-- Ԥ���ֶ�
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,					-- �������� - ��Ӧ�����Ա���� profile 
	exp_s2		varchar(10)		null,					-- Ԥ����ϵ�� guest.haccnt
	exp_s3		varchar(10)		null,					-- ����Ԥ������
	exp_s4		varchar(10)		null,					-- 
	exp_s5		varchar(20)		null,					-- 
	exp_s6		varchar(60)		null,					-- 

	logmark     int    default 0 			not null
);
exec sp_primarykey master_last,accnt
create unique index  master_last on master_last(accnt)
;


if exists(select * from sysobjects where name = "master_log" and type="U")
	drop table master_log;
create table master_log
(
	accnt		   char(10)						not null,	/* �ʺ�:����(�����ɼ�˵����)  */
	haccnt		char(7)		default '' 	not null,	/* ���͵�����  */
	groupno		char(10)		default '' 	not null,	/* �����ź�  */
	type		   char(5)		default ''	not null,	/* ��������(cf. typim,block,pickup)  */
   otype       char(5)     default ''	not null,  	/* ����ǰ�ķ�������  */
	up_type		char(5)     default ''	null,  		/* ���ĸ�������������  */
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

	artag1		char(3)		default '' 	not null,	/* ���� */
	artag2		char(3)		default '' 	not null,	/* ���� */
	
	share		   char(1)		default '' 	not null,	/* �Ƿ����ͬס   */
	gstno		   int			default 1 	not null,   /* ���� */
	children		int			default 0	not null,	/* С�� */
	rmreason	   char(1)		default ''	not null,	/* �������� */

	ratecode    char(10)    default '' 	not null,	/* ������  */
	packages		varchar(50)		default ''	not null,	/* ����  */
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

	paycode		char(6)		default ''	not null,	/* ���㷽ʽ */
	limit		   money			default 0 	not null,	/* �޶�(������) */
	credcode		varchar(20)	default ''	not null,	/* ���ÿ����� */
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
	applname    varchar(30)    			null,       /* ������/ί���� */
	applicant	varchar(60)	default ''	not null,	/* ��λ/ί�е�λ */
	araccnt		varchar(7)	default ''	not null,	/* AR�ʺ�(��City ledger,travel agency������) */
	phone    	varchar(16)    			null,       /* ��ϵ�绰�� */
	fax    		varchar(16)    			null,       /* fax */
	email    	varchar(30)    			null,       /* email */

	wherefrom	char(6)		default ''	not null,	/* �ε��� */
	whereto		char(6)		default ''	not null,	/* �ε�ȥ */
	purpose		char(3)		default ''	not null,	/* ���� */

	arrdate		datetime						null,			/* ������Ϣ */
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       /* �뿪��Ϣ */
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	/* ������Ϣ: 1-�����˻�  4-���� 5-���ܷ��� 
                                                   6-�绰 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money		default 0		not null,
	credit 		money		default 0		not null,
	accredit		money		default 0		not null,	/* ���� */

	lastnumb	   int		default 0		not null,	/* account��number������ */
	lastinumb	int		default 0		not null,	/* account��inumber������ */

	srqs		   varchar(30)	default ''	not null,	/* ����Ҫ�� */
	amenities  	varchar(30)	default ''	not null,	/* ���䲼�� */
	master		char(10)		default ''	not null, 	/* �ͷ����� */
	saccnt		char(10)		default ''	not null, 	/* �������� */
	blkcode		char(10)		default ''	not null, 	/* blkcode */
	oblkcode		char(10)		default ''	not null, 	/* blkcode */
	pcrec			char(10)		default ''	not null, 	/* ���� */
	pcrec_pkg	char(10)		default ''	not null, 	/* ���� gaoliang */
	resno			varchar(10)	default ''	not null, 	/* Ԥ����� */
	crsno			varchar(20)	default ''	null, 		/* ��������Ԥ����� */
	ref			varchar(255)	default ''	null, 		/* comment */
	comsg			varchar(255)	default ''	null, 		/* c/o msg */
	card			varchar(7)		default ''	not null,	/* ����� */
	saleid		varchar(10)		default ''	not null,	/* ����Ա */

	cmscode		varchar(10)		default ''	not null,	/* Ӷ���� */
	cardcode		varchar(10)		default ''	not null,	/* ��Ա������ */
	cardno		varchar(20)		default ''	not null,	/* ��Ա������ */

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

-- Ԥ���ֶ�
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,					-- �������� - ��Ӧ�����Ա���� profile 
	exp_s2		varchar(10)		null,					-- Ԥ����ϵ�� guest.haccnt
	exp_s3		varchar(10)		null,					-- ����Ԥ������
	exp_s4		varchar(10)		null,					-- 
	exp_s5		varchar(20)		null,					-- 
	exp_s6		varchar(60)		null,					-- 

	logmark     int    default 0 			not null
);
exec sp_primarykey master_log, accnt, logmark
create unique index master_log on master_log(accnt, logmark)
;


//--------------------------------------------------------------------------
//		master_middle  �����Աģ��ȵ�
//--------------------------------------------------------------------------
if exists(select * from sysobjects where name = "master_middle" and type="U")
	drop table master_middle;
create table master_middle
(
	accnt		   char(10)						not null,	/* �ʺ�:����(�����ɼ�˵����)  */
	haccnt		char(7)		default '' 	not null,	/* ���͵�����  */
	groupno		char(10)		default '' 	not null,	/* �����ź�  */
	type		   char(5)		default ''	not null,	/* ��������(cf. typim,block,pickup)  */
   otype       char(5)     default ''	not null,  	/* ����ǰ�ķ�������  */
	up_type		char(5)     default ''	null,  		/* ���ĸ�������������  */
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

	artag1		char(3)		default '' 	not null,	/* ���� */
	artag2		char(3)		default '' 	not null,	/* ���� */
	
	share		   char(1)		default '' 	not null,	/* �Ƿ����ͬס   */
	gstno		   int			default 1 	not null,   /* ���� */
	children		int			default 0	not null,	/* С�� */
	rmreason	   char(1)		default ''	not null,	/* �������� */

	ratecode    char(10)    default '' 	not null,	/* ������  */
	packages		varchar(50)		default ''	not null,	/* ����  */
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

	paycode		char(6)		default ''	not null,	/* ���㷽ʽ */
	limit		   money			default 0 	not null,	/* �޶�(������) */
	credcode		varchar(20)	default ''	not null,	/* ���ÿ����� */
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
	applname    varchar(30)    			null,       /* ������/ί���� */
	applicant	varchar(60)	default ''	not null,	/* ��λ/ί�е�λ */
	araccnt		varchar(7)	default ''	not null,	/* AR�ʺ�(��City ledger,travel agency������) */
	phone    	varchar(16)    			null,       /* ��ϵ�绰�� */
	fax    		varchar(16)    			null,       /* fax */
	email    	varchar(30)    			null,       /* email */

	wherefrom	char(6)		default ''	not null,	/* �ε��� */
	whereto		char(6)		default ''	not null,	/* �ε�ȥ */
	purpose		char(3)		default ''	not null,	/* ���� */

	arrdate		datetime						null,			/* ������Ϣ */
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       /* �뿪��Ϣ */
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	/* ������Ϣ: 1-�����˻�  4-���� 5-���ܷ��� 
                                                   6-�绰 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money		default 0		not null,
	credit 		money		default 0		not null,
	accredit		money		default 0		not null,	/* ���� */

	lastnumb	   int		default 0		not null,	/* account��number������ */
	lastinumb	int		default 0		not null,	/* account��inumber������ */

	srqs		   varchar(30)	default ''	not null,	/* ����Ҫ�� */
	amenities  	varchar(30)	default ''	not null,	/* ���䲼�� */
	master		char(10)		default ''	not null, 	/* �ͷ����� */
	saccnt		char(10)		default ''	not null, 	/* �������� */
	blkcode		char(10)		default ''	not null, 	/* blkcode */
	oblkcode		char(10)		default ''	not null, 	/* blkcode */
	pcrec			char(10)		default ''	not null, 	/* ���� */
	pcrec_pkg	char(10)		default ''	not null, 	/* ���� gaoliang */
	resno			varchar(10)	default ''	not null, 	/* Ԥ����� */
	crsno			varchar(20)	default ''	null, 		/* ��������Ԥ����� */
	ref			varchar(255)	default ''	null, 		/* comment */
	comsg			varchar(255)	default ''	null, 		/* c/o msg */
	card			varchar(7)		default ''	not null,	/* ����� */
	saleid		varchar(10)		default ''	not null,	/* ����Ա */

	cmscode		varchar(10)		default ''	not null,	/* Ӷ���� */
	cardcode		varchar(10)		default ''	not null,	/* ��Ա������ */
	cardno		varchar(20)		default ''	not null,	/* ��Ա������ */

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

-- Ԥ���ֶ�
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,					-- �������� - ��Ӧ�����Ա���� profile 
	exp_s2		varchar(10)		null,					-- Ԥ����ϵ�� guest.haccnt
	exp_s3		varchar(10)		null,					-- ����Ԥ������
	exp_s4		varchar(10)		null,					-- 
	exp_s5		varchar(20)		null,					-- 
	exp_s6		varchar(60)		null,					-- 

	logmark     int    default 0 			not null
);
exec sp_primarykey master_middle,groupno,accnt
create unique index  master_middle on master_middle(groupno,accnt)
;


//--------------------------------------------------------------------------
//		master_del  ɾ��
//--------------------------------------------------------------------------
if exists(select * from sysobjects where name = "master_del" and type="U")
	drop table master_del;
create table master_del
(
	accnt		   char(10)						not null,	/* �ʺ�:����(�����ɼ�˵����)  */
	haccnt		char(7)		default '' 	not null,	/* ���͵�����  */
	groupno		char(10)		default '' 	not null,	/* �����ź�  */
	type		   char(5)		default ''	not null,	/* ��������(cf. typim,block,pickup)  */
   otype       char(5)     default ''	not null,  	/* ����ǰ�ķ�������  */
	up_type		char(5)     default ''	null,  		/* ���ĸ�������������  */
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

	artag1		char(3)		default '' 	not null,	/* ���� */
	artag2		char(3)		default '' 	not null,	/* ���� */
	
	share		   char(1)		default '' 	not null,	/* �Ƿ����ͬס   */
	gstno		   int			default 1 	not null,   /* ���� */
	children		int			default 0	not null,	/* С�� */
	rmreason	   char(1)		default ''	not null,	/* �������� */

	ratecode    char(10)    default '' 	not null,	/* ������  */
	packages		varchar(50)		default ''	not null,	/* ����  */
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

	paycode		char(6)		default ''	not null,	/* ���㷽ʽ */
	limit		   money			default 0 	not null,	/* �޶�(������) */
	credcode		varchar(20)	default ''	not null,	/* ���ÿ����� */
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
	applname    varchar(30)    			null,       /* ������/ί���� */
	applicant	varchar(60)	default ''	not null,	/* ��λ/ί�е�λ */
	araccnt		varchar(7)	default ''	not null,	/* AR�ʺ�(��City ledger,travel agency������) */
	phone    	varchar(16)    			null,       /* ��ϵ�绰�� */
	fax    		varchar(16)    			null,       /* fax */
	email    	varchar(30)    			null,       /* email */

	wherefrom	char(6)		default ''	not null,	/* �ε��� */
	whereto		char(6)		default ''	not null,	/* �ε�ȥ */
	purpose		char(3)		default ''	not null,	/* ���� */

	arrdate		datetime						null,			/* ������Ϣ */
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       /* �뿪��Ϣ */
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	/* ������Ϣ: 1-�����˻�  4-���� 5-���ܷ��� 
                                                   6-�绰 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money		default 0		not null,
	credit 		money		default 0		not null,
	accredit		money		default 0		not null,	/* ���� */

	lastnumb	   int		default 0		not null,	/* account��number������ */
	lastinumb	int		default 0		not null,	/* account��inumber������ */

	srqs		   varchar(30)	default ''	not null,	/* ����Ҫ�� */
	amenities  	varchar(30)	default ''	not null,	/* ���䲼�� */
	master		char(10)		default ''	not null, 	/* �ͷ����� */
	saccnt		char(10)		default ''	not null, 	/* �������� */
	blkcode		char(10)		default ''	not null, 	/* blkcode */
	oblkcode		char(10)		default ''	not null, 	/* blkcode */
	pcrec			char(10)		default ''	not null, 	/* ���� */
	pcrec_pkg	char(10)		default ''	not null, 	/* ���� gaoliang */
	resno			varchar(10)	default ''	not null, 	/* Ԥ����� */
	crsno			varchar(20)	default ''	null, 		/* ��������Ԥ����� */
	ref			varchar(255)	default ''	null, 		/* comment */
	comsg			varchar(255)	default ''	null, 		/* c/o msg */
	card			varchar(7)		default ''	not null,	/* ����� */
	saleid		varchar(10)		default ''	not null,	/* ����Ա */

	cmscode		varchar(10)		default ''	not null,	/* Ӷ���� */
	cardcode		varchar(10)		default ''	not null,	/* ��Ա������ */
	cardno		varchar(20)		default ''	not null,	/* ��Ա������ */

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

-- Ԥ���ֶ�
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,					-- �������� - ��Ӧ�����Ա���� profile 
	exp_s2		varchar(10)		null,					-- Ԥ����ϵ�� guest.haccnt
	exp_s3		varchar(10)		null,					-- ����Ԥ������
	exp_s4		varchar(10)		null,					-- 
	exp_s5		varchar(20)		null,					-- 
	exp_s6		varchar(60)		null,					-- 

	logmark     int    default 0 			not null
);
exec sp_primarykey master_del,accnt
create unique index  master_del on master_del(accnt)
;


if exists(select * from sysobjects where name = "hmaster" and type="U")
	drop table hmaster;
create table hmaster
(
	accnt		   char(10)						not null,	/* �ʺ�:����(�����ɼ�˵����)  */
	haccnt		char(7)		default '' 	not null,	/* ���͵�����  */
	groupno		char(10)		default '' 	not null,	/* �����ź�  */
	type		   char(5)		default ''	not null,	/* ��������(cf. typim,block,pickup)  */
   otype       char(5)     default ''	not null,  	/* ����ǰ�ķ�������  */
	up_type		char(5)     default ''	null,  		/* ���ĸ�������������  */
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

	artag1		char(3)		default '' 	not null,	/* ���� */
	artag2		char(3)		default '' 	not null,	/* ���� */
	
	share		   char(1)		default '' 	not null,	/* �Ƿ����ͬס   */
	gstno		   int			default 1 	not null,   /* ���� */
	children		int			default 0	not null,	/* С�� */
	rmreason	   char(1)		default ''	not null,	/* �������� */

	ratecode    char(10)    default '' 	not null,	/* ������  */
	packages		varchar(50)		default ''	not null,	/* ����  */
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

	paycode		char(6)		default ''	not null,	/* ���㷽ʽ */
	limit		   money			default 0 	not null,	/* �޶�(������) */
	credcode		varchar(20)	default ''	not null,	/* ���ÿ����� */
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
	applname    varchar(30)    			null,       /* ������/ί���� */
	applicant	varchar(60)	default ''	not null,	/* ��λ/ί�е�λ */
	araccnt		varchar(7)	default ''	not null,	/* AR�ʺ�(��City ledger,travel agency������) */
	phone    	varchar(16)    			null,       /* ��ϵ�绰�� */
	fax    		varchar(16)    			null,       /* fax */
	email    	varchar(30)    			null,       /* email */

	wherefrom	char(6)		default ''	not null,	/* �ε��� */
	whereto		char(6)		default ''	not null,	/* �ε�ȥ */
	purpose		char(3)		default ''	not null,	/* ���� */

	arrdate		datetime						null,			/* ������Ϣ */
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       /* �뿪��Ϣ */
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	/* ������Ϣ: 1-�����˻�  4-���� 5-���ܷ��� 
                                                   6-�绰 7-vod 8-internet 9-walkin 10-lock 12-fixroom */

	charge		money		default 0		not null,
	credit 		money		default 0		not null,
	accredit		money		default 0		not null,	/* ���� */

	lastnumb	   int		default 0		not null,	/* account��number������ */
	lastinumb	int		default 0		not null,	/* account��inumber������ */

	srqs		   varchar(30)	default ''	not null,	/* ����Ҫ�� */
	amenities  	varchar(30)	default ''	not null,	/* ���䲼�� */
	master		char(10)		default ''	not null, 	/* �ͷ����� */
	saccnt		char(10)		default ''	not null, 	/* �������� */
	blkcode		char(10)		default ''	not null, 	/* blkcode */
	oblkcode		char(10)		default ''	not null, 	/* blkcode */
	pcrec			char(10)		default ''	not null, 	/* ���� */
	pcrec_pkg	char(10)		default ''	not null, 	/* ���� gaoliang */
	resno			varchar(10)	default ''	not null, 	/* Ԥ����� */
	crsno			varchar(20)	default ''	null, 		/* ��������Ԥ����� */
	ref			varchar(255)	default ''	null, 		/* comment */
	comsg			varchar(255)	default ''	null, 		/* c/o msg */
	card			varchar(7)		default ''	not null,	/* ����� */
	saleid		varchar(10)		default ''	not null,	/* ����Ա */

	cmscode		varchar(10)		default ''	not null,	/* Ӷ���� */
	cardcode		varchar(10)		default ''	not null,	/* ��Ա������ */
	cardno		varchar(20)		default ''	not null,	/* ��Ա������ */

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

-- Ԥ���ֶ�
	exp_m1		money				null,
	exp_m2		money				null,
	exp_dt1		datetime			null,
	exp_dt2		datetime			null,
	exp_s1		varchar(10)		null,					-- �������� - ��Ӧ�����Ա���� profile 
	exp_s2		varchar(10)		null,					-- Ԥ����ϵ�� guest.haccnt
	exp_s3		varchar(10)		null,					-- ����Ԥ������
	exp_s4		varchar(10)		null,					-- 
	exp_s5		varchar(20)		null,					-- 
	exp_s6		varchar(60)		null,					-- 

-- ��Ϊɾ�� hguest ���ӵĲ����ֶ�  
	name		   varchar(50)	 						not null,	 	// ����: ���� 
	fname       varchar(30)		default ''		not null, 		// Ӣ���� 
	lname			varchar(30)		default '' 		not null,		// Ӣ���� 
	name2		   varchar(50)		default '' 		not null,		// �������� 
	name3		   varchar(50)		default '' 		not null,		// �������� 
	name4		   varchar(255)	default '' 		not null,		// �������� 
	class1		varchar(3)		default '0'		not null, 		// �������	0=��ʾû�ж��壻
	class2		varchar(3)		default '0'		not null,
	class3		varchar(3)		default '0'		not null,
	class4		varchar(3)		default '0'		not null,
	vip			char(3)			default '0'		not null,  		// vip 
	sex			char(1)			default '1'		not null,      // �Ա�:M,F 
	birth       datetime								null,         	// ����
	nation		varchar(3)		default ''		not null,	   // ���� 
	country		char(3)			default ''		not null,	   // ���� 
	state			char(3)			default ''		not null,
	town			varchar(40)		default ''		not null,		// ����
	city  		varchar(6)		default ''		not null,      // ���� ���� 
	street	   varchar(60)		default ''		not null,		// סַ 
   idcls       varchar(3)     default ''		not null,     	// ����֤����� 
	ident		   varchar(20)	   default ''		not null,     	// ����֤������ 
	pextra		varchar(255)	null,									// ���ܼ�¼�������������� 

	logmark     int    			default 0 		not null
);
exec sp_primarykey hmaster,accnt
create unique index  hmaster on hmaster(accnt)
create index  groupno on hmaster(groupno,accnt)
create index  index3 on hmaster (roomno)
create index  index4 on hmaster (haccnt)
create index  index5 on hmaster (cusno)
create index  index6 on hmaster (agent)
create index  index7 on hmaster (source)
create index  master on hmaster (master)
create index  pcrec on hmaster (pcrec)
create index  exp_s2 on hmaster (exp_s2,dep)
create index  bdate on hmaster (bdate,class,sta,market)
create index  arr on hmaster (arr,class,sta)
;


// ------------------------------------------------------------------------------
//	master_remark : ��ע
// ------------------------------------------------------------------------------
//if exists(select * from sysobjects where name = "master_remark")
//   drop table master_remark;
//create table master_remark
//(
//	accnt			char(10)						not null,
//	remark		text		default ''		null
//)
//exec sp_primarykey master_remark,accnt
//create unique index index1 on master_remark(accnt)
//;


//update master set extra=rtrim(extra)+'000000000000000' ; 
//update master_till set extra=rtrim(extra)+'000000000000000' ; 
//update master_last set extra=rtrim(extra)+'000000000000000' ; 
//update master_log set extra=rtrim(extra)+'000000000000000' ; 
//update master_del set extra=rtrim(extra)+'000000000000000' ; 
//update master_middle set extra=rtrim(extra)+'000000000000000' ; 
//update hmaster set extra=rtrim(extra)+'000000000000000' ; 
//