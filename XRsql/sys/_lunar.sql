if exists(select 1 from sysobjects where name = "lunar" and type="U")
	drop table lunar;

create table lunar
(
	date	 		datetime		               not null,	-- ����
	descript1 	varchar(10)		            null,			-- ��
	descript2 	varchar(10)		            null,			-- ��
	descript3 	varchar(10)		            null,			-- ��
	descript4 	varchar(10)		            null,			-- ����
)
exec sp_primarykey lunar, date
create unique index index1 on lunar(date)
;
