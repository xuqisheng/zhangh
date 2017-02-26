//==========================================================================
//Table : sc_master
//
//			= fidelio business block 
//==========================================================================

//--------------------------------------------------------------------------
//		sc_master, sc_master_till, sc_master_last, sc_master_log, sc_hmaster
//		sc_master_del
//--------------------------------------------------------------------------

if exists(select * from sysobjects where name = "sc_master" and type="U")
	drop table sc_master;
create table sc_master
(
	accnt		   char(10)						not null,	-- �ʺ�:����(�����ɼ�˵����)  
	foact		   char(10)	default ''			not null,	-- block ״̬��1=��Դ 2=��ǰλ��  F=FO, S=SC 
	haccnt		char(7)		default '' 	not null,	-- ���͵�����  
--	groupno		char(10)		default '' 	not null,	-- �����ź�  
	type		   char(5)		default ''	not null,	-- ��������(cf. typim,block,pickup)  
   otype       char(5)     default ''	not null,  	-- ����ǰ�ķ�������  
--	up_type		char(5)     default ''	null,  		-- ���ĸ�������������  
--	up_reason	char(3)     default ''	not null,  	-- ����ԭ��  
	rmnum			int			default 0	not null,
--	ormnum		int			default 0	not null,
	roomno		char(5)		default ''	not null,  	-- ���� 
	oroomno     char(5)     default ''	not null,  	-- ����ǰ�ķ��� 
	bdate		   datetime	   				not null,	-- ��ס�����Ӫҵ����=business date 
	sta			char(1)						not null,   -- �ʺ�״̬(��˵����˵����) 
	osta        char(1)     default ''	not null,   -- ����ǰ���ʺ�״̬ 
--	ressta      char(1)     default ''	not null,   -- ����ʱ�����״̬,�����������ʲ��ָ���ԭ״̬ 
--	exp_sta		char(1)		default '' 	null,			--  ���巿�ķ���  										---
	sta_tm		char(1)		default '' 	not null,	-- �ʺ�״̬(������) 
--	rmpoststa	char(1)		default '' 	not null,	-- �����ֶ�:������ʱ�� 									---
--	rmposted	   char(1)		default "F"	not null,	-- ����ס�����Ƿ�������� 
	tag0		   char(1)		default '' 	null,
	arr			datetime	   				not null,	-- ��������=arrival 
	dep			datetime	   				not null,	-- �������=departure 
--   resdep      datetime    				null,       -- ����ʱ������뿪����,������������ 
	oarr        datetime    				null,
	odep        datetime    				null,

	agent			char(7)		default '' 	not null,
	cusno			char(7)		default '' 	not null,
	source		char(7)		default '' 	not null,

	class		   char(1)		default '' 	not null,	-- ���: F-fit, G-grp, M-meet, A-armst, C-House accounts
	src			char(3)		default '' 	not null,	-- ��Դ 
	market		char(3)		default '' 	not null,	-- �г��� 
	restype		char(3)		default '' 	not null,	-- Ԥ����� 
	channel		char(3)		default '' 	not null,	-- ���� 

--	artag1		char(3)		default '' 	not null,	-- ���� 
--	artag2		char(3)		default '' 	not null,	-- ���� 
	
--	share		   char(1)		default '' 	not null,	-- �Ƿ����ͬס   
	gstno		   int			default 1 	not null,   -- ���� 
	children		int			default 0	not null,	-- С�� 
--	rmreason	   char(1)		default ''	not null,	-- �������� 

	ratecode    char(10)    default '' 	not null,	-- ������  
	packages		varchar(50)		default ''	not null,	-- ����  
--	fixrate	   char(1)		default 'F'	not null,	-- �̶����� 
--	rmrate		money			default 0	not null,	-- ���䱨�� 
--	qtrate		money			default 0	not null,	-- Э�鷿�䱨�� 
	setrate		money			default 0	not null,	-- ���Żݼ��Ż�����һ�����ʵ�ʷ��� 
--	rtreason	   char(3)		default ''	not null,	-- �����Ż�����(cf.rtreason.dbf) 
--	discount	   money			default 0	not null,	-- �Żݶ� 
--	discount1	money			default 0	not null,	-- �Żݱ��� 
--	addbed	   money			default 0 	not null,	-- �Ӵ�����  
--	addbed_rate	money			default 0 	not null,	-- �Ӵ��� 
--	crib	   	money			default 0 	not null,	-- Ӥ�������� 
--	crib_rate	money			default 0 	not null,	-- Ӥ�����۸� 

	paycode		char(6)		default ''	not null,	-- ���㷽ʽ 
	limit		   money			default 0 	not null,	-- �޶�(������) 
	credcode		varchar(20)	default ''	not null,	-- ���ÿ����� 
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
--	applname    varchar(30)    			null,       -- ������/ί���� 
--	applicant	varchar(60)	default ''	not null,	-- ��λ/ί�е�λ 
	araccnt		varchar(7)	default ''	not null,	-- AR�ʺ�(��City ledger,travel agency������) 
--	phone    	varchar(16)    			null,       -- ��ϵ�绰�� 
--	fax    		varchar(16)    			null,       -- fax 
--	email    	varchar(30)    			null,       -- email 

	wherefrom	char(6)		default ''	not null,	-- �ε��� 
	whereto		char(6)		default ''	not null,	-- �ε�ȥ 
	purpose		char(3)		default ''	not null,	-- ���� 

	arrdate		datetime						null,			-- ������Ϣ 
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       -- �뿪��Ϣ 
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	-- ������Ϣ: 1-�����˻�  4-���� 5-���ܷ��� 
                                                   -- 6-�绰 7-vod 8-internet 9-walkin 10-lock 12-fixroom 

	charge		money			default 0	not null,
	credit 		money			default 0	not null,
	accredit		money			default 0	not null,	-- ���� 

	lastnumb	   int			default 0	not null,	-- account��number������ 
	lastinumb	int			default 0	not null,	-- account��inumber������ 

	srqs		   varchar(30)	default ''	not null,	-- ����Ҫ�� 
	amenities  	varchar(30)	default ''	not null,	-- ���䲼�� 
	master		char(10)		default ''	not null, 	-- �ͷ����� 
	saccnt		char(10)		default ''	not null, 	-- �������� 
	blkcode		char(10)		default ''	not null,	-- 
	pcrec			char(10)		default ''	not null, 	-- ���� 
	pcrec_pkg	char(10)		default ''	not null, 	-- ���� gaoliang 
	resno			varchar(10)	default ''	not null, 	-- Ԥ����� 
	crsno			varchar(20)	default ''	null, 		-- ��������Ԥ����� 
	ref			varchar(255)	default ''	null, 		-- comment 
	comsg			varchar(255)	default ''	null, 		-- c/o msg 
--	card			varchar(7)		default ''	not null,	-- ����� 
	saleid		varchar(10)		default ''	not null,	-- ����Ա 

	cmscode		varchar(10)		default ''	not null,	-- Ӷ���� 
	cardcode		varchar(10)		default ''	not null,	-- ��Ա������ 
	cardno		varchar(20)		default ''	not null,	-- ��Ա������ 

-- sales 
	contact		char(10)		default ''		not null,	-- ��ϵ��
	name			varchar(50)	default ''		null,			-- block name 
	name2			varchar(50)	default ''		null,
	blockcode	varchar(20)	default ''		not null,
	status		char(10)							not null,	
	btype			char(10)	default ''			not null,	-- business type 
	bscope		char(1)		default '0'		not null,	-- ҵ�񷶳� 0=blk+catering 1=blk 2=catering 
	potential	varchar(30)						null,
	saleid2		varchar(10)		default ''	not null,	-- ����Ա
	peakrms		int								null,		-- ����
	avrate		money								null,		-- ƽ������

	cutoff		datetime							null,
	follow		datetime							null,
	decision		datetime							null,
	rmlistdate	datetime							null,		-- room list date 
	currency		varchar(10)						null,		-- ����
	tracecode	varchar(30)						null,
	triggers		varchar(30)						null,
	
	porterage	char(1)		default 'F'		not null,	-- ��ͨ
	ptgrate		money 		default 0		not null,
	breakfast	char(1)		default 'F'		not null,	-- ���
	bfrate		money 		default 0		not null,
	bfdes			varchar(30)						null,


-- catering 
	c_status		char(10)	default ''		not null,	-- ���״̬
	c_attendees	int			default 0		not null,	-- ����
	c_guaranteed	char(3)	default 'F'		not null,	-- ��֤ for c_attendees
	c_infoboard	varchar(100)					null,			-- ����
	c_follow		datetime							null,
	c_decision	datetime							null,
	c_function	varchar(40)						null,			-- ��������
	c_contract	varchar(20)						null,			-- ��Լ���
	c_detailok	char(1)			default 'F'	not null,	-- ϸ����� ��
	c_distributed	char(1)		default 'F'	not null,	-- ��Ϣ�����ˣ�
	c_saleid		varchar(10)		default ''	not null,	-- ����Ա

	resby			char(10)		default ''	not null,	-- Ԥ��Ա��Ϣ 
	restime		datetime						null,			
	defby			char(10)		default ''	not null,	-- ȷ����Ϣ 
	deftime		datetime						null,			
	tfby			char(10)		default ''	not null,	-- to fo ��Ϣ 
	tftime		datetime						null,
	coby			char(10)		default ''	not null,	-- ����Ա��Ϣ 
	cotime		datetime						null,
	depby			char(10)		default ''	not null,	-- �˷�Ա��Ϣ 
	deptime		datetime						null,			

	cby			char(10)						not null,	-- �����޸�����Ϣ 
	changed		datetime						not null,	

-- Ԥ���ֶ�
	exp_m1		money							null,
	exp_m2		money							null,
	exp_m3		money							null,
	exp_m4		money							null,
	exp_dt1		datetime						null,
	exp_dt2		datetime						null,
	exp_dt3		datetime						null,
	exp_dt4		datetime						null,
	exp_s1		varchar(30)					null,
	exp_s2		varchar(30)					null,
	exp_s3		varchar(30)					null,
	exp_s4		varchar(30)					null,
	exp_s5		varchar(60)					null,
	exp_s6		varchar(100)				null,

	logmark     int    default 0 			not null
)
exec sp_primarykey sc_master,accnt
create unique index  sc_master on sc_master(accnt)
create index  sta on sc_master (sta, arr)
create index  arr on sc_master (arr, sta)
create index  haccnt on sc_master (haccnt, sta, arr)
create index  cusno on sc_master (cusno, sta, arr)
create index  agent on sc_master (agent, sta, arr)
create index  source on sc_master (source, sta, arr)
create index  resby on sc_master (resby)
create index  tfby on sc_master (tfby)
create index  contact on sc_master (contact,arr)
create index  saleid on sc_master (saleid,arr)
create index  blockcode on sc_master (blockcode)
;



