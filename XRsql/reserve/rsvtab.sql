-------------------------------------------------------------------
--		�ͷ���Դ������ر�
--
--		����
--			rsvsrc, rsvsaccnt, rsvtype, rsvroom, rsvdtl, grprate
--			rsvsrc_till, rsvsrc_last, rsvsrc_log, rsvsrc_cxl, rsvsrc_blkinit 
--
--		������
--			chktprm, rsvdtl_segment
-- 		rsvsrc_1, rsvsrc_2, linksaccnt 
--
--		������
--			master_hhung, master_hung
--			turnaway, turnawayh
--			qroom, gtype_inventory
-------------------------------------------------------------------

/* ����and/or������ϸ����ռ�ñ� -- ԭʼ��¼ 
	
	�ͷ�Ԥ�����ϵĴ��
	����ļ�¼�е��ж�Ӧ����Դ�������е�û�У���Ԥ������---- id ?

	ע�⣺������������Ψһ�����������޸ĵ�ʱ����������������޷��жϣ�

	����id : id=0, ��ʾ���˺ŵ�����Ԥ������ˣ����崿Ԥ���� id >0��ֻ�б����������� id=0 �� rsvsrc ��¼��
		id>0, ��ʾû�ж�Ӧ����������Ԥ����=��Ԥ������
		ͬʱ��id ������Ϊ����Ĺؼ��֣�
*/
if exists(select * from sysobjects where name = "rsvsrc" and type='U')
	drop table rsvsrc;
create table rsvsrc
(
   accnt     	char(10) 				not null,
	id				int		default 0	not null,	-- ��ţ�����ḻ
	type      	char(5) 					not null,
   roomno    	char(5) 	default ''	not null,
	blkmark   	char(1)	default ''	not null,
	blkcode		char(10)	default ''	not null,
	begin_    	datetime  				not null,		-- ������ʱ��
	end_      	datetime  				not null,
	quantity  	int		default 0	not null,
	gstno			int		default 0	not null,
	child			int		default 0	not null,
	rmrate		money		default 0	not null,
	rate			money		default 0	not null,
	rtreason		char(3) default ''	not null,			-- �Ż�����
	remark		varchar(50)	default ''	not null,
	saccnt		char(10) default ''	not null,			-- ������
	master		char(10) default ''	not null,			-- ͬס���˺�
	rateok		char(1)	default 'F'	not null,			-- �Ƿ��׼����۸�
	arr			datetime					not null,		-- ����ʱ��
	dep			datetime					not null,
	ratecode    char(10)    default '' 	not null,	/* ������  */
	src			char(3)		default '' 	not null,	/* ��Դ */
	market		char(3)		default '' 	not null,	/* �г��� */
	packages		varchar(50)		default ''	not null,	/* ����  */
	srqs		   varchar(30)	default ''	not null,	/* ����Ҫ�� */
	amenities  	varchar(30)	default ''	not null,	/* ���䲼�� */
	exp_m			money							null,
	exp_dt		datetime						null,
	exp_s1		varchar(20)					null,
	exp_s2		varchar(20)					null,
	cby			char(10)						null,
	changed		datetime						null,
	logmark		int		default 0		null
)
exec sp_primarykey rsvsrc,accnt,id;
create unique index index1 on rsvsrc(accnt,id);
-- create unique index index2 on rsvsrc(accnt,type,roomno,begin_,end_,quantity,gstno,rate,remark);
create index index3 on rsvsrc(roomno,accnt);
create index rsvsrc_saccnt on rsvsrc(saccnt);
create index rsvsrc_blkcode on rsvsrc(blkcode,type,begin_,end_,roomno);


-- ������
if exists(select * from sysobjects where name = "rsvsrc_till" and type='U')
	drop table rsvsrc_till;
