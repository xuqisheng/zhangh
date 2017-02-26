
// ------------------------------------------------------------------------------
//	appid : FOXHIS 系统应用编码
// ------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "appid")
	drop table appid;
create table appid
(
	code			char(1)						not null,
	moduno		char(2)		default ''	not null,
	descript    varchar(20)					not null,
	descript1   varchar(30)	default ''	not null,
   ref			varchar(20)	default ''	not null,
	exename		varchar(20)	default ''	not null
);
exec sp_primarykey appid,code,moduno
create unique index index1 on appid(code,moduno)
;
insert appid select '1', '', '前台系统', 'Front Office', '','front'
insert appid select '2', '', '维护系统', 'Maintance System', '','maint'
insert appid select '3', '', '餐饮系统', 'Food System', '','pos'
insert appid select '4', '', '娱乐系统', 'Entertainment System', '',''
insert appid select '6', '', '电话系统', 'Phone System', '','phone'
insert appid select '8', '', '桑拿系统', 'Suna System', '','sunna'
insert appid select '9', '', '应收系统', 'AR System', '',''
insert appid select 'A', '', '物流系统', 'FOXHIS SCM', '','supply'
insert appid select 'B', '', '成本核算系统', '成本核算_eng', '','cost'
insert appid select 'C', '', '设备管理系统', '设备管理_eng', '',''
insert appid select 'V', '', 'VOD 系统', 'VOD System_eng', '','vod'
insert appid select 'K', '', 'VIP 系统', 'VIP System_eng', '','vip'
;
// --------------------------------------------------------------------
//	toolbar_cat : 系统主窗口上方大工具条
//						同时也是系统模块的定义
//
//			appid		-- 应用编号
//			moduno	-- 应用内部的模块编号  moduno=00 系统定义用
//
//		针对这个大工具条的脚本定义，由程序员根据code编写，这里不作定义。
// --------------------------------------------------------------------
if exists(select * from sysobjects where name = "toolbar_cat" and type = 'U')
	drop table toolbar_cat;
create table toolbar_cat
(
	code			char(12)						not null,	// 标记
	descript    varchar(30)					not null,	// 中文描述
	descript1   varchar(40)	default ''	not null,	// 英文描述
	appid			char(1)		default ''	not null,	// 应用编号：1-前台系统，2-餐饮系统等；
	moduno   	char(2)		default ''	not null,	// 模块编号 -- 可以为空串，表示不是模块，比如 exit
	pic			varchar(20)	default ''	not null,	// 图像名称关键字
	show			char(1)		default 'T'	not null,	// 采用？
	lic			varchar(20)	default ''	not null,
	sequence		int			default 0	not null
)
exec sp_primarykey toolbar_cat,appid,code
create unique index index1 on toolbar_cat(appid,code)
;
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '',  'system',  '系统',		'system',		'00',	'',			0;

// 以下是定义前台系统总工具条
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '1', 'reserve',	'预订',		'Reserve',		'01',	'res',		10;
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '1', 'recept', 	'接待',		'Recept',		'02',	'recept',	20;
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '1', 'casher', 	'收银',		'Casher',		'03',	'cash',		30;
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '1', 'pubmkt', 	'公关销售',	'P&R Market',	'04',	'sale',		40;
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '1', 'house',  	'客房中心',	'House',			'05',	'house',		50;
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '1', 'business','商务中心',	'Business',		'06',	'bus',		60;
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '1', 'polite', 	'礼宾',		'Polite',		'07',	'car',		70;
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '1', 'audit',   '帐务审核',	'Audit',			'08',	'check',		80;
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '1', 'info',  	'信息查询',	'Information',	'09',	'query',		90;
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '1', 'other',   '其他',		'Other',			'10',	'flower',	100;
insert toolbar_cat(appid,code,descript,descript1,moduno,pic,sequence) select '1', 'exit',   	'退出',		'Exit',			'',	'exit',		800;


// --------------------------------------------------------------------
//	toolbar : 系统应用左边的功能列表
// --------------------------------------------------------------------
if exists(select * from sysobjects where name = "toolbar" and type = 'U')
	drop table toolbar;
create table toolbar
(
	appid			char(1)						not null,	// 应用编号：1-前台系统，2-餐饮系统等；
	cat			varchar(40)					not null,	// 类别归属  －－－ toolbar_cat
	code			varchar(12)					not null,	// 标记
	descript    varchar(30)					not null,	// 中文描述
	descript1   varchar(40)	default ''	not null,	// 英文描述
	wtype			char(10)		default ''	not null,	// 编辑类型: response, hry, sheet, event-系统主窗口事件
	auth			varchar(20)	default ''	not null,
   source  		text        default ''	not null,   // 编辑
   parm  		text  		default '' 	not null,   // 编辑参数
	multi			char(1)		default 'F' not null,	// 是否为多个实例打开
	lic			varchar(20)	default ''	not null,
	sequence		int			default 0	not null
)
exec sp_primarykey toolbar,appid,cat, code
create unique index index1 on toolbar(appid,cat, code)
;
