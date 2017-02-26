-- 新的报表历史数据存放
-- 月报(每日数据)
if exists(select * from sysobjects where name = "statistic_m")
	drop table statistic_m;
create table statistic_m(
	year				integer				Not Null,
	month				integer				Not Null,
	cat				char(30)				Not Null,
	grp				char(10)				Default '' Not Null,
	code				char(10)				Default '' Not Null,
	day01				money					Default 0 Not Null,
	day02				money					Default 0 Not Null,
	day03				money					Default 0 Not Null,
	day04				money					Default 0 Not Null,
	day05				money					Default 0 Not Null,
	day06				money					Default 0 Not Null,
	day07				money					Default 0 Not Null,
	day08				money					Default 0 Not Null,
	day09				money					Default 0 Not Null,
	day10				money					Default 0 Not Null,
	day11				money					Default 0 Not Null,
	day12				money					Default 0 Not Null,
	day13				money					Default 0 Not Null,
	day14				money					Default 0 Not Null,
	day15				money					Default 0 Not Null,
	day16				money					Default 0 Not Null,
	day17				money					Default 0 Not Null,
	day18				money					Default 0 Not Null,
	day19				money					Default 0 Not Null,
	day20				money					Default 0 Not Null,
	day21				money					Default 0 Not Null,
	day22				money					Default 0 Not Null,
	day23				money					Default 0 Not Null,
	day24				money					Default 0 Not Null,
	day25				money					Default 0 Not Null,
	day26				money					Default 0 Not Null,
	day27				money					Default 0 Not Null,
	day28				money					Default 0 Not Null,
	day29				money					Default 0 Not Null,
	day30				money					Default 0 Not Null,
	day31				money					Default 0 Not Null,
	day99				money					Default 0 Not Null,
	hotelid			varchar(20)			default '' Not Null
)
exec sp_primarykey statistic_m, year, month, cat, grp, code
create unique index index1 on statistic_m(year, month, cat, grp, code)
;
//-- 年报(每月数据)
//if exists(select * from sysobjects where name = "statistic_y")
//	drop table statistic_y;
//create table statistic_y(
//	year				integer				Not Null,
//	cat				char(30)				Not Null,
//	grp				char(10)				Default '' Not Null,
//	code				char(10)				Default '' Not Null,
//	month01_1		money					Default 0 Not Null,
//	month02_1		money					Default 0 Not Null,
//	month03_1		money					Default 0 Not Null,
//	month04_1		money					Default 0 Not Null,
//	month05_1		money					Default 0 Not Null,
//	month06_1		money					Default 0 Not Null,
//	month07_1		money					Default 0 Not Null,
//	month08_1		money					Default 0 Not Null,
//	month09_1		money					Default 0 Not Null,
//	month10_1		money					Default 0 Not Null,
//	month11_1		money					Default 0 Not Null,
//	month12_1		money					Default 0 Not Null,
//	month99_1		money					Default 0 Not Null,				-- 以上为物理日期
//	month01_2		money					Default 0 Not Null,
//	month02_2		money					Default 0 Not Null,
//	month03_2		money					Default 0 Not Null,
//	month04_2		money					Default 0 Not Null,
//	month05_2		money					Default 0 Not Null,
//	month06_2		money					Default 0 Not Null,
//	month07_2		money					Default 0 Not Null,
//	month08_2		money					Default 0 Not Null,
//	month09_2		money					Default 0 Not Null,
//	month10_2		money					Default 0 Not Null,
//	month11_2		money					Default 0 Not Null,
//	month12_2		money					Default 0 Not Null,
//	month99_2		money					Default 0 Not Null,				-- 以上为会计日期
//	hotelid			varchar(20)			default '' Not Null
//)
//exec sp_primarykey statistic_y, year, cat, grp, code
//create unique index index1 on statistic_y(year, cat, grp, code)
//;
-- 年报(每月数据)
if exists(select * from sysobjects where name = "statistic_y")
	drop table statistic_y;
create table statistic_y(
	year				integer				Not Null,
	cat				char(30)				Not Null,
	grp				char(10)				Default '' Not Null,
	code				char(10)				Default '' Not Null,
	month01			money					Default 0 Not Null,
	month02			money					Default 0 Not Null,
	month03			money					Default 0 Not Null,
	month04			money					Default 0 Not Null,
	month05			money					Default 0 Not Null,
	month06			money					Default 0 Not Null,
	month07			money					Default 0 Not Null,
	month08			money					Default 0 Not Null,
	month09			money					Default 0 Not Null,
	month10			money					Default 0 Not Null,
	month11			money					Default 0 Not Null,
	month12			money					Default 0 Not Null,
	month99			money					Default 0 Not Null,
	hotelid			varchar(20)			default '' Not Null
)
exec sp_primarykey statistic_y, year, cat, grp, code
create unique index index1 on statistic_y(year, cat, grp, code)
;
-- 指标描述
if exists(select * from sysobjects where name = "statistic_i")
	drop table statistic_i;
