if exists(select 1 from sysobjects where name = "sys_cmarco" and type="U")
	drop table sys_cmarco;
create table sys_cmarco
(
	code	 		varchar(30)		            not null,	-- 条件宏
	mcode			varchar(30)	default ''     not null,	-- 多选代码 
	descript 	varchar(60)		            null,			-- 描述
	descript1 	varchar(60)		            null,			-- 描述 
	def			varchar(60)		            null,			-- 默认值 
	hlpcode		text								null,			-- 帮助脚本 
	sequence    int								null 	
)
exec sp_primarykey sys_cmarco, code
create unique index index1 on sys_cmarco(code)
;
