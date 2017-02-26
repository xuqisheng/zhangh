
// exec sp_rename  sysoption, a_sysoption;

-------------------------------------------------------------------------------------
--	ϵͳ�������Ʊ�
-------------------------------------------------------------------------------------
IF OBJECT_ID('sysoption') IS NOT NULL
    DROP TABLE sysoption
;
CREATE TABLE sysoption 
(
	catalog 		char(12)     	not NULL,
	item    		char(32)     	not NULL,
	value   		varchar(255) 	NULL,
	def			varchar(255) 	NULL,		-- ����ȱʡֵ
	remark  		varchar(255) 	NULL,		-- ����˵��
	remark1		varchar(255) 	NULL,		-- Ӣ��˵��
	addby			varchar(10) 	NULL,		-- �����ߣ��ɻ��ʱ�򣬿��������ʡ���
	addtime		datetime	default getdate() not null,	-- ������ʱ�� 
	usermod		char(1)	default 'T'	null,					-- �û������޸�
	lic			varchar(20) default '' not null,			-- ��Ȩ����
	cby			varchar(10) 	NULL,		-- �޸���
	changed		datetime	default getdate() not null,	-- 
);
EXEC sp_primarykey 'sysoption', catalog,item;
CREATE UNIQUE NONCLUSTERED INDEX index1 ON sysoption(catalog,item);


//insert sysoption select *, '', getdate() from a_sysoption;
//select * from sysoption;



