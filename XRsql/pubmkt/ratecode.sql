
// --------------------------------------------------------------------------
//  basecode : rmratecat  -- 房价码类别
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='rmratecat')
	delete basecode_cat where cat='rmratecat';
insert basecode_cat select 'rmratecat', '房价码类别', 'Rate Code Catalog', 3;
delete basecode where cat='rmratecat';
insert basecode(cat,code,descript,descript1) select 'rmratecat', 'COR', 'COR', 'COR';
insert basecode(cat,code,descript,descript1) select 'rmratecat', 'FIT', 'FIT', 'FIT';
insert basecode(cat,code,descript,descript1) select 'rmratecat', 'GRP', 'GRP', 'GRP';
insert basecode(cat,code,descript,descript1) select 'rmratecat', 'PAC', 'PAC', 'PAC';
insert basecode(cat,code,descript,descript1) select 'rmratecat', 'RAK', 'RAK', 'RAK';
insert basecode(cat,code,descript,descript1) select 'rmratecat', 'OTH', 'OTH', 'OTH';


// ----------------------------------------------------------------
// rmratecode---房价代码表 
// ----------------------------------------------------------------
//exec sp_rename rmratecode, a_rmratecode;
if exists(select * from sysobjects where name = "rmratecode")
	drop table rmratecode;
create table rmratecode
(
	code          char(10)	    					not null,  	// 代码
	cat          	char(3)	    					not null,
   descript      varchar(60)      				not null,  	// 描述  
   descript1     varchar(60)     default ''	not null,  	// 描述  
   private       char(1) 			default 'T'	not null,  	// 私有 or 公用
   mode       	  char(1) 			default ''	not null,  	// 模式--以后用来控制主单房价的取舍
	inher_fo      char(10)        DEFAULT ''	 NOT NULL,	// 继承自
   folio       	varchar(30) 	default ''	not null, 	// 帐单
	src				char(3)			default ''	not null,	// 宾客来源
	market			char(3)			default ''	not null,	// 市场代码
	packages			char(50)			default ''	not null,	//	包价
	amenities  		varchar(30)		default ''	not null,	// 房间布置
	begin_			datetime							null,
	end_				datetime							null,
	calendar			char(1)		default 'F'	not null,	// 房价日历
	yieldable		char(1)		default 'F'	not null,	// 限制策略
	yieldcat			char(3)		default ''	not null,
	bucket			char(3)		default ''	not null,
   arrmin	  int			  DEFAULT 0	 NOT NULL,			//最小提前
   arrmax	  int			  DEFAULT 0	 NOT NULL,			//最大提前
   thoughmin int			  DEFAULT 0	 NOT NULL,			//不用
   thoughmax int			  DEFAULT 0	 NOT NULL,			//不用
	staymin			int			default 0	not null,	//最小住日
	staymax			int			default 0	not null,	//最大住日
	multi     money			  DEFAULT 0	 NOT NULL,
   addition  money		  DEFAULT 0	 NOT NULL,
	pccode			char(5)		default ''	not null,
	halt				char(1)		default 'F'	not null,
	sequence			int			default 0	not null
)
EXEC sp_primarykey 'dbo.rmratecode', code;

CREATE UNIQUE NONCLUSTERED INDEX index2
    ON dbo.rmratecode(descript);

CREATE UNIQUE NONCLUSTERED INDEX index1
    ON dbo.rmratecode(code);
//insert rmratecode select * from a_rmratecode;
//select * from rmratecode;
//drop table a_rmratecode;
//----------------------------------------
//t_gds_rmratecode_delete
//----------------------------------------
IF OBJECT_ID('dbo.t_gds_rmratecode_delete') IS NOT NULL
	DROP TRIGGER dbo.t_gds_rmratecode_delete;
create trigger t_gds_rmratecode_delete
   on rmratecode
   for delete as
begin
	declare	@code		char(10)
	select @code = code from deleted 
	if @@rowcount = 1
	begin
		if exists ( select 1 from guest_extra where item='ratecode' and value=@code)
		begin
			rollback trigger with raiserror 20000 "该代码正在使用, 不能删除HRY_MARK"
			return 
		end
		if exists ( select 1 from master where ratecode=@code)
		begin
			rollback trigger with raiserror 20000 "该代码正在使用, 不能删除HRY_MARK"
			return 
		end
	end 
	delete from rmratedef_sslink where code in (select rmcode from rmratecode_link where code in (select code from deleted where rtrim(inher_fo) = null))
	delete from rmratedef where code in (select rmcode from rmratecode_link where code in (select code from deleted where rtrim(inher_fo) = null))
	delete rmratecode_link where code in (select code from deleted)
	delete from rmratecode where inher_fo in (select code from deleted)
	declare	@retmode		char(1),
				@empno		varchar(10),
				@shift		char(1),
				@pc_id		char(4),
				@appid		varchar(5),
				@info 		 varchar(255)
	select  @info = ' 代码:'+rtrim(code)+' 描述1:'+rtrim(descript)+' 描述2:'+rtrim(descript1) from deleted
	execute p_gds_get_login_info	'R',@empno output,@shift output,@pc_id output,@appid output
	insert into lgfl(columnname,accnt,old,new,empno,date,ext) 
		select 'rmrc_','rmrc',@info, '删除',isnull(@empno,''),getdate(),code 
		from deleted 