create table rsvsrc_till
(
   accnt     	char(10) 				not null,
	id				int		default 0	not null,	-- ��ţ�����ḻ
	type      	char(5) 					not null,
   roomno    	char(5) 	default ''	not null,
	blkmark   	char(1)	default ''	not null,
	blkcode		char(10)	default ''	not null,
	begin_    	datetime  				not null,		-- ������ʱ��
	end_      	datetime  				not null,
	quantity  	int		default 0	not null,
	gstno			int		default 0	not null,
	child			int		default 0	not null,
	rmrate		money		default 0	not null,
	rate			money		default 0	not null,
	rtreason		char(3) default ''	not null,			-- �Ż�����
	remark		varchar(50)	default ''	not null,
	saccnt		char(10) default ''	not null,			-- ������
	master		char(10) default ''	not null,			-- ͬס���˺�
	rateok		char(1)	default 'F'	not null,			-- �Ƿ��׼����۸�
	arr			datetime					not null,		-- ����ʱ��
	dep			datetime					not null,
	ratecode    char(10)    default '' 	not null,	/* ������  */
	src			char(3)		default '' 	not null,	/* ��Դ */
	market		char(3)		default '' 	not null,	/* �г��� */
	packages		varchar(50)		default ''	not null,	/* ����  */
	srqs		   varchar(30)	default ''	not null,	/* ����Ҫ�� */
	amenities  	varchar(30)	default ''	not null,	/* ���䲼�� */
	exp_m			money							null,
	exp_dt		datetime						null,
	exp_s1		varchar(20)					null,
	exp_s2		varchar(20)					null,
	cby			char(10)						null,
	changed		datetime						null,
	logmark		int		default 0		null
)
exec sp_primarykey rsvsrc_till,accnt,id;
create unique index index1 on rsvsrc_till(accnt,id);
-- create unique index index2 on rsvsrc_till(accnt,type,roomno,begin_,end_,quantity,gstno,rate,remark);
create index index3 on rsvsrc_till(roomno,accnt);


-- ������
if exists(select * from sysobjects where name = "rsvsrc_last" and type='U')
	drop table rsvsrc_last;
create table rsvsrc_last
(
   accnt     	char(10) 				not null,
	id				int		default 0	not null,	-- ��ţ�����ḻ
	type      	char(5) 					not null,
   roomno    	char(5) 	default ''	not null,
	blkmark   	char(1)	default ''	not null,
	blkcode		char(10)	default ''	not null,
	begin_    	datetime  				not null,		-- ������ʱ��
	end_      	datetime  				not null,
	quantity  	int		default 0	not null,
	gstno			int		default 0	not null,
	child			int		default 0	not null,
	rmrate		money		default 0	not null,
	rate			money		default 0	not null,
	rtreason		char(3) default ''	not null,			-- �Ż�����
	remark		varchar(50)	default ''	not null,
	saccnt		char(10) default ''	not null,			-- ������
	master		char(10) default ''	not null,			-- ͬס���˺�
	rateok		char(1)	default 'F'	not null,			-- �Ƿ��׼����۸�
	arr			datetime					not null,		-- ����ʱ��
	dep			datetime					not null,
	ratecode    char(10)    default '' 	not null,	/* ������  */
	src			char(3)		default '' 	not null,	/* ��Դ */
	market		char(3)		default '' 	not null,	/* �г��� */
	packages		varchar(50)		default ''	not null,	/* ����  */
	srqs		   varchar(30)	default ''	not null,	/* ����Ҫ�� */
	amenities  	varchar(30)	default ''	not null,	/* ���䲼�� */
	exp_m			money							null,
	exp_dt		datetime						null,
	exp_s1		varchar(20)					null,
	exp_s2		varchar(20)					null,
	cby			char(10)						null,
	changed		datetime						null,
	logmark		int		default 0		null
)
exec sp_primarykey rsvsrc_last,accnt,id;
create unique index index1 on rsvsrc_last(accnt,id);
-- create unique index index2 on rsvsrc_last(accnt,type,roomno,begin_,end_,quantity,gstno,rate,remark);
create index index3 on rsvsrc_last(roomno,accnt);

-- ��־
if exists(select * from sysobjects where name = "rsvsrc_log" and type='U')
	drop table rsvsrc_log;
