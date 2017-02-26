// --------------------------------------------------------------------------
//	客房中心相关 表
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
//		basecode:		rmmaint_reason, ocsta, hall, hsregion, feature, amenities
//							sw_class, sw_grade, sw_sta, hs_empno
//
//		table:			hs_sysdata, hs_mapparm				- 客房中心系统级参数表
//							flrcode, typim, rmsta, rmsta_till, rmsta_last, rmsta_log,
//							rmstalist, rmstalist1, rmstamap, gtype, 
//							checkroom, checkroomset				- 查房
//							discrepant_room, room_input		- 矛盾房
//							hsmap_term, hsmap_term_end			- 客户端客房动态选择（房态表、房态管理）
//							rm_ooo, hrm_ooo, rm_ooo_log		- 维修房
//							rmtmpsta, hrmtmpsta					- 临时态
//							hs_mapclr, hsmapsel					- 房态管理
//							hsmap, hsmap_des, hsmap_bu			- 房态表2
//							attendant_allot						- 客房清洁任务分配临时表
//							hsmap_new								- 房态表5的一个临时表 
//							hsmap_project							- 房态表5颜色等设置方案的表和sysoption表关联
//							hall_station 
// --------------------------------------------------------------------------


// --------------------------------------------------------------------------
//  basecode : rmmaint_reason	客房维修原因
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='rmmaint_reason')
	delete basecode_cat where cat='rmmaint_reason';
insert basecode_cat select 'rmmaint_reason', '客房维修原因', 'Room Maintn Reason', 3;
delete basecode where cat='rmmaint_reason';
insert basecode(cat,code,descript,descript1) select 'rmmaint_reason', 'WAT', '缺水', 'No Water';
insert basecode(cat,code,descript,descript1) select 'rmmaint_reason', 'ELE', '无电', 'No Electricity';
insert basecode(cat,code,descript,descript1) select 'rmmaint_reason', 'TEL', '电话坏', 'Phone Error';
insert basecode(cat,code,descript,descript1) select 'rmmaint_reason', 'MIN',  '酒吧坏', 'MiniBar Error';


// --------------------------------------------------------------------------
//  basecode : ocsta
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='ocsta')
	delete basecode_cat where cat='ocsta';
insert basecode_cat select 'ocsta', '客房占用状态', 'Room Occ. Status', 1;

delete basecode where cat='ocsta';
insert basecode(cat,code,descript,descript1,sys) select 'ocsta', 'O', 'Occ', 'Occ', 'T';
insert basecode(cat,code,descript,descript1,sys) select 'ocsta', 'V', 'Vac', 'Vac', 'T';


// --------------------------------------------------------------------------
//  basecode : hall
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='hall')
	delete basecode_cat where cat='hall';
insert basecode_cat select 'hall', '楼宇', 'Room Building', 1;

delete basecode where cat='hall';
insert basecode(cat,code,descript,descript1) select 'hall', '0', '主楼', 'Main Building';


// --------------------------------------------------------------------------
//  basecode : rmtag	 房间标志
// --------------------------------------------------------------------------
update basecode set sys='F' where cat='rmtag';
delete basecode where cat='rmtag';
delete basecode_cat where cat='rmtag';
insert basecode_cat(cat,descript,descript1,len) select 'rmtag', '房间标志', 'Room Flag', 1;
INSERT INTO basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) VALUES ('rmtag','K','客房','Guest Room','T','F',100,'','F');
INSERT INTO basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) VALUES ('rmtag','B','办公','Office Room1','T','F',200,'','F');
INSERT INTO basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) VALUES ('rmtag','X','写字间','Office Room2','T','F',300,'','F');
INSERT INTO basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) VALUES ('rmtag','G','公寓','mansion','T','F',400,'','F');
INSERT INTO basecode(cat,code,descript,descript1,sys,halt,sequence,grp,center) VALUES ('rmtag','P','假房','Pseudo','T','F',900,'','F');


// --------------------------------------------------------------------
//	Reservation code : gtype
// --------------------------------------------------------------------
if exists(select 1 from sysobjects where name='gtype' and type='U')
   drop table gtype;
create table gtype
(
   code				char(3)						not null,
   descript			varchar(30)					not null,
   descript1		varchar(30)	default ''	not null,
	tag				char(1)		default 'K'	not null,
	halt				char(1)		default 'F'	not null,
	cby				char(10)		default '' not null,
	changed			datetime		default getdate() not null, 
	sequence			int			default 0	not null
)
exec sp_primarykey gtype,code
create unique index index1 on gtype(code)
;
insert gtype(code,descript,descript1) select 'SIN', '单人间', 'Single';
insert gtype(code,descript,descript1) select 'DOU', '双人间', 'Double';
insert gtype(code,descript,descript1) select 'SUT', '套间', 'Suite';


// --------------------------------------------------------------------------
//  basecode : room region
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='hsregion')
	delete basecode_cat where cat='hsregion';
insert basecode_cat select 'hsregion', '客房区域', 'Room Region', 3;

delete basecode where cat='hsregion';
insert basecode(cat,code,descript,descript1) select 'hsregion', '0', '客房区域', 'Room Region';


// --------------------------------------------------------------------------
//  basecode : feature
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='feature')
	delete basecode_cat where cat='feature';
insert basecode_cat select 'feature', '客房特征', 'Room Feature', 3;

delete basecode where cat='feature';
insert basecode(cat,code,descript,descript1) select 'feature', 'NS', '无烟房', 'No Smoking';
insert basecode(cat,code,descript,descript1) select 'feature', 'SM', '吸烟房', 'Smoking';
insert basecode(cat,code,descript,descript1) select 'feature', 'SS', '淋浴', 'Stand Shower';
insert basecode(cat,code,descript,descript1) select 'feature', 'CV', '城景房', 'City View';
insert basecode(cat,code,descript,descript1) select 'feature', 'LV', '湖景房', 'Lake View';
insert basecode(cat,code,descript,descript1) select 'feature', 'CN', '连通房', 'Connecting Room';
insert basecode(cat,code,descript,descript1) select 'feature', 'BT', '浴盆', 'Bidet';
insert basecode(cat,code,descript,descript1) select 'feature', 'ADS', '宽带网', 'VOD & ADSL System';
insert basecode(cat,code,descript,descript1) select 'feature', 'HDC', '残疾房', 'Handicap';


// --------------------------------------------------------------------------
//  basecode : expend
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='expend')
	delete basecode_cat where cat='expend';
insert basecode_cat select 'expend', '消耗品', 'Room Expend', 3;

delete basecode where cat='expend';
insert basecode(cat,code,descript,descript1) select 'expend', '101', '牙具', 't';
insert basecode(cat,code,descript,descript1) select 'expend', '102', '拖鞋', 't';
insert basecode(cat,code,descript,descript1) select 'expend', '103', '香皂', 't';
insert basecode(cat,code,descript,descript1) select 'expend', '104', '浴帽', 't';


// --------------------------------------------------------------------------
//  basecode : jifen		参数积分
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='jifen')
	delete basecode_cat where cat='jifen';
