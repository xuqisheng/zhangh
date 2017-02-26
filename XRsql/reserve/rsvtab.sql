-------------------------------------------------------------------
--		客房资源管理相关表
--
--		主表
--			rsvsrc, rsvsaccnt, rsvtype, rsvroom, rsvdtl, grprate
--			rsvsrc_till, rsvsrc_last, rsvsrc_log, rsvsrc_cxl, rsvsrc_blkinit 
--
--		辅助表
--			chktprm, rsvdtl_segment
-- 		rsvsrc_1, rsvsrc_2, linksaccnt 
--
--		其他表
--			master_hhung, master_hung
--			turnaway, turnawayh
--			qroom, gtype_inventory
-------------------------------------------------------------------

/* 房类and/or房间明细区间占用表 -- 原始记录 
	
	客房预留资料的存放
	这里的纪录有的有对应的资源主单；有的没有（纯预留）。---- id ?

	注意：这里有两个‘唯一索引’。在修改的时候必须这样，否则无法判断；

	关于id : id=0, 表示该账号的主单预留；因此，团体纯预留的 id >0，只有宾客主单才有 id=0 的 rsvsrc 纪录；
		id>0, 表示没有对应宾客主单的预留（=纯预留）；
		同时，id 还是作为排序的关键字；
*/
if exists(select * from sysobjects where name = "rsvsrc" and type='U')
	drop table rsvsrc;
