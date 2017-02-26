-- ------------------------------------------------------------------------------
-- crs link pms 
-- 
-- 遗留问题
--		代码对照的问题,比如房类,市场码等, 1-1, 1-n ? 
--		房价码的对照与更新问题: crslink_rc & rmratecode 的数据对应与一致性如何保证 
--		。。。。。。 
--
--
--	2006/9/19 simon
--	根据锦江德尔 最新的解释， 代码体系针对接口即可，即：建立一个对照关系就行了。
-- 代码体系与 渠道 没有关系。
-- 如此以来，原来代码表中的crsid 字段就没有用了。 
--
--
-- ------------------------------------------------------------------------------

-- ########################
-- Part 1: 系统参数 
-- ########################

-- ------------------------
-- CRS Interface 系统参数 
-- ------------------------
if exists(select * from sysobjects where name = "crslink_option")
	drop table crslink_option;
create table crslink_option
(
	crsid			char(30)							not null,	-- 这个是 CRS 渠道特性，还是接口特性呢 ？ 
																		-- 原来的注释: pms 连接的 crs 标记，如 HUBS1=德尔 PEGASUS ...
	catalog 		char(12)     					not NULL,
	item    		char(32)     					not NULL,
	value   		varchar(255) 					NULL,
	def			varchar(255) 					NULL,		-- 参数缺省值
	remark  		varchar(255) 					NULL,		-- 中文说明
	remark1		varchar(255) 					NULL,		-- 英文说明
	addby			varchar(10) 					NULL,		-- 创建者，疑惑的时候，可以找人问。。
	addtime		datetime	default getdate() not null,	-- 创建的时间 
	usermod		char(1)	default 'T'	null,					-- 用户可以修改
	lic			varchar(20) default '' not null			-- 授权代码
)
exec sp_primarykey crslink_option,crsid,catalog,item
create unique index index1 on crslink_option(crsid,catalog,item)
;


-- ########################
-- Part 2: 普通代码
-- ########################

-- ------------------------
-- CRS 系统代码
-- ------------------------
if exists(select * from sysobjects where name = "crslink_id")
	drop table crslink_id;
create table crslink_id
(
	crsid			char(30)							not null,	-- 这个是 CRS 渠道特性，还是接口特性呢 ？ -- 这里肯定是渠道 
																		-- 原来的注释: pms 连接的 crs 标记，如 HUBS1=德尔 PEGASUS ...
   descript   		varchar(60) default ''		not null,
   descript1  		varchar(60) default ''		not null,
	flag				char(30)		default ''		not null,	-- 标记
	remark			text								null,			-- 描述
	halt				char(1)		default 'F'		not null,	-- 停用
	sequence			int			default 0		not null		-- 次序
)
exec sp_primarykey crslink_id,crsid
create unique index index1 on crslink_id(crsid)
;

-- -------------------------------------------------------------------
-- 一般代码对照表
--
--		特别注意，这里的代码对照要求  CRS  ：PMS = N  ：1  
--		因为中央订单下载的时候，需要能够方便的产生本地订单
--		暂时不考虑其他对应情况. 
--		但是实际可能需要，比如CRS指定的标准间客房，可能对应到酒店多个房类
-- -------------------------------------------------------------------
if exists(select * from sysobjects where name = "crslink_code")
	drop table crslink_code;
create table crslink_code
(
	crsid			char(30)							not null,	-- 这个是 CRS 渠道特性，还是接口特性呢 ？ 
																		-- 原来的注释: pms 连接的 crs 标记，如 HUBS1=德尔 PEGASUS ...
	cat				char(30)							not null,	-- 代码类别标记 
   descript   		varchar(60)    				not null,
   descript1  		varchar(60) default ''   	not null,
	pmscode			text			default ''   	not null,
	sequence			int			default 0		not null			-- 次序
)
exec sp_primarykey crslink_code,crsid,cat
create unique index index1 on crslink_code(crsid,cat)
;


if exists(select * from sysobjects where name = "crslink_codedef")
	drop table crslink_codedef;