insert basecode_cat select 'jifen', '清洁积分', 'Hswk Credit', 10;
delete basecode where cat='jifen';


// --------------------------------------------------------------------------
//  basecode : jineng	打扫技能
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='jineng')
	delete basecode_cat where cat='jineng';
insert basecode_cat select 'jineng', '技能值', 'Room Capability', 10;
delete basecode where cat='jineng';


// --------------------------------------------------------------------------
//  basecode : amenities
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='amenities')
	delete basecode_cat where cat='amenities';
insert basecode_cat select 'amenities', '客房布置', 'Room amenities', 3;

delete basecode where cat='amenities';
insert basecode(cat,code,descript,descript1) select 'amenities', 'SS', '淋浴', 'Stand Shower';
insert basecode(cat,code,descript,descript1) select 'amenities', 'BT', '浴盆', 'Bidet';
insert basecode(cat,code,descript,descript1) select 'amenities', 'ADS', '宽带网', 'VOD & ADSL System';
insert basecode(cat,code,descript,descript1) select 'amenities', 'FLR', '鲜花', 'Flower';
insert basecode(cat,code,descript,descript1) select 'amenities', 'FRT', '水果', 'Fruit';
insert basecode(cat,code,descript,descript1) select 'amenities', 'DIR', '中国日报', 'China Diary';


// --------------------------------------------------------------------------
//  basecode : sw_grade	失物等级
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='sw_grade')
	delete basecode_cat where cat='sw_grade';
insert basecode_cat select 'sw_grade', '失物等级', 'Lostings Grade', 1;
delete basecode where cat='sw_grade';

// --------------------------------------------------------------------------
//  basecode : sw_class	失物类别
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='sw_class')
	delete basecode_cat where cat='sw_class';
insert basecode_cat select 'sw_class', '失物类别', 'Lostings Class', 1;
delete basecode where cat='sw_class';

// --------------------------------------------------------------------------
//  basecode : sw_sta	失物状态
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='sw_sta')
	delete basecode_cat where cat='sw_sta';
insert basecode_cat select 'sw_sta', '失物状态', 'Lostings Status', 1;
delete basecode where cat='sw_sta';


//------------------------------------------------------------------------------
//		客房中心系列参数表
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'hs_sysdata')
	drop table hs_sysdata
;
create table  hs_sysdata(
	mapcode		varchar(10)		not null,  	// 客房中心房态表方案代码
	mbbase		numeric(10,0)	not null,	// 当天最新可用MINI吧帐号 
	xhbase		numeric(10,0)	not null,	// 当天最新可用消耗帐号 
	sbbase		numeric(10,0)	not null,	// 当天最新可用设备帐号 
	xybase		numeric(10,0)	not null,	// 当天最新可用洗衣帐号 
	oobase		numeric(10,0)	not null,	// 当天最新可用维修帐号 
	swbase		numeric(10,0)	not null,	// 当天最新可用失物帐号 
	pcbase		numeric(10,0)	not null,	// 当天最新可用赔偿帐号 
	habase		numeric(10,0)	not null,	// 当天最新可用HA帐号 
	hbbase		numeric(10,0)	not null,	// 当天最新可用HB帐号 
	hcbase		numeric(10,0)	not null,	// 当天最新可用HC帐号 
	mbstart		char(1) default 'F' not null,	// MB is running ?
	hstime1		datetime			null,			// 预留
	hstime2		datetime			null,			// 预留
	hstime3		datetime			null,			// 预留
	hstime4		datetime			null			// 预留
)
;

//declare @bdate datetime
//select @bdate = bdate1 from sysdata
//insert hs_sysdata values(	
//			'XR',
//			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
//			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
//			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
//			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
//			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
//			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
//			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
//			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
//			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
//			convert(numeric(10,0),substring(convert(char(4),datepart(yy,@bdate)),3,2) + substring(convert(char(3),datepart(mm,@bdate) + 100),2,2) + substring(convert(char(3),datepart(dd,@bdate)+100),2,2) + "0001"),
//			'F',
//			null,
//			null,
//			null,
//			null
//		   );
//
//select * from hs_sysdata;



//------------------------------------------------------------------------------
//		客房中心房态表设置参数
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'hs_mapparm')
	drop table hs_mapparm
;
create table  hs_mapparm (
	code			varchar(10)	not null,				
	rownum		int	default 0 not null,
	colnum		int	default 0 not null,
	rowspacing	int	default 0 not null,
	colspacing	int	default 0 not null,	
	width			int	default 0 not null,
	height		int	default 0 not null,
	zoom			int	default 0 not null,
	baseclr		money	default 0 not null,	// 基本色
	clsclr1		money	default 0 not null,	// 类别色 1-8
	clsclr2		money	default 0 not null,
	clsclr3		money	default 0 not null,
	clsclr4		money	default 0 not null,
	clsclr5		money	default 0 not null,
	clsclr6		money	default 0 not null,
	clsclr7		money	default 0 not null,
	clsclr8		money	default 0 not null,
	addclr1		money	default 0 not null,	// 附加色1-3
	addclr2		money	default 0 not null,
	addclr3		money	default 0 not null,
	maptip		int	default 16 not null	// 
)
exec sp_primarykey hs_mapparm, code
create unique index code on hs_mapparm(code)
;

//insert hs_mapparm
//	select 'XR', 11, 11, 100, 100, 1500, 800, 100, 
//	 	12639424,
//		32768,
//		8388608,
//		128,
//		32896,
//		16711680,
//		8388736,
//		65535,
//	 	12639424,
//		255,
//		15780518,    // 8421376
//		65280,
//		16;
//select * from hs_mapparm;

//   --------------------------  end ---------------------------------------------

// --------------------------------------------------------------------
//	Reservation code : flrcode
// --------------------------------------------------------------------
if exists(select 1 from sysobjects where name='flrcode' and type='U')
   drop table flrcode;
create table flrcode
(
   code				char(3)						not null,
   descript			varchar(30)					not null,
   descript1		varchar(30)	default ''	not null,
	ground_plan		varchar(60)	default ''	not null,	// 平面图
	halt				char(1)		default 'F' not null,
	cby				char(10)		default 'FOX' not null,
	changed			datetime		default getdate() not null, 
	sequence			int			default 0	not null
)
exec sp_primarykey flrcode,code
create unique index index1 on flrcode(code)
;
//insert flrcode select *, 0 from aa_flrcode;


// --------------------------------------------------------------------------
//	Reservation code : type
// --------------------------------------------------------------------------
if exists(select 1 from sysobjects where name='typim' and type='U')
   drop table typim;
