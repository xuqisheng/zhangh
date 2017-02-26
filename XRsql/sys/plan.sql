-- ------------------------------------------------------------------------------
-- plan 计划  
--                       simon 2006.8.8 
-- ------------------------------------------------------------------------------


-- ------------------------------------------------------------------------------
-- 改造
--  1. plan_cat 中的项目定义 planitem ，需要用另外的表定义最好 
--  2. plan_code 这个表没有必要，创建的时候，直接从相关代码表提取
-- ------------------------------------------------------------------------------


-- --------------------------------------
--  basecode : plan_period  计划区间定义
-- --------------------------------------
delete basecode where cat='plan_period';
delete basecode_cat where cat='plan_period';
insert basecode_cat(cat,descript,descript1,len,flag,center) 
	select 'plan_period', '计划区间定义', 'Plan Period', 1, '', 'F';
insert basecode(cat,code,descript,descript1,sequence) values('plan_period', 'Y', '年', 'Year', 100);
insert basecode(cat,code,descript,descript1,sequence) values('plan_period', 'S', '季度', 'Season', 200);
insert basecode(cat,code,descript,descript1,sequence) values('plan_period', 'M', '月', 'Month', 300);
insert basecode(cat,code,descript,descript1,sequence) values('plan_period', 'H', '半月', 'Half Month', 400);
insert basecode(cat,code,descript,descript1,sequence) values('plan_period', 'X', '旬', 'Ten Days', 500);
insert basecode(cat,code,descript,descript1,sequence) values('plan_period', 'W', '星期', 'Week', 600);
insert basecode(cat,code,descript,descript1,sequence) values('plan_period', 'D', '天', 'Day', 700);
select * from basecode where cat='plan_period' order by sequence, code ;


-- --------------------------------------
--  basecode : plan_type  计划类别定义
-- --------------------------------------
delete basecode where cat='plan_type';
delete basecode_cat where cat='plan_type';
insert basecode_cat(cat,descript,descript1,len,flag,center) 
	select 'plan_type', '计划类别定义', 'Plan Type', 1, '', 'F';
insert basecode(cat,code,descript,descript1,sequence) values('plan_type', 'B', '预算', 'budget', 100);
-- insert basecode(cat,code,descript,descript1,sequence) values('plan_type', 'F', '预测', 'Forecast', 200);
select * from basecode where cat='plan_type' order by sequence, code ;


-- -----------------------------------------------------------
--  basecode : plan_who  计划针对者 -- 用 plan_who表替代 
-- -----------------------------------------------------------
delete basecode where cat='plan_who';
delete basecode_cat where cat='plan_who';
//insert basecode_cat(cat,descript,descript1,len,flag,center) 
//	select 'plan_who', '计划针对者', 'Whose Plan', 10, '', 'F';
//-- 下面的 basecode.grp -对应 foxhelp.hlpkey ， 在代码编辑的时候使用 
//insert basecode(cat,code,descript,descript1,grp,sequence) values('plan_who', 'HOTEL', '酒店', 'Hotel', '', 100);
//insert basecode(cat,code,descript,descript1,grp,sequence) values('plan_who', 'DEPTNO', '部门', 'Department', 'p_deptno', 200);
//insert basecode(cat,code,descript,descript1,grp,sequence) values('plan_who', 'SALEGRP', '销售组', 'Sales Team', 'p_salegrp', 300);
//insert basecode(cat,code,descript,descript1,grp,sequence) values('plan_who', 'SALEID', '销售员', 'Sales Agent', 'p_saleid', 400);
//insert basecode(cat,code,descript,descript1,grp,sequence) values('plan_who', 'ACCOUNT', '协议单位', 'Accounts', 'p_account', 500);
//insert basecode(cat,code,descript,descript1,grp,sequence) values('plan_who', 'CONTACT', '联系人', 'Contacts', 'p_contact', 600);
//insert basecode(cat,code,descript,descript1,grp,sequence) values('plan_who', 'GUEST', '客人', 'Guests', 'p_guest', 700);
//select * from basecode where cat='plan_who' order by sequence, code ;


-- --------------------------------------
--  plan_cat  计划类别（对象）定义 
-- --------------------------------------
if exists(select * from sysobjects where name = "plan_cat")
	drop table plan_cat;