create table crslink_codedef
(
	crsid				char(30)							not null,
	cat				char(30)							not null,	-- 代码类别标记 

	crscode			char(20)							not null,
   crsdes   		varchar(60)    				not null,
   crsdes1  		varchar(60) default ''   	not null,

	pmscode			char(20)							not null,
   pmsdes   		varchar(60)    				not null,
   pmsdes1  		varchar(60) default ''   	not null,

	crsgrp			varchar(20)	default ''   	not null,		-- 归类
	sequence			int			default 0		not null			-- 次序
)
exec sp_primarykey crslink_codedef,crsid,cat,crscode
create unique index index1 on crslink_codedef(crsid,cat,crscode)
create index index2 on crslink_codedef(crsid,cat,pmscode)
;


-- ########################
-- Part 3: 房价代码
-- ########################

-- ------------------------
-- crslink_rc---房价代码表 
-- ------------------------
if exists(select * from sysobjects where name = "crslink_rc")
	drop table crslink_rc;
create table crslink_rc
(
	crsid				char(30)							not null,
	pmsrc				char(10)							not null,	-- pms 房价代码
	channel_link	varchar(100)	default ''	not null,  	-- 针对那些渠道开放 
	code          char(10)	    					not null,  	-- 房价代码
	cat          	char(3)	    					not null,
   descript      varchar(60)      				not null,  	-- 描述  
   descript1     varchar(60)     default ''	not null,  	-- 描述  
   private       char(1) 			default 'T'	not null,  	-- 私有 or 公用
   mode       	  char(1) 			default ''	not null,  	-- 模式--以后用来控制主单房价的取舍
   folio       	varchar(30) 	default ''	not null, 	-- 帐单
	src				char(3)			default ''	not null,	-- 宾客来源
	market			char(3)			default ''	not null,	-- 市场代码
	packages			char(50)			default ''	not null,	--	包价
	amenities  		varchar(30)		default ''	not null,	-- 房间布置
	begin_			datetime							null,
	end_				datetime							null,
	calendar			char(1)		default 'F'	not null,	-- 房价日历
	yieldable		char(1)		default 'F'	not null,	-- 限制策略
	yieldcat			char(3)		default ''	not null,
	bucket			char(3)		default ''	not null,
	staymin			int			default 0	not null,
	staymax			int			default 0	not null,
	pccode			char(5)		default ''	not null,
	halt				char(1)		default 'F'	not null,
	sequence			int			default 0	not null
)
exec sp_primarykey crslink_rc,crsid, code;
create unique index index1 on crslink_rc(crsid, code);
create unique index index2 on crslink_rc(crsid, descript);
;


-- -------------------------------
-- crslink_rcdef - 房价定义明细表
-- -------------------------------
if exists(select * from sysobjects where name = "crslink_rcdef")
	drop table crslink_rcdef;
create table crslink_rcdef
(
	crsid				char(30)							not null,
	code          	char(10)	    					not null,  	--  房价代码  
	id          	char(10)	    					not null,  	--  明细标记
   descript      	varchar(30)						not null,
   descript1     	varchar(40)		default ''	not null,
	begin_			datetime							null,
	end_				datetime							null,

	packages			varchar(50)		default ''	not null,	--	包价
	amenities  		varchar(30)		default ''	not null,	-- 房间布置
	market			char(3)			default ''	not null,	-- 市场代码
	src				char(3)			default ''	not null,	-- 宾客来源

	year				varchar(100)	default ''	not null,
	month				varchar(34)		default ''	not null,
	day				varchar(100)	default ''	not null,
	week				varchar(20)		default ''	not null,
	stay				int				default 0	not null,

	hall				varchar(20)		default ''	not null,
	gtype				varchar(100)	default ''	not null,
	type				varchar(100)	default ''	not null,
	flr				varchar(30)		default ''	not null,
	roomno			varchar(100)	default ''	not null,
	rmnums			int				default 0	not null,
	ratemode			char(1)			default 'S'	not null,	-- 定价模式  S=实价 D=优惠 (但是针对加床、小孩床仍是实价)
	
	stay_cost		money				default 0	not null,	-- 参考 fidelio
	fix_cost			money				default 0	not null,
	prs_cost			money				default 0	not null,

-- 正常价格
	rate1				money			default 0		not null,		-- 1 人价
	rate2				money			default 0		not null,
	rate3				money			default 0		not null,
	rate4				money			default 0		not null,
	rate5				money			default 0		not null,
	rate6				money			default 0		not null,
	extra				money			default 0		not null,		-- 加床
	child				money			default 0		not null,		-- 小孩床
	crib				money			default 0		not null			-- 婴儿床
)
exec sp_primarykey crslink_rcdef,crsid,code,id
create unique index index1 on crslink_rcdef(crsid,code,id)
;