if exists(select * from sysobjects where name = "sc_master_till" and type="U")
	drop table sc_master_till;
create table sc_master_till
(
	accnt		   char(10)						not null,	-- �ʺ�:����(�����ɼ�˵����)  
	foact		   char(10)	default ''			not null,	-- block ״̬��1=��Դ 2=��ǰλ��  F=FO, S=SC 
	haccnt		char(7)		default '' 	not null,	-- ���͵�����  
--	groupno		char(10)		default '' 	not null,	-- �����ź�  
	type		   char(5)		default ''	not null,	-- ��������(cf. typim,block,pickup)  
   otype       char(5)     default ''	not null,  	-- ����ǰ�ķ�������  
--	up_type		char(5)     default ''	null,  		-- ���ĸ�������������  
--	up_reason	char(3)     default ''	not null,  	-- ����ԭ��  
	rmnum			int			default 0	not null,
--	ormnum		int			default 0	not null,
	roomno		char(5)		default ''	not null,  	-- ���� 
	oroomno     char(5)     default ''	not null,  	-- ����ǰ�ķ��� 
	bdate		   datetime	   				not null,	-- ��ס�����Ӫҵ����=business date 
	sta			char(1)						not null,   -- �ʺ�״̬(��˵����˵����) 
	osta        char(1)     default ''	not null,   -- ����ǰ���ʺ�״̬ 
--	ressta      char(1)     default ''	not null,   -- ����ʱ�����״̬,�����������ʲ��ָ���ԭ״̬ 
--	exp_sta		char(1)		default '' 	null,			--  ���巿�ķ���  										---
	sta_tm		char(1)		default '' 	not null,	-- �ʺ�״̬(������) 
--	rmpoststa	char(1)		default '' 	not null,	-- �����ֶ�:������ʱ�� 									---
--	rmposted	   char(1)		default "F"	not null,	-- ����ס�����Ƿ�������� 
	tag0		   char(1)		default '' 	null,
	arr			datetime	   				not null,	-- ��������=arrival 
	dep			datetime	   				not null,	-- �������=departure 
--   resdep      datetime    				null,       -- ����ʱ������뿪����,������������ 
	oarr        datetime    				null,
	odep        datetime    				null,

	agent			char(7)		default '' 	not null,
	cusno			char(7)		default '' 	not null,
	source		char(7)		default '' 	not null,

	class		   char(1)		default '' 	not null,	-- ���: F-fit, G-grp, M-meet, A-armst, C-House accounts
	src			char(3)		default '' 	not null,	-- ��Դ 
	market		char(3)		default '' 	not null,	-- �г��� 
	restype		char(3)		default '' 	not null,	-- Ԥ����� 
	channel		char(3)		default '' 	not null,	-- ���� 

--	artag1		char(3)		default '' 	not null,	-- ���� 
--	artag2		char(3)		default '' 	not null,	-- ���� 
	
--	share		   char(1)		default '' 	not null,	-- �Ƿ����ͬס   
	gstno		   int			default 1 	not null,   -- ���� 
	children		int			default 0	not null,	-- С�� 
--	rmreason	   char(1)		default ''	not null,	-- �������� 

	ratecode    char(10)    default '' 	not null,	-- ������  
	packages		varchar(50)		default ''	not null,	-- ����  
--	fixrate	   char(1)		default 'F'	not null,	-- �̶����� 
--	rmrate		money			default 0	not null,	-- ���䱨�� 
--	qtrate		money			default 0	not null,	-- Э�鷿�䱨�� 
	setrate		money			default 0	not null,	-- ���Żݼ��Ż�����һ�����ʵ�ʷ��� 
--	rtreason	   char(3)		default ''	not null,	-- �����Ż�����(cf.rtreason.dbf) 
--	discount	   money			default 0	not null,	-- �Żݶ� 
--	discount1	money			default 0	not null,	-- �Żݱ��� 
--	addbed	   money			default 0 	not null,	-- �Ӵ�����  
--	addbed_rate	money			default 0 	not null,	-- �Ӵ��� 
--	crib	   	money			default 0 	not null,	-- Ӥ�������� 
--	crib_rate	money			default 0 	not null,	-- Ӥ�����۸� 

	paycode		char(6)		default ''	not null,	-- ���㷽ʽ 
	limit		   money			default 0 	not null,	-- �޶�(������) 
	credcode		varchar(20)	default ''	not null,	-- ���ÿ����� 
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
--	applname    varchar(30)    			null,       -- ������/ί���� 
--	applicant	varchar(60)	default ''	not null,	-- ��λ/ί�е�λ 
	araccnt		varchar(7)	default ''	not null,	-- AR�ʺ�(��City ledger,travel agency������) 
--	phone    	varchar(16)    			null,       -- ��ϵ�绰�� 
--	fax    		varchar(16)    			null,       -- fax 
--	email    	varchar(30)    			null,       -- email 

	wherefrom	char(6)		default ''	not null,	-- �ε��� 
	whereto		char(6)		default ''	not null,	-- �ε�ȥ 
	purpose		char(3)		default ''	not null,	-- ���� 

	arrdate		datetime						null,			-- ������Ϣ 
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       -- �뿪��Ϣ 
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	-- ������Ϣ: 1-�����˻�  4-���� 5-���ܷ��� 
                                                   -- 6-�绰 7-vod 8-internet 9-walkin 10-lock 12-fixroom 

	charge		money			default 0	not null,
	credit 		money			default 0	not null,
	accredit		money			default 0	not null,	-- ���� 

	lastnumb	   int			default 0	not null,	-- account��number������ 
	lastinumb	int			default 0	not null,	-- account��inumber������ 

	srqs		   varchar(30)	default ''	not null,	-- ����Ҫ�� 
	amenities  	varchar(30)	default ''	not null,	-- ���䲼�� 
	master		char(10)		default ''	not null, 	-- �ͷ����� 
	saccnt		char(10)		default ''	not null, 	-- �������� 
	blkcode		char(10)		default ''	not null,	-- 
	pcrec			char(10)		default ''	not null, 	-- ���� 
	pcrec_pkg	char(10)		default ''	not null, 	-- ���� gaoliang 
	resno			varchar(10)	default ''	not null, 	-- Ԥ����� 
	crsno			varchar(20)	default ''	null, 		-- ��������Ԥ����� 
	ref			varchar(255)	default ''	null, 		-- comment 
	comsg			varchar(255)	default ''	null, 		-- c/o msg 
--	card			varchar(7)		default ''	not null,	-- ����� 
	saleid		varchar(10)		default ''	not null,	-- ����Ա 

	cmscode		varchar(10)		default ''	not null,	-- Ӷ���� 
	cardcode		varchar(10)		default ''	not null,	-- ��Ա������ 
	cardno		varchar(20)		default ''	not null,	-- ��Ա������ 

-- sales 
	contact		char(10)		default ''		not null,	-- ��ϵ��
	name			varchar(50)	default ''		null,			-- block name 
	name2			varchar(50)	default ''		null,
	blockcode	varchar(20)	default ''		not null,
	status		char(10)							not null,	
	btype			char(10)	default ''			not null,	-- business type 
	bscope		char(1)		default '0'		not null,	-- ҵ�񷶳� 0=blk+catering 1=blk 2=catering 
	potential	varchar(30)						null,
	saleid2		varchar(10)		default ''	not null,	-- ����Ա
	peakrms		int								null,		-- ����
	avrate		money								null,		-- ƽ������

	cutoff		datetime							null,
	follow		datetime							null,
	decision		datetime							null,
	rmlistdate	datetime							null,		-- room list date 
	currency		varchar(10)						null,		-- ����
	tracecode	varchar(30)						null,
	triggers		varchar(30)						null,
	
	porterage	char(1)		default 'F'		not null,	-- ��ͨ
	ptgrate		money 		default 0		not null,
	breakfast	char(1)		default 'F'		not null,	-- ���
	bfrate		money 		default 0		not null,
	bfdes			varchar(30)						null,


-- catering 
	c_status		char(10)	default ''		not null,	-- ���״̬
	c_attendees	int			default 0		not null,	-- ����
	c_guaranteed	char(3)	default 'F'		not null,	-- ��֤ for c_attendees
	c_infoboard	varchar(100)					null,			-- ����
	c_follow		datetime							null,
	c_decision	datetime							null,
	c_function	varchar(40)						null,			-- ��������
	c_contract	varchar(20)						null,			-- ��Լ���
	c_detailok	char(1)			default 'F'	not null,	-- ϸ����� ��
	c_distributed	char(1)		default 'F'	not null,	-- ��Ϣ�����ˣ�
	c_saleid		varchar(10)		default ''	not null,	-- ����Ա

	resby			char(10)		default ''	not null,	-- Ԥ��Ա��Ϣ 
	restime		datetime						null,			
	defby			char(10)		default ''	not null,	-- ȷ����Ϣ 
	deftime		datetime						null,			
	tfby			char(10)		default ''	not null,	-- to fo ��Ϣ 
	tftime		datetime						null,
	coby			char(10)		default ''	not null,	-- ����Ա��Ϣ 
	cotime		datetime						null,
	depby			char(10)		default ''	not null,	-- �˷�Ա��Ϣ 
	deptime		datetime						null,			

	cby			char(10)						not null,	-- �����޸�����Ϣ 
	changed		datetime						not null,	

-- Ԥ���ֶ�
	exp_m1		money							null,
	exp_m2		money							null,
	exp_m3		money							null,
	exp_m4		money							null,
	exp_dt1		datetime						null,
	exp_dt2		datetime						null,
	exp_dt3		datetime						null,
	exp_dt4		datetime						null,
	exp_s1		varchar(30)					null,
	exp_s2		varchar(30)					null,
	exp_s3		varchar(30)					null,
	exp_s4		varchar(30)					null,
	exp_s5		varchar(60)					null,
	exp_s6		varchar(100)				null,

	logmark     int    default 0 			not null
);
exec sp_primarykey sc_master_till,accnt
create unique index  sc_master_till on sc_master_till(accnt)
;


