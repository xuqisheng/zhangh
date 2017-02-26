
/* 系统存盘验证 */

if exists (select * from sysobjects where name ='syscheck' and type ='U')
	drop table syscheck
;
create table syscheck
(
	window			varchar(30)	not null,							/* 窗口名 */
	datawindow		varchar(30)	not null,							/* 数据窗口名或其他关键字 */
	checkset			varchar(255) default ''	not null				/* 列名 */
)
exec sp_primarykey syscheck, window, datawindow
create unique index index1 on syscheck(window, datawindow)
;
INSERT INTO syscheck VALUES (	'w_gds_master', 'd_gds_master11',	'c:ref;');