-- ########################
-- Part 4: 客房放房 
-- ########################
-- ------------------------
-- 放房设置 
-- ------------------------
if exists(select * from sysobjects where name = "crslink_rmset")
	drop table crslink_rmset;
create table crslink_rmset
(
	crsid				char(30)							not null,
	date				datetime							not null,
	rmtype			char(5)							not null,
	usetype			char(1)		default ''		not null,	-- 是否使用百分比 
	quantity			int			default 0		not null,
	used				int			default 0		not null,
	cby				char(10)		default ''		not null,
	changed			datetime							null,
	logmark			int			default 0		not null
)
exec sp_primarykey crslink_rmset,crsid,date,rmtype
create unique index index1 on crslink_rmset(crsid,date,rmtype)
;


-- ########################
-- Part 5: 相关触发器, 过程 
-- ########################

if exists(select 1 from sysobjects where name='t_crslink_id_insert' and type='TR')
	drop trigger t_crslink_id_insert
;
//create trigger t_crslink_id_insert		-- 代码不针对渠道的时候，这个触发器就没有用了。 
//   on crslink_id
//   for insert 
//as
//--------------------------------------------------------------------------
//--	crslink_id trigger : Insert 
//--------------------------------------------------------------------------
//declare	@crsid		char(30)
//
//select @crsid = crsid from inserted 
//if @@rowcount = 0 
//   rollback trigger with raiserror 20000 "增加代码错误HRY_MARK"
//else
//begin
//	insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
//		values (@crsid,"RMTYPE","房类","Room Type","ddlb=select type, rtrim(descript)+'-'+descript1 from typim where tag<>'P' order by sequence,type；",100)
//	insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
//		values (@crsid,"RESTYPE","预订类型","Resrv. Type","ddlb=select code, rtrim(descript)+'-'+descript1 from restype order by sequence,code； ",100)
//	insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
//		values (@crsid,"MARKET","市场码","Market","ddlb=select code, rtrim(descript)+'-'+descript1 from mktcode order by sequence,code； ",100)
//	insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
//		values (@crsid,"SOURCE","来源","Source","ddlb=select code, rtrim(descript)+'-'+descript1 from srccode order by sequence,code； ",100)
//	insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
//		values (@crsid,"CHANNEL","渠道","Channel","ddlb=select code, rtrim(descript)+'-'+descript1 from basecode where cat='channel' and halt='F' order by sequence,code； ",100)
//	insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
//		values (@crsid,"REQUEST","特殊要求","Request","ddlb=select code, rtrim(descript)+'-'+descript1 from reqcode order by sequence,code； ",100)
//	insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
//		values (@crsid,"AMENITIES","客房布置","Amenities","ddlb=select code, rtrim(descript)+'-'+descript1 from basecode where cat='amenities' and halt='F' order by sequence,code； ",100)
//	insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
//		values (@crsid,"VIP","贵宾等级","VIP Grade","ddlb=select code, rtrim(descript)+'-'+descript1 from basecode where cat='vip' and halt='F' order by sequence,code； ",100)
//end
//;

if exists(select 1 from sysobjects where name='t_crslink_id_delete' and type='TR')
	drop trigger t_crslink_id_delete
;
//create trigger t_crslink_id_delete		-- 代码不针对渠道的时候，这个触发器就没有用了。 
//   on crslink_id
//   for delete
//as
//--------------------------------------------------------------------------
//--	crslink_id trigger : Delete 
//--------------------------------------------------------------------------
//declare	@crsid		char(30)
//select @crsid = crsid from deleted  
//if @@rowcount = 0 
//   rollback trigger with raiserror 20000 "删除代码错误HRY_MARK"
//else
//begin
//	delete crslink_code where crsid=@crsid 
//	delete crslink_codedef where crsid=@crsid 
//	delete crslink_rc where crsid=@crsid 
//	delete crslink_rcdef where crsid=@crsid 
//	delete crslink_rmset where crsid=@crsid 
//end
//;