create table rsvsrc
(
   accnt     	char(10) 				not null,
	id				int		default 0	not null,	-- 序号，含意丰富
	type      	char(5) 					not null,
   roomno    	char(5) 	default ''	not null,
	blkmark   	char(1)	default ''	not null,
	blkcode		char(10)	default ''	not null,
	begin_    	datetime  				not null,		-- 不包含时间
	end_      	datetime  				not null,
	quantity  	int		default 0	not null,
	gstno			int		default 0	not null,
	child			int		default 0	not null,
	rmrate		money		default 0	not null,
	rate			money		default 0	not null,
	rtreason		char(3) default ''	not null,			-- 优惠理由
	remark		varchar(50)	default ''	not null,
	saccnt		char(10) default ''	not null,			-- 共享标记
	master		char(10) default ''	not null,			-- 同住主账号
	rateok		char(1)	default 'F'	not null,			-- 是否核准共享价格
	arr			datetime					not null,		-- 包含时间
	dep			datetime					not null,
	ratecode    char(10)    default '' 	not null,	/* 房价码  */
	src			char(3)		default '' 	not null,	/* 来源 */
	market		char(3)		default '' 	not null,	/* 市场码 */
	packages		varchar(50)		default ''	not null,	/* 包价  */
	srqs		   varchar(30)	default ''	not null,	/* 特殊要求 */
	amenities  	varchar(30)	default ''	not null,	/* 房间布置 */
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


-- 报表用
if exists(select * from sysobjects where name = "rsvsrc_till" and type='U')
	drop table rsvsrc_till;
create table rsvsrc_till
(
   accnt     	char(10) 				not null,
	id				int		default 0	not null,	-- 序号，含意丰富
	type      	char(5) 					not null,
   roomno    	char(5) 	default ''	not null,
	blkmark   	char(1)	default ''	not null,
	blkcode		char(10)	default ''	not null,
	begin_    	datetime  				not null,		-- 不包含时间
	end_      	datetime  				not null,
	quantity  	int		default 0	not null,
	gstno			int		default 0	not null,
	child			int		default 0	not null,
	rmrate		money		default 0	not null,
	rate			money		default 0	not null,
	rtreason		char(3) default ''	not null,			-- 优惠理由
	remark		varchar(50)	default ''	not null,
	saccnt		char(10) default ''	not null,			-- 共享标记
	master		char(10) default ''	not null,			-- 同住主账号
	rateok		char(1)	default 'F'	not null,			-- 是否核准共享价格
	arr			datetime					not null,		-- 包含时间
	dep			datetime					not null,
	ratecode    char(10)    default '' 	not null,	/* 房价码  */
	src			char(3)		default '' 	not null,	/* 来源 */
	market		char(3)		default '' 	not null,	/* 市场码 */
	packages		varchar(50)		default ''	not null,	/* 包价  */
	srqs		   varchar(30)	default ''	not null,	/* 特殊要求 */
	amenities  	varchar(30)	default ''	not null,	/* 房间布置 */
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


-- 报表用
if exists(select * from sysobjects where name = "rsvsrc_last" and type='U')
	drop table rsvsrc_last;
create table rsvsrc_last
(
   accnt     	char(10) 				not null,
	id				int		default 0	not null,	-- 序号，含意丰富
	type      	char(5) 					not null,
   roomno    	char(5) 	default ''	not null,
	blkmark   	char(1)	default ''	not null,
	blkcode		char(10)	default ''	not null,
	begin_    	datetime  				not null,		-- 不包含时间
	end_      	datetime  				not null,
	quantity  	int		default 0	not null,
	gstno			int		default 0	not null,
	child			int		default 0	not null,
	rmrate		money		default 0	not null,
	rate			money		default 0	not null,
	rtreason		char(3) default ''	not null,			-- 优惠理由
	remark		varchar(50)	default ''	not null,
	saccnt		char(10) default ''	not null,			-- 共享标记
	master		char(10) default ''	not null,			-- 同住主账号
	rateok		char(1)	default 'F'	not null,			-- 是否核准共享价格
	arr			datetime					not null,		-- 包含时间
	dep			datetime					not null,
	ratecode    char(10)    default '' 	not null,	/* 房价码  */
	src			char(3)		default '' 	not null,	/* 来源 */
	market		char(3)		default '' 	not null,	/* 市场码 */
	packages		varchar(50)		default ''	not null,	/* 包价  */
	srqs		   varchar(30)	default ''	not null,	/* 特殊要求 */
	amenities  	varchar(30)	default ''	not null,	/* 房间布置 */
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

-- 日志
if exists(select * from sysobjects where name = "rsvsrc_log" and type='U')
	drop table rsvsrc_log;
create table rsvsrc_log
(
   accnt     	char(10) 				not null,
	id				int		default 0	not null,	-- 序号，含意丰富
	type      	char(5) 					not null,
   roomno    	char(5) 	default ''	not null,
	blkmark   	char(1)	default ''	not null,
	blkcode		char(10)	default ''	not null,
	begin_    	datetime  				not null,		-- 不包含时间
	end_      	datetime  				not null,
	quantity  	int		default 0	not null,
	gstno			int		default 0	not null,
	child			int		default 0	not null,
	rmrate		money		default 0	not null,
	rate			money		default 0	not null,
	rtreason		char(3) default ''	not null,			-- 优惠理由
	remark		varchar(50)	default ''	not null,
	saccnt		char(10) default ''	not null,			-- 共享标记
	master		char(10) default ''	not null,			-- 同住主账号
	rateok		char(1)	default 'F'	not null,			-- 是否核准共享价格
	arr			datetime					not null,		-- 包含时间
	dep			datetime					not null,
	ratecode    char(10)    default '' 	not null,	/* 房价码  */
	src			char(3)		default '' 	not null,	/* 来源 */
	market		char(3)		default '' 	not null,	/* 市场码 */
	packages		varchar(50)		default ''	not null,	/* 包价  */
	srqs		   varchar(30)	default ''	not null,	/* 特殊要求 */
	amenities  	varchar(30)	default ''	not null,	/* 房间布置 */
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

-- rsvsrc_cxl 记录团体取消或NOSHOW的资源  
if exists(select * from sysobjects where name = "rsvsrc_cxl" and type='U')
	drop table rsvsrc_cxl;
create table rsvsrc_cxl
(
   accnt     	char(10) 				not null,
	id				int		default 0	not null,	-- 序号，含意丰富
	type      	char(5) 					not null,
   roomno    	char(5) 	default ''	not null,
	blkmark   	char(1)	default ''	not null,
	blkcode		char(10)	default ''	not null,
	begin_    	datetime  				not null,		-- 不包含时间
	end_      	datetime  				not null,
	quantity  	int		default 0	not null,
	gstno			int		default 0	not null,
	child			int		default 0	not null,
	rmrate		money		default 0	not null,
	rate			money		default 0	not null,
	rtreason		char(3) default ''	not null,			-- 优惠理由
	remark		varchar(50)	default ''	not null,
	saccnt		char(10) default ''	not null,			-- 共享标记
	master		char(10) default ''	not null,			-- 同住主账号
	rateok		char(1)	default 'F'	not null,			-- 是否核准共享价格
	arr			datetime					not null,		-- 包含时间
	dep			datetime					not null,
	ratecode    char(10)    default '' 	not null,	/* 房价码  */
	src			char(3)		default '' 	not null,	/* 来源 */
	market		char(3)		default '' 	not null,	/* 市场码 */
	packages		varchar(50)		default ''	not null,	/* 包价  */
	srqs		   varchar(30)	default ''	not null,	/* 特殊要求 */
	amenities  	varchar(30)	default ''	not null,	/* 房间布置 */
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

-- BLOCK 初始客房占用 
if exists(select * from sysobjects where name = "rsvsrc_blkinit" and type='U')
	drop table rsvsrc_blkinit;
create table rsvsrc_blkinit
(
   accnt     	char(10) 				not null,
	id				int		default 0	not null,	-- 序号，含意丰富
	type      	char(5) 					not null,
   roomno    	char(5) 	default ''	not null,
	blkmark   	char(1)	default ''	not null,
	blkcode		char(10)	default ''	not null,
	begin_    	datetime  				not null,		-- 不包含时间
	end_      	datetime  				not null,
	quantity  	int		default 0	not null,
	gstno			int		default 0	not null,
	child			int		default 0	not null,
	rmrate		money		default 0	not null,
	rate			money		default 0	not null,
	rtreason		char(3) default ''	not null,			-- 优惠理由
	remark		varchar(50)	default ''	not null,
	saccnt		char(10) default ''	not null,			-- 共享标记
	master		char(10) default ''	not null,			-- 同住主账号
	rateok		char(1)	default 'F'	not null,			-- 是否核准共享价格
	arr			datetime					not null,		-- 包含时间
	dep			datetime					not null,
	ratecode    char(10)    default '' 	not null,	/* 房价码  */
	src			char(3)		default '' 	not null,	/* 来源 */
	market		char(3)		default '' 	not null,	/* 市场码 */
	packages		varchar(50)		default ''	not null,	/* 包价  */
	srqs		   varchar(30)	default ''	not null,	/* 特殊要求 */
	amenities  	varchar(30)	default ''	not null,	/* 房间布置 */
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

/* 辅助工作表－1 */
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


/* 辅助工作表－2 */
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


/* 辅助工作表－3 */
if exists(select * from sysobjects where name = "linksaccnt" and type='U')
	drop table linksaccnt;
create table linksaccnt
(
   host_id     varchar(30)		default ''	not null,
   saccnt     	char(10) 				not null
)
exec sp_primarykey linksaccnt,host_id,saccnt;
create unique index index1 on linksaccnt(host_id,saccnt);


/* 辅助工作表－4  BLOCK 应用 */
if exists(select * from sysobjects where name = "rsvsrc_blk" and type='U')
	drop table rsvsrc_blk;
create table rsvsrc_blk
(
	host_id		varchar(30)				not null,
	blkcode		char(10) 				not null,
	type			char(5) 					not null,
	date			datetime					not null,
	rmnum1		int		default 0	not null,	-- 变化前
	rmnum2		int		default 0	not null,	-- 变化后 
	rmnum			int		default 0	not null		-- 差异 
)
exec sp_primarykey rsvsrc_blk,host_id,blkcode,type,date;
create unique index index1 on rsvsrc_blk(host_id,blkcode,type,date);




/* 房类and/or房间明细区间占用表 -- 原始记录合并 

saccnt: 表示同住一个客房。客人账户之间的这种关系是自动的。
	有串联关系的多个客人有一个 saccnt, 即使第一个客人和最后一个客人也许根本不交叉；
	rsvsaccnt 是客房预留操作的中枢。

saccnt 的一个难点：没有指定房号的情况下，如何处理宾客同住；
宾客主单的房数如果 〉1，则肯定没有 share。

当 master 预留多间客房的时候，可能有多个对应的saccnt;这种关系在 rsvsrc 中体现；

saccnt 账号的产生采用独立的方式

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
	accnt			char(10)	default ''	not null		-- 一个标志性的账号，表明客房的占用属性（预订类型，vip 等等）
)
exec sp_primarykey rsvsaccnt,saccnt;
create unique index index1 on rsvsaccnt(saccnt);
create unique index index2 on rsvsaccnt(saccnt,type,roomno,begin_);
create index index3 on rsvsaccnt(roomno,saccnt);



/* 房类区间占用表 */
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

/* 房间区间占用表 */
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

/* 房类and/or房间明细区间占用表 */
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

/*  分房排它信号 */
if exists(select * from sysobjects where name = "chktprm" and type = 'U')
	drop table chktprm;
create table chktprm
(
	code		char(1)
)
;
insert chktprm values ('A')
;

/* 预留房时间段表 */
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
--	团体会议 主单房价定义
-------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "grprate" and type = 'U')
	drop table grprate;
create table grprate
(
	accnt		char(10)								not null,	   -- 帐号    
   type		char(5)								not null,	   -- 房类    
	rate		money				   				not null,	   -- 房价    
	oldrate	money				   				null,		      -- 原房价  
	cby		char(10)								not null,      -- 修改人  
   changed	datetime		default getdate() not null,		-- 修改日期       
)
exec sp_primarykey grprate,accnt,type
create unique index index1 on grprate(accnt,type)
;


-------------------------------------------------------------------------------
-- 
--	宾客主单挂起。包含两个应用 = 取消 + Waitlist
--
-- 一个帐号可能有多次记录，但是有效的只能有一个
-- 
-------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "master_hung" and type = 'U')
	drop table master_hung;
create table master_hung
(
	accnt		char(10)								not null,	   -- 记录状态
   sta		char(1)								not null,	   -- 状态：Waitlist=W, Cancel=X
   status	char(1)		default 'I'			not null,	   -- 状态 : I-有效, X-无效
   phone		varchar(20)	default ''			not null,	   -- 电话
   priority	char(1)		default ''			not null,	   -- 优先级
	reason	char(3)								not null,
	remark	varchar(100) default ''			not null,
	crtby		char(10)		default ''			not null,      -- 创建
   crttime	datetime		default getdate() not null			-- 创建日期       
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
	accnt		char(10)								not null,	   -- 记录状态
   sta		char(1)								not null,	   -- 状态：Waitlist=W, Cancel=X
   status	char(1)		default 'I'			not null,	   -- 状态 : I-有效, X-无效
   phone		varchar(20)	default ''			not null,	   -- 电话
   priority	char(1)		default ''			not null,	   -- 优先级
	reason	char(3)								not null,
	remark	varchar(100) default ''			not null,
	crtby		char(10)		default ''			not null,      -- 创建
   crttime	datetime		default getdate() not null			-- 创建日期       
)
exec sp_primarykey master_hhung,crttime
create unique index index1 on master_hhung(crttime)
create index index2 on master_hhung(accnt,status)
create index index3 on master_hhung(reason)
;


-------------------------------------------------------------------------------
--	销售问询  兼顾 Trunaway 
-------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "turnaway" and type = 'U')
	drop table turnaway;
create table turnaway
(
	id			int			default 0			not null,
   sta		char(1)		default 'I'			not null,	   -- 状态 : I-有效, T-Trunaway, X-取消, O-产生预订
	arr		datetime								not null,
	days		int			default 0			not null,
	type		varchar(20)	default ''			not null,	   -- 房类
	rmnum		int			default 0			not null,
	gstno		int			default 0			not null,
	market	char(3)		default ''			not null,	   -- 市场码
   phone		varchar(20)	default ''			not null,	   -- 电话
	reason	char(1)								not null,
	remark	text 			default ''			not null,
	haccnt	char(7)		default ''			not null,      -- profile
	name		varchar(60)	default ''			not null,      -- Name
	accnt		char(10)		default ''			not null,		-- 预订后生成的账号
	crtby		char(10)		default ''			not null,      -- 创建
   crttime	datetime		default getdate() not null,		-- 创建日期       
	cby		char(10)		default ''			not null,      -- 修改人  
   changed	datetime		default getdate() not null			-- 修改日期       
)
exec sp_primarykey turnaway,id
create unique index index1 on turnaway(id)
create index index2 on turnaway(reason)
create index index3 on turnaway(haccnt)
create index index4 on turnaway(arr)
create index index5 on turnaway(crttime)
;


-------------------------------------------------------------------------------
--	销售问询  兼顾 Trunaway  (历史记录)
-------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "turnawayh" and type = 'U')
	drop table turnawayh;
create table turnawayh
(
	id			int			default 0			not null,
   sta		char(1)		default 'I'			not null,	   -- 状态 : I-有效, T-Trunaway, X-取消, O-产生预订
	arr		datetime								not null,
	days		int			default 0			not null,
	type		varchar(20)	default ''			not null,	   -- 房类
	rmnum		int			default 0			not null,
	gstno		int			default 0			not null,
	market	char(3)		default ''			not null,	   -- 市场码
   phone		varchar(20)	default ''			not null,	   -- 电话
	reason	char(1)								not null,
	remark	text 			default ''			not null,
	haccnt	char(7)		default ''			not null,      -- profile
	name		varchar(60)	default ''			not null,      -- Name
	accnt		char(10)		default ''			not null,		-- 预订后生成的账号
	crtby		char(10)		default ''			not null,      -- 创建
   crttime	datetime		default getdate() not null,		-- 创建日期       
	cby		char(10)		default ''			not null,      -- 修改人  
   changed	datetime		default getdate() not null			-- 修改日期       
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
	status	char(1)		default 'I'			not null,	   -- accnt 状态
	accnt		char(10)								not null,
   sta		char(1)		default 'I'			not null,	   -- accnt 状态
	arr		datetime								not null,
	roomno	char(5)								not null,
	haccnt	char(10)								not null,
	crtby		char(10)		default ''			not null,      -- 创建
   crttime	datetime		default getdate() not null,		-- 创建日期       
	cby		char(10)		default ''			not null,      -- 修改
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
if update(logmark)  -- 记录日志
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