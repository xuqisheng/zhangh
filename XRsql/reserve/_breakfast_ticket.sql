/* 早餐券发放明细明细 */

if exists(select * from sysobjects where type ="U" and name = "breakfast_ticket")
	drop table breakfast_ticket
;
create table breakfast_ticket
(
	accnt			char(10)		not null,								/* 帐号 */
	roomno		char(5)		default '' not null,					/* 房号 */
	startno		char(10)		not null,								/* 起始编号 */
	starting		datetime		null,										/* 起始日期 */
	quantity		integer		default 1 not null,					/* 数量 */
	endno			char(10)		not null,								/* 截止编号 */
	ending		datetime		null,										/* 截止日期 */
	tag			char(1)		default '0' not null,				/* 状态:0.发放;5.作废;9.使用*/
	empno1		char(10)		not null,								/* 发放/使用工号 */
	bdate1		datetime		not null,								/* 发放/使用营业日期 */
	shift1		char(1)		not null,								/* 发放/使用班别 */
	log_date1	datetime		default getdate() not null,		/* 发放/使用时间 */
	empno2		char(10)		null,										/* 作废工号 */
	bdate2		datetime		null,										/* 作废营业日期 */
	shift2		char(1)		null,										/* 作废班别 */
	log_date2	datetime		null										/* 作废时间 */
)
exec sp_primarykey breakfast_ticket, accnt, log_date1
create unique index index1 on breakfast_ticket(accnt, log_date1)
;

/* 早餐券用户对照表 */

if exists(select * from sysobjects where type ="U" and name = "breakfast_empno")
	drop table breakfast_empno
;
create table breakfast_empno
(
	empno			char(10)		not null,								/* 发放工号 */
	no				char(10)		not null									/* 起始编号 */
)
exec sp_primarykey breakfast_empno, empno
create unique index index1 on breakfast_empno(empno)
;
insert basecode values ('breakfast_ticket_tag', '0', '发放', '', 'T', 'F', 10, '', 'F');
insert basecode values ('breakfast_ticket_tag', '5', '作废', '', 'T', 'F', 20, '', 'F');
insert basecode values ('breakfast_ticket_tag', '9', '使用', '', 'T', 'F', 30, '', 'F');