create table rsvsrc_log
(
   accnt     	char(10) 				not null,
	id				int		default 0	not null,	-- ��ţ�����ḻ
	type      	char(5) 					not null,
   roomno    	char(5) 	default ''	not null,
	blkmark   	char(1)	default ''	not null,
	blkcode		char(10)	default ''	not null,
	begin_    	datetime  				not null,		-- ������ʱ��
	end_      	datetime  				not null,
	quantity  	int		default 0	not null,
	gstno			int		default 0	not null,
	child			int		default 0	not null,
	rmrate		money		default 0	not null,
	rate			money		default 0	not null,
	rtreason		char(3) default ''	not null,			-- �Ż�����
	remark		varchar(50)	default ''	not null,
	saccnt		char(10) default ''	not null,			-- ������
	master		char(10) default ''	not null,			-- ͬס���˺�
	rateok		char(1)	default 'F'	not null,			-- �Ƿ��׼����۸�
	arr			datetime					not null,		-- ����ʱ��
	dep			datetime					not null,
	ratecode    char(10)    default '' 	not null,	/* ������  */
	src			char(3)		default '' 	not null,	/* ��Դ */
	market		char(3)		default '' 	not null,	/* �г��� */
	packages		varchar(50)		default ''	not null,	/* ����  */
	srqs		   varchar(30)	default ''	not null,	/* ����Ҫ�� */
	amenities  	varchar(30)	default ''	not null,	/* ���䲼�� */
	exp_m			money							null,
	exp_dt		datetime						null,
	exp_s1		varchar(20)					null,
	exp_s2		varchar(20)					null,
	cby			char(10)						null,
	changed		datetime						null,
	logmark		int		default 0		null
)
exec sp_primarykey rsvsrc_log,accnt,id,logmark;
create unique index index1 on rsvsrc_log(accnt,id,logmark);

-- rsvsrc_cxl ��¼����ȡ����NOSHOW����Դ  
if exists(select * from sysobjects where name = "rsvsrc_cxl" and type='U')
	drop table rsvsrc_cxl;
create table rsvsrc_cxl
(
   accnt     	char(10) 				not null,
	id				int		default 0	not null,	-- ��ţ�����ḻ
	type      	char(5) 					not null,
   roomno    	char(5) 	default ''	not null,
	blkmark   	char(1)	default ''	not null,
	blkcode		char(10)	default ''	not null,
	begin_    	datetime  				not null,		-- ������ʱ��
	end_      	datetime  				not null,
	quantity  	int		default 0	not null,
	gstno			int		default 0	not null,
	child			int		default 0	not null,
	rmrate		money		default 0	not null,
	rate			money		default 0	not null,
	rtreason		char(3) default ''	not null,			-- �Ż�����
	remark		varchar(50)	default ''	not null,
	saccnt		char(10) default ''	not null,			-- ������
	master		char(10) default ''	not null,			-- ͬס���˺�
	rateok		char(1)	default 'F'	not null,			-- �Ƿ��׼����۸�
	arr			datetime					not null,		-- ����ʱ��
	dep			datetime					not null,
	ratecode    char(10)    default '' 	not null,	/* ������  */
	src			char(3)		default '' 	not null,	/* ��Դ */
	market		char(3)		default '' 	not null,	/* �г��� */
	packages		varchar(50)		default ''	not null,	/* ����  */
	srqs		   varchar(30)	default ''	not null,	/* ����Ҫ�� */
	amenities  	varchar(30)	default ''	not null,	/* ���䲼�� */
	exp_m			money							null,
	exp_dt		datetime						null,
	exp_s1		varchar(20)					null,
	exp_s2		varchar(20)					null,
	cby			char(10)						null,
	changed		datetime						null,
	logmark		int		default 0		null
)
exec sp_primarykey rsvsrc_cxl,accnt,id;
create unique index index1 on rsvsrc_cxl(accnt,id);
-- create unique index index2 on rsvsrc_cxl(accnt,type,roomno,begin_,end_,quantity,gstno,rate,remark);

-- BLOCK ��ʼ�ͷ�ռ�� 
if exists(select * from sysobjects where name = "rsvsrc_blkinit" and type='U')
	drop table rsvsrc_blkinit;
