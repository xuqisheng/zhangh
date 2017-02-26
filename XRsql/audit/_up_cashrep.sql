sp_rename cashrep, cashrep_old;
sp_rename ycashrep, ycashrep_old;
/* 现金收入表 */

if exists (select * from sysobjects where name = 'cashrep' and type ='U')
	drop table cashrep;
create table cashrep
(
	date		datetime		null,
	class		char(2)		default '' null, /* '01' 前厅,'02' AR帐,'03',商务中心,'04',综合收银 */
	pccode	char(5)		default '' null,
	shift		char(1)		default '' null,
	empno		char(10)		default '' null,
	cclass	char(1)		default '' null,
	ccode		char(5)		default '' null,
	credit	money			default 0 not null
)
exec sp_primarykey cashrep,class,pccode,shift,empno,cclass,ccode 
create unique index index1 on cashrep(class,pccode,shift,empno,cclass,ccode)
;

insert cashrep (pccode, date, class, shift, empno, cclass, ccode, credit)
	select isnull((select min(b.pccode) from pccode b where substring(b.descript, 1, 10) = a.descript), ''),
	a.date, a.class, a.shift, a.empno, a.cclass, a.ccode, a.credit from cashrep_old a
	where a.class <> '03'
insert cashrep (pccode, date, class, shift, empno, cclass, ccode, credit)
	select isnull((select code from basecode b where b.cat = 'moduno' and substring(b.descript, 1, 10) = a.descript), ''),
	a.date, a.class, a.shift, a.empno, a.cclass, a.ccode, a.credit from cashrep_old a
	where a.class = '03'
;

if exists (select * from sysobjects where name = 'ycashrep' and type ='U')
	drop table ycashrep;
create table ycashrep
(
	date		datetime		null,
	class		char(2)		default '' null, /* '01' 前厅,'02' AR帐,'03',商务中心,'04',综合收银 */
	pccode	char(5)		default '' null,
	shift		char(1)		default '' null,
	empno		char(10)		default '' null,
	cclass	char(1)		default '' null,
	ccode		char(5)		default '' null,
	credit	money			default 0 not null
)
exec sp_primarykey ycashrep,date,class,pccode,shift,empno,cclass,ccode 
create unique index index1 on ycashrep(date,class,pccode,shift,empno,cclass,ccode)
;

insert ycashrep (pccode, date, class, shift, empno, cclass, ccode, credit)
	select isnull((select min(b.pccode) from pccode b where substring(b.descript, 1, 10) = a.descript), ''),
	a.date, a.class, a.shift, a.empno, a.cclass, a.ccode, a.credit from ycashrep_old a
	where a.class <> '03'
insert ycashrep (pccode, date, class, shift, empno, cclass, ccode, credit)
	select isnull((select code from basecode b where b.cat = 'moduno' and substring(b.descript, 1, 10) = a.descript), ''),
	a.date, a.class, a.shift, a.empno, a.cclass, a.ccode, a.credit from ycashrep_old a
	where a.class = '03'
;
