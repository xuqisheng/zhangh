// ------------------------------------------------------------------------------
// 简单代码  -- 合并原来系统中所有的简单代码
//
//		简单代码的界定：代码记录不是很长，不需要帮助码； 		-- 国籍、区划不能加入
//							代码列数很少，没有什么多余的附加属性； -- 房类、市场码不能加入
//
// ------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "basecode_cat")
	drop table basecode_cat;
create table basecode_cat
(
	cat				char(30)							not null,
   descript   		varchar(60)    				not null,
   descript1  		varchar(60) default ''   	not null,
	len				int			default 3		not null,		// 代码长度
	flag				char(30)		default ''		not null,
	center			char(1)		default 'F'		not null			// 中央代码
)
exec sp_primarykey basecode_cat,cat
create unique index index1 on basecode_cat(cat)
;

if exists(select * from sysobjects where name = "basecode")
	drop table basecode;
create table basecode
(
	cat				char(30)							not null,
	code				char(10)							not null,
   descript   		varchar(60)    				not null,
   descript1  		varchar(60) default ''   	not null,
	sys				char(1)		default 'F'		not null,		//	系统代码
	halt				char(1)		default 'F'		not null,		// 停用?
	sequence			int			default 0		not null,		// 次序
	grp				varchar(16)	default ''   	not null,		// 归类
	center			char(1)		default 'F'   	not null,			// center code ?
	cby				char(10)		default '!' 	not null,	/* 最新修改人信息 */
	changed			datetime		default getdate()		not null 
)
exec sp_primarykey basecode,cat,code
create unique index index1 on basecode(cat,code)
;