create table rsvsrc_blkinit
(
   accnt     	char(10) 				not null,
	id				int		default 0	not null,	-- ��ţ�����ḻ
	type      	char(5) 					not null,
   roomno    	char(5) 	default ''	not null,
	blkmark   	char(1)	default ''	not null,
	blkcode		char(10)	default ''	not null,
	begin_    	datetime  				not null,		-- ������ʱ��
	end_      	datetime  				not null,
	quantity  	int		default 0	not null,
	gstno			int		default 0	not null,
	child			int		default 0	not null,
	rmrate		money		default 0	not null,
	rate			money		default 0	not null,
	rtreason		char(3) default ''	not null,			-- �Ż�����
	remark		varchar(50)	default ''	not null,
	saccnt		char(10) default ''	not null,			-- ������
	master		char(10) default ''	not null,			-- ͬס���˺�
	rateok		char(1)	default 'F'	not null,			-- �Ƿ��׼����۸�
	arr			datetime					not null,		-- ����ʱ��
	dep			datetime					not null,
	ratecode    char(10)    default '' 	not null,	/* ������  */
	src			char(3)		default '' 	not null,	/* ��Դ */
	market		char(3)		default '' 	not null,	/* �г��� */
	packages		varchar(50)		default ''	not null,	/* ����  */
	srqs		   varchar(30)	default ''	not null,	/* ����Ҫ�� */
	amenities  	varchar(30)	default ''	not null,	/* ���䲼�� */
	exp_m			money							null,
	exp_dt		datetime						null,
	exp_s1		varchar(20)					null,
	exp_s2		varchar(20)					null,
	cby			char(10)						null,
	changed		datetime						null,
	logmark		int		default 0		null
); 
-- exec sp_primarykey rsvsrc_blkinit,accnt,id;
-- create unique index index1 on rsvsrc_blkinit(accnt,id);
-- create unique index index2 on rsvsrc_blkinit(accnt,type,roomno,begin_,end_,quantity,gstno,rate,remark);
--create index index3 on rsvsrc_blkinit(roomno,accnt);
--create index rsvsrc_blkinit_saccnt on rsvsrc_blkinit(saccnt);
--create index rsvsrc_blkinit_blkcode on rsvsrc_blkinit(blkcode,type,begin_,end_,roomno);
create index rsvsrc_blkinit_blkcode on rsvsrc_blkinit(accnt,type,begin_);

/* ����������1 */
if exists(select * from sysobjects where name = "rsvsrc_1" and type='U')
	drop table rsvsrc_1;
create table rsvsrc_1
(
	host_id		varchar(30)		default '' 	not null,
   accnt     	char(10) 				not null,
	id				int		default 0	not null
)
exec sp_primarykey rsvsrc_1,host_id,accnt,id;
create unique index index1 on rsvsrc_1(host_id,accnt,id);


/* ����������2 */
if exists(select * from sysobjects where name = "rsvsrc_2" and type='U')
	drop table rsvsrc_2;
create table rsvsrc_2
(
	host_id		varchar(30)		default '' 	not null,
   accnt     	char(10) 				not null,
	id				int		default 0	not null
)
exec sp_primarykey rsvsrc_2,host_id,accnt,id;
create unique index index1 on rsvsrc_2(host_id,accnt,id);


/* ����������3 */
if exists(select * from sysobjects where name = "linksaccnt" and type='U')
	drop table linksaccnt;
create table linksaccnt
(
   host_id     varchar(30)		default ''	not null,
   saccnt     	char(10) 				not null
)
exec sp_primarykey linksaccnt,host_id,saccnt;
create unique index index1 on linksaccnt(host_id,saccnt);


/* ����������4  BLOCK Ӧ�� */
if exists(select * from sysobjects where name = "rsvsrc_blk" and type='U')
	drop table rsvsrc_blk;
create table rsvsrc_blk
(
	host_id		varchar(30)				not null,
	blkcode		char(10) 				not null,
	type			char(5) 					not null,
	date			datetime					not null,
	rmnum1		int		default 0	not null,	-- �仯ǰ
	rmnum2		int		default 0	not null,	-- �仯�� 
	rmnum			int		default 0	not null		-- ���� 
)
exec sp_primarykey rsvsrc_blk,host_id,blkcode,type,date;
create unique index index1 on rsvsrc_blk(host_id,blkcode,type,date);




