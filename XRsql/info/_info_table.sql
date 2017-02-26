/* 预先定义的总经理查询 */

if exists(select * from sysobjects where type = 'U' and name = 'info_msgraph')
   drop table info_msgraph;

create table info_msgraph
(
	id				integer			not null,					/*序号*/
	descript		varchar(40)		not null,					/*描述*/
	descript1	varchar(40)		not null,					/*描述*/
	source		char(10)			not null,					/*数据源*/
	parms			varchar(255)	null,							/*CLASS*/
	legend		char(3)			not null						/*图例*/
)
exec sp_primarykey info_msgraph, id
create unique index index1 on info_msgraph(id)
create unique index index2 on info_msgraph(descript)
;
INSERT INTO info_msgraph VALUES (	0,	'本月房价走势','本月房价走势',	'jourrep',	'-D#010180;010190;010200;010210;010220#平均房价走势#本月',	'060');
INSERT INTO info_msgraph VALUES (	110,	'本年出租率走势','本年出租率走势',	'jourrep',	'-D#010080;010090;010100;010110;010120#出租率走势#本年',	'070');
INSERT INTO info_msgraph VALUES (	120,	'本周收入分析','本周收入分析',	'jourrep',	'-D#000005;000010;000015;000018;000020#** 饭店净收入**明细#本周',	'170');
INSERT INTO info_msgraph VALUES (	130,	'本月收入走势','本月收入走势',	'jourrep',	'-D#000050#饭店净收入走势#本月',	'130');
INSERT INTO info_msgraph VALUES (	310,	'宾客来源分析','宾客来源分析',	'mktrep',	'class1#4',	'110');
INSERT INTO info_msgraph VALUES (	320,	'宾客来源分析(散客)','宾客来源分析(散客)',	'mktrep',	'A#4',	'110');
INSERT INTO info_msgraph VALUES (	330,	'宾客来源分析(团体)','宾客来源分析(团体)',	'mktrep',	'G#4',	'110');
INSERT INTO info_msgraph VALUES (	410,	'宾客构成分析','宾客构成分析',	'gststa',	'zt#nw',	'110');
INSERT INTO info_msgraph VALUES (	420,	'宾客构成分析(外宾)','宾客构成分析(外宾)',	'gststa',	'zt#jw',	'110');
INSERT INTO info_msgraph VALUES (	430,	'宾客构成分析(国内)','宾客构成分析(国内)',	'gststa',	'zt#jn',	'110');
INSERT INTO info_msgraph VALUES (	440,	'宾客构成分析(省内)','宾客构成分析(省内)',	'gststa',	'zt#sn',	'110');

/* 预先定义的图例 */

if exists(select * from sysobjects where type = 'U' and name = 'info_legend')
   drop table info_legend;

create table info_legend
(
	code			char(3)				not null,					/*图例*/
	descript		varchar(60)			not null,					/*中文描述*/
	descript1	varchar(60)			not null,					/*英文描述*/
	filename		varchar(255)		not null						/*文件名*/
)
exec   sp_primarykey info_legend, code
create unique index index1 on info_legend(code)
;

insert info_legend values ( '010', '自然条形图', '自然条形图', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '020', '对数图', '对数图', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '030', '柱状-面积图', '柱状-面积图', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '040', '两轴折线图', '两轴折线图', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '050', '两轴线-柱图', '两轴线-柱图', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '060', '线-柱图', '线-柱图', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '070', '平滑直线图', '平滑直线图', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '080', '圆锥图', '圆锥图', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '090', '蜡笔图', '蜡笔图', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '100', '管状图', '管状图', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '110', '分裂的饼图', '分裂的饼图', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '120', '彩色堆积图', '彩色堆积图', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '130', '带深度的柱形图', '带深度的柱形图', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '140', '蓝色饼图', '蓝色饼图', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '150', '悬浮的条形图', '悬浮的条形图', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '160', '彩色折线图', '彩色折线图', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '170', '带图表的柱形图', '带图表的柱形图', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '180', '黑白折线图—时间刻度', '黑白折线图—时间刻度', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '190', '黑白面积图', '黑白面积图', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '200', '黑白饼图', '黑白饼图', 'c:\syhis\legend\foxhis.xls')
;

/* INFO 比较分析时间段 */

if exists(select * from sysobjects where name = 'diff_date')
	drop table diff_date;

create table diff_date
(
	pc_id			char(4)			not null,
	modu_id		char(2)			not null,
	s_date		datetime			not null,
	e_date		datetime			not null,
	t_des			varchar(20)		not null
)
exec sp_primarykey diff_date, pc_id, modu_id, s_date, e_date, t_des
create unique index index1 on diff_date(s_date, pc_id, modu_id, e_date, t_des)
;
/*  */

if exists ( select * from sysobjects where name = 'info_analyze' and type ='U')
	drop table info_analyze;
create table info_analyze
(
	pc_id			char(4)			not null, 
	modu_id		char(2)			not null, 
	date			datetime			not null,
	class			char(8)			not null,
	descriptx	char(16)			null,
	descripty	char(8)			null,
	value			money				default 0 null
)
exec sp_primarykey info_analyze, pc_id, modu_id, date, class
create unique index index1 on info_analyze(pc_id, modu_id, date, class)

/*  */

if exists ( select * from sysobjects where name = 'info_pmsgraph' and type ='U')
	drop table info_pmsgraph;
create table info_pmsgraph
(
	pc_id			char(4)		not null, 
	modu_id		char(2)		not null, 
	date			datetime		not null, 
	descript		char(16)		default '' null, 
	v1				money			default 0 null, 
	v2				money			default 0 null, 
	v3				money			default 0 null, 
	v4				money			default 0 null, 
	v5				money			default 0 null, 
	v6				money			default 0 null, 
	v7				money			default 0 null, 
	v8				money			default 0 null, 
	v9				money			default 0 null, 
	v10			money			default 0 null, 
	v11			money			default 0 null, 
	v12			money			default 0 null, 
	v13			money			default 0 null, 
	v14			money			default 0 null, 
	v15			money			default 0 null, 
	v16			money			default 0 null, 
	v17			money			default 0 null, 
	v18			money			default 0 null, 
	v19			money			default 0 null, 
	v20			money			default 0 null, 
	v21			money			default 0 null, 
	v22			money			default 0 null, 
	v23			money			default 0 null, 
	v24			money			default 0 null, 
	v25			money			default 0 null, 
	v26			money			default 0 null, 
	v27			money			default 0 null, 
	v28			money			default 0 null, 
	v29			money			default 0 null, 
	v30			money			default 0 null, 
	v31			money			default 0 null, 
	v32			money			default 0 null, 
	v33			money			default 0 null, 
	v34			money			default 0 null, 
	v35			money			default 0 null, 
	v36			money			default 0 null, 
	v37			money			default 0 null, 
	v38			money			default 0 null, 
	v39			money			default 0 null, 
	v40			money			default 0 null, 
	vtl			money			default 0 null 
)
exec sp_primarykey info_pmsgraph, pc_id, modu_id, date
create unique index index1 on info_pmsgraph(pc_id, modu_id, date)
;

