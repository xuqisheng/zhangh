/* 早餐券调整明细 */

if exists(select * from sysobjects where name = "breakfast")
	drop table breakfast;

create table breakfast(
	date			datetime		not null,					/* 营业日期 */
	posted		char(1)		default 'F'	not null,	/* 标志 */
	lf				money			default 0 	not null,	/* 上日预提散客 */
	lg		  		money			default 0 	not null,	/* 上日预提团体 */
	lm		  		money			default 0 	not null,	/* 上日预提会议 */
	ll				money			default 0 	not null,	/* 上日预提长住 */
	cf				money			default 0 	not null,	/* 本日实收散客 */
	cg		  		money			default 0 	not null,	/* 本日实收团体 */
	cm		  		money			default 0 	not null,	/* 本日实收会议 */
	cl				money			default 0 	not null,	/* 本日实收长住 */
	tf				money			default 0 	not null,	/* 本日预提散客 */
	tg		  		money			default 0 	not null,	/* 本日预提团体 */
	tm		  		money			default 0 	not null,	/* 本日预提会议 */
	tl				money			default 0 	not null,	/* 本日预提长住 */
)
exec sp_primarykey breakfast, date
create unique index index1 on breakfast(date)
;