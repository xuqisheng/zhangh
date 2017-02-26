-- --------------------------------------------------------------------------
--  basecode : bursar_kind  财务分录类别
-- --------------------------------------------------------------------------
delete basecode where cat='bursar_kind';
delete basecode_cat where cat='bursar_kind';
insert basecode_cat(cat,descript,descript1,len,flag,center) 
	select 'bursar_kind', '财务分录类别', 'Finance Subject Class', 2, '', 'F';
insert basecode(cat,code,descript,descript1,sequence) values('bursar_kind', '资', '资产类', '资产类', 100);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_kind', '负', '负债类', '负债类', 200);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_kind', '权', '权益类', '权益类', 300);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_kind', '成', '成本类', '成本类', 400);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_kind', '损', '损益类', '损益类', 500);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_kind', '记', '记帐类', '记帐类', 600);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_kind', '其', '其他', '其他', 700);

-- --------------------------------------------------------------------------
--  basecode : bursar_class  财务凭证类别
-- --------------------------------------------------------------------------
delete basecode where cat='bursar_class';
delete basecode_cat where cat='bursar_class';
insert basecode_cat(cat,descript,descript1,len,flag,center) 
	select 'bursar_class', '财务凭证类别', 'Finance Bursar Class', 4, '', 'F';
insert basecode(cat,code,descript,descript1,sequence) values('bursar_class', '记帐', '记帐', '记帐', 100);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_class', '收款', '收款', '收款', 200);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_class', '付款', '付款', '付款', 300);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_class', '银收', '银收', '银收', 400);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_class', '银付', '银付', '银付', 500);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_class', '现收', '现收', '现收', 600);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_class', '现付', '现付', '现付', 700);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_class', '转帐', '转帐', '转帐', 800);


-- --------------------------------------------------------------------------
--  basecode : bursar_src  财务凭证数据来源
-- --------------------------------------------------------------------------
delete basecode where cat='bursar_src';
delete basecode_cat where cat='bursar_src';
insert basecode_cat(cat,descript,descript1,len,flag,center) 
	select 'bursar_src', '财务凭证数据来源', 'Finance Bursar Data Source', 10, '', 'F';
insert basecode(cat,code,descript,descript1,sequence) values('bursar_src', 'jierep', '底表收入', '底表收入', 100);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_src', 'dairep', '底表收款', '底表收款', 200);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_src', 'deptjie', 'POS收入', 'POS收入', 300);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_src', 'deptdai', 'POS收款', 'POS收款', 400);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_src', 'act_bal', '帐户', '帐户', 500);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_src', 'pccode9', '收款', '收款', 800);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_src', 'impdata', '稽核指标', '稽核指标', 900);


--------------------------------------------------------------
--		前台相关凭证代码
--------------------------------------------------------------
if object_id('bursar') is not null
	drop table bursar
;
CREATE TABLE bursar (
	code 			char(20)								not null,
	descript 	varchar(30) 						not null,
	descript1 	varchar(30) default ''			not null,
	kind 			char(2)  	default '' 		not null,		-- basecode = bursar_kind
	src 			char(20) 	default ''		not null,		-- 数据来源 -- 相关报表 jierep,dairep,yingjiao ....
	classes		varchar(255) default ''		not null
);
exec sp_primarykey bursar, code
create unique index index1 on bursar(code)
;

--------------------------------------------------------------
--		输出凭证代码
--------------------------------------------------------------
if object_id('bursar_code') is not null
	drop table bursar_code
;
CREATE TABLE bursar_code (
	code 			char(15)							not null,
	descript 	varchar(30) 					not null,	-- 描述
	descript1 	varchar(30) 					not null,	-- 描述
	class 		char(4)  	default '' 		not null,	-- 凭证类别  basecode = bursar_class
	no				varchar(20)	default '' 		not null,	-- 业务号码
	instready	varchar(1)  default 'T'		not null		
);
exec sp_primarykey bursar_code, code
create unique index index1 on bursar_code(code)
;

--------------------------------------------------------------
--		输出凭证代码 -- 明细定义
--------------------------------------------------------------
if object_id('bursar_def') is not null
	drop table bursar_def
;
CREATE TABLE bursar_def (
	code 			char(15)							not null,		-- 输出凭证代码  bursar_code
	id				int								not null,
	remark		varchar(30)	 default '' 	null,				-- 摘要
	bursar		char(20) 						not null,		-- 科目 bursar
	tag 			char(2)  	 default '借' 	not null,		-- 借 / 贷
	src 			char(10)  	 default '' 	not null,		-- 数据源类别   basecode = bursar_src 
	classes		varchar(255) default '' 	not null			-- 数据源定义
);
exec sp_primarykey bursar_def, code, id
create unique index index1 on bursar_def(code, id)
;

--------------------------------------------------------------
--		输出凭证 -- 内容根据 bursar_def 得来
--------------------------------------------------------------
if object_id('bursar_out') is not null
	drop table bursar_out
;
CREATE TABLE bursar_out (
	date			datetime							not null,
	code 			char(15)							not null,
	id				int								not null,
	remark		varchar(30)	 default '' 	null,				-- 摘要
	bursar		char(20) 						not null,		-- 科目
	kind 			char(2)  	default '' 		not null,		-- basecode = bursar_kind
	tag 			char(2)  	 default '借' 	not null,		-- 借 / 贷
	amount		money 		 default 0 		not null
);
exec sp_primarykey bursar_out, code, id
create unique index index1 on bursar_out(code, id)
;


--------------------------------------------------------------
--		输出凭证
--------------------------------------------------------------
if object_id('ybursar_out') is not null
	drop table ybursar_out
;
CREATE TABLE ybursar_out (
	date			datetime							not null,
	code 			char(15)							not null,
	id				int								not null,
	remark		varchar(30)	 default '' 	null,				-- 摘要
	bursar		char(20) 						not null,		-- 科目
	kind 			char(2)  	default '' 		not null,		-- basecode = bursar_kind
	tag 			char(2)  	 default '借' 	not null,		-- 借 / 贷
	amount		money 		 default 0 		not null
);
exec sp_primarykey ybursar_out, date, code, id
create unique index index1 on ybursar_out(date, code, id)
;

