/*	�绰ת�ʹ�ϵά����*/

if exists(select * from sysobjects where name = "phspclis")
	drop table phspclis;

create table phspclis
(
	room		   char(8)		not null,	/*�ֻ���*/
	rm_ac_type	char(1)		not null,	/*�ʺŻ�ֻ�"A"/"R"*/
	r_a_number	char(10)		not null,	/*�ʺ�,�ֻ�*/
	name		   char(50)	   not null,	/*�û�����*/
)
exec sp_primarykey phspclis,room
create unique index index1 on phspclis(room);