if exists(select * from sysobjects where name = "sc_master_last" and type="U")
	drop table sc_master_last;
create table sc_master_last
(
	accnt		   char(10)						not null,	-- �ʺ�:����(�����ɼ�˵����)  
	foact		   char(10)	default ''			not null,	-- block ״̬��1=��Դ 2=��ǰλ��  F=FO, S=SC 
	haccnt		char(7)		default '' 	not null,	-- ���͵�����  
--	groupno		char(10)		default '' 	not null,	-- �����ź�  
	type		   char(5)		default ''	not null,	-- ��������(cf. typim,block,pickup)  
   otype       char(5)     default ''	not null,  	-- ����ǰ�ķ�������  
--	up_type		char(5)     default ''	null,  		-- ���ĸ�������������  
--	up_reason	char(3)     default ''	not null,  	-- ����ԭ��  
	rmnum			int			default 0	not null,
--	ormnum		int			default 0	not null,
	roomno		char(5)		default ''	not null,  	-- ���� 
	oroomno     char(5)     default ''	not null,  	-- ����ǰ�ķ��� 
	bdate		   datetime	   				not null,	-- ��ס�����Ӫҵ����=business date 
	sta			char(1)						not null,   -- �ʺ�״̬(��˵����˵����) 
	osta        char(1)     default ''	not null,   -- ����ǰ���ʺ�״̬ 
--	ressta      char(1)     default ''	not null,   -- ����ʱ�����״̬,�����������ʲ��ָ���ԭ״̬ 
--	exp_sta		char(1)		default '' 	null,			--  ���巿�ķ���  										---
	sta_tm		char(1)		default '' 	not null,	-- �ʺ�״̬(������) 
--	rmpoststa	char(1)		default '' 	not null,	-- �����ֶ�:������ʱ�� 									---
--	rmposted	   char(1)		default "F"	not null,	-- ����ס�����Ƿ�������� 
	tag0		   char(1)		default '' 	null,
	arr			datetime	   				not null,	-- ��������=arrival 
	dep			datetime	   				not null,	-- �������=departure 
--   resdep      datetime    				null,       -- ����ʱ������뿪����,������������ 
	oarr        datetime    				null,
	odep        datetime    				null,

	agent			char(7)		default '' 	not null,
	cusno			char(7)		default '' 	not null,
	source		char(7)		default '' 	not null,

	class		   char(1)		default '' 	not null,	-- ���: F-fit, G-grp, M-meet, A-armst, C-House accounts
	src			char(3)		default '' 	not null,	-- ��Դ 
	market		char(3)		default '' 	not null,	-- �г��� 
	restype		char(3)		default '' 	not null,	-- Ԥ����� 
	channel		char(3)		default '' 	not null,	-- ���� 

--	artag1		char(3)		default '' 	not null,	-- ���� 
--	artag2		char(3)		default '' 	not null,	-- ���� 
	
--	share		   char(1)		default '' 	not null,	-- �Ƿ����ͬס   
	gstno		   int			default 1 	not null,   -- ���� 
	children		int			default 0	not null,	-- С�� 
--	rmreason	   char(1)		default ''	not null,	-- �������� 

	ratecode    char(10)    default '' 	not null,	-- ������  
	packages		varchar(50)		default ''	not null,	-- ����  
--	fixrate	   char(1)		default 'F'	not null,	-- �̶����� 
--	rmrate		money			default 0	not null,	-- ���䱨�� 
--	qtrate		money			default 0	not null,	-- Э�鷿�䱨�� 
	setrate		money			default 0	not null,	-- ���Żݼ��Ż�����һ�����ʵ�ʷ��� 
--	rtreason	   char(3)		default ''	not null,	-- �����Ż�����(cf.rtreason.dbf) 
--	discount	   money			default 0	not null,	-- �Żݶ� 
--	discount1	money			default 0	not null,	-- �Żݱ��� 
--	addbed	   money			default 0 	not null,	-- �Ӵ�����  
--	addbed_rate	money			default 0 	not null,	-- �Ӵ��� 
--	crib	   	money			default 0 	not null,	-- Ӥ�������� 
--	crib_rate	money			default 0 	not null,	-- Ӥ�����۸� 

	paycode		char(6)		default ''	not null,	-- ���㷽ʽ 
	limit		   money			default 0 	not null,	-- �޶�(������) 
	credcode		varchar(20)	default ''	not null,	-- ���ÿ����� 
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
--	applname    varchar(30)    			null,       -- ������/ί���� 
--	applicant	varchar(60)	default ''	not null,	-- ��λ/ί�е�λ 
	araccnt		varchar(7)	default ''	not null,	-- AR�ʺ�(��City ledger,travel agency������) 
--	phone    	varchar(16)    			null,       -- ��ϵ�绰�� 
--	fax    		varchar(16)    			null,       -- fax 
--	email    	varchar(30)    			null,       -- email 

	wherefrom	char(6)		default ''	not null,	-- �ε��� 
	whereto		char(6)		default ''	not null,	-- �ε�ȥ 
	purpose		char(3)		default ''	not null,	-- ���� 

	arrdate		datetime						null,			-- ������Ϣ 
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       -- �뿪��Ϣ 
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	-- ������Ϣ: 1-�����˻�  4-���� 5-���ܷ��� 
                                                   -- 6-�绰 7-vod 8-internet 9-walkin 10-lock 12-fixroom 

	charge		money			default 0	not null,
	credit 		money			default 0	not null,
	accredit		money			default 0	not null,	-- ���� 

	lastnumb	   int			default 0	not null,	-- account��number������ 
	lastinumb	int			default 0	not null,	-- account��inumber������ 

	srqs		   varchar(30)	default ''	not null,	-- ����Ҫ�� 
	amenities  	varchar(30)	default ''	not null,	-- ���䲼�� 
	master		char(10)		default ''	not null, 	-- �ͷ����� 
	saccnt		char(10)		default ''	not null, 	-- �������� 
	blkcode		char(10)		default ''	not null,	-- 
	pcrec			char(10)		default ''	not null, 	-- ���� 
	pcrec_pkg	char(10)		default ''	not null, 	-- ���� gaoliang 
	resno			varchar(10)	default ''	not null, 	-- Ԥ����� 
	crsno			varchar(20)	default ''	null, 		-- ��������Ԥ����� 
	ref			varchar(255)	default ''	null, 		-- comment 
	comsg			varchar(255)	default ''	null, 		-- c/o msg 
--	card			varchar(7)		default ''	not null,	-- ����� 
	saleid		varchar(10)		default ''	not null,	-- ����Ա 

	cmscode		varchar(10)		default ''	not null,	-- Ӷ���� 
	cardcode		varchar(10)		default ''	not null,	-- ��Ա������ 
	cardno		varchar(20)		default ''	not null,	-- ��Ա������ 

-- sales 
	contact		char(10)		default ''		not null,	-- ��ϵ��
	name			varchar(50)	default ''		null,			-- block name 
	name2			varchar(50)	default ''		null,
	blockcode	varchar(20)	default ''		not null,
	status		char(10)							not null,	
	btype			char(10)	default ''			not null,	-- business type 
	bscope		char(1)		default '0'		not null,	-- ҵ�񷶳� 0=blk+catering 1=blk 2=catering 
	potential	varchar(30)						null,
	saleid2		varchar(10)		default ''	not null,	-- ����Ա
	peakrms		int								null,		-- ����
	avrate		money								null,		-- ƽ������

	cutoff		datetime							null,
	follow		datetime							null,
	decision		datetime							null,
	rmlistdate	datetime							null,		-- room list date 
	currency		varchar(10)						null,		-- ����
	tracecode	varchar(30)						null,
	triggers		varchar(30)						null,
	
	porterage	char(1)		default 'F'		not null,	-- ��ͨ
	ptgrate		money 		default 0		not null,
	breakfast	char(1)		default 'F'		not null,	-- ���
	bfrate		money 		default 0		not null,
	bfdes			varchar(30)						null,


-- catering 
	c_status		char(10)	default ''		not null,	-- ���״̬
	c_attendees	int			default 0		not null,	-- ����
	c_guaranteed	char(3)	default 'F'		not null,	-- ��֤ for c_attendees
	c_infoboard	varchar(100)					null,			-- ����
	c_follow		datetime							null,
	c_decision	datetime							null,
	c_function	varchar(40)						null,			-- ��������
	c_contract	varchar(20)						null,			-- ��Լ���
	c_detailok	char(1)			default 'F'	not null,	-- ϸ����� ��
	c_distributed	char(1)		default 'F'	not null,	-- ��Ϣ�����ˣ�
	c_saleid		varchar(10)		default ''	not null,	-- ����Ա

	resby			char(10)		default ''	not null,	-- Ԥ��Ա��Ϣ 
	restime		datetime						null,			
	defby			char(10)		default ''	not null,	-- ȷ����Ϣ 
	deftime		datetime						null,			
	tfby			char(10)		default ''	not null,	-- to fo ��Ϣ 
	tftime		datetime						null,
	coby			char(10)		default ''	not null,	-- ����Ա��Ϣ 
	cotime		datetime						null,
	depby			char(10)		default ''	not null,	-- �˷�Ա��Ϣ 
	deptime		datetime						null,			

	cby			char(10)						not null,	-- �����޸�����Ϣ 
	changed		datetime						not null,	

-- Ԥ���ֶ�
	exp_m1		money							null,
	exp_m2		money							null,
	exp_m3		money							null,
	exp_m4		money							null,
	exp_dt1		datetime						null,
	exp_dt2		datetime						null,
	exp_dt3		datetime						null,
	exp_dt4		datetime						null,
	exp_s1		varchar(30)					null,
	exp_s2		varchar(30)					null,
	exp_s3		varchar(30)					null,
	exp_s4		varchar(30)					null,
	exp_s5		varchar(60)					null,
	exp_s6		varchar(100)				null,

	logmark     int    default 0 			not null
);
exec sp_primarykey sc_master_last,accnt
create unique index  sc_master_last on sc_master_last(accnt)
;