create table typim
(
   type			char(5)						not null,
   descript		char(60)						not null,
   descript1	char(60)		default ''	not null,
   descript2	char(60)		default ''	not null,
   descript3	char(60)		default ''	not null,
   descript4	char(60)		default ''	not null,
   quantity		int			default 0	not null,
   overquan		int			default 0	not null,
   futdate		datetime	      			null,
   adjquan		int			default 0   not null,
	ratecode		char(10)		default ''	not null,
   rate			money			default 0	not null,
   futrate		money			default 0	not null,
   begin_		datetime						null	,
	hotelcode	char(10)		default ''	not null,	// 酒店代码
	sequence		int			default 0	not null,
	gtype			char(3)						not null,  	// 大房类
	tag			char(1)		default 'K'	not null,
	internal		int			default 0 	not null,	// 内部号
	yieldable	char(1)		default 'F'	not null,	// 限制策略
	yieldcat		char(3)		default ''	not null,
	crsthr		int			default 0	not null,	// 全球预订
	crsper		int			default 0	not null,
	pic			varchar(60)	default ''	not null,
	halt				char(1)		default 'F' not null,
	cby				char(10)		default 'FOX' not null,
	changed			datetime		default getdate() not null
)
exec sp_primarykey typim,type
create unique index index1 on typim(type)
;
//insert typim(type,descript,quantity,overquan,futdate,adjquan,rate,futrate,begin_,gtype)
//	select type,descript,quantity,overquan,futdate,adjquan,rate,futrate,begin_,'' from aa_typim;



// --------------------------------------------------------------------
//	Reservation code : rmsta, rmsta_till, rmsta_last, rmsta_log
//
// 		如何体现 8 种房态: 	CL = Clean					VR
//										DI = Dirty					VD
//										IS = Inspected				VI
//										TU = Touch Up				VT
//
//										OO = Out of Order			VM
//										OS = Out of Service		VL
//
//										OC = Occupy Clean			OR
//										OD = Occupy Dirty			OD
// --------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'rmsta' and type='U')
   drop table rmsta;
create table rmsta
(
   roomno		char(5)				    not null,
   oroomno		char(5)	default ''   not null,	//	内部房号
	hall			char(1)					 not null,	// 楼号
	flr			char(3)					 not null,	// 楼层
   rmreg		   char(3)	default ''   not null,	// 客房区域
   type		   char(5)				    not null,
	tag			char(1)	default 'K'	 not null,
   ocsta		   char(1)	default 'V'	 not null,
   oldsta		char(1)	default 'R'	 not null,
   sta			char(1)	default 'R'	 not null,
   tmpsta		char(1)	default ''	 not null,	// 临时态
   people		int		default 1    not null,
   bedno		   int		default 0    not null,
   special		char(1)	default 'F'  not null,	// 特殊房价
   ratecode	   char(10)	default ''	 not null,
   rate		   money		default 0    not null,
   feature		varchar(50)	default ''	not null,	// 客房特征
   locked		char(1)	default 'N'	 not null,	// 锁房
   futsta		char(1)	default ''   not null,	// 未来房态
   futbegin	   datetime			       null,
   futend		datetime			       null,
   fcdate      datetime              null,
   fempno      char(10)               null,
   onumber		int	   default 0	 null,
   number		int	   default 0	 null,
   accntset	   char(70)	default ''   null,
   futmark		char(1)	default 'F'  not null,	// 预设标志
   futdate		datetime		          null,		// 启用日期
   empty_days  int      default 0    not null,		// ?
	x				int		default 0	 not null,
	y				int		default 0	 not null,
	width			int		default 0	 not null,
	height		int		default 0	 not null,
	s1				char(3)	default ''	 not null,	// 预留字段
	s2				char(3)	default ''	 not null,
	s3				char(3)	default ''	 not null,
	s4				char(3)	default ''	 not null,
	n1				int		default 0	 not null,
	n2				int		default 0	 not null,
	n3				int		default 0	 not null,
	n4				int		default 0	 not null,
	ref			varchar(50)	default ''	null,		// 说明
	sequence		int		default 0	not null,
   empno		   char(10)				    not null,
   changed		datetime	default getdate()	not null,
   logmark     int      default 0	 not null
)
exec   sp_primarykey rmsta,roomno
create unique clustered index index1 on rmsta(roomno)
create unique index index2 on rmsta(oroomno)
create index index3 on rmsta(type)
create index index4 on rmsta(locked,type)
create index index5 on rmsta(changed)
create index index6 on rmsta(flr)
;
//insert rmsta
//  SELECT roomno,oroomno,hall,flr,f4,type,ocsta,oldsta,sta,f5,people,bedno,special,'',rate,'',
//	locked,futsta,futbegin,futend,fcdate,fempno,onumber,number,accntset,futmark,futdate,
//	isnull(empty_days,0),x,y,width,height,'','','','',0,0,0,0,ref,0,empno,cdate,logmark
//    from  aa_rmsta;
//update rmsta set tmpsta='' where tmpsta='E';

if exists (select 1 from sysobjects where name = 'rmsta_till' and type='U')
   drop table rmsta_till;
create table rmsta_till
(
   roomno		char(5)				    not null,
   oroomno		char(5)	default ''   not null,	//	内部房号
	hall			char(1)					 not null,	// 楼号
	flr			char(3)					 not null,	// 楼层
   rmreg		   char(3)	default ''   not null,	// 客房区域
   type		   char(5)				    not null,
	tag			char(1)	default 'K'	 not null,
   ocsta		   char(1)	default 'V'	 not null,
   oldsta		char(1)	default 'R'	 not null,
   sta			char(1)	default 'R'	 not null,
   tmpsta		char(1)	default ''	 not null,	// 临时态
   people		int		default 1    not null,
   bedno		   int		default 0    not null,
   special		char(1)	default 'F'  not null,	// 特殊房价
   ratecode	   char(10)	default ''	 not null,
   rate		   money		default 0    not null,
   feature		varchar(50)	default ''	not null,	// 客房特征
   locked		char(1)	default 'N'	 not null,	// 锁房
   futsta		char(1)	default ''   not null,	// 未来房态
   futbegin	   datetime			       null,
   futend		datetime			       null,
   fcdate      datetime              null,
   fempno      char(10)               null,
   onumber		int	   default 0	 null,
   number		int	   default 0	 null,
   accntset	   char(70)	default ''   null,
   futmark		char(1)	default 'F'  not null,	// 预设标志
   futdate		datetime		          null,		// 启用日期
   empty_days  int      default 0    not null,		// ?
	x				int		default 0	 not null,
	y				int		default 0	 not null,
	width			int		default 0	 not null,
	height		int		default 0	 not null,
	s1				char(3)	default ''	 not null,	// 预留字段
	s2				char(3)	default ''	 not null,
	s3				char(3)	default ''	 not null,
	s4				char(3)	default ''	 not null,
	n1				int		default 0	 not null,
	n2				int		default 0	 not null,
	n3				int		default 0	 not null,
	n4				int		default 0	 not null,
	ref			varchar(50)	default ''	null,		// 说明
	sequence		int		default 0	not null,
   empno		   char(10)				    not null,
   changed		datetime	default getdate()	not null,
   logmark     int      default 0	 not null
)
exec   sp_primarykey rmsta_till,roomno
create unique clustered index index1 on rmsta_till(roomno)
create unique index index2 on rmsta_till(oroomno)
create index index3 on rmsta_till(type)
create index index4 on rmsta_till(locked,type)
create index index5 on rmsta_till(changed)
create index index6 on rmsta_till(flr)
;

