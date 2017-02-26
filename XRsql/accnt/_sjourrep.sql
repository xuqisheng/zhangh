/* 四川锦江费综合报表 */

if exists (select * from sysobjects where name ='sjourrep' and type ='U')
	drop table sjourrep;
create table sjourrep
(
	date			datetime			not null,
	tag			char(1)			default '' not null, 
	deptno		char(5)			not null,
	pccode		char(5)			default '' not null,
	descript		char(24)			not null,
	balance_l	money				default 0 not null,			/* 上日未收数 */
	day0			money				default 0 not null,			/* 本日发生数 */
	month0		money				default 0 not null,			/* 本月发生数 */
	day1			money				default 0 not null,			/* 本日减免打折 */
	month1		money				default 0 not null,			/* 本月减免打折 */
	day2			money				default 0 not null,			/* 本日二次折扣 */
	month2		money				default 0 not null,			/* 本月二次折扣 */
	day3			money				default 0 not null,
	month3		money				default 0 not null,
	day8			money				default 0 not null,			/* 本日实收记账款 */
	month8		money				default 0 not null,			/* 本月实收记账款 */
	day9			money				default 0 not null,			/* 本日实收款 */
	month9		money				default 0 not null,			/* 本月实收款 */
	balance_t	money				default 0 not null			/* 本日未收数 */
);
exec sp_primarykey sjourrep, tag, deptno, pccode
create unique index index1 on sjourrep(tag, deptno, pccode)
;

if exists (select * from sysobjects where name ='ysjourrep' and type ='U')
	drop table ysjourrep;
create table ysjourrep
(
	date			datetime			not null,
	tag			char(1)			default '' not null, 
	deptno		char(5)			not null,
	pccode		char(5)			default '' not null,
	descript		char(24)			not null,
	balance_l	money				default 0 not null,			/* 上日未收数 */
	day0			money				default 0 not null,			/* 本日发生数 */
	month0		money				default 0 not null,			/* 本月发生数 */
	day1			money				default 0 not null,			/* 本日减免打折 */
	month1		money				default 0 not null,			/* 本月减免打折 */
	day2			money				default 0 not null,			/* 本日二次折扣 */
	month2		money				default 0 not null,			/* 本月二次折扣 */
	day3			money				default 0 not null,
	month3		money				default 0 not null,
	day8			money				default 0 not null,			/* 本日实收记账款 */
	month8		money				default 0 not null,			/* 本月实收记账款 */
	day9			money				default 0 not null,			/* 本日实收款 */
	month9		money				default 0 not null,			/* 本月实收款 */
	balance_t	money				default 0 not null			/* 本日未收数 */
);
exec sp_primarykey ysjourrep, date, tag, deptno, pccode
create unique index index1 on ysjourrep(date, tag, deptno, pccode)
;
