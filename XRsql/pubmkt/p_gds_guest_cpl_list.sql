/* ָ�����˵���Ҫ��Ϣ�����Ը����û����������޸� */

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
	date					datetime			not null,						/* ���� */
	item					char(3)			not null,						/* ��Ŀ */
	ref					text		null,								/* ��ע */
	tag					char(1)			default '' not null,			/* ��־ */
	cby					char(10)			not null,						/* �û� */
	changed				datetime			not null							/* ���� */
)
insert #cpl select date, item, ref, tag, cby, changed from guest_cpl where no = @no
select date, item, ref, tag, cby, changed from #cpl order by date
;
