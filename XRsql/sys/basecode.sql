// ------------------------------------------------------------------------------
// �򵥴���  -- �ϲ�ԭ��ϵͳ�����еļ򵥴���
//
//		�򵥴���Ľ綨�������¼���Ǻܳ�������Ҫ�����룻 		-- �������������ܼ���
//							�����������٣�û��ʲô����ĸ������ԣ� -- ���ࡢ�г��벻�ܼ���
//
// ------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "basecode_cat")
	drop table basecode_cat;
create table basecode_cat
(
	cat				char(30)							not null,
   descript   		varchar(60)    				not null,
   descript1  		varchar(60) default ''   	not null,
	len				int			default 3		not null,		// ���볤��
	flag				char(30)		default ''		not null,
	center			char(1)		default 'F'		not null			// �������
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
	sys				char(1)		default 'F'		not null,		//	ϵͳ����
	halt				char(1)		default 'F'		not null,		// ͣ��?
	sequence			int			default 0		not null,		// ����
	grp				varchar(16)	default ''   	not null,		// ����
	center			char(1)		default 'F'   	not null,			// center code ?
	cby				char(10)		default '!' 	not null,	/* �����޸�����Ϣ */
	changed			datetime		default getdate()		not null 
)
exec sp_primarykey basecode,cat,code
create unique index index1 on basecode(cat,code)
;