if exists (select 1 from sysobjects where name = 'rmsta_last' and type='U')
   drop table rmsta_last;
create table rmsta_last
(
   roomno		char(5)				    not null,
   oroomno		char(5)	default ''   not null,	//	内部房号
	hall			char(1)					 not null,	// 楼号
	flr			char(3)					 not null,	// 楼层
   rmreg		   char(3)	default ''   not null,	// 客房区域
   type		   char(5)				    not null,
	tag			char(1)	default 'K'	 not null,
   ocsta		   char(1)	default 'V'	 not null,
   oldsta		char(1)	default 'R'	 not null,
   sta			char(1)	default 'R'	 not null,
   tmpsta		char(1)	default ''	 not null,	// 临时态
   people		int		default 1    not null,
   bedno		   int		default 0    not null,
   special		char(1)	default 'F'  not null,	// 特殊房价
   ratecode	   char(10)	default ''	 not null,
   rate		   money		default 0    not null,
   feature		varchar(50)	default ''	not null,	// 客房特征
   locked		char(1)	default 'N'	 not null,	// 锁房
   futsta		char(1)	default ''   not null,	// 未来房态
   futbegin	   datetime			       null,
   futend		datetime			       null,
   fcdate      datetime              null,
   fempno      char(10)               null,
   onumber		int	   default 0	 null,
   number		int	   default 0	 null,
   accntset	   char(70)	default ''   null,
   futmark		char(1)	default 'F'  not null,	// 预设标志
   futdate		datetime		          null,		// 启用日期
   empty_days  int      default 0    not null,		// ?
	x				int		default 0	 not null,
	y				int		default 0	 not null,
	width			int		default 0	 not null,
	height		int		default 0	 not null,
	s1				char(3)	default ''	 not null,	// 预留字段
	s2				char(3)	default ''	 not null,
	s3				char(3)	default ''	 not null,
	s4				char(3)	default ''	 not null,
	n1				int		default 0	 not null,
	n2				int		default 0	 not null,
	n3				int		default 0	 not null,
	n4				int		default 0	 not null,
	ref			varchar(50)	default ''	null,		// 说明
	sequence		int		default 0	not null,
   empno		   char(10)				    not null,
   changed		datetime	default getdate()	not null,
   logmark     int      default 0	 not null
)
exec   sp_primarykey rmsta_last,roomno
create unique clustered index index1 on rmsta_last(roomno)
create unique index index2 on rmsta_last(oroomno)
create index index3 on rmsta_last(type)
create index index4 on rmsta_last(locked,type)
create index index5 on rmsta_last(changed)
create index index6 on rmsta_last(flr)
;


if exists (select 1 from sysobjects where name = 'rmsta_log' and type='U')
   drop table rmsta_log;
create table rmsta_log
(
   roomno		char(5)				    not null,
   oroomno		char(5)	default ''   not null,	//	内部房号
	hall			char(1)					 not null,	// 楼号
	flr			char(3)					 not null,	// 楼层
   rmreg		   char(3)	default ''   not null,	// 客房区域
   type		   char(5)				    not null,
	tag			char(1)	default 'K'	 not null,
   ocsta		   char(1)	default 'V'	 not null,
   oldsta		char(1)	default 'R'	 not null,
   sta			char(1)	default 'R'	 not null,
   tmpsta		char(1)	default ''	 not null,	// 临时态
   people		int		default 1    not null,
   bedno		   int		default 0    not null,
   special		char(1)	default 'F'  not null,	// 特殊房价
   ratecode	   char(10)	default ''	 not null,
   rate		   money		default 0    not null,
   feature		varchar(50)	default ''	not null,	// 客房特征
   locked		char(1)	default 'N'	 not null,	// 锁房
   futsta		char(1)	default ''   not null,	// 未来房态
   futbegin	   datetime			       null,
   futend		datetime			       null,
   fcdate      datetime              null,
   fempno      char(10)               null,
   onumber		int	   default 0	 null,
   number		int	   default 0	 null,
   accntset	   char(70)	default ''   null,
   futmark		char(1)	default 'F'  not null,	// 预设标志
   futdate		datetime		          null,		// 启用日期
   empty_days  int      default 0    not null,		// ?
	x				int		default 0	 not null,
	y				int		default 0	 not null,
	width			int		default 0	 not null,
	height		int		default 0	 not null,
	s1				char(3)	default ''	 not null,	// 预留字段
	s2				char(3)	default ''	 not null,
	s3				char(3)	default ''	 not null,
	s4				char(3)	default ''	 not null,
	n1				int		default 0	 not null,
	n2				int		default 0	 not null,
	n3				int		default 0	 not null,
	n4				int		default 0	 not null,
	ref			varchar(50)	default ''	null,		// 说明
	sequence		int		default 0	not null,
   empno		   char(10)				    not null,
   changed		datetime	default getdate()	not null,
   logmark     int      default 0	 not null
)
exec   sp_primarykey rmsta_log,roomno,logmark
create unique clustered index index1 on rmsta_log(roomno,logmark)
;



// --------------------------------------------------------------------
//	Reservation rmstalist : 房间状态表,现有或未来每个房间的状态
// --------------------------------------------------------------------
if exists(select * from sysobjects where name = "rmstalist" and type='U')
	drop table rmstalist;
create table rmstalist
(
   sta 		   char(1)     			not null,		/* 状态码 */
   descript    char(8)     			not null,		/* 描述   */
   descript1   char(12) default ''	not null,		/* 描述   */
   maintnmark  char(1)  default 'F'	not null,		/* 是否维护房 */
   instready  	char(1)  default 'T'	not null,		/* 是否启用。主要针对 I, T */
	sequence		int		default 0	not null
)
exec sp_primarykey rmstalist,sta
create unique clustered index rmstalist on rmstalist(sta)
;
insert into rmstalist values ('R','干净','Clean','F', 'T', 10)
insert into rmstalist values ('D','脏房','Dirty','F', 'T', 20)
insert into rmstalist values ('I','检查','Inspected','F', 'T', 30)
insert into rmstalist values ('T','Touch-Up','Touch-Up','F', 'T', 40)

insert into rmstalist values ('S','锁定','Lock','T', 'T', 50)
insert into rmstalist values ('O','维修','Maint','T', 'T', 60)
;


// --------------------------------------------------------------------
//	Reservation rmstalist1 : 客房临时状态表
// --------------------------------------------------------------------
if exists(select * from sysobjects where name = "rmstalist1" and type='U')
	drop table rmstalist1;