if exists(select * from sysobjects where name = "sc_master_log" and type="U")
	drop table sc_master_log;
create table sc_master_log
(
	accnt		   char(10)						not null,	-- �ʺ�:����(�����ɼ�˵����)  
	foact		   char(10)	default ''			not null,	-- block ״̬��1=��Դ 2=��ǰλ��  F=FO, S=SC 
	haccnt		char(7)		default '' 	not null,	-- ���͵�����  
--	groupno		char(10)		default '' 	not null,	-- �����ź�  
	type		   char(5)		default ''	not null,	-- ��������(cf. typim,block,pickup)  
   otype       char(5)     default ''	not null,  	-- ����ǰ�ķ�������  
--	up_type		char(5)     default ''	null,  		-- ���ĸ�������������  
--	up_reason	char(3)     default ''	not null,  	-- ����ԭ��  
	rmnum			int			default 0	not null,
--	ormnum		int			default 0	not null,
	roomno		char(5)		default ''	not null,  	-- ���� 
	oroomno     char(5)     default ''	not null,  	-- ����ǰ�ķ��� 
	bdate		   datetime	   				not null,	-- ��ס�����Ӫҵ����=business date 
	sta			char(1)						not null,   -- �ʺ�״̬(��˵����˵����) 
	osta        char(1)     default ''	not null,   -- ����ǰ���ʺ�״̬ 
--	ressta      char(1)     default ''	not null,   -- ����ʱ�����״̬,�����������ʲ��ָ���ԭ״̬ 
--	exp_sta		char(1)		default '' 	null,			--  ���巿�ķ���  										---
	sta_tm		char(1)		default '' 	not null,	-- �ʺ�״̬(������) 
--	rmpoststa	char(1)		default '' 	not null,	-- �����ֶ�:������ʱ�� 									---
--	rmposted	   char(1)		default "F"	not null,	-- ����ס�����Ƿ�������� 
	tag0		   char(1)		default '' 	null,
	arr			datetime	   				not null,	-- ��������=arrival 
	dep			datetime	   				not null,	-- �������=departure 
--   resdep      datetime    				null,       -- ����ʱ������뿪����,������������ 
	oarr        datetime    				null,
	odep        datetime    				null,

	agent			char(7)		default '' 	not null,
	cusno			char(7)		default '' 	not null,
	source		char(7)		default '' 	not null,

	class		   char(1)		default '' 	not null,	-- ���: F-fit, G-grp, M-meet, A-armst, C-House accounts
	src			char(3)		default '' 	not null,	-- ��Դ 
	market		char(3)		default '' 	not null,	-- �г��� 
	restype		char(3)		default '' 	not null,	-- Ԥ����� 
	channel		char(3)		default '' 	not null,	-- ���� 

--	artag1		char(3)		default '' 	not null,	-- ���� 
--	artag2		char(3)		default '' 	not null,	-- ���� 
	
--	share		   char(1)		default '' 	not null,	-- �Ƿ����ͬס   
	gstno		   int			default 1 	not null,   -- ���� 
	children		int			default 0	not null,	-- С�� 
--	rmreason	   char(1)		default ''	not null,	-- �������� 

	ratecode    char(10)    default '' 	not null,	-- ������  
	packages		varchar(50)		default ''	not null,	-- ����  
--	fixrate	   char(1)		default 'F'	not null,	-- �̶����� 
--	rmrate		money			default 0	not null,	-- ���䱨�� 
--	qtrate		money			default 0	not null,	-- Э�鷿�䱨�� 
	setrate		money			default 0	not null,	-- ���Żݼ��Ż�����һ�����ʵ�ʷ��� 
--	rtreason	   char(3)		default ''	not null,	-- �����Ż�����(cf.rtreason.dbf) 
--	discount	   money			default 0	not null,	-- �Żݶ� 
--	discount1	money			default 0	not null,	-- �Żݱ��� 
--	addbed	   money			default 0 	not null,	-- �Ӵ�����  
--	addbed_rate	money			default 0 	not null,	-- �Ӵ��� 
--	crib	   	money			default 0 	not null,	-- Ӥ�������� 
--	crib_rate	money			default 0 	not null,	-- Ӥ�����۸� 

	paycode		char(6)		default ''	not null,	-- ���㷽ʽ 
	limit		   money			default 0 	not null,	-- �޶�(������) 
	credcode		varchar(20)	default ''	not null,	-- ���ÿ����� 
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
--	applname    varchar(30)    			null,       -- ������/ί���� 
--	applicant	varchar(60)	default ''	not null,	-- ��λ/ί�е�λ 
	araccnt		varchar(7)	default ''	not null,	-- AR�ʺ�(��City ledger,travel agency������) 
--	phone    	varchar(16)    			null,       -- ��ϵ�绰�� 
--	fax    		varchar(16)    			null,       -- fax 
--	email    	varchar(30)    			null,       -- email 

	wherefrom	char(6)		default ''	not null,	-- �ε��� 
	whereto		char(6)		default ''	not null,	-- �ε�ȥ 
	purpose		char(3)		default ''	not null,	-- ���� 

	arrdate		datetime						null,			-- ������Ϣ 
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       -- �뿪��Ϣ 
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	-- ������Ϣ: 1-�����˻�  4-���� 5-���ܷ��� 
                                                   -- 6-�绰 7-vod 8-internet 9-walkin 10-lock 12-fixroom 

	charge		money			default 0	not null,
	credit 		money			default 0	not null,
	accredit		money			default 0	not null,	-- ���� 

	lastnumb	   int			default 0	not null,	-- account��number������ 
	lastinumb	int			default 0	not null,	-- account��inumber������ 

	srqs		   varchar(30)	default ''	not null,	-- ����Ҫ�� 
	amenities  	varchar(30)	default ''	not null,	-- ���䲼�� 
	master		char(10)		default ''	not null, 	-- �ͷ����� 
	saccnt		char(10)		default ''	not null, 	-- �������� 
	blkcode		char(10)		default ''	not null,	-- 
	pcrec			char(10)		default ''	not null, 	-- ���� 
	pcrec_pkg	char(10)		default ''	not null, 	-- ���� gaoliang 
	resno			varchar(10)	default ''	not null, 	-- Ԥ����� 
	crsno			varchar(20)	default ''	null, 		-- ��������Ԥ����� 
	ref			varchar(255)	default ''	null, 		-- comment 
	comsg			varchar(255)	default ''	null, 		-- c/o msg 
--	card			varchar(7)		default ''	not null,	-- ����� 
	saleid		varchar(10)		default ''	not null,	-- ����Ա 

	cmscode		varchar(10)		default ''	not null,	-- Ӷ���� 
	cardcode		varchar(10)		default ''	not null,	-- ��Ա������ 
	cardno		varchar(20)		default ''	not null,	-- ��Ա������ 

-- sales 
	contact		char(10)		default ''		not null,	-- ��ϵ��
	name			varchar(50)	default ''		null,			-- block name 
	name2			varchar(50)	default ''		null,
	blockcode	varchar(20)	default ''		not null,
	status		char(10)							not null,	
	btype			char(10)	default ''			not null,	-- business type 
	bscope		char(1)		default '0'		not null,	-- ҵ�񷶳� 0=blk+catering 1=blk 2=catering 
	potential	varchar(30)						null,
	saleid2		varchar(10)		default ''	not null,	-- ����Ա
	peakrms		int								null,		-- ����
	avrate		money								null,		-- ƽ������

	cutoff		datetime							null,
	follow		datetime							null,
	decision		datetime							null,
	rmlistdate	datetime							null,		-- room list date 
	currency		varchar(10)						null,		-- ����
	tracecode	varchar(30)						null,
	triggers		varchar(30)						null,
	
	porterage	char(1)		default 'F'		not null,	-- ��ͨ
	ptgrate		money 		default 0		not null,
	breakfast	char(1)		default 'F'		not null,	-- ���
	bfrate		money 		default 0		not null,
	bfdes			varchar(30)						null,


-- catering 
	c_status		char(10)	default ''		not null,	-- ���״̬
	c_attendees	int			default 0		not null,	-- ����
	c_guaranteed	char(3)	default 'F'		not null,	-- ��֤ for c_attendees
	c_infoboard	varchar(100)					null,			-- ����
	c_follow		datetime							null,
	c_decision	datetime							null,
	c_function	varchar(40)						null,			-- ��������
	c_contract	varchar(20)						null,			-- ��Լ���
	c_detailok	char(1)			default 'F'	not null,	-- ϸ����� ��
	c_distributed	char(1)		default 'F'	not null,	-- ��Ϣ�����ˣ�
	c_saleid		varchar(10)		default ''	not null,	-- ����Ա

	resby			char(10)		default ''	not null,	-- Ԥ��Ա��Ϣ 
	restime		datetime						null,			
	defby			char(10)		default ''	not null,	-- ȷ����Ϣ 
	deftime		datetime						null,			
	tfby			char(10)		default ''	not null,	-- to fo ��Ϣ 
	tftime		datetime						null,
	coby			char(10)		default ''	not null,	-- ����Ա��Ϣ 
	cotime		datetime						null,
	depby			char(10)		default ''	not null,	-- �˷�Ա��Ϣ 
	deptime		datetime						null,			

	cby			char(10)						not null,	-- �����޸�����Ϣ 
	changed		datetime						not null,	

-- Ԥ���ֶ�
	exp_m1		money							null,
	exp_m2		money							null,
	exp_m3		money							null,
	exp_m4		money							null,
	exp_dt1		datetime						null,
	exp_dt2		datetime						null,
	exp_dt3		datetime						null,
	exp_dt4		datetime						null,
	exp_s1		varchar(30)					null,
	exp_s2		varchar(30)					null,
	exp_s3		varchar(30)					null,
	exp_s4		varchar(30)					null,
	exp_s5		varchar(60)					null,
	exp_s6		varchar(100)				null,

	logmark     int    default 0 			not null
);
exec sp_primarykey sc_master_log, accnt, logmark
create unique index sc_master_log on sc_master_log(accnt, logmark)
;