/* ����and/or������ϸ����ռ�ñ� -- ԭʼ��¼�ϲ� 

saccnt: ��ʾͬסһ���ͷ��������˻�֮������ֹ�ϵ���Զ��ġ�
	�д�����ϵ�Ķ��������һ�� saccnt, ��ʹ��һ�����˺����һ������Ҳ����������棻
	rsvsaccnt �ǿͷ�Ԥ�����������ࡣ

saccnt ��һ���ѵ㣺û��ָ�����ŵ�����£���δ������ͬס��
���������ķ������ ��1����϶�û�� share��

�� master Ԥ�����ͷ���ʱ�򣬿����ж����Ӧ��saccnt;���ֹ�ϵ�� rsvsrc �����֣�

saccnt �˺ŵĲ������ö����ķ�ʽ

*/
if exists(select * from sysobjects where name = "rsvsaccnt" and type='U')
	drop table rsvsaccnt;
create table rsvsaccnt
(
   saccnt     	char(10) 				not null,
	type      	char(5) 					not null,
   roomno    	char(5) 	default ''	not null,
	blkmark   	char(1)	default ''	not null,
	blkcode		char(10)	default ''	not null,
	begin_    	datetime  				not null,
	end_      	datetime  				not null,
	quantity  	int		default 0	not null,
	accnt			char(10)	default ''	not null		-- һ����־�Ե��˺ţ������ͷ���ռ�����ԣ�Ԥ�����ͣ�vip �ȵȣ�
)
exec sp_primarykey rsvsaccnt,saccnt;
create unique index index1 on rsvsaccnt(saccnt);
create unique index index2 on rsvsaccnt(saccnt,type,roomno,begin_);
create index index3 on rsvsaccnt(roomno,saccnt);



/* ��������ռ�ñ� */
if exists(select * from sysobjects where name = "rsvtype" and type='U')
	drop table rsvtype;
create table rsvtype
(
	type      char(5) not null,
	blkmark   char(1)    default ''  not null,
	blkcode	 char(10)	default ''	not null,
	begin_    datetime  not null,
	end_      datetime  not null,
	blockcnt  int       not null,
	blkcnt    int       not null,
	piccnt    int       not null
)
exec sp_primarykey rsvtype,type,begin_
create unique index rsvtype on rsvtype(type,begin_)
;

/* ��������ռ�ñ� */
if exists(select * from sysobjects where name = "rsvroom" and type='U')
	drop table rsvroom;
create table rsvroom
(
	type      char(5) not null,
   roomno    char(5) not null,
	blkmark   char(1)   default '' not null,
	blkcode		char(10)	default ''	not null,
	begin_    datetime  not null,
	end_      datetime  not null,
	quantity  int       not null,
)
exec sp_primarykey rsvroom,type,roomno,begin_
create unique index rsvroom on rsvroom(type,roomno,begin_)
;

/* ����and/or������ϸ����ռ�ñ� */
if exists(select * from sysobjects where name = "rsvdtl" and type='U')
	drop table rsvdtl;
create table rsvdtl
(
   accnt     char(10) not null,
	type      char(5) not null,
   roomno    char(5) not null,
	blkmark   char(1) default '' not null,
	blkcode		char(10)	default ''	not null,
	begin_    datetime  not null,
	end_      datetime  not null,
	quantity  int       not null,
)
exec sp_primarykey rsvdtl,accnt,type,roomno,begin_
create unique index rsvdtl on rsvdtl(accnt,type,roomno,begin_);
create index index2 on rsvdtl(roomno,accnt);

/*  �ַ������ź� */
if exists(select * from sysobjects where name = "chktprm" and type = 'U')
	drop table chktprm;
create table chktprm
(
	code		char(1)
)
;
insert chktprm values ('A')
;

/* Ԥ����ʱ��α� */
if exists(select * from sysobjects where name = "rsvdtl_segment")
   drop table rsvdtl_segment;