if exists(select * from sysobjects where name = "p_crslink_rmset_list")
   drop proc p_crslink_rmset_list
;
create proc p_crslink_rmset_list
	@crsid			char(30),
	@begin			datetime,
	@end				datetime,
	@rmtype			char(5),
	@empno			char(10)
as
------------------------------------------------------------------------------
--	CRS Interface 放房记录查询
------------------------------------------------------------------------------
if rtrim(@crsid) is null -- or not exists(select 1 from crslink_id where crsid=@crsid) 
	return 1

select @rmtype = ltrim(rtrim(@rmtype))
if @rmtype is not null and not exists(select 1 from crslink_codedef where crsid='HUBS1' and cat='RMTYPE' and crscode=@rmtype) 
	return 1

if @begin is null or @end is null
	return 1 

-- 
declare	@count		int 
select @begin 	= convert(datetime,convert(char(8),@begin,1))
select @end 	= convert(datetime,convert(char(8),@end,1))
select @count = datediff(dd, @begin, @end) 
if @count<=0 or @count>366 
	return 1 

-- 
declare	@now	datetime 
select @now = getdate()
create table #allrec (date datetime, rmtype char(5), cby char(10)  null )
while @begin <= @end
begin
	insert #allrec 
		select @begin, crscode, null from crslink_codedef
			where crsid='HUBS1' and cat='RMTYPE' and (@rmtype is null or crscode=@rmtype)

	select @begin = dateadd(dd, 1, @begin)
end
update #allrec set cby=a.cby from crslink_rmset a 
	where #allrec.date=a.date and #allrec.rmtype=a.rmtype and a.crsid=@crsid 
insert crslink_rmset(crsid,date,rmtype,quantity,used,cby,changed,logmark)
	select @crsid, date, rmtype, 0, 0, @empno, @now, 0 
		from #allrec a where cby is null 

return 0
;


----------------------------------------------------------------------
--	房价码设置 
----------------------------------------------------------------------
IF OBJECT_ID('p_crslink_rcset') IS NOT NULL
    DROP PROCEDURE p_crslink_rcset
;
create proc p_crslink_rcset
	@crsid			char(30),
	@code				char(10),
	@des				char(60),
	@des1				char(60),
	@pmsrc			char(10),
	@clink			varchar(100), 
	@sequence		int,
	@empno			char(10)
as
------------------------------------------------------------------------------
--	CRS Interface 房价码设置 
------------------------------------------------------------------------------
declare	@ret			int,
			@msg			varchar(60)

select @ret=0, @msg=''

-- 代码校验 
select @crsid 	= ltrim(rtrim(@crsid))
select @code 	= ltrim(rtrim(@code))
select @des 	= ltrim(rtrim(@des))
select @des1 	= ltrim(rtrim(@des1))
select @pmsrc 	= ltrim(rtrim(@pmsrc))
select @clink 	= ltrim(rtrim(@clink))
select @sequence = isnull(@sequence, 0) 
			
//if @crsid is null or not exists(select 1 from crslink_id where crsid=@crsid) 
//begin
//	select @ret=1, @msg='中央预订接口代码错误'
//	goto goutput 
//end
select @crsid = 'HUBS1'

if @code is null 
begin
	select @ret=1, @msg='请输入%1^房价代码'
	goto goutput 
end
if @des is null  or @des1 is null 
begin
	select @ret=1, @msg='请输入%1^房价代码描述'
	goto goutput 
end
if @pmsrc is null or not exists(select 1 from rmratecode where code=@pmsrc) 
begin
	select @ret=1, @msg='设置的本地房价代码错误'
	goto goutput 
end
if @clink is null 
	select @clink = ''