create table rmstalist1
(
   code 		   char(1)     			not null,
	cat			char(1)					not null,	// 类别: G-前台设置  H-客房中心设置
   descript    char(20)     			not null,
   descript1   char(30) default ''	not null,
	color			int		default 255	not null,
	rlock			char(1) 	default 'F' not null,	// 禁止预订
	ilock			char(1) 	default 'F' not null,	// 禁止入住
	sequence		int		default 0	not null,
	halt			char(1) 	default 'F' not null,
	cby			char(10) default 'FOX' not null,
	changed		datetime	default getdate() not null 
)
exec sp_primarykey rmstalist1,code
create unique clustered index rmstalist1 on rmstalist1(code)
;
insert into rmstalist1(code,cat,descript,descript1,color) values ('A','H','矛盾房','Problem',255)
insert into rmstalist1(code,cat,descript,descript1,color) values ('B','G','参观房','Visit',65535)
insert into rmstalist1(code,cat,descript,descript1,color) values ('C','H','领导用','Leader',65280)
insert into rmstalist1(code,cat,descript,descript1,color) values ('D','H','无行李','No bag',8388736)
insert into rmstalist1(code,cat,descript,descript1,color) values ('E','H','预  留','Reservation',16711935)
;



// --------------------------------------------------------------------
//	Reservation rmstamap : 状态对照表
// --------------------------------------------------------------------
if exists(select * from sysobjects where name = "rmstamap")
   drop table rmstamap;
create table rmstamap
(
	code		   char(2)	not null,
	eccocode    char(3)  not null	  // 各宾馆可以自定义
)
exec sp_primarykey rmstamap,code,eccocode
create unique clustered index index1 on rmstamap(code,eccocode)
;
insert rmstamap values ('VR','CL')
insert rmstamap values ('VD','DI')
insert rmstamap values ('VT','TU')
insert rmstamap values ('VI','IS')
insert rmstamap values ('VO','OO')
insert rmstamap values ('VS','OS')

insert rmstamap values ('OD','OD')
insert rmstamap values ('OR','OC')
insert rmstamap values ('OT','OC')
insert rmstamap values ('OI','OC')
insert rmstamap values ('OO','OC')
insert rmstamap values ('OS','OC')
;


// --------------------------------------------------------------------------
//  basecode : hs_empno
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='hs_empno')
	delete basecode_cat where cat='hs_empno';
insert basecode_cat select 'hs_empno', '客房服务员工', 'HSK Employee', 10;
delete basecode where cat='hs_empno';
insert basecode(cat,code,descript,descript1) select 'hs_empno', 'KITTY', 'KITTY','KITTY';
insert basecode(cat,code,descript,descript1) select 'hs_empno', 'MARRY', 'MARRY','MARRY';
insert basecode(cat,code,descript,descript1) select 'hs_empno', 'JONE', 'JONE','JONE';
insert basecode(cat,code,descript,descript1) select 'hs_empno', 'MIKE',  'MIKE', 'MIKE';

//---------------------------------------------------------------
//	客房清洁任务分配临时表
//---------------------------------------------------------------
if exists(select 1 from sysobjects where name='attendant_allot' and type='U')
	drop table attendant_allot;
create table attendant_allot(
			cdate			datetime					not null,
			empno			char(10)					null,
			attendant	integer					null,
			hall			char(1)					null,
			flr			char(3)					null,
			roomno 		char(5)					null,
			status		char(4)					null,
			people		integer	default 0	null,
			vip			char(3)					null,	
			credits		money		default 0	null
);
exec sp_primarykey attendant_allot,roomno;
create unique index index1 on attendant_allot(attendant,roomno);

//====================================================================
//这是一个房态表5的一个临时表 
//write by wz at 2003.07.01 
//====================================================================
drop table hsmap_new ;
create table hsmap_new (
	modu_id		char(2)						not null,
	pc_id			char(4)						not null,
	roomno		char(5)						not null,
	flr			char(3)						not null,
	type			char(5)						not null,
	ocsta			char(1)	default 'V' 	not null,
	sta			char(1)	default 'R' 	not null,
	main			char(3)	default ''		not null,
	ea				int		default 0		not null,
	ed				int		default 0		not null,
	flag			varchar(10)	default '' 	not null,
	limit			int		default 0 		not null,
	gstno			int		default 0		not null,
	tmpsta		char(1)	default ''			 null,
	groupno		char(10)	default ''		    null,
	extra			char(15)	default ''		    null,
	dep			datetime						not null,
	addbed		money		default 0  	not null,
	rate			money		default 0 		not null,
	phonesta		char(1)	default '0' 	not null,
	vsta			integer	default 1		not null,
	ar1			char(2)	default '' 		not null,
	ar2			char(2)	default '' 		not null
)
;
exec sp_primarykey hsmap_new,roomno;
create unique index index2 on hsmap_new(modu_id,pc_id,roomno);

//====================================================================
// 房态表5方案的表和sysoption表关联
//====================================================================
drop table hsmap_project;
create table hsmap_project(
			project		varchar(10)		         not null,
			colnum		integer	default 0		not null,
			rowspac		integer	default 0		not null,
			colspac 		integer 	default 0		not null,
			width			integer	default 0		not null,
			height		integer	default 0		not null,
			zoom			integer	default 0		not null,
			clr_d			money		default 0		not null,
			clr_m			money		default 0		not null,
			clr_v			money		default 0		not null,
			clr_o			money		default 0		not null,
			dw				varchar(30)	default ''  not null
);
//init
insert hsmap_project
	select 'STANDARD',8,18,18,440,288,100,8421504,65535,12639424,9830364,'d_wz_house_map_standard';
//insert sysoption select 'house','project','STANDARD','' ;

// ------------------------------------------------
//  查房表
// ------------------------------------------------
if exists(select * from sysobjects where type ="U" and name = "checkroom")
	drop table checkroom
;
create table checkroom
(
	type			char(1)	default '1' not null,					/* 业务类型
																					1.查房 */
	pc_id			char(4)	default ''	not null,					/* IP地址 */
	roomno		char(5)	default ''  not null,					/* 房号 */
	accnt			char(10)	default ''  null,							/* 账号 */
	sta			char(1)	default '0' not null,					/* 业务代码
																					0.总台申请查房
																					1.客房中心查房
																					9.查房完毕 */
	empno1		char(10)	default ''	null,							/* 申请工号 */
	date1			datetime	default getdate() not null,			/* 申请时间 */
	empno2		char(10)	default ''	null,							/* 答复工号 */
	date2			datetime	null,											/* 答复时间 */
	empno3		char(10)	default ''	null,							/* 完成工号 */
	date3			datetime	null,											/* 完成时间 */
	refer			varchar(100)	default ''	null					/* 备注 */
)
exec sp_primarykey checkroom, type, pc_id, roomno
create index index1 on checkroom(type, pc_id, roomno)
;

// ------------------------------------------------
// 控制查房, 开房信息的的工作站显示
// ------------------------------------------------
if exists(select * from sysobjects where type ="U" and name = "checkroomset")
	drop table checkroomset
;
create table checkroomset
(
	rcid		char(4)		not null,
	type		varchar(255)	 default '' not null,  	// 房类
	sdid		varchar(100) default '' not null,  		// 空表示所有
	halt			char(1) 	default 'F' not null,
	cby			char(10) default 'FOX' not null,
	changed		datetime	default getdate() not null 
)
exec sp_primarykey checkroomset, rcid
create index index1 on checkroomset(rcid)
;