create table rsvdtl_segment
(
   pc_id    char(4),
   modu_id  char(2),
   type     char(5),
   begin_   datetime
)
exec sp_primarykey rsvdtl_segment,pc_id,modu_id,type,begin_
create unique index index1 on rsvdtl_segment(pc_id,modu_id,type,begin_)
;

-------------------------------------------------------------------------------
--	������� �������۶���
-------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "grprate" and type = 'U')
	drop table grprate;
create table grprate
(
	accnt		char(10)								not null,	   -- �ʺ�    
   type		char(5)								not null,	   -- ����    
	rate		money				   				not null,	   -- ����    
	oldrate	money				   				null,		      -- ԭ����  
	cby		char(10)								not null,      -- �޸���  
   changed	datetime		default getdate() not null,		-- �޸�����       
)
exec sp_primarykey grprate,accnt,type
create unique index index1 on grprate(accnt,type)
;


-------------------------------------------------------------------------------
-- 
--	�����������𡣰�������Ӧ�� = ȡ�� + Waitlist
--
-- һ���ʺſ����ж�μ�¼��������Ч��ֻ����һ��
-- 
-------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "master_hung" and type = 'U')
	drop table master_hung;
create table master_hung
(
	accnt		char(10)								not null,	   -- ��¼״̬
   sta		char(1)								not null,	   -- ״̬��Waitlist=W, Cancel=X
   status	char(1)		default 'I'			not null,	   -- ״̬ : I-��Ч, X-��Ч
   phone		varchar(20)	default ''			not null,	   -- �绰
   priority	char(1)		default ''			not null,	   -- ���ȼ�
	reason	char(3)								not null,
	remark	varchar(100) default ''			not null,
	crtby		char(10)		default ''			not null,      -- ����
   crttime	datetime		default getdate() not null			-- ��������       
)
exec sp_primarykey master_hung,crttime
create unique index index1 on master_hung(crttime)
create index index2 on master_hung(accnt,status)
create index index3 on master_hung(reason)
;

if exists(select * from sysobjects where name = "master_hhung" and type = 'U')
	drop table master_hhung;
create table master_hhung
(
	accnt		char(10)								not null,	   -- ��¼״̬
   sta		char(1)								not null,	   -- ״̬��Waitlist=W, Cancel=X
   status	char(1)		default 'I'			not null,	   -- ״̬ : I-��Ч, X-��Ч
   phone		varchar(20)	default ''			not null,	   -- �绰
   priority	char(1)		default ''			not null,	   -- ���ȼ�
	reason	char(3)								not null,
	remark	varchar(100) default ''			not null,
	crtby		char(10)		default ''			not null,      -- ����
   crttime	datetime		default getdate() not null			-- ��������       
)
exec sp_primarykey master_hhung,crttime
create unique index index1 on master_hhung(crttime)
create index index2 on master_hhung(accnt,status)
create index index3 on master_hhung(reason)
;


-------------------------------------------------------------------------------
--	������ѯ  ��� Trunaway 
-------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "turnaway" and type = 'U')
	drop table turnaway;
create table turnaway
(
	id			int			default 0			not null,
   sta		char(1)		default 'I'			not null,	   -- ״̬ : I-��Ч, T-Trunaway, X-ȡ��, O-����Ԥ��
	arr		datetime								not null,
	days		int			default 0			not null,
	type		varchar(20)	default ''			not null,	   -- ����
	rmnum		int			default 0			not null,
	gstno		int			default 0			not null,
	market	char(3)		default ''			not null,	   -- �г���
   phone		varchar(20)	default ''			not null,	   -- �绰
	reason	char(1)								not null,
	remark	text 			default ''			not null,
	haccnt	char(7)		default ''			not null,      -- profile
	name		varchar(60)	default ''			not null,      -- Name
	accnt		char(10)		default ''			not null,		-- Ԥ�������ɵ��˺�
	crtby		char(10)		default ''			not null,      -- ����
   crttime	datetime		default getdate() not null,		-- ��������       
	cby		char(10)		default ''			not null,      -- �޸���  
   changed	datetime		default getdate() not null			-- �޸�����       
)
exec sp_primarykey turnaway,id
create unique index index1 on turnaway(id)
create index index2 on turnaway(reason)
create index index3 on turnaway(haccnt)
create index index4 on turnaway(arr)
create index index5 on turnaway(crttime)
;


