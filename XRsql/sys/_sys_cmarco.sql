if exists(select 1 from sysobjects where name = "sys_cmarco" and type="U")
	drop table sys_cmarco;
create table sys_cmarco
(
	code	 		varchar(30)		            not null,	-- ������
	mcode			varchar(30)	default ''     not null,	-- ��ѡ���� 
	descript 	varchar(60)		            null,			-- ����
	descript1 	varchar(60)		            null,			-- ���� 
	def			varchar(60)		            null,			-- Ĭ��ֵ 
	hlpcode		text								null,			-- �����ű� 
	sequence    int								null 	
)
exec sp_primarykey sys_cmarco, code
create unique index index1 on sys_cmarco(code)
;
