
/* ϵͳ������֤ */

if exists (select * from sysobjects where name ='syscheck' and type ='U')
	drop table syscheck
;
create table syscheck
(
	window			varchar(30)	not null,							/* ������ */
	datawindow		varchar(30)	not null,							/* ���ݴ������������ؼ��� */
	checkset			varchar(255) default ''	not null				/* ���� */
)
exec sp_primarykey syscheck, window, datawindow
create unique index index1 on syscheck(window, datawindow)
;
INSERT INTO syscheck VALUES (	'w_gds_master', 'd_gds_master11',	'c:ref;');
