
// exec sp_rename  sysoption, a_sysoption;

-------------------------------------------------------------------------------------
--	系统参数控制表
-------------------------------------------------------------------------------------
IF OBJECT_ID('sysoption') IS NOT NULL
    DROP TABLE sysoption
;
CREATE TABLE sysoption 
(
	catalog 		char(12)     	not NULL,
	item    		char(32)     	not NULL,
	value   		varchar(255) 	NULL,
	def			varchar(255) 	NULL,		-- 参数缺省值
	remark  		varchar(255) 	NULL,		-- 中文说明
	remark1		varchar(255) 	NULL,		-- 英文说明
	addby			varchar(10) 	NULL,		-- 创建者，疑惑的时候，可以找人问。。
	addtime		datetime	default getdate() not null,	-- 创建的时间 
	usermod		char(1)	default 'T'	null,					-- 用户可以修改
	lic			varchar(20) default '' not null,			-- 授权代码
	cby			varchar(10) 	NULL,		-- 修改者
	changed		datetime	default getdate() not null,	-- 
);
EXEC sp_primarykey 'sysoption', catalog,item;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON sysoption(catalog,item);


//insert sysoption select *, '', getdate() from a_sysoption;
//select * from sysoption;