//--------------------------------------------------------------------------
//		sc_master_del  ɾ��
//--------------------------------------------------------------------------
if exists(select * from sysobjects where name = "sc_master_del" and type="U")
	drop table sc_master_del;
create table sc_master_del
(
	accnt		   char(10)						not null,	-- �ʺ�:����(�����ɼ�˵����)  
	foact		   char(10)	default ''			not null,	-- block ״̬��1=��Դ 2=��ǰλ��  F=FO, S=SC 
	haccnt		char(7)		default '' 	not null,	-- ���͵�����  
--	groupno		char(10)		default '' 	not null,	-- �����ź�  
	type		   char(5)		default ''	not null,	-- ��������(cf. typim,block,pickup)  
   otype       char(5)     default ''	not null,  	-- ����ǰ�ķ�������  
--	up_type		char(5)     default ''	null,  		-- ���ĸ�������������  
--	up_reason	char(3)     default ''	not null,  	-- ����ԭ��  
	rmnum			int			default 0	not null,
--	ormnum		int			default 0	not null,
	roomno		char(5)		default ''	not null,  	-- ���� 
	oroomno     char(5)     default ''	not null,  	-- ����ǰ�ķ��� 
	bdate		   datetime	   				not null,	-- ��ס�����Ӫҵ����=business date 
	sta			char(1)						not null,   -- �ʺ�״̬(��˵����˵����) 
	osta        char(1)     default ''	not null,   -- ����ǰ���ʺ�״̬ 
--	ressta      char(1)     default ''	not null,   -- ����ʱ�����״̬,�����������ʲ��ָ���ԭ״̬ 
--	exp_sta		char(1)		default '' 	null,			--  ���巿�ķ���  										---
	sta_tm		char(1)		default '' 	not null,	-- �ʺ�״̬(������) 
--	rmpoststa	char(1)		default '' 	not null,	-- �����ֶ�:������ʱ�� 									---
--	rmposted	   char(1)		default "F"	not null,	-- ����ס�����Ƿ�������� 
	tag0		   char(1)		default '' 	null,
	arr			datetime	   				not null,	-- ��������=arrival 
	dep			datetime	   				not null,	-- �������=departure 
--   resdep      datetime    				null,       -- ����ʱ������뿪����,������������ 
	oarr        datetime    				null,
	odep        datetime    				null,

	agent			char(7)		default '' 	not null,
	cusno			char(7)		default '' 	not null,
	source		char(7)		default '' 	not null,

	class		   char(1)		default '' 	not null,	-- ���: F-fit, G-grp, M-meet, A-armst, C-House accounts
	src			char(3)		default '' 	not null,	-- ��Դ 
	market		char(3)		default '' 	not null,	-- �г��� 
	restype		char(3)		default '' 	not null,	-- Ԥ����� 
	channel		char(3)		default '' 	not null,	-- ���� 

--	artag1		char(3)		default '' 	not null,	-- ���� 
--	artag2		char(3)		default '' 	not null,	-- ���� 
	
--	share		   char(1)		default '' 	not null,	-- �Ƿ����ͬס   
	gstno		   int			default 1 	not null,   -- ���� 
	children		int			default 0	not null,	-- С�� 
--	rmreason	   char(1)		default ''	not null,	-- �������� 

	ratecode    char(10)    default '' 	not null,	-- ������  
	packages		varchar(50)		default ''	not null,	-- ����  
--	fixrate	   char(1)		default 'F'	not null,	-- �̶����� 
--	rmrate		money			default 0	not null,	-- ���䱨�� 
--	qtrate		money			default 0	not null,	-- Э�鷿�䱨�� 
	setrate		money			default 0	not null,	-- ���Żݼ��Ż�����һ�����ʵ�ʷ��� 
--	rtreason	   char(3)		default ''	not null,	-- �����Ż�����(cf.rtreason.dbf) 
--	discount	   money			default 0	not null,	-- �Żݶ� 
--	discount1	money			default 0	not null,	-- �Żݱ��� 
--	addbed	   money			default 0 	not null,	-- �Ӵ�����  
--	addbed_rate	money			default 0 	not null,	-- �Ӵ��� 
--	crib	   	money			default 0 	not null,	-- Ӥ�������� 
--	crib_rate	money			default 0 	not null,	-- Ӥ�����۸� 

	paycode		char(6)		default ''	not null,	-- ���㷽ʽ 
	limit		   money			default 0 	not null,	-- �޶�(������) 
	credcode		varchar(20)	default ''	not null,	-- ���ÿ����� 
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
--	applname    varchar(30)    			null,       -- ������/ί���� 
--	applicant	varchar(60)	default ''	not null,	-- ��λ/ί�е�λ 
	araccnt		varchar(7)	default ''	not null,	-- AR�ʺ�(��City ledger,travel agency������) 
--	phone    	varchar(16)    			null,       -- ��ϵ�绰�� 
--	fax    		varchar(16)    			null,       -- fax 
--	email    	varchar(30)    			null,       -- email 

	wherefrom	char(6)		default ''	not null,	-- �ε��� 
	whereto		char(6)		default ''	not null,	-- �ε�ȥ 
	purpose		char(3)		default ''	not null,	-- ���� 

	arrdate		datetime						null,			-- ������Ϣ 
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       -- �뿪��Ϣ 
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	-- ������Ϣ: 1-�����˻�  4-���� 5-���ܷ��� 
                                                   -- 6-�绰 7-vod 8-internet 9-walkin 10-lock 12-fixroom 

	charge		money			default 0	not null,
	credit 		money			default 0	not null,
	accredit		money			default 0	not null,	-- ���� 

	lastnumb	   int			default 0	not null,	-- account��number������ 
	lastinumb	int			default 0	not null,	-- account��inumber������ 

	srqs		   varchar(30)	default ''	not null,	-- ����Ҫ�� 
	amenities  	varchar(30)	default ''	not null,	-- ���䲼�� 
	master		char(10)		default ''	not null, 	-- �ͷ����� 
	saccnt		char(10)		default ''	not null, 	-- �������� 
	blkcode		char(10)		default ''	not null,	-- 
	pcrec			char(10)		default ''	not null, 	-- ���� 
	pcrec_pkg	char(10)		default ''	not null, 	-- ���� gaoliang 
	resno			varchar(10)	default ''	not null, 	-- Ԥ����� 
	crsno			varchar(20)	default ''	null, 		-- ��������Ԥ����� 
	ref			varchar(255)	default ''	null, 		-- comment 
	comsg			varchar(255)	default ''	null, 		-- c/o msg 
--	card			varchar(7)		default ''	not null,	-- ����� 
	saleid		varchar(10)		default ''	not null,	-- ����Ա 

	cmscode		varchar(10)		default ''	not null,	-- Ӷ���� 
	cardcode		varchar(10)		default ''	not null,	-- ��Ա������ 
	cardno		varchar(20)		default ''	not null,	-- ��Ա������ 

-- sales 
	contact		char(10)		default ''		not null,	-- ��ϵ��
	name			varchar(50)	default ''		null,			-- block name 
	name2			varchar(50)	default ''		null,
	blockcode	varchar(20)	default ''		not null,
	status		char(10)							not null,	
	btype			char(10)	default ''			not null,	-- business type 
	bscope		char(1)		default '0'		not null,	-- ҵ�񷶳� 0=blk+catering 1=blk 2=catering 
	potential	varchar(30)						null,
	saleid2		varchar(10)		default ''	not null,	-- ����Ա
	peakrms		int								null,		-- ����
	avrate		money								null,		-- ƽ������

	cutoff		datetime							null,
	follow		datetime							null,
	decision		datetime							null,
	rmlistdate	datetime							null,		-- room list date 
	currency		varchar(10)						null,		-- ����
	tracecode	varchar(30)						null,
	triggers		varchar(30)						null,
	
	porterage	char(1)		default 'F'		not null,	-- ��ͨ
	ptgrate		money 		default 0		not null,
	breakfast	char(1)		default 'F'		not null,	-- ���
	bfrate		money 		default 0		not null,
	bfdes			varchar(30)						null,


-- catering 
	c_status		char(10)	default ''		not null,	-- ���״̬
	c_attendees	int			default 0		not null,	-- ����
	c_guaranteed	char(3)	default 'F'		not null,	-- ��֤ for c_attendees
	c_infoboard	varchar(100)					null,			-- ����
	c_follow		datetime							null,
	c_decision	datetime							null,
	c_function	varchar(40)						null,			-- ��������
	c_contract	varchar(20)						null,			-- ��Լ���
	c_detailok	char(1)			default 'F'	not null,	-- ϸ����� ��
	c_distributed	char(1)		default 'F'	not null,	-- ��Ϣ�����ˣ�
	c_saleid		varchar(10)		default ''	not null,	-- ����Ա

	resby			char(10)		default ''	not null,	-- Ԥ��Ա��Ϣ 
	restime		datetime						null,			
	defby			char(10)		default ''	not null,	-- ȷ����Ϣ 
	deftime		datetime						null,			
	tfby			char(10)		default ''	not null,	-- to fo ��Ϣ 
	tftime		datetime						null,
	coby			char(10)		default ''	not null,	-- ����Ա��Ϣ 
	cotime		datetime						null,
	depby			char(10)		default ''	not null,	-- �˷�Ա��Ϣ 
	deptime		datetime						null,			

	cby			char(10)						not null,	-- �����޸�����Ϣ 
	changed		datetime						not null,	

-- Ԥ���ֶ�
	exp_m1		money							null,
	exp_m2		money							null,
	exp_m3		money							null,
	exp_m4		money							null,
	exp_dt1		datetime						null,
	exp_dt2		datetime						null,
	exp_dt3		datetime						null,
	exp_dt4		datetime						null,
	exp_s1		varchar(30)					null,
	exp_s2		varchar(30)					null,
	exp_s3		varchar(30)					null,
	exp_s4		varchar(30)					null,
	exp_s5		varchar(60)					null,
	exp_s6		varchar(100)				null,

	logmark     int    default 0 			not null
);
exec sp_primarykey sc_master_del,accnt
create unique index  sc_master_del on sc_master_del(accnt)
;


