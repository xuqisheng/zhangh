	
------------------------------------------------------------
--
--	餐饮触摸屏类表结构定义
--
------------------------------------------------------------

-- 功能分类
create table pos_func_class(
	func_class		char(40) default '' not null,            	-- 类别
	class_des		char(40) default '' not null,					-- 描述
	remark			varchar(60)  null
)
;
exec sp_primarykey pos_func_class,func_class
create unique index index1 on pos_func_class(func_class)
;
INSERT INTO pos_func_class VALUES (	'system',	'系统类',	NULL);
INSERT INTO pos_func_class VALUES (	'order',	'点菜操作类',	NULL);
INSERT INTO pos_func_class VALUES (	'login',	'登陆窗口类',	NULL);
INSERT INTO pos_func_class VALUES (	'check',	'结帐类',	NULL);
INSERT INTO pos_func_class VALUES (	'menu_list',	'开单窗口类',	NULL);
INSERT INTO pos_func_class VALUES (	'map',	'餐位图类',	NULL);
INSERT INTO pos_func_class VALUES (	'dish_cond',	'配料窗口类',	NULL);
INSERT INTO pos_func_class VALUES (	'info',	'查询类',	NULL);

-- 功能
create table pos_func(
	class				char(40) default '' not null,					-- 类别			
	func				char(40) default '' not null,					-- 函数
	func_des			char(40) default '' not null,					-- 描述
	parm				text,													-- 参数
	nextwin			char(1)  default 'N' not null,				-- 是否要打开窗口
	remark			varchar(60)  null,
   sequence 		char(10)    DEFAULT '1000' NOT NULL,
   halt     		varchar(1)  NULL
)
;
exec sp_primarykey pos_func,func
create unique index index1 on pos_func(func)
;

-- 附加功能：主要有关点菜
create table pos_func_more(
	class				char(40) default '' not null,					-- 类别
	func				char(40) default '' not null,					-- 函数
	descript			char(20) default '' not null,					-- 描述
	descript1		char(20) default '' not null,					-- 描述
	parm				char(100),											-- 参数
	remark			varchar(60)  null,
	sequence			char(10)		null,
   halt      char(1)     NULL
)
;
exec sp_primarykey pos_func_more,func
create unique index index1 on pos_func_more(func)
;


-- 界面模板
create table pos_win_class(
	win_class		char(40) default '' not null,					-- 模板
	class_name		char(40) default '' not null,					-- 命名解释
	dw_name			char(40) default '' not null,					-- 模版ｄｗ
	dw_number		int		default 0  not null,					-- 窗口中其他数据窗口的数量
	win_default		char(40)	default '' not null,					-- 缺省窗口
	remark			varchar(60),										--	描述
	usedw				char(1)	default 'F' not null,            -- 是否直接使用pbl中的dw 
	wintype			char(1)  default '0' not null             
)
;
exec sp_primarykey pos_win_class,win_class
create unique index index1 on pos_win_class(win_class)
;

--	界面
create table pos_win(
	win_class		char(40) default '' not null,					-- 模板
	win_name			char(40) default '' not null,					-- 窗口
	win_des			char(40) default '' not null,					-- 描述
	arrangement		char(1) 	default 'C' not null,				-- 位置安排:U-Up；B-botton；R-right；L-left；C-center
	dtl_row			int		default	0	not null,				-- 如有明细查询每行个数
	dtl_column		int		default	0	not null,				-- 如有明细查询每列个数
	dwlist			char(40)	default	''	not null,				-- 数据窗口列表名称
	dw_syntax		text		,											-- 界面数据窗口语法
	sys				char(1)	default	'N' not null,				-- 是否是系统窗口
	usedw				char(1)	default	'F' not null,				-- 是否直接调用pbd的datawindow
	wintype			char(1)  default  '0' not null,             -- 窗口类型, 0 - 中餐, 1 - 西餐
	langid			char(1)	default	'0' not null,				-- 语种　
   dtl_row1    int      NULL,
   dtl_column1 int      NULL
)
;
exec sp_primarykey pos_win,win_name
create unique index index1 on pos_win(win_name)
;

--	界面模板能用的功能类
create table pos_win_func(
	win_class		char(40) default '' not null,					-- 模板
	func_class		char(40) default '' not null					-- 功能类
)
;
exec sp_primarykey pos_win_func,win_class,func_class
create unique index index1 on pos_win_func(win_class,func_class)
;


/*
	触摸屏登陆, 磁卡信息同工号(sys_empno)对照表
*/
if exists(select * from sysobjects where name = "pos_login_card" and type ="U")
	 drop table pos_login_card;

create table pos_login_card
(
	card				char(20)		not null,								/*卡信息*/
	empno				char(10)		not null									/*场地代码*/
)
;
exec sp_primarykey pos_login_card, card
create unique index index1 on pos_login_card(card)
;