-------------------------------------------------------------------------------
--	Discrepant Room  -- 矛盾房
-------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "discrepant_room" and type = 'U')
	drop table discrepant_room;
create table discrepant_room
(
	id			int			default 0			not null,
	sta		char(1)		default 'I'			not null,	   -- I, X
	roomno	char(5)								not null,
	hs_sta	char(1)								not null,
	fo_sta	char(1)								not null,
	remark	varchar(50)	default ''			not null,
	crtby		char(10)		default ''			not null,      -- 创建
   crttime	datetime		default getdate() not null,		-- 创建日期       
	cby		char(10)		default ''			not null,      -- 修改
   changed	datetime		default 				null				
)
exec sp_primarykey discrepant_room,id
create unique index index1 on discrepant_room(id)
create index index2 on discrepant_room(roomno,sta)
create index index3 on discrepant_room(cby)
create index index4 on discrepant_room(crttime)
;

-------------------------------------------------------------------------------
--	room_input  -- 房号录入
-------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "room_input" and type = 'U')
	drop table room_input;
create table room_input
(
	logdate	datetime		default getdate() not null,		-- 创建日期
	roomno	char(5)								not null,
	ocsta		char(1)								not null,	   -- V, O, M-维修, S-锁定
	empno		char(10)		default ''			not null,      -- 报告员工
	crtby		char(10)		default ''			not null,      -- 创建
	id			int			default 0			not null,		-- 矛盾房记录号码
)
exec sp_primarykey room_input,logdate,roomno
create unique index index1 on room_input(logdate,roomno)
create index index2 on room_input(roomno)
;


// --------------------------------------------------------------------
// 客户端客房动态选择
//		应用 : 房态表， 房态修改
// --------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'hsmap_term')
	drop table hsmap_term
;
create table hsmap_term (
	code			char(2)							not null,
	cat			char(1)							not null,	// 1-房态表， 2-房态修改
	descript		varchar(30)						not null,
	descript1	varchar(40)		default ''	not null,
	term			varchar(255)					not null,	// 条件描述
	sequence		int				default 0	not null
)
exec sp_primarykey hsmap_term, code
create unique index index1 on hsmap_term(code)
;
insert hsmap_term(cat,code,descript,term) select "1", "A1", "OCC", 	"select roomno from rmsta where ocsta='O'"
insert hsmap_term(cat,code,descript,term) select "1", "A2", "VC", 	"select roomno from rmsta where ocsta='V' and sta='R'"
insert hsmap_term(cat,code,descript,term) select "1", "A3", "VD", 	"select roomno from rmsta where ocsta='V' and sta='D'"
insert hsmap_term(cat,code,descript,term) select "1", "A4", "OOO", 	"select roomno from rmsta where ocsta='V' and sta in ('O','S')"
insert hsmap_term(cat,code,descript,term) select "1", "A5", "单床间", "select roomno from rmsta where bedno=1"
insert hsmap_term(cat,code,descript,term) select "1", "A6", "双床间", "select roomno from rmsta where bedno=2"
insert hsmap_term(cat,code,descript,term) select "1", "A8", "临时态", "select roomno from rmsta where not (tmpsta='E' or tmpsta='')"

insert hsmap_term(cat,code,descript,term) select "1", "B1", "自用房", "select roomno from master where sta='I' and class='Z'"
insert hsmap_term(cat,code,descript,term) select "1", "B2", "长包房", "select roomno from master where sta='I' and class='L'"
insert hsmap_term(cat,code,descript,term) select "1", "B3", "免费房", "select roomno from master where sta='I' and setrate*(1-discount1)=0"
insert hsmap_term(cat,code,descript,term) select "1", "B4", "本日将到", "select roomno from master where charindex(sta,'RCG')>0 and datediff(dd,getdate(),arr)<=0"
insert hsmap_term(cat,code,descript,term) select "1", "B5", "本日将离", "select roomno from master where sta='I' and datediff(dd,getdate(),dep)<=0"
insert hsmap_term(cat,code,descript,term) select "1", "B6", "当前散客房", "select roomno from master where groupno='' and charindex(sta,'RICG')>0 and datediff(dd,arr,getdate())>=0"
insert hsmap_term(cat,code,descript,term) select "1", "B7", "当前团体房", "select roomno from master where groupno<>'' and charindex(sta,'RICG')>0 and datediff(dd,arr,getdate())>=0"

insert hsmap_term(cat,code,descript,term) select "1", "C1", "外籍住客", "select a.roomno from master a, guest b where a.haccnt=b.no and a.sta='I' and b.nation<>'CHN'"
insert hsmap_term(cat,code,descript,term) select "1", "C2", "保密住客", "select a.roomno from master a, guest b where a.haccnt=b.no and a.sta='I' and secret='T'"
insert hsmap_term(cat,code,descript,term) select "1", "C3", "女住客", "select a.roomno from master a, guest b where a.haccnt=b.no and sta='I' and sex='2'"
insert hsmap_term(cat,code,descript,term) select "1", "C4", "年龄>=60", "select a.roomno from master a, guest b where a.haccnt=b.no and sta='I' and birth is not null and datediff(yy,birth,getdate())>=60"
//
//insert hsmap_term(cat,code,descript,term) select "1", "D1", "指定团队", "grpmst", "accnt='#char12!请输入团体账号或名称关键字#' or name like '%#char12#%'"

// 房态更改条件
insert hsmap_term(cat,code,descript,term) select "2", "U0", "空房", "select roomno from rmsta where ocsta='V' "
insert hsmap_term(cat,code,descript,term) select "2", "U1", "空房+脏", "select roomno from rmsta where ocsta='V' and sta='D' "
insert hsmap_term(cat,code,descript,term) select "2", "U2", "住客房", "select roomno from rmsta where ocsta='O' "
insert hsmap_term(cat,code,descript,term) select "2", "U3", "本日将到", "select distinct roomno from master where sta='R' and datediff(dd,arr,getdate())=0 and roomno<>'' "
insert hsmap_term(cat,code,descript,term) select "2", "U4", "本日将到+脏", "select distinct a.roomno from master a, rmsta b where a.sta='R' and datediff(dd,a.arr,getdate())=0 and a.roomno=b.roomno and b.sta='D' "
insert hsmap_term(cat,code,descript,term) select "2", "U5", "本日将离", "select distinct roomno from master where sta='I' and datediff(dd,dep,getdate())=0 and roomno<>'' "
insert hsmap_term(cat,code,descript,term) select "2", "U6", "本日退房", "select distinct roomno from master where sta='O' and roomno<>'' "
insert hsmap_term(cat,code,descript,term) select "2", "U7", "本日入住", "select distinct roomno from master where sta='I' and datediff(dd,arr,getdate())=0 and roomno<>'' "
insert hsmap_term(cat,code,descript,term) select "2", "V0", "临时态客房", "select roomno from rmsta where tmpsta<>'E' and tmpsta<>'' "
insert hsmap_term(cat,code,descript,term) select "2", "V1", "维修房", "select roomno from rmsta where sta='O' "
insert hsmap_term(cat,code,descript,term) select "2", "V2", "锁定房", "select roomno from rmsta where sta='S' "
;