create table plan_cat
(
	cat				varchar(30)							not null,		-- plan catalog. eg: mkt, src, jourrep...... 
   descript   		varchar(60)    				not null,
   descript1  		varchar(60) default ''   	not null,
	codesql			text			default ''		not null,		-- 计划代码的生成 sql, 客户端使用， 便于自动生成  
																				-- 这里的sql可能有多段，用分号隔开
																				-- 也可以使 proc 
	plantype			varchar(30)		default ''		not null,		-- 编制计划的类别 日，月，年，周，季度，半月，旬 等   
																				-- 分别用代码 D, M, Y, W, S, H, X 等代码表示
																				-- basecode  (cat = plan_period)
																				-- 这个字段可以考虑多选，即可以同时编制多种计划，此时数据一致性需要考虑
																				-- 如此一来，系统需要设置完备的时间属性表，采用日历表 ？
	planwho			varchar(255) default 'HOTEL'		not null,		-- plan_who 可以多选 
	lic				varchar(20)	default ''		not null,		-- 授权代码 
	halt				char(1)		default 'F'		not null,
	sequence			int			default 0		not null
)
exec sp_primarykey plan_cat,cat
create unique index index1 on plan_cat(cat)
;
//insert plan_cat(cat,descript,descript1,plantype,sequence) select 'jourrep','总体营业收入','Hotel Revenue','M',100;
//insert plan_cat(cat,descript,descript1,plantype,planitem,sequence) select 'market','市场','Market','M','1=房晚:NT^2=收入:REV^',200;
//insert plan_cat(cat,descript,descript1,plantype,planitem,sequence) select 'source','来源','Source','M','1=房晚:NT^2=收入:REV^',300;
//insert plan_cat(cat,descript,descript1,plantype,planitem,sequence) select 'channel','渠道','Channel','M','1=房晚:NT^2=收入:REV^',400;
//select * from plan_cat order by sequence, cat;


-- --------------------------------------
--  plan_who  = plan_cat.planwho 
-- --------------------------------------
if exists(select * from sysobjects where name = "plan_who")
	drop table plan_who;
create table plan_who
(
	planwho			varchar(30)						not null,		-- 计划的对象 
   descript   		varchar(60)    				not null,
   descript1  		varchar(60) default ''   	not null,
	codesql			text    		default 'HOTEL' not null,
	halt				char(1)		default 'F'		not null,
	sequence			int			default 0		not null
)
exec sp_primarykey plan_who,planwho
create unique index index1 on plan_who(planwho)
;
insert plan_who(planwho,descript,descript1,codesql,halt,sequence) select 'HOTEL','酒店','Hotel','HOTEL','F',0;
insert plan_who(planwho,descript,descript1,codesql,halt,sequence) select 'DEPTNO','部门','Department','select code,descript,descript1 from basecode where cat=''dept'' and char_length(rtrim(code))=1 and code<>''0'' order by sequence,code','F',0;
insert plan_who(planwho,descript,descript1,codesql,halt,sequence) select 'SALEGRP','销售组','Sales Team','select code,descript,descript1 from salegrp where halt=''F'' order by sequence,code','F',0;
insert plan_who(planwho,descript,descript1,codesql,halt,sequence) select 'SALEID','销售员','Sales Agent','select code,name,name2 from saleid order by sequence,code','F',0;
insert plan_who(planwho,descript,descript1,codesql,halt,sequence) select 'ACCOUNT','协议单位','Accounts','select no,name,name2 from guest where class in (''C'',''A'',''S'') order by name','F',0;
insert plan_who(planwho,descript,descript1,codesql,halt,sequence) select 'CONTACT','联系人','Contacts','select a.no,b.name,b.name2 from argst a, guest b where a.no=b.no and a.tag1=''T'' order by b.name','F',0;
select * from plan_who order by sequence, planwho;


