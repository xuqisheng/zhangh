-- ��Ա��ͳ�Ʊ���

if exists(select * from sysobjects where type ="U" and name = "vipreport")
   drop table vipreport;
create table vipreport
(
	date			datetime		not null,							-- Ӫҵ����
	class			char(10)		not null,							-- ��Ŀ����
	type			char(3)		not null,							-- ����
	descript		char(24)		not null,							-- ��������
	descript1	char(24)		not null,							-- Ӣ������
	day			money			default 0 not null,
	month			money			default 0 not null,
	year			money			default 0 not null
)
;
exec   sp_primarykey vipreport, class, type
create unique index index1 on vipreport(class, type)
;

if exists(select * from sysobjects where type ="U" and name = "yvipreport")
   drop table yvipreport;
create table yvipreport
(
	date			datetime		not null,							-- Ӫҵ����
	class			char(10)		not null,							-- ��Ŀ����
	type			char(3)		not null,							-- ����
	day			money			default 0 not null,
	month			money			default 0 not null,
	year			money			default 0 not null
)
;
exec   sp_primarykey yvipreport, date, class, type
create unique index index1 on yvipreport(date, class, type)
;