end
;

// ----------------------------------------------------------------
// rmratecode_link ---房价代码的明细定义
// ----------------------------------------------------------------
if exists(select * from sysobjects where name = "rmratecode_link")
	drop table rmratecode_link;
create table rmratecode_link
(
	code          	char(10)	    		not null,  	// 代码  
	pri				int					not null,	// 优先级	
   rmcode        	char(10)      		not null    // 房价定义明细
)
exec sp_primarykey rmratecode_link,code, pri
create unique index index1 on rmratecode_link(code, pri)
create unique index index2 on rmratecode_link(code, rmcode)
;

// ----------------------------------------------------------------
// rmrate_season - 房价季节
// ----------------------------------------------------------------
if exists(select 1 from sysobjects where name = "rmrate_season")
	drop table rmrate_season;
create table rmrate_season
(
	code          	char(3)	    					not null,  	//  代码  
   descript       varchar(30)						not null,
   descript1      varchar(40)		default ''	not null,
	begin_			datetime							null,
	end_				datetime							null,
	day				varchar(250)	default ''	not null,
	week				varchar(10)		default ''	not null,
	sequence			int				default 0	not null
)
exec sp_primarykey rmrate_season,code
create unique index index1 on rmrate_season(code)
create unique index index2 on rmrate_season(descript)
;
insert rmrate_season select 'WST','西湖博览会','西湖博览会_eng',null,null,'10/11,10/12,10/13', '', 10;
insert rmrate_season select 'LAW','法定节假日','法定节假日_eng',null,null,'05/01,10/01,01/01', '', 20;
insert rmrate_season select 'WK','周末','Weekend',null,null,'','6,7', 30;
insert rmrate_season select 'NOR','平日','Normal',null,null,'', '', 40;



// ----------------------------------------------------------------
// rmratedef - 房价定义明细表
// ----------------------------------------------------------------
if exists(select * from sysobjects where name = "rmratedef")
	drop table rmratedef;
create table rmratedef
(
	code          	char(10)	    					not null,  	//  代码  
   descript      	varchar(30)						not null,
   descript1     	varchar(40)		default ''	not null,
	begin_			datetime							null,
	end_				datetime							null,

	packages			varchar(50)		default ''	not null,	//	包价
	amenities  		varchar(30)		default ''	not null,	// 房间布置
	market			char(3)			default ''	not null,	// 市场代码
	src				char(3)			default ''	not null,	// 宾客来源

	year				varchar(100)	default ''	not null,	//不用
	month				varchar(34)		default ''	not null,	//不用
	day				varchar(100)	default ''	not null,	//不用
	week				varchar(20)		default ''	not null,	//周内可用日
	stay				int				default 0	not null,	//最小住日
	stay_e			int				default 0	not null,	//最大住日
	hall				varchar(20)		default ''	not null,
	gtype				varchar(100)	default ''	not null,
	type				varchar(100)	default ''	not null,
	flr				varchar(30)		default ''	not null,
	roomno			varchar(100)	default ''	not null,
	rmnums			int				default 0	not null,
	ratemode			char(1)			default 'S'	not null,	// 定价模式  S=实价 D=优惠 (但是针对加床、小孩床仍是实价)
	
	stay_cost		money				default 0	not null,	// 参考 fidelio
	fix_cost			money				default 0	not null,
	prs_cost			money				default 0	not null,

-- 正常价格
	rate1				money			default 0		not null,		// 1 人价
	rate2				money			default 0		not null,
	rate3				money			default 0		not null,
	rate4				money			default 0		not null,
	rate5				money			default 0		not null,
	rate6				money			default 0		not null,
	extra				money			default 0		not null,		// 加床
	child				money			default 0		not null,		// 小孩床
	crib				money			default 0		not null			// 婴儿床
)
exec sp_primarykey rmratedef,code
create unique index index1 on rmratedef(code)
create unique index index2 on rmratedef(descript)
;


