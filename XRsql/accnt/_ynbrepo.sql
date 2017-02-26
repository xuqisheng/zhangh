/* 每日应收款日报 */
-----------------------------------------------
--为了东方豪生暂时统计packages的需要，需要历史数据

if exists(select * from sysobjects where name = "ynbrepo")
	drop table ynbrepo;

create table ynbrepo(
	bdate			datetime		,
	deptno		char(3)		not null,					/* 类别 */
	deptname		char(24)		null,							/* 大类的中文名称 */
	pccode		char(5)		not null,					/*  */
	descript		char(24)    null,							/* 中文名称 */
	f_in			money			default 0 	not null,	/* 前台 */
	b_in  		money			default 0 	not null,	/* 后台 */	/*录入,定金*/
	f_out			money			default 0 	not null,	/* 前台 */
	b_out			money			default 0 	not null,	/* 后台 */	/*退款,部结*/
	f_tran      money			default 0 	not null,	/* 前台 */
	b_tran      money			default 0 	not null,	/* 后台 */	/*转入,清算*/
)
exec sp_primarykey ynbrepo,pccode
create unique index index1 on ynbrepo(pccode)
;