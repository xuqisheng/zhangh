/* 客房信用卡 */
if exists ( select * from sysobjects where name = 'p_gl_audit_bankcard' and type ='P')
	drop proc p_gl_audit_bankcard;
create proc p_gl_audit_bankcard
	@begin			datetime, 
	@end				datetime
as

create table #account
(
	pccode		char(5)		not null,							/* 营业点码 */
	credit		money			default 0 not null,				/* 贷方数,记录客人定金及结算款 */
	waiter		char(3)		default '' not null,				/* 信用卡刷卡行代码 */
	tofrom		char(2)		default '' not null,				/* 转账方向,"TO"或"FM" */
	billno		char(10)		default '' not null,				/* 结账单号 */
)
create table #bankcard
(
	pccode		char(5)	not null,
	waiter		char(3)	not null,
	quantity		money		default 0 not null,
	amount		money		default 0 not null
)
insert #account select pccode, credit, waiter, tofrom, billno from account
	where bdate >= @begin and bdate <= @end and argcode > '9'
insert #account select pccode, credit, waiter, tofrom, billno from haccount
	where bdate >= @begin and bdate <= @end and argcode > '9'
delete #account where tofrom in ('TO', 'FM') or billno like 'C%' or waiter = ''
insert #bankcard select pccode, waiter, count(1), sum(credit) from #account group by pccode, waiter
select b.descript, c.descript, isnull(d.quantity, 0), isnull(d.amount, 0)
	from bankcard a, basecode b, pccode c, #bankcard d
	where a.bankcode = b.code and b.cat='bankcode' and a.pccode = c.pccode and a.pccode + a.bankcode *= d.pccode + d.waiter
//select c.descript, b.descript, count(1), sum(a.credit)
//	from #account a, pccode b, basecode c
//	where a.pccode = b.pccode and a.waiter = c.code and c.cat = 'bankcode'
//	group by c.descript, b.descript
;