// ----------------------------------------------------------------
// rmratedef_sslink - 房价定义明细表 -- 针对各种不同的特殊季节 rmrate_season
// ----------------------------------------------------------------
if exists(select * from sysobjects where name = "rmratedef_sslink")
	drop table rmratedef_sslink;
create table rmratedef_sslink
(
	code          	char(10)	    					not null,
	season			char(3)	    					not null,
	rate1				money			default 0		not null,		// 1 人价
	rate2				money			default 0		not null,
	rate3				money			default 0		not null,
	rate4				money			default 0		not null,
	rate5				money			default 0		not null,
	rate6				money			default 0		not null,
	extra				money			default 0		not null,		// 加床
	child				money			default 0		not null,		// 小孩床
	crib				money			default 0		not null,		// 婴儿床
	packages			varchar(50)		default ''	not null,		//	包价
	amenities  		varchar(30)		default ''	not null			// 房间布置
)
exec sp_primarykey rmratedef_sslink,code,season
create unique index index1 on rmratedef_sslink(code,season)
;

// ----------------------------------------------------------------
// rmrate_factor --- 房价日历代码
// ----------------------------------------------------------------
if exists(select * from sysobjects where name = "rmrate_factor")
	drop table rmrate_factor;
create table rmrate_factor
(
	code          	char(1)	    					not null,  	// 代码  
	descript			varchar(50)						not null,
	descript1		varchar(50)		default ''	not null,
	multi				money				default 0	not null,	// 乘法系数
	adder				money				default 0	not null		// 加法系数
)
exec sp_primarykey rmrate_factor,code
create unique index index1 on rmrate_factor(code)
;
insert rmrate_factor values('A', '普通日期', '普通日期_eng', 1, 0);
insert rmrate_factor values('B', '西博会', '西博会_eng', 1, 0);
insert rmrate_factor values('C', '春节', '春节_eng', 1, 0);
insert rmrate_factor values('D', '世界杯', '世界杯_eng', 1, 0);



// ----------------------------------------------------------------
// rmrate_calendar --- 房价日历
// ----------------------------------------------------------------
if exists(select * from sysobjects where name = "rmrate_calendar")
	drop table rmrate_calendar;
create table rmrate_calendar
(
	date          	datetime	    					not null,
	factor			char(1)							not null
)
exec sp_primarykey rmrate_calendar,date
create unique index index1 on rmrate_calendar(date)
;


// ----------------------------------------------------------------
// rmratecode_info---房价代码描述信息
//		code = '' ---> 模版
// ----------------------------------------------------------------
if exists(select * from sysobjects where name = "rmratecode_info")
	drop table rmratecode_info;
create table rmratecode_info
(
	code          char(10)	    					not null,  	// 代码
	info          text	    						null
)
exec sp_primarykey rmratecode_info,code;
create unique index index1 on rmratecode_info(code);
;

// ----------------------------------------------------------------
// rmrate_strategy - 房价策略
// ----------------------------------------------------------------
if exists(select 1 from sysobjects where name = "rmrate_strategy")
	drop table rmrate_strategy;
create table rmrate_strategy
(
	id					char(10)	    					not null,

	gtype          varchar(100)	    	default ''	not null,
	rmtype        	varchar(100)	    	default ''	not null,

	ratecat			varchar(100)	    	default ''	not null,
	ratecode			varchar(200)	    	default ''	not null,

	cond				char(3)	    	default ''	not null,
	cond_parm		varchar(254)	default ''	not null,
	cond_value		money				default 0	not null,		

	flag				char(3)	    	default ''	not null,
	flag_num			int	    		default 0	not null,

	cdate1			datetime							not null,		-- Dates to Control
	cdate2			datetime							not null,
	wdate1			datetime							null,				-- When to Control
	wdate2			datetime							null,
	days1				int								null,		-- Days in Advance
	days2				int								null,

	halt				char(1)			default 'F'	not null,
	sequence			int				default 0	not null,
	cby				char(10)			default ''	not null,
	changed			datetime			default getdate()	not null,
	logmark			int				default 0	not null
); 
exec sp_primarykey rmrate_strategy,id
create unique index index1 on rmrate_strategy(id)
;

if exists(select 1 from sysobjects where name = "rmrate_strategy_log")
	drop table rmrate_strategy_log;