create table statistic_i(
	cat				char(30)				Not Null,
	descript			varchar(50)			Default '' Null,
	descript1		varchar(50)			Default '' Null,
	sequence			integer				Default 0 Null,
	center			char(1)				Default 'F' Null,					-- 是否需要上传
	idescript		varchar(50)			Default '' Null,
	idescript1		varchar(50)			Default '' Null,
	operator			char(1)				Default '' Null,
	cat1				varchar(255)		Default '' Null,
	cat2				varchar(255)		Default '' Null,
	display			char(1)				Default '' Null,					-- 是否显示
)
exec sp_primarykey statistic_i, cat
create unique clustered index index1 on statistic_i(cat)
;
-- 代码描述
if exists(select * from sysobjects where name = "statistic_c")
	drop table statistic_c;
create table statistic_c(
	cat				char(30)				Not Null,
	grp				char(10)				Default '' Not Null,
	grp_descript	varchar(50)			Default '' Null,
	grp_descript1	varchar(50)			Default '' Null,
	grp_sequence	integer				Default 0 Null,
	code				char(10)				Default '' Not Null,
	code_descript	varchar(50)			Default '' Null,
	code_descript1	varchar(50)			Default '' Null,
	code_sequence	integer				Default 0 Null,
	bdate				datetime				Default '2000/1/1' Not Null,
)
exec sp_primarykey statistic_c, cat, grp, code, bdate
create unique index index1 on statistic_c(cat, grp, code, bdate)
;
-- 临时数据
if exists(select * from sysobjects where name = "statistic_t")
	drop table statistic_t;
create table statistic_t(
	pc_id				char(4)				Not Null,
	cat				char(30)				Not Null,
	grp				char(10)				Default '' Not Null,
	code				char(10)				Default '' Not Null,
	tag				char(10)				Default 'F' Not Null,			-- 临时标志
	amount			money					Default 0 Not Null
)
exec sp_primarykey statistic_t, pc_id, cat, grp, code
create unique index index1 on statistic_t(pc_id, cat, grp, code)
;
-- 打印数据
if exists(select * from sysobjects where name = "statistic_p")
	drop table statistic_p;
create table statistic_p(
	pc_id				char(4)				Not Null,
	date				datetime				default '2000/1/1' Not Null,
	year				integer				Default 0 Not Null,
	cat				char(30)				Default '' Not Null,
	cat_descript	varchar(50)			Default '' Null,
	cat_descript1	varchar(50)			Default '' Null,
	cat_sequence	integer				Default 0 Null,
	grp				char(10)				Default '' Not Null,
	grp_descript	varchar(50)			Default '' Null,
	grp_descript1	varchar(50)			Default '' Null,
	grp_sequence	integer				Default 0 Null,
	code				char(10)				Default '' Not Null,
	code_descript	varchar(50)			Default '' Null,
	code_descript1	varchar(50)			Default '' Null,
	code_sequence	integer				Default 0 Null,
	display			char(1)				Default 'T' Not Null,
	selected			integer				Default 0 Not Null,
	amount01			money					Default 0 Not Null,
	amount02			money					Default 0 Not Null,
	amount03			money					Default 0 Not Null,
	amount04			money					Default 0 Not Null,
	amount05			money					Default 0 Not Null,
	amount06			money					Default 0 Not Null,
	amount07			money					Default 0 Not Null,
	amount08			money					Default 0 Not Null,
	amount09			money					Default 0 Not Null,
	amount10			money					Default 0 Not Null,
	amount11			money					Default 0 Not Null,
	amount12			money					Default 0 Not Null,
	amount13			money					Default 0 Not Null,
	amount14			money					Default 0 Not Null,
	amount15			money					Default 0 Not Null,
	amount16			money					Default 0 Not Null,
	amount17			money					Default 0 Not Null,
	amount18			money					Default 0 Not Null,
	amount19			money					Default 0 Not Null,
	amount20			money					Default 0 Not Null,
	amount21			money					Default 0 Not Null,
	amount22			money					Default 0 Not Null,
	amount23			money					Default 0 Not Null,
	amount24			money					Default 0 Not Null,
	amount25			money					Default 0 Not Null,
	amount26			money					Default 0 Not Null
)
create index index1 on statistic_p(pc_id, year, cat, grp, code, display)
create index index2 on statistic_p(pc_id, date)
;
