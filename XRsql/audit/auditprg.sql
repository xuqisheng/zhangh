// ------------------------------------------------------------------------------
// --  auditprg 
// ------------------------------------------------------------------------------
//exec sp_rename auditprg, a_auditprg ;
if exists (select * from sysobjects where name='auditprg' and type='U')
   drop table auditprg;
create table auditprg
(
	exec_order  	int     		default 0		not null,
	prgname     	char(11)		default ''		not null,
	descript    	varchar(60)	default ''		not null,
	descript1    	varchar(60)	default ''		not null,
	callform    	varchar(85)	default ''		not null,
	hasdone     	char(1) 		default 'F'		not null,
	starttime   	datetime							null,
	duration    	int     		default 0		not null,
	pduration   	int     		default 0		not null,
	moduname    	char(2) 		default ''		not null,
	needinst    	char(1) 		default 'T'		not null,
	retotal   		char(1) 		default 'F'		not null,
	decdbf      	varchar(50)	default ''		null
)
exec sp_primarykey auditprg,exec_order
create unique clustered index index1 on auditprg(exec_order);
//
//insert auditprg select exec_order,prgname,descript,descript,callform,hasdone,starttime,duration,pduration,
//	isnull(moduname,''),needinst,retotal,decdbf from a_auditprg;
//drop table a_auditprg;



// ------------------------------------------------------------------------------
//		adtrep
// ------------------------------------------------------------------------------
//exec sp_rename adtrep, a_adtrep;
if exists (select * from sysobjects where name = 'adtrep' and type ='U')
   drop table adtrep;
create table adtrep
(
   order_      int 				default 0		not null,
	descript    varchar(60)  	default ''		not null,
	descript1   varchar(60)  	default ''		not null,
   callform    varchar(140) 	default ''		not null,
	prtno       int 				default 0		not null,
	prtno1      int 				default 0		not null,
	parms       text									null,
   withhis     char(1) 			default 'F' 	not null,
   wpaper      char(1) 			default 'F' 	not null,
   allowmodus  varchar(90) 	default '99#' 	not null ,
	needinst    char(1) 			default 'F' 	not null,
	instready   char(1) 			default 'F' 	not null,
)
exec sp_primarykey adtrep,order_
create unique index index1 on adtrep(order_);
//
//insert adtrep select order_,repname,rtrim(repname)+'_eng',callform,prtno,prtno1,parms,withhis,wpaper,allowmodus,needinst,
//instready from a_adtrep;
//
//select * from adtrep;



// ------------------------------------------------------------------------------
// 报表的部门编码
// ------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "auto_dept")
	drop table auto_dept;
create table auto_dept
(
	code			char(10)				not null,  // 类别--最多十级
   descript		varchar(30)     	not null,  // 标识
   descript1	varchar(30)     	not null,  // 标识
	sys			char(1)	default 'F'	not null,
	halt			char(1)	default 'F'	not null,
	sequence		int		default 0	not null
)
exec sp_primarykey auto_dept,code
create unique index index1 on auto_dept(code)
create index index2 on auto_dept(descript)
create index index3 on auto_dept(descript1)
;


// ------------------------------------------------------------------------------
// 报表纪录
// ------------------------------------------------------------------------------
//exec sp_rename auto_report, a_auto_report;
if exists(select * from sysobjects where name = "auto_report")
	drop table auto_report;
create table auto_report
(
	dept			char(10)			default 'A'	not null,			// 类别--最多十级
	wtype			char(3)			default 'tab' not null,			// 窗口类型: tab, grf, crs
	id				char(30)			not null,							// 标识
	rid			char(30)			default '' not null,				// 报表编号
	descript		char(60)			not null,							// 标题
	descript1	char(60)			not null,							// 标题
	remark		varchar(255)	default '' not null,				// 简要说明
	allowmodus	varchar(90)		null,
	orientation	char(1)			default "0" not null,			// 纵打、横打
	source		text				not null,							// 报表数据定义
	condition	text				not null,							// 参数输入数据窗口定义
	lic_buy		char(20)			default "" not null,				// 所依赖的系统模块
	sys			char(1)			default "F" not null,			// 系统报表?
	halt			char(1)			default "F" not null,			// 有效?
	crby			char(10)			default "" not null,				// 报表创建人
	crdate		datetime			default getdate() not null,	// 报表创建时间
	expby			char(10)			default "" not null,				// 报表修改人
	expdate		datetime			default getdate() not null,	// 报表修改时间
)
exec sp_primarykey auto_report,id
create unique index index1 on auto_report(id)
create index index2 on auto_report(descript)
create index index3 on auto_report(descript1)
;
//
//insert auto_report select dept, wtype, id, title, rtrim(title)+'_eng', allowmodus, source from a_auto_report;
//drop table a_auto_report;
//

// ------------------------------------------------------------------------------
// 批量报表 						--  GaoLiang 2005/06/02
// ------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "auto_batch")
	drop table auto_batch;
create table auto_batch
(
	code			char(10)			not null,							// 代码
	descript		varchar(60)		not null,							// 中文标题
	descript1	varchar(60)		not null,							// 英文标题
	condition	text				not null,							// 参数输入数据窗口定义
	sys			char(1)			default "F" not null,			// 系统报表?
	halt			char(1)			default "F" not null,			// 有效?
	cby			char(10)			default "" not null,				// 修改人
	changed		datetime			default getdate() not null,	// 修改时间
)
exec sp_primarykey auto_batch, code
create unique index index1 on auto_batch(code)
;
//insert auto_batch select code,descript, descript1, '', 'T', 'F', 'FOX', getdate()
//	from basecode where cat = 'adtrep';

// ------------------------------------------------------------------------------
// 我的报表(My Reports)纪录	--  GaoLiang 2005/05/26
// ------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "auto_empno")
	drop table auto_empno;
create table auto_empno
(
	empno			char(10)			not null,							// 用户名
	id				char(30)			not null,							// 报表标识
	prtno       integer			default 0 not null,				// 预设份数
	prtno1      integer			default 0 not null,				// 打印份数
	cby			char(10)			default "" not null,				// 修改人
	changed		datetime			default getdate() not null,	// 修改时间
)
exec sp_primarykey auto_empno, empno, id
create unique index index1 on auto_empno(empno, id)
;

//insert sys_function values ('0015', '00', '设置批量报表', '设置批量报表_e', 'repdef!batch');	
//insert auto_report select 'A', 'tab', 'rep!' + ltrim(convert(char(10), order_)), '', descript, descript1, '','02',
//	'dataobject:' + rtrim(callform) + ';' + convert(char(255), parms), '', '', 'T', 'F', 'GL', getdate(), 'GL', getdate()
//	from adtrep where callform like 'd_%';
//insert auto_report select 'A', 'tab', 'rep!' + ltrim(convert(char(10), order_)), '', descript, descript1, '','02',
//	rtrim(callform) + '(' + rtrim(convert(char(255), parms)) + ')', '', '', 'T', 'F', 'GL', getdate(), 'GL', getdate()
//	from adtrep where callform like 'f_%';