if exists(select * from sysobjects where name = "sc_hmaster" and type="U")
	drop table sc_hmaster;
create table sc_hmaster
(
	accnt		   char(10)						not null,	-- �ʺ�:����(�����ɼ�˵����)  
	foact		   char(10)	default ''			not null,	-- block ״̬��1=��Դ 2=��ǰλ��  F=FO, S=SC 
	haccnt		char(7)		default '' 	not null,	-- ���͵�����  
--	groupno		char(10)		default '' 	not null,	-- �����ź�  
	type		   char(5)		default ''	not null,	-- ��������(cf. typim,block,pickup)  
   otype       char(5)     default ''	not null,  	-- ����ǰ�ķ�������  
--	up_type		char(5)     default ''	null,  		-- ���ĸ�������������  
--	up_reason	char(3)     default ''	not null,  	-- ����ԭ��  
	rmnum			int			default 0	not null,
--	ormnum		int			default 0	not null,
	roomno		char(5)		default ''	not null,  	-- ���� 
	oroomno     char(5)     default ''	not null,  	-- ����ǰ�ķ��� 
	bdate		   datetime	   				not null,	-- ��ס�����Ӫҵ����=business date 
	sta			char(1)						not null,   -- �ʺ�״̬(��˵����˵����) 
	osta        char(1)     default ''	not null,   -- ����ǰ���ʺ�״̬ 
--	ressta      char(1)     default ''	not null,   -- ����ʱ�����״̬,�����������ʲ��ָ���ԭ״̬ 
--	exp_sta		char(1)		default '' 	null,			--  ���巿�ķ���  										---
	sta_tm		char(1)		default '' 	not null,	-- �ʺ�״̬(������) 
--	rmpoststa	char(1)		default '' 	not null,	-- �����ֶ�:������ʱ�� 									---
--	rmposted	   char(1)		default "F"	not null,	-- ����ס�����Ƿ�������� 
	tag0		   char(1)		default '' 	null,
	arr			datetime	   				not null,	-- ��������=arrival 
	dep			datetime	   				not null,	-- �������=departure 
--   resdep      datetime    				null,       -- ����ʱ������뿪����,������������ 
	oarr        datetime    				null,
	odep        datetime    				null,

	agent			char(7)		default '' 	not null,
	cusno			char(7)		default '' 	not null,
	source		char(7)		default '' 	not null,

	class		   char(1)		default '' 	not null,	-- ���: F-fit, G-grp, M-meet, A-armst, C-House accounts
	src			char(3)		default '' 	not null,	-- ��Դ 
	market		char(3)		default '' 	not null,	-- �г��� 
	restype		char(3)		default '' 	not null,	-- Ԥ����� 
	channel		char(3)		default '' 	not null,	-- ���� 

--	artag1		char(3)		default '' 	not null,	-- ���� 
--	artag2		char(3)		default '' 	not null,	-- ���� 
	
--	share		   char(1)		default '' 	not null,	-- �Ƿ����ͬס   
	gstno		   int			default 1 	not null,   -- ���� 
	children		int			default 0	not null,	-- С�� 
--	rmreason	   char(1)		default ''	not null,	-- �������� 

	ratecode    char(10)    default '' 	not null,	-- ������  
	packages		varchar(50)		default ''	not null,	-- ����  
--	fixrate	   char(1)		default 'F'	not null,	-- �̶����� 
--	rmrate		money			default 0	not null,	-- ���䱨�� 
--	qtrate		money			default 0	not null,	-- Э�鷿�䱨�� 
	setrate		money			default 0	not null,	-- ���Żݼ��Ż�����һ�����ʵ�ʷ��� 
--	rtreason	   char(3)		default ''	not null,	-- �����Ż�����(cf.rtreason.dbf) 
--	discount	   money			default 0	not null,	-- �Żݶ� 
--	discount1	money			default 0	not null,	-- �Żݱ��� 
--	addbed	   money			default 0 	not null,	-- �Ӵ�����  
--	addbed_rate	money			default 0 	not null,	-- �Ӵ��� 
--	crib	   	money			default 0 	not null,	-- Ӥ�������� 
--	crib_rate	money			default 0 	not null,	-- Ӥ�����۸� 

	paycode		char(6)		default ''	not null,	-- ���㷽ʽ 
	limit		   money			default 0 	not null,	-- �޶�(������) 
	credcode		varchar(20)	default ''	not null,	-- ���ÿ����� 
	credman		varchar(20)					null,
	credunit		varchar(40)					null,
--	applname    varchar(30)    			null,       -- ������/ί���� 
--	applicant	varchar(60)	default ''	not null,	-- ��λ/ί�е�λ 
	araccnt		varchar(7)	default ''	not null,	-- AR�ʺ�(��City ledger,travel agency������) 
--	phone    	varchar(16)    			null,       -- ��ϵ�绰�� 
--	fax    		varchar(16)    			null,       -- fax 
--	email    	varchar(30)    			null,       -- email 

	wherefrom	char(6)		default ''	not null,	-- �ε��� 
	whereto		char(6)		default ''	not null,	-- �ε�ȥ 
	purpose		char(3)		default ''	not null,	-- ���� 

	arrdate		datetime						null,			-- ������Ϣ 
	arrinfo		varchar(30)					null,
	arrcar		varchar(10)					null,
	arrrate		money							null,
	depdate		datetime						null,       -- �뿪��Ϣ 
	depinfo		varchar(30)					null,
	depcar		varchar(10)					null,
	deprate		money							null,

	extra			char(30)		default ''	not null,	-- ������Ϣ: 1-�����˻�  4-���� 5-���ܷ��� 
                                                   -- 6-�绰 7-vod 8-internet 9-walkin 10-lock 12-fixroom 

	charge		money			default 0	not null,
	credit 		money			default 0	not null,
	accredit		money			default 0	not null,	-- ���� 

	lastnumb	   int			default 0	not null,	-- account��number������ 
	lastinumb	int			default 0	not null,	-- account��inumber������ 

	srqs		   varchar(30)	default ''	not null,	-- ����Ҫ�� 
	amenities  	varchar(30)	default ''	not null,	-- ���䲼�� 
	master		char(10)		default ''	not null, 	-- �ͷ����� 
	saccnt		char(10)		default ''	not null, 	-- �������� 
	blkcode		char(10)		default ''	not null,	-- 
	pcrec			char(10)		default ''	not null, 	-- ���� 
	pcrec_pkg	char(10)		default ''	not null, 	-- ���� gaoliang 
	resno			varchar(10)	default ''	not null, 	-- Ԥ����� 
	crsno			varchar(20)	default ''	null, 		-- ��������Ԥ����� 
	ref			varchar(255)	default ''	null, 		-- comment 
	comsg			varchar(255)	default ''	null, 		-- c/o msg 
--	card			varchar(7)		default ''	not null,	-- ����� 
	saleid		varchar(10)		default ''	not null,	-- ����Ա 

	cmscode		varchar(10)		default ''	not null,	-- Ӷ���� 
	cardcode		varchar(10)		default ''	not null,	-- ��Ա������ 
	cardno		varchar(20)		default ''	not null,	-- ��Ա������ 

-- sales 
	contact		char(10)		default ''		not null,	-- ��ϵ��
	name			varchar(50)	default ''		null,			-- block name 
	name2			varchar(50)	default ''		null,
	blockcode	varchar(20)	default ''		not null,
	status		char(10)							not null,	
	btype			char(10)	default ''			not null,	-- business type 
	bscope		char(1)		default '0'		not null,	-- ҵ�񷶳� 0=blk+catering 1=blk 2=catering 
	potential	varchar(30)						null,
	saleid2		varchar(10)		default ''	not null,	-- ����Ա
	peakrms		int								null,		-- ����
	avrate		money								null,		-- ƽ������

	cutoff		datetime							null,
	follow		datetime							null,
	decision		datetime							null,
	rmlistdate	datetime							null,		-- room list date 
	currency		varchar(10)						null,		-- ����
	tracecode	varchar(30)						null,
	triggers		varchar(30)						null,
	
	porterage	char(1)		default 'F'		not null,	-- ��ͨ
	ptgrate		money 		default 0		not null,
	breakfast	char(1)		default 'F'		not null,	-- ���
	bfrate		money 		default 0		not null,
	bfdes			varchar(30)						null,


-- catering 
	c_status		char(10)	default ''		not null,	-- ���״̬
	c_attendees	int			default 0		not null,	-- ����
	c_guaranteed	char(3)	default 'F'		not null,	-- ��֤ for c_attendees
	c_infoboard	varchar(100)					null,			-- ����
	c_follow		datetime							null,
	c_decision	datetime							null,
	c_function	varchar(40)						null,			-- ��������
	c_contract	varchar(20)						null,			-- ��Լ���
	c_detailok	char(1)			default 'F'	not null,	-- ϸ����� ��
	c_distributed	char(1)		default 'F'	not null,	-- ��Ϣ�����ˣ�
	c_saleid		varchar(10)		default ''	not null,	-- ����Ա

	resby			char(10)		default ''	not null,	-- Ԥ��Ա��Ϣ 
	restime		datetime						null,			
	defby			char(10)		default ''	not null,	-- ȷ����Ϣ 
	deftime		datetime						null,			
	tfby			char(10)		default ''	not null,	-- to fo ��Ϣ 
	tftime		datetime						null,
	coby			char(10)		default ''	not null,	-- ����Ա��Ϣ 
	cotime		datetime						null,
	depby			char(10)		default ''	not null,	-- �˷�Ա��Ϣ 
	deptime		datetime						null,			

	cby			char(10)						not null,	-- �����޸�����Ϣ 
	changed		datetime						not null,	

-- Ԥ���ֶ�
	exp_m1		money							null,
	exp_m2		money							null,
	exp_m3		money							null,
	exp_m4		money							null,
	exp_dt1		datetime						null,
	exp_dt2		datetime						null,
	exp_dt3		datetime						null,
	exp_dt4		datetime						null,
	exp_s1		varchar(30)					null,
	exp_s2		varchar(30)					null,
	exp_s3		varchar(30)					null,
	exp_s4		varchar(30)					null,
	exp_s5		varchar(60)					null,
	exp_s6		varchar(100)				null,

	logmark     int    default 0 			not null
);
exec sp_primarykey sc_hmaster,accnt
create unique index  sc_hmaster on sc_hmaster(accnt)
create index  sta on sc_hmaster (sta, arr)
create index  arr on sc_hmaster (arr, sta)
create index  haccnt on sc_hmaster (haccnt, sta, arr)
create index  cusno on sc_hmaster (cusno, sta, arr)
create index  agent on sc_hmaster (agent, sta, arr)
create index  source on sc_hmaster (source, sta, arr)
create index  resby on sc_hmaster (resby)
create index  tfby on sc_hmaster (tfby)
create index  contact on sc_hmaster (contact,arr)
create index  saleid on sc_hmaster (saleid,arr)
create index  blockcode on sc_hmaster (blockcode)
;

