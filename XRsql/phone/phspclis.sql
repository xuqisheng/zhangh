/*	电话转帐关系维护表*/

if exists(select * from sysobjects where name = "phspclis")
	drop table phspclis;

create table phspclis
(
	room		   char(8)		not null,	/*分机号*/
	rm_ac_type	char(1)		not null,	/*帐号或分机"A"/"R"*/
	r_a_number	char(10)		not null,	/*帐号,分机*/
	name		   char(50)	   not null,	/*用户姓名*/
)
exec sp_primarykey phspclis,room
create unique index index1 on phspclis(room);
