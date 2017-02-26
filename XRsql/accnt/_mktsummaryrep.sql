/* ��Դ�������� */

if exists (select * from sysobjects where name ='mktsummaryrep' and type ='U')
	drop table mktsummaryrep;

create table  mktsummaryrep
(
	date			datetime null, 
	class			char(1)  not null, 						/* ����, A=ɢ��, B=����, C=���� */
	descript		char(20)  null,  
	class1		char(3)  null, 								/* С�� */
	descript1	char(20) null, 								/* ���� */
	pquan			money default 0 not null, 
	rquan			money default 0 not null, 
	rincome		money default 0 not null, 
	tincome		money default 0 not null
)
exec sp_primarykey mktsummaryrep, class, class1
create unique index index1 on mktsummaryrep(class, class1)
;

if exists (select * from sysobjects where name ='ymktsummaryrep' and type ='U')
	drop table ymktsummaryrep;

create table  ymktsummaryrep
(
	date			datetime null, 
	class			char(1)  not null, 						/* ����, A=ɢ��, B=����, C=���� */
	descript		char(20)  null,  
	class1		char(3)  null, 								/* С�� */
	descript1	char(20) null, 								/* ���� */
	pquan			money default 0 not null, 
	rquan			money default 0 not null, 
	rincome		money default 0 not null, 
	tincome		money default 0 not null
)
exec sp_primarykey ymktsummaryrep, date, class, class1
create unique index index1 on ymktsummaryrep(date, class, class1)
create unique index index2 on ymktsummaryrep(class, class1, date)
;

