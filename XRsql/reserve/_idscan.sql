
// 证件扫描临时表 

if exists(select * from sysobjects where name = "idscan" and type="U")
	drop table idscan;
create table idscan
(
	no  			char(10)						not null,	-- 流水号 
	idtype		char(10)	default 'ID'	not null,	-- ID=证件  SIGN=签名 
	name			varchar(50)					null,			-- 名称
	ref			varchar(60)					null,			-- 说明 
	haccnt		char(10)	default ''		not null, 
	idtext		text							null,
	idpic			image							null,
	empno1		char(10)						null,			-- 扫描人
	date1			datetime						null,
	pc_id			char(4)						null,			-- 扫描站点 
	empno2		char(10)						null,			-- 关联人 
	date2			datetime						null
)
exec sp_primarykey idscan, no
create unique index  idscan on idscan(no)
;

