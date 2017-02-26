if exists(select 1 from sysobjects where name = "lunar" and type="U")
	drop table lunar;

create table lunar
(
	date	 		datetime		               not null,	-- 日期
	descript1 	varchar(10)		            null,			-- 年
	descript2 	varchar(10)		            null,			-- 月
	descript3 	varchar(10)		            null,			-- 日
	descript4 	varchar(10)		            null,			-- 节气
)
exec sp_primarykey lunar, date
create unique index index1 on lunar(date)
;