-- 
if not exists(select 1 from crslink_rc where crsid=@crsid and code=@code and pmsrc=@pmsrc)
begin
	delete crslink_rc where crsid=@crsid and code=@code 
	delete crslink_rcdef where crsid=@crsid and code=@code 

	insert crslink_rc (crsid,pmsrc,channel_link,code,cat,descript,descript1,private,mode,folio,src,market,packages,amenities,
			begin_,end_,calendar,yieldable,yieldcat,bucket,staymin,staymax,pccode,halt,sequence )
		SELECT @crsid,b.code,@clink,@code,b.cat,@des,@des1,b.private,b.mode,b.folio,b.src,b.market,b.packages,b.amenities,
					b.begin_,b.end_,b.calendar,b.yieldable,b.yieldcat,b.bucket,b.staymin,b.staymax,b.pccode,b.halt,b.sequence  
			FROM rmratecode b where b.code = @pmsrc

	insert crslink_rcdef(crsid,code,id,descript,descript1,begin_,end_,packages,amenities,market,src,
			year,month,day,week,stay,hall,gtype,type,flr,roomno,rmnums,ratemode,
			stay_cost,fix_cost,prs_cost,rate1,rate2,rate3,rate4,rate5,rate6,extra,child,crib)
		SELECT a.crsid,a.code,c.code,c.descript,c.descript1,c.begin_,c.end_,c.packages,c.amenities,c.market,c.src,c.
				year,c.month,c.day,c.week,c.stay,c.hall,c.gtype,c.type,c.flr,c.roomno,c.rmnums,c.ratemode,c.
				stay_cost,c.fix_cost,c.prs_cost,c.rate1,c.rate2,c.rate3,c.rate4,c.rate5,c.rate6,c.extra,c.child,c.crib  
			FROM crslink_rc a, rmratecode_link b, rmratedef c
				where a.crsid=@crsid and a.code=@code and a.pmsrc=b.code and b.rmcode=c.code 
end
else
begin
	update crslink_rc set descript=@des, descript1=@des1, channel_link=@clink, sequence=@sequence where crsid=@crsid and code=@code and pmsrc=@pmsrc 
end

goutput:
select @ret, @msg

return @ret
;


------------------------------------------------------------------------------
--	放房记录修改
------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = "p_crslink_rmset_update" and type='P')
   drop proc p_crslink_rmset_update;
create proc p_crslink_rmset_update
	@crsid			char(30),
	@begin			datetime,
	@end				datetime,
	@rmtype			char(5),
	@rmnum			integer,
	@mode				char(1),	--'1'新增，'0'覆盖
	@empno			char(10)
as
------------------------------------------------------------------------------
--	CRS Interface 放房记录修改
------------------------------------------------------------------------------
if rtrim(@crsid) is null -- or not exists(select 1 from crslink_id where crsid=@crsid) 
	return 1

select @rmtype = ltrim(rtrim(@rmtype))
if @rmtype is not null and not exists(select 1 from crslink_codedef where crsid='HUBS1' and cat='RMTYPE' and crscode=@rmtype) 
	return 1

if @begin is null or @end is null
	return 1 

select @begin 	= convert(datetime,convert(char(8),@begin,1))
select @end 	= convert(datetime,convert(char(8),@end,1))

while @begin <= @end
begin
	if exists( select 1 from crslink_rmset where date=@begin and crsid=@crsid and (@rmtype is null or rmtype=@rmtype) )
		begin
		if @mode = '1'	---新增
			update crslink_rmset set quantity = quantity + @rmnum,cby=@empno,changed=getdate(),logmark=logmark+1 where date=@begin and crsid=@crsid and (@rmtype is null or rmtype=@rmtype)
		else
			update crslink_rmset set quantity = @rmnum,cby=@empno,changed=getdate(),logmark=logmark+1 where date=@begin and crsid=@crsid and (@rmtype is null or rmtype=@rmtype)
		end
	else
		begin
		if @rmtype is null
			insert crslink_rmset(crsid,date,rmtype,quantity,used,cby,changed,logmark) 
			 select @crsid,@begin,crscode,@rmnum,0,@empno,getdate(),0 from crslink_codedef where crsid='HUBS1' and cat='RMTYPE'
		else
			insert crslink_rmset(crsid,date,rmtype,quantity,used,cby,changed,logmark) 
			 select @crsid,@begin,@rmtype,@rmnum,0,@empno,getdate(),0
		end

	select @begin = dateadd(dd, 1, @begin)
end

return 0
;



------------------------------------------------------------------------------
-- 设置初始数据及其显示 
------------------------------------------------------------------------------
------------------------
-- 1. 数据插入
------------------------
-- 插入 crslink_option 
insert crslink_option (crsid,catalog,item,value,def,remark,remark1,addby,addtime)
	select 'HUBS1','channel','selected_for_room','GDS,CTRIP','','房量发布渠道','房量发布渠道','FOX','2006/9/1';
