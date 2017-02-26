/* 指定客人的主要信息，可以根据用户需求自行修改 */

if exists(select * from sysobjects where name = "p_gds_guest_cpl_list")
	drop proc p_gds_guest_cpl_list;

create proc p_gds_guest_cpl_list
	@no				char(7)
as

declare
	@arr				datetime, 
	@dep				datetime, 
	@ratecode		char(10), 
	@srqs				varchar(30), 
	@charge			money, 
	@credit			money, 
	@accredit		money, 
	@vip				char(1)


create table #cpl
(
	date					datetime			not null,						/* 日期 */
	item					char(3)			not null,						/* 项目 */
	ref					text		null,								/* 备注 */
	tag					char(1)			default '' not null,			/* 标志 */
	cby					char(10)			not null,						/* 用户 */
	changed				datetime			not null							/* 日期 */
)
insert #cpl select date, item, ref, tag, cby, changed from guest_cpl where no = @no
select date, item, ref, tag, cby, changed from #cpl order by date
;