// --------------------------------------------------------------------
// 房态表2 自定义条件 -- 结果
// --------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'hsmap_term_end')
	drop table hsmap_term_end
;
create table hsmap_term_end (
	modu_id		char(2)	not null,
	pc_id			char(4)	not null,
	cat			char(1)	not null,
	roomno		char(5)	not null
)
exec sp_primarykey hsmap_term_end, modu_id, pc_id, cat, roomno;
create unique index index1 on hsmap_term_end(modu_id, pc_id, cat, roomno)
;


//-----------------------------------------------------------------------
// 当前维护房档案
//
//		维护房管理表单 -- folio 唯一索引, 
//
//		提要：为了以后可能要与工程部联系，故库结构有如下变化
//			1。folio -- 唯一标志号，便于索引；
//			2. roomno + status('I') 唯一索引, 系统暂不支持一个房号同时有两张有效维修单;
//			3。工号分开，职责分明 ---- empno1, empno2, empno3
//			4。预留字段----- l1, l2
//			5。通过状态进行数据备份
//-----------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'rm_ooo')
	drop table rm_ooo
;
create table rm_ooo 
(
	folio		varchar(10)					not null,  // 流水号
	sfolio	varchar(10)	default''	not null,  // 单据号
	status	char(1)		default 'I' not null,  // 有效(I),解除(O),取消(X)
	roomno	char(5)						not null,
	oroomno	char(5)						not null,
	sta		char(1)						not null, // 维护态 --> O，S
	dbegin	datetime						not null,
	dend		datetime 					null,
	reason	char(3)						not null, // 原因
	remark	varchar(255)	default ''	not null, // 描述
	empno1	char(10)						not null, // 设定工号
	date1		datetime						not null,
	empno2	char(10)						null,	    // 维修工号
	date2		datetime						null,
	empno3	char(10)						null,	    // 解除工号
	date3		datetime						null,
	empno4	char(10)						null,	    // 取消工号
	date4		datetime						null,
	l1			varchar(10)					null,		
	l2			varchar(10)					null,		
	logmark	int			default 0 	not null
)
exec sp_primarykey rm_ooo, folio
create unique index index1 on rm_ooo(folio)
create index index2 on rm_ooo(roomno, status)  // I 状态必须唯一, 其他状态不一定
create  index index3 on rm_ooo(roomno, folio)
create  index index4 on rm_ooo(reason)
;
// 历史维护房档案
if exists (select 1 from sysobjects where name = 'hrm_ooo')
	drop table hrm_ooo;
select * into hrm_ooo from rm_ooo where 1=2;
exec sp_primarykey hrm_ooo, folio
create unique index index1 on hrm_ooo(folio)
create  index index2 on hrm_ooo(roomno, folio)
create  index index3 on hrm_ooo(reason)
;
// 维护房档案日志
if exists (select 1 from sysobjects where name = 'rm_ooo_log')
	drop table rm_ooo_log;
select * into rm_ooo_log from rm_ooo where 1=2;
exec sp_primarykey rm_ooo_log, folio, logmark
create unique index index1 on rm_ooo_log(folio, logmark)
;


//------------------------------------------------------------------------------
//		客房中心房态表颜色设置临时表
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'hs_mapclr')
	drop table hs_mapclr
;
create table  hs_mapclr (
	pc_id			char(4)			not null,
	modu_id		char(2)			not null,
	baseclr		money	default 0 not null,	// 基本色
	clsclr1		money	default 0 not null,	// 类别色 1-8
	clsclr2		money	default 0 not null,
	clsclr3		money	default 0 not null,
	clsclr4		money	default 0 not null,
	clsclr5		money	default 0 not null,
	clsclr6		money	default 0 not null,
	clsclr7		money	default 0 not null,
	clsclr8		money	default 0 not null,
	addclr1		money	default 0 not null,	// 附加色1-3
	addclr2		money	default 0 not null,
	addclr3		money	default 0 not null
)
exec sp_primarykey hs_mapclr, pc_id, modu_id
create unique index code on hs_mapclr(pc_id, modu_id)
;


//------------------------------------------------------------------------------------
// 客房实时房态表中, 存储选中的行
//------------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = 'hsmapsel' and type = 'U')
	drop table hsmapsel
;
create table hsmapsel
(
	pc_id		char(4)	null,
	modu_id	char(2)	null,
	irow 		integer	null
)
exec sp_primarykey hsmapsel, pc_id, modu_id, irow
create unique index index1 on hsmapsel(pc_id, modu_id, irow)
;

//------------------------------------------------------------------------------
//		客房部房态表 -- 传统方块房态表，应用最为普及得房态表
//		该表注意：不能创建任何主键和索引
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'hsmap')
	drop table hsmap
;
create table hsmap (
	pc_id		char(4) not null,
	modu_id	char(2) not null,
	roomno	char(5) not null,
	oroomno	char(5) not null,
	flr		char(3) not null,
	bu			char(1) default 'F' not null,    // 补充的
	base		char(1) default '' not null,  	// 基本状态
	ad1		char(1) default '' not null,		// 附加状态  --  房态中的临时态
	ad2		char(1) default '' not null,		// 附加状态  --  将来
	ad3		char(1) default '' not null,		// 附加状态  --  将走
	box		char(1) default '' not null,		// 边框
	num0		smallint	default 0 not null,
	num1		smallint	default 0 not null,
	num2		smallint	default 0 not null,
	num3		smallint	default 0 not null,
	num4		smallint	default 0 not null,
	num5		smallint	default 0 not null,
	num6		smallint	default 0 not null,
	num7		smallint	default 0 not null,
	adn1		smallint	default 0 not null,		// number of ad1
	adn2		smallint	default 0 not null,		// number of ad2
	adn3		smallint	default 0 not null		// number of ad3
)

//------------------------------------------------------------------------------
//		客房部房态表  -- 描述
//------------------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'hsmap_des')
	drop table hsmap_des
;
create table hsmap_des (
	pc_id		char(4) not null,
	modu_id	char(2) not null,
	base0		char(4) null,
	base1		char(4) null,
	base2		char(4) null,
	base3		char(4) null,
	base4		char(4) null,
	base5		char(4) null,
	base6		char(4) null,
	base7		char(4) null,
	ad1		char(4) null,
	ad2		char(4) null,
	ad3		char(4) null
)

// --------------------------------------------------------------------
// 为了楼层换行,进行的虚拟房号的插入
// --------------------------------------------------------------------
if exists (select 1 from sysobjects where name = 'hsmap_bu')
	drop table hsmap_bu
;
create table hsmap_bu (
	modu_id		char(2)	not null,
	pc_id			char(4)	not null,
	oroomno		char(5)	not null,
	flr			char(3)	not null
)
exec sp_primarykey hsmap_bu, modu_id, pc_id, oroomno;
create unique index index1 on hsmap_bu(modu_id, pc_id, oroomno)
;