insert crslink_option (crsid,catalog,item,value,def,remark,remark1,addby,addtime)
	select 'HUBS1','rmset','mode','1','1','网上房量发布模式：0=酒店实际实时房量 1=手工设置房量','网上房量发布模式：0=酒店实际实时房量 1=手工设置房量','FOX','2006/9/1';

-- 插入 crslink_id  = 渠道 
insert crslink_id(crsid,descript,descript1,sequence) values ('GDS', '全球酒店预订网', 'Global Distribution System', 100);
insert crslink_id(crsid,descript,descript1,sequence) values ('IDS', '互联网分销网', 'Internet Distribution System', 200);
insert crslink_id(crsid,descript,descript1,sequence) values ('CTRIP', '携程旅行网', 'Ctrip Traval', 300);
insert crslink_id(crsid,descript,descript1,sequence) values ('ELONG', 'e龙旅行网', 'eLong Traval', 400);

-- 插入 crslink_code  = 一般代码对照表
insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
	values ('HUBS1',"RMTYPE","房类","Room Type","ddlb=select type, type+'-'+rtrim(descript)+'-'+descript1 from typim where tag<>'P' order by sequence,type；",100)
insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
	values ('HUBS1',"RESTYPE","预订类型","Resrv. Type","ddlb=select code, code+'-'+rtrim(descript)+'-'+descript1 from restype order by sequence,code； ",200)
insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
	values ('HUBS1',"MARKET_CAT","市场码类别","Market Catalog","ddlb=select code, code+'-'+rtrim(descript)+'-'+descript1 from basecode where cat='market_cat' order by sequence,code； ",300)
insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
	values ('HUBS1',"MARKET","市场码","Market","ddlb=select code, code+'-'+rtrim(descript)+'-'+descript1 from mktcode order by sequence,code； ",400)
insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
	values ('HUBS1',"SOURCE","来源","Source","ddlb=select code, code+'-'+rtrim(descript)+'-'+descript1 from srccode order by sequence,code； ",500)
insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
	values ('HUBS1',"CHANNEL","渠道","Channel","ddlb=select code, code+'-'+rtrim(descript)+'-'+descript1 from basecode where cat='channel' and halt='F' order by sequence,code； ",600)
insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
	values ('HUBS1',"REQUEST","特殊要求","Request","ddlb=select code, code+'-'+rtrim(descript)+'-'+descript1 from reqcode order by sequence,code； ",700)
insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
	values ('HUBS1',"AMENITIES","客房布置","Amenities","ddlb=select code, code+'-'+rtrim(descript)+'-'+descript1 from basecode where cat='amenities' and halt='F' order by sequence,code； ",800)
insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
	values ('HUBS1',"VIP","贵宾等级","VIP Grade","ddlb=select code, code+'-'+rtrim(descript)+'-'+descript1 from basecode where cat='vip' and halt='F' order by sequence,code； ",900)
insert crslink_code (crsid,cat,descript,descript1,pmscode,sequence)
	values ('HUBS1',"RCGRP","房价代码类别","RateCode Group","ddlb=select code, code+'-'+rtrim(descript)+'-'+descript1 from basecode where cat='rmratecat' and halt='F' order by sequence,code； ",1000)

-- 插入 普通代码 -- crsid 不再是渠道，直接插入 HUBS1 
insert crslink_codedef(crsid,cat,crscode,crsdes,crsdes1,pmscode,pmsdes,pmsdes1,crsgrp,sequence)
	select 'HUBS1', 'RMTYPE',type,descript,descript1,type,descript,descript1,'',sequence from typim; 
insert crslink_codedef(crsid,cat,crscode,crsdes,crsdes1,pmscode,pmsdes,pmsdes1,crsgrp,sequence)
	select 'HUBS1', 'RESTYPE',code,descript,descript1,code,descript,descript1,'',sequence from restype; 
insert crslink_codedef(crsid,cat,crscode,crsdes,crsdes1,pmscode,pmsdes,pmsdes1,crsgrp,sequence)
	select 'HUBS1', 'MARKET',code,descript,descript1,code,descript,descript1,'',sequence from mktcode; 
