/* 指定客人的主要信息，可以根据用户需求自行修改 */

if exists(select * from sysobjects where name = "p_gl_public_reservation_detail")
	drop proc p_gl_public_reservation_detail;

create proc p_gl_public_reservation_detail
	@date				datetime
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


create table #detail
(
	type					char(5)			null,								/* 房类 */
	restype				char(3)			null,								/* 预订类型 */
	descript				char(30)			null,								/* 描述 */
	descript1			char(30)			null,								/* 英文描述 */
	quantity				integer			default 0 null					/* 数量 */
)
insert #detail select a.type, b.code, b.descript, b.descript1, 0 from typim a, restype b where b.code > '0'
insert #detail select type, '', '在住', 'Checked In', 0 from typim
insert #detail select b.type, '', '在住', 'Checked In', b.quantity from master a, rsvsaccnt b
	where a.sta = 'I' and a.accnt = b.saccnt and datediff(dd, b.begin_, @date) >= 0 and datediff(dd, b.end_, @date) <= 0
insert #detail select b.type, a.restype, c.descript, c.descript1, b.quantity from master a, rsvsaccnt b, restype c
	where a.sta != 'I' and a.accnt = b.saccnt and datediff(dd, b.begin_, @date) >= 0 and datediff(dd, b.end_, @date) <= 0
	and a.restype *= c.code
select * from #detail
select type, restype, descript, descript1, sum(quantity) from #detail group by type, restype, descript, descript1
;
