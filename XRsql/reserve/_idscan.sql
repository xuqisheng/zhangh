
// ֤��ɨ����ʱ�� 

if exists(select * from sysobjects where name = "idscan" and type="U")
	drop table idscan;
create table idscan
(
	no  			char(10)						not null,	-- ��ˮ�� 
	idtype		char(10)	default 'ID'	not null,	-- ID=֤��  SIGN=ǩ�� 
	name			varchar(50)					null,			-- ����
	ref			varchar(60)					null,			-- ˵�� 
	haccnt		char(10)	default ''		not null, 
	idtext		text							null,
	idpic			image							null,
	empno1		char(10)						null,			-- ɨ����
	date1			datetime						null,
	pc_id			char(4)						null,			-- ɨ��վ�� 
	empno2		char(10)						null,			-- ������ 
	date2			datetime						null
)
exec sp_primarykey idscan, no
create unique index  idscan on idscan(no)
;