//-- --------------------------------------s
//--  plan_code  计划代码定义 
//-- --------------------------------------
//if exists(select * from sysobjects where name = "plan_code")
//	drop table plan_code;
//create table plan_code
//(
//	cat				varchar(30)							not null,
//	clskey			varchar(30)						not null,		-- class key 表示 class 的关键字 
//	class				varchar(30)						not null,
//   descript   		varchar(60)    				not null,
//   descript1  		varchar(60) default ''   	not null,
//	rectype			char(2)		default  ''		null,				-- B, C or Null 
//	toop				char(2)		default  ''		null,				-- +, /, % 
//	toclass1			varchar(60)	default  ''		null,				-- clskey+class
//	toclass2			varchar(60)	default  ''		null,				-- clskey+class
//	unit				char(6)		default  '. .'	null,				-- .., % 
//	show				char(1)		default  'T'	null,
//	flag				char(10)		default  '>='	null,				-- 计划特性, 表示数据对比要求的，比如 >, >=, <, <=, =, ... 
//	scope1			money			default 0		not null,		-- 计划范围特性 
//	scope2			money			default 0		not null,
//	scope3			money			default 0		not null,
//	extra 			varchar(30)	default  ''		null,
//	sequence			int			default 0 		not null
//)
//exec sp_primarykey plan_code,cat,clskey,class
//create unique index index1 on plan_code(cat,clskey,class)
//;
//insert plan_code select 'jourrep','class',class,descript,descript1,rectype,toop,toclass1,toclass2,unit,show,'>=',0,0,0,'',0 from jourrep ;
//update plan_code set toclass1='class'+toclass1 where cat='jourrep' and rtrim(toclass1) is not null;
//update plan_code set toclass2='class'+toclass2 where cat='jourrep' and rtrim(toclass2) is not null;
//update plan_code set sequence = convert(int, class) where cat='jourrep'
//
//insert plan_code select 'market','grp',code,descript,descript1,'C','','','','','T','>=',0,0,0,'',0 from basecode where cat='market_cat';
//insert plan_code select 'market','code',code,descript,descript1,'B','+','grp'+grp,'','','T','>=',0,0,0,'',0 from mktcode ;
//
//insert plan_code select 'source','grp',code,descript,descript1,'C','',grp,'','','T','>=',0,0,0,'',0 from basecode where cat='src_cat';
//insert plan_code select 'source','code',code,descript,descript1,'B','+','grp'+grp,'','','T','>=',0,0,0,'',0 from srccode ;
//
//insert plan_code select 'channel','code',code,descript,descript1,'B','','','','','T','>=',0,0,0,'',0 from basecode where cat='channel';
//
//select * from plan_code order by cat, sequence, class;


-- ----------------------------------------------------
--  plan_def  计划内容存储. 暂时最多支持8列数据
-- ----------------------------------------------------
if exists(select * from sysobjects where name = "plan_def")
	drop table plan_def;
create table plan_def
(
	cat				varchar(30)							not null,		-- plan_cat 
	owner				varchar(30)							not null,		-- plan_who 
	planwho 			varchar(30)							not null,		-- plan_who 对应的代码 
	item 				varchar(30)							not null,      -- plan_item 计划项目
	type				char(1)								not null,		-- plan_type 
	clskey			varchar(30)							not null,		-- grp 
	class				varchar(30)							not null,		-- code 
	period			varchar(30)							not null,		-- plan_period 由‘计划区间定义’与日期字符拼接而成
																					-- 如：Y2005, Y2006, M200601, M200609, S200601, D20060909 等 
	amount1			money			default 0		not null,
//	amount2			money			default 0		not null,
//	amount3			money			default 0		not null,
//	amount4			money			default 0		not null,
//	amount5			money			default 0		not null,
//	amount6			money			default 0		not null,
//	amount7			money			default 0		not null,
//	amount8			money			default 0		not null,
	empno				char(10)							not null,		-- 预留字段，系统可能需要对计划编制记录日志
	changed			datetime							not null,
	logmark			int			default 0		not null
)
exec sp_primarykey plan_def,cat,owner,planwho,type,clskey,class,period,item
create unique index index1 on plan_def(cat,owner,planwho,type,clskey,class,period,item)
;

if exists(select * from sysobjects where name = "plan_def_log")
	drop table plan_def_log;