-------------------------------------------------------------------------------
--	������ѯ  ��� Trunaway  (��ʷ��¼)
-------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "turnawayh" and type = 'U')
	drop table turnawayh;
create table turnawayh
(
	id			int			default 0			not null,
   sta		char(1)		default 'I'			not null,	   -- ״̬ : I-��Ч, T-Trunaway, X-ȡ��, O-����Ԥ��
	arr		datetime								not null,
	days		int			default 0			not null,
	type		varchar(20)	default ''			not null,	   -- ����
	rmnum		int			default 0			not null,
	gstno		int			default 0			not null,
	market	char(3)		default ''			not null,	   -- �г���
   phone		varchar(20)	default ''			not null,	   -- �绰
	reason	char(1)								not null,
	remark	text 			default ''			not null,
	haccnt	char(7)		default ''			not null,      -- profile
	name		varchar(60)	default ''			not null,      -- Name
	accnt		char(10)		default ''			not null,		-- Ԥ�������ɵ��˺�
	crtby		char(10)		default ''			not null,      -- ����
   crttime	datetime		default getdate() not null,		-- ��������       
	cby		char(10)		default ''			not null,      -- �޸���  
   changed	datetime		default getdate() not null			-- �޸�����       
)
exec sp_primarykey turnawayh,id
create unique index index1 on turnawayh(id)
create index index2 on turnawayh(reason)
create index index3 on turnawayh(haccnt)
create index index4 on turnawayh(arr)
create index index5 on turnawayh(crttime)
;

-------------------------------------------------------------------------------
--	Q-room
-------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "qroom" and type = 'U')
	drop table qroom;
create table qroom
(
	id			int			default 0			not null,
	status	char(1)		default 'I'			not null,	   -- accnt ״̬
	accnt		char(10)								not null,
   sta		char(1)		default 'I'			not null,	   -- accnt ״̬
	arr		datetime								not null,
	roomno	char(5)								not null,
	haccnt	char(10)								not null,
	crtby		char(10)		default ''			not null,      -- ����
   crttime	datetime		default getdate() not null,		-- ��������       
	cby		char(10)		default ''			not null,      -- �޸�
   changed	datetime		default 				null				
)
exec sp_primarykey qroom,id
create unique index index1 on qroom(id)
create index index2 on qroom(roomno)
create index index3 on qroom(crtby)
create index index4 on qroom(accnt, status)
;


--------------------------------------------------------------------------
--		rsvsrc update trigger
--------------------------------------------------------------------------
if exists(select 1 from sysobjects where name='t_gds_rsvsrc_update' and type='TR')
	drop trigger t_gds_rsvsrc_update
;
create trigger t_gds_rsvsrc_update
   on rsvsrc
   for update 
as
if update(logmark)  -- ��¼��־
   insert rsvsrc_log select * from inserted
return 
;


--------------------------------------------------------------------------
--		
--------------------------------------------------------------------------
IF OBJECT_ID('gtype_inventory') IS NOT NULL
    DROP TABLE gtype_inventory
;
CREATE TABLE gtype_inventory 
(
    modu_id    char(2)  NOT NULL,
    pc_id      char(4)  NOT NULL,
    date       datetime NOT NULL,
    weekday    int      NOT NULL,
    type       char(5)  NOT NULL,
    quantity   int      DEFAULT 0 NOT NULL,
    adjquan    int      DEFAULT 0 NOT NULL,
    overquan   int      DEFAULT 0 NOT NULL,
    lockedquan int      DEFAULT 0 NOT NULL,
    rsvquan    int      DEFAULT 0 NOT NULL
)
EXEC sp_primarykey 'gtype_inventory', modu_id,pc_id,date,type;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON gtype_inventory(modu_id,pc_id,date,type)
;