create table rmrate_strategy_log
(
	id					char(10)	    					not null,

	gtype          varchar(100)	    	default ''	not null,
	rmtype        	varchar(100)	    	default ''	not null,

	ratecat			varchar(100)	    	default ''	not null,
	ratecode			varchar(200)	    	default ''	not null,

	cond				char(3)	    	default ''	not null,
	cond_parm		varchar(254)	default ''	not null,
	cond_value		money				default 0	not null,		

	flag				char(3)	    	default ''	not null,
	flag_num			int	    		default 0	not null,

	cdate1			datetime							not null,		-- Dates to Control
	cdate2			datetime							not null,
	wdate1			datetime							null,				-- When to Control
	wdate2			datetime							null,
	days1				int								null,		-- Days in Advance
	days2				int								null,

	halt				char(1)			default 'F'	not null,
	sequence			int				default 0	not null,
	cby				char(10)			default ''	not null,
	changed			datetime			default getdate()	not null,
	logmark			int				default 0	not null
); 
exec sp_primarykey rmrate_strategy_log,id,logmark
create unique index index1 on rmrate_strategy_log(id,logmark)
;

-----------------------
--	trigger - Insert
-----------------------
create trigger t_gds_rmrate_strategy_insert
   on rmrate_strategy
   for insert as
begin
	if exists(select 1 from inserted)
	   insert rmrate_strategy_log select * from inserted
end
;


-----------------------
--	trigger - Update
-----------------------
create trigger t_gds_rmrate_strategy_update
   on rmrate_strategy
   for update as
begin
if update(logmark)
   insert rmrate_strategy_log select * from inserted
end
;



// ----------------------------------------------------------------
// rmrate_stcond - 房价策略条件定义 
// ----------------------------------------------------------------
if exists(select 1 from sysobjects where name = "rmrate_stcond")
	drop table rmrate_stcond;
create table rmrate_stcond
(
	code				char(3)	    					not null,
   descript   		varchar(60)    				not null,
   descript1  		varchar(60) default ''   	not null,
	def				text								not null,
	syntax			text								null,
	sys				char(1)		default 'F'		not null,		//	系统代码
	halt				char(1)		default 'F'		not null,		// 停用?
	sequence			int			default 0		not null,		// 次序
	grp				varchar(16)	default ''   	not null,		// 归类
	center			char(1)		default 'F'   	not null,			// center code ?
	cby				char(10)		default '!' 	not null,	/* 最新修改人信息 */
	changed			datetime		default getdate()		not null 
); 
exec sp_primarykey rmrate_stcond,code
create unique index index1 on rmrate_stcond(code)
;

// ----------------------------------------------------------------
// rmrate_ava - 房价码可用性
// ----------------------------------------------------------------
if exists(select 1 from sysobjects where name = "rmratecode_ava")
	drop table rmratecode_ava;
CREATE TABLE dbo.rmratecode_ava 
(
    date       datetime NOT NULL,
    value      char(10) NOT NULL,		//C 关闭;B 当日到关闭;E 当日力关闭
    min_stay   int      NOT NULL,		//最小住日
    max_stay   int      NOT NULL,		//最大住日
    room_class char(255) NOT NULL,		//大房类
    room_type  char(255) NOT NULL,		//房类
    rate_cat   char(255) NOT NULL,		//房价码大类
    ratecode   char(255) NOT NULL,		//房价码
    season     char(10) NOT NULL,		//暂时不用
    cdate      datetime NOT NULL,
    empno      char(5)  NOT NULL
);
EXEC sp_primarykey 'dbo.rmratecode_ava', date,room_class,room_type,rate_cat,ratecode;
//CREATE UNIQUE NONCLUSTERED INDEX index1
//    ON dbo.rmratecode_ava(date,room_class,room_type,rate_cat,ratecode);


INSERT INTO rmrate_stcond(def,syntax,code,descript,descript1,sys,halt,sequence,grp,center) VALUES (
	'', '', 
	'1',
	'出租率大于',
	'OCC% more then',
	'T',
	'F',
	100,
	'',
	'F');
INSERT INTO rmrate_stcond(def,syntax,code,descript,descript1,sys,halt,sequence,grp,center) VALUES (
	'', '', 
	'2',
	'出租率小于',
	'OCC% less then',
	'T',
	'F',
	200,
	'',
	'F');
INSERT INTO rmrate_stcond(def,syntax,code,descript,descript1,sys,halt,sequence,grp,center) VALUES (
	'', '', 
	'3',
	'团队客房比率大于',
	'Group Occ. more then',
	'T',
	'F',
	300,
	'',
	'F');
INSERT INTO rmrate_stcond(def,syntax,code,descript,descript1,sys,halt,sequence,grp,center) VALUES (
	'', '', 
	'4',
	'团队客房比率小于',
	'Group Occ. less then',
	'T',
	'F',
	400,
	'',
	'F');