// --------------------------------------------------------------------
//	临时态
// --------------------------------------------------------------------
IF OBJECT_ID('rmtmpsta') IS NOT NULL
    DROP TABLE rmtmpsta
;
CREATE TABLE rmtmpsta 
(
    roomno char(5)     NOT NULL,
    tmpsta char(1)     NOT NULL,
    remark varchar(60) NULL,
    empno  char(10)     NULL,
    date   datetime    NULL
);
EXEC sp_primarykey 'rmtmpsta', roomno;
CREATE UNIQUE NONCLUSTERED INDEX index1  ON rmtmpsta(roomno);
// 历史临时态
if exists (select 1 from sysobjects where name = 'hrmtmpsta')
	drop table hrmtmpsta;
CREATE TABLE hrmtmpsta 
(
    roomno char(5)     NOT NULL,
    tmpsta char(1)     NOT NULL,
    remark varchar(60) NULL,
    empno  char(10)    NULL,
    date   datetime    NULL,
    empno1 char(10)    NULL,
    date1  datetime    NULL,
	 status char(1)	  NULL
);
exec sp_primarykey hrmtmpsta, roomno,date1;
create unique index index1 on hrmtmpsta(roomno,date1)
;

IF OBJECT_ID('hsmap_bu_cond') IS NOT NULL
    DROP TABLE hsmap_bu_cond
;
CREATE TABLE hsmap_bu_cond 
(
    modu_id char(2) NOT NULL,
    pc_id   char(4) NOT NULL,
    hall    char(1) NULL,
    type    char(5) NULL,
    flr     char(3) NULL
)
EXEC sp_primarykey 'hsmap_bu_cond', modu_id,pc_id
CREATE UNIQUE NONCLUSTERED INDEX index1   ON hsmap_bu_cond(modu_id,pc_id)
;

IF OBJECT_ID('rmstarep') IS NOT NULL
    DROP TABLE rmstarep
;
CREATE TABLE rmstarep 
(
    pc_id   char(4)  NOT NULL,
    modu_id char(2)  NOT NULL,
    type    char(5)  NOT NULL,
    flr     char(3)  NOT NULL,
    roomno  char(5)  NOT NULL,
    sta     char(3)  NOT NULL,
    bksta   char(12) NULL,
    locked1 char(1)  NULL,
    locksta char(1)  NOT NULL,
    v01     char(2)  NULL,
    v02     char(2)  NULL,
    v03     char(2)  NULL,
    v04     char(2)  NULL,
    v05     char(2)  NULL,
    v06     char(2)  NULL,
    v07     char(2)  NULL,
    v08     char(2)  NULL,
    v09     char(2)  NULL,
    v10     char(2)  NULL,
    v11     char(2)  NULL,
    v12     char(2)  NULL,
    v13     char(2)  NULL,
    v14     char(2)  NULL,
    v15     char(2)  NULL
)
EXEC sp_primarykey 'rmstarep', pc_id,modu_id,roomno
CREATE UNIQUE NONCLUSTERED INDEX index1    ON rmstarep(pc_id,modu_id,roomno)
;


//------------------------------------------------------------------------------
//		客房中心清洁员工作分配表，目前新增3张
//------------------------------------------------------------------------------
IF OBJECT_ID('task_assignment') IS NOT NULL
    DROP TABLE task_assignment
;
CREATE TABLE task_assignment
       (no money NOT NULL,
       rmno char(8) NOT NULL,
       rmtype char(8) NULL,
       lou char(6) NULL,
       floor char(6) NULL,
       guestname char(60) NULL,
       vip char(15) NULL,
       foreigner char(20) NULL,
       rmamenities char(80) NULL,
       rmsta char(4) NULL,
       points money NULL,
       attendantid char(10) NULL,
       attendantname char(20) NULL,
       checked char(4) NULL,
       specialflag char(4) NULL,
       expendable char(80) NULL,
       cleantime datetime NULL,
       assigntime datetime NULL,
       beizhu char(80) NULL,
       beizhu2 char(80) NULL,
       assignman char(20) NULL,
       checkman char(20) NULL,
       usedtime int NULL,
       ocsta char(4) NULL,
       newsta char(4) NULL,
       changetime datetime NULL,
       changer char(20) NULL,
       e1 integer NULL,
       e2 integer NULL,
       e3 integer NULL,
       e4 integer NULL,
       e5 integer NULL,
       e6 integer NULL,
       e7 integer NULL,
       e8 integer NULL,
       e9 integer NULL,
       e10 integer NULL,
       e11 integer NULL,
       e12 integer NULL,
       e13 integer NULL,
       e14 integer NULL,
       e15 integer NULL,
       e16 integer NULL,
       e17 integer NULL,
       e18 integer NULL,
       e19 integer NULL,
       e20 integer NULL,
       e21 integer NULL,
       e22 integer NULL,
       e23 integer NULL,
       e24 integer NULL,
       e25 integer NULL,
       e26 integer NULL,
       e27 integer NULL,
       e28 integer NULL,
       e29 integer NULL,
       e30 integer NULL,
		 accnt char(10) NULL) ; 
EXEC sp_primarykey 'task_assignment',
       'no' ;

IF OBJECT_ID('attendant_info') IS NOT NULL
    DROP TABLE attendant_info
;
CREATE TABLE attendant_info
       (no int NULL,
       id char(10) NOT NULL,
       name varchar(30) NOT NULL,
       name2 varchar(30) NULL,
       hall varchar(10) NULL,
       flr varchar(60) NULL,
       english int NULL,
       capability money NULL,
       totalpoints money NULL,
       other varchar(60) NULL,
       sta char(5) NULL,
       changetime datetime NULL,
       changer char(5) NULL) ; 
EXEC sp_primarykey 'attendant_info',
       'id' ;

IF OBJECT_ID('task_rooms') IS NOT NULL
    DROP TABLE task_rooms
;
CREATE TABLE task_rooms
       (roomno char(6) NOT NULL) ;



------------------------------------------------
--	hall_station 
------------------------------------------------
//exec sp_rename hall_station, a_hall_station; 
if object_id('hall_station') is not null 
	drop TABLE hall_station ; 
CREATE TABLE hall_station 
(
    pc_id char(4)      NOT NULL,
    halls varchar(30)  NULL,
    types varchar(100) NULL
);
EXEC sp_primarykey 'hall_station', pc_id;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON hall_station(pc_id);
//insert hall_station select * from a_hall_station; 
//drop table a_hall_station; 
//select * from hall_station; 


------------------------------------------------
--	hall_station_user 
------------------------------------------------
if object_id('hall_station_user') is not null 
	drop TABLE hall_station_user ; 
CREATE TABLE hall_station_user 
(
    empno char(10)      NOT NULL,
    halls varchar(255)  NULL,
    types varchar(255) 	NULL
);
EXEC sp_primarykey 'hall_station_user', empno;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON hall_station_user(empno);
insert hall_station_user(empno, halls, types) 
	select code, descript, descript1 from basecode where cat='rmscope'; 
select * from hall_station_user; 