create table plan_def_log
(
	cat				varchar(30)							not null,
	owner				varchar(30)							not null,
	planwho 			varchar(30)							not null,		-- plan_who 对应的代码 
	item 				varchar(30)						not null,         -- 项目
	type				char(1)								not null,
	clskey			varchar(30)							not null,
	class				varchar(30)							not null,
	period			varchar(30)							not null,		-- 由‘计划区间定义’与日期字符拼接而成
																				-- 如：Y2005, Y2006, M200601, M200609, S200601, D20060909 等 
	amount1			money			default 0		not null,
//	amount2			money			default 0		not null,
//	amount3			money			default 0		not null,
//	amount4			money			default 0		not null,
//	amount5			money			default 0		not null,
//	amount6			money			default 0		not null,
//	amount7			money			default 0		not null,
//	amount8			money			default 0		not null,
	empno				char(10)							not null,		-- 预留字段，系统可能需要对计划编制记录日志
	changed			datetime							not null,
	logmark			int			default 0		not null
)
exec sp_primarykey plan_def_log,cat,owner,planwho,type,clskey,class,period,logmark,item
create unique index index1 on plan_def_log(cat,owner,planwho,type,clskey,class,period,logmark,item)
;

//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200601','FOX',getdate() from jourrep order by class; 
//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200602','FOX',getdate() from jourrep order by class; 
//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200603','FOX',getdate() from jourrep order by class; 
//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200604','FOX',getdate() from jourrep order by class; 
//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200605','FOX',getdate() from jourrep order by class; 
//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200606','FOX',getdate() from jourrep order by class; 
//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200607','FOX',getdate() from jourrep order by class; 
//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200608','FOX',getdate() from jourrep order by class; 
//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200609','FOX',getdate() from jourrep order by class; 
//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200610','FOX',getdate() from jourrep order by class; 
//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200611','FOX',getdate() from jourrep order by class; 
//insert plan_def(cat,owner,type,clskey,class,period,empno,changed) select 'jourrep','0','B','class',class,'M200612','FOX',getdate() from jourrep order by class; 
//
//select * from plan_def order by cat, period, class; 

 
// ------------------------------------------------------------------------------------
//		plan_def 触发器
// ------------------------------------------------------------------------------------
//if exists (select * from sysobjects where name = 't_gds_plan_def_insert' and type = 'TR')
//	drop trigger t_gds_plan_def_insert;
//create trigger t_gds_plan_def_insert
//   on plan_def for insert
//	as
//begin
//insert lgfl select 'plan_?', no, '', no, cby, changed from inserted
//end;
if exists (select * from sysobjects where name = 't_gds_plan_def_update' and type = 'TR')
	drop trigger t_gds_plan_def_update
;
create trigger t_gds_plan_def_update
   on plan_def for update
	as
begin
if update(logmark)   -- 注意，这里插入的是 deleted
	insert plan_def_log select deleted.* from deleted
end;

//  日志项目描述 
delete lgfl_des where columnname like 'plan_%';
//insert lgfl_des(columnname,descript,descript1,tag) values('plan_amount1', '数值1', 'Amount1', 'O');
//insert lgfl_des(columnname,descript,descript1,tag) values('plan_amount2', '数值2', 'Amount2', 'O');
//insert lgfl_des(columnname,descript,descript1,tag) values('plan_amount3', '数值3', 'Amount3', 'O');
//insert lgfl_des(columnname,descript,descript1,tag) values('plan_amount4', '数值4', 'Amount4', 'O');
//insert lgfl_des(columnname,descript,descript1,tag) values('plan_amount5', '数值5', 'Amount5', 'O');
//insert lgfl_des(columnname,descript,descript1,tag) values('plan_amount6', '数值6', 'Amount6', 'O');
//insert lgfl_des(columnname,descript,descript1,tag) values('plan_amount7', '数值7', 'Amount7', 'O');
//insert lgfl_des(columnname,descript,descript1,tag) values('plan_amount8', '数值8', 'Amount8', 'O');.



-- --------------------------------------
--  plan_item  编码项目定义 
-- --------------------------------------
if exists(select * from sysobjects where name = "plan_item")
	drop table plan_item;
create table plan_item
(
	cat				varchar(30)							not null,		-- plan catalog. eg: mkt, src, jourrep...... 
	item 				varchar(30)						not null,         -- 项目
   descript   		varchar(60)    				not null,         -- 中文描述
   descript1  		varchar(60) default ''   	not null,			-- 英文描述
	format			varchar(30)	default '#,##0.00' not null,		-- 格式 
	tag				varchar(30) default ''   	not null,			-- 预留
	halt				char(1)		default 'F'		not null,			
	sequence			int			default 0		not null				
)		
create unique index index1 on plan_item(cat,item)
;		