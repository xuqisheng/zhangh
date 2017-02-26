/* 现金收入表 */

if exists (select * from sysobjects where name = 'cashrep' and type ='U')
	drop table cashrep;
create table cashrep
(
	date		datetime		null,
	class		char(2)		default '' null, /* '01' 前厅,'02' AR帐,'03',商务中心,'04',综合收银 */
	descript char(10)		default '' null,
	shift		char(1)		default '' null,
	sname		char(6)		default '' null,
	empno		char(10)		default '' null,
	ename		char(12)		default '' null,
	cclass	char(1)		default '' null,
	ccode		char(5)		default '' null,
	credit	money			default 0 not null
)
exec sp_primarykey cashrep,class,shift,empno,cclass,ccode 
create unique index index1 on cashrep(class,shift,empno,cclass,ccode)
;


if exists (select * from sysobjects where name = 'ycashrep' and type ='U')
	drop table ycashrep;
create table ycashrep
(
	date		datetime		null,
	class		char(2)		default '' null, /* '01' 前厅,'02' AR帐,'03',商务中心,'04',综合收银 */
	descript char(10)		default '' null,
	shift		char(1)		default '' null,
	sname		char(6)		default '' null,
	empno		char(10)		default '' null,
	ename		char(12)		default '' null,
	cclass	char(1)		default '' null,
	ccode		char(5)		default '' null,
	credit	money			default 0 not null
)
exec sp_primarykey ycashrep,date,class,shift,empno,cclass,ccode 
create unique index index1 on ycashrep(date,class,shift,empno,cclass,ccode)
;