insert crslink_codedef(crsid,cat,crscode,crsdes,crsdes1,pmscode,pmsdes,pmsdes1,crsgrp,sequence)
	select 'HUBS1', 'MARKET_CAT',code,descript,descript1,code,descript,descript1,'',sequence from basecode where cat='market_cat'; 
insert crslink_codedef(crsid,cat,crscode,crsdes,crsdes1,pmscode,pmsdes,pmsdes1,crsgrp,sequence)
	select 'HUBS1', 'SOURCE',code,descript,descript1,code,descript,descript1,'',sequence from srccode; 
insert crslink_codedef(crsid,cat,crscode,crsdes,crsdes1,pmscode,pmsdes,pmsdes1,crsgrp,sequence)
	select 'HUBS1', 'CHANNEL',code,descript,descript1,code,descript,descript1,'',sequence from basecode where cat='channel'; 
insert crslink_codedef(crsid,cat,crscode,crsdes,crsdes1,pmscode,pmsdes,pmsdes1,crsgrp,sequence)
	select 'HUBS1', 'REQUEST',code,descript,descript1,code,descript,descript1,'',sequence from reqcode; 
insert crslink_codedef(crsid,cat,crscode,crsdes,crsdes1,pmscode,pmsdes,pmsdes1,crsgrp,sequence)
	select 'HUBS1', 'AMENITIES',code,descript,descript1,code,descript,descript1,'',sequence from basecode where cat='amenities'; 
insert crslink_codedef(crsid,cat,crscode,crsdes,crsdes1,pmscode,pmsdes,pmsdes1,crsgrp,sequence)
	select 'HUBS1', 'VIP',code,descript,descript1,code,descript,descript1,'',sequence from basecode where cat='vip'; 
insert crslink_codedef(crsid,cat,crscode,crsdes,crsdes1,pmscode,pmsdes,pmsdes1,crsgrp,sequence)
	select 'HUBS1', 'RCGRP',code,descript,descript1,code,descript,descript1,'',sequence from basecode where cat='rmratecat'; 

-- 插入 PMS中带有 CRS 特征的房价码 - 1：crslink_rc
insert crslink_rc (crsid,pmsrc,code,cat,descript,descript1,private,mode,folio,src,market,packages,amenities,
						begin_,end_,calendar,yieldable,yieldcat,bucket,staymin,staymax,pccode,halt,sequence )
	SELECT 'HUBS1',b.code,b.code,b.cat,b.descript,b.descript1,b.private,b.mode,b.folio,b.src,b.market,b.packages,b.amenities,
			b.begin_,b.end_,b.calendar,b.yieldable,b.yieldcat,b.bucket,b.staymin,b.staymax,b.pccode,b.halt,b.sequence  
	FROM rmratecode b where b.descript like '%CRS%';
-- 插入 PMS中带有 CRS 特征的房价码 - 2：crslink_rcdef
insert crslink_rcdef(crsid,code,id,descript,descript1,begin_,end_,packages,amenities,market,src,
							year,month,day,week,stay,hall,gtype,type,flr,roomno,rmnums,ratemode,
							stay_cost,fix_cost,prs_cost,rate1,rate2,rate3,rate4,rate5,rate6,extra,child,crib)
	SELECT a.crsid,a.code,c.code,c.descript,c.descript1,c.begin_,c.end_,c.packages,c.amenities,c.market,c.src,c.
			year,c.month,c.day,c.week,c.stay,c.hall,c.gtype,c.type,c.flr,c.roomno,c.rmnums,c.ratemode,c.
			stay_cost,c.fix_cost,c.prs_cost,c.rate1,c.rate2,c.rate3,c.rate4,c.rate5,c.rate6,c.extra,c.child,c.crib  
	FROM crslink_rc a, rmratecode_link b, rmratedef c where a.code=b.code and b.rmcode=c.code;

------------------------
-- 2. 数据显示
------------------------
select * from sysdata; 
select * from crslink_id order by sequence, crsid; 
select * from crslink_code order by crsid, sequence, cat;
select * from crslink_codedef order by crsid, cat, sequence, crscode;
select * from crslink_rc order by crsid, sequence, code;
select * from crslink_rcdef order by crsid, code, id;
select * from crslink_rmset order by crsid, date, rmtype; 
