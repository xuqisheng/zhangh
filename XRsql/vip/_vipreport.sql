-- 会员卡统计报表

if exists(select * from sysobjects where type ="U" and name = "vipreport")
   drop table vipreport;
create table vipreport
(
	date			datetime		not null,							-- 营业日期
	class			char(10)		not null,							-- 项目代码
	type			char(3)		not null,							-- 卡类
	descript		char(24)		not null,							-- 中文描述
	descript1	char(24)		not null,							-- 英文描述
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
	date			datetime		not null,							-- 营业日期
	class			char(10)		not null,							-- 项目代码
	type			char(3)		not null,							-- 卡类
	day			money			default 0 not null,
	month			money			default 0 not null,
	year			money			default 0 not null
)
;
exec   sp_primarykey yvipreport, date, class, type
create unique index index1 on yvipreport(date, class, type)
;
