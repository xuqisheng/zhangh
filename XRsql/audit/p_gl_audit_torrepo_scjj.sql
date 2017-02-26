/* 四川锦江临时挂帐(转应收帐)日报表 */
//
//if exists (select * from sysobjects where name ='torrepo' and type ='U')
//	drop table torrepo;
//create table torrepo
//(
//	date			datetime			default getdate() not null, // 日期
//	type			char(1)			default '' not null, 		// S:挂帐;其他:转应收帐
//	modu_id		char(2)			default '01' not null, 
//	roomno		char(5)			null, 
//	foliono		char(10)			default '' not null, 
//	name			varchar(50)		null, 
//	groupno		char(10)			default '' not null, 
//	grpname		varchar(50)		null, 
//	araccnt		char(10)			default '' not null, 
//	arname		varchar(60)		null, 
//	amount1		money				default 0 not null, 			// 预付款
//	amount2		money				default 0 not null, 			// 房费
//	amount3		money				default 0 not null, 			// 餐费
//	amount4		money				default 0 not null, 			// 电话
//	amount5		money				default 0 not null, 			// 商务
//	amount6		money				default 0 not null, 			// 预付款
//	amount7		money				default 0 not null, 			// 预付款
//	amount8		money				default 0 not null, 			// 预付款
//	amount9		money				default 0 not null, 			// 其他
//	amount10		money				default 0 not null, 
//	amount		money				default 0 not null, 
//	empno			char(10)			not null, 
//	descript		char(16)			not null
//)
//exec sp_primarykey torrepo, type, modu_id, foliono, groupno, araccnt, empno
//create unique index index1 on torrepo(type, modu_id, foliono, groupno, araccnt, empno)
//;
//
//if exists (select * from sysobjects where name ='ytorrepo' and type ='U')
//	drop table ytorrepo;
//create table ytorrepo
//(
//	date			datetime			default getdate() not null, // 日期
//	type			char(1)			default '' not null, 		// S:挂帐;其他:转应收帐
//	modu_id		char(2)			default '01' not null, 
//	roomno		char(5)			null, 
//	foliono		char(10)			default '' not null, 
//	name			varchar(50)		null, 
//	groupno		char(10)			default '' not null, 
//	grpname		varchar(50)		null, 
//	araccnt		char(10)			default '' not null, 
//	arname		varchar(60)		null, 
//	amount1		money				default 0 not null, 			// 预付款
//	amount2		money				default 0 not null, 			// 房费
//	amount3		money				default 0 not null, 			// 餐费
//	amount4		money				default 0 not null, 			// 电话
//	amount5		money				default 0 not null, 			// 商务
//	amount6		money				default 0 not null, 			// 预付款
//	amount7		money				default 0 not null, 			// 预付款
//	amount8		money				default 0 not null, 			// 预付款
//	amount9		money				default 0 not null, 			// 其他
//	amount10		money				default 0 not null, 
//	amount		money				default 0 not null, 
//	empno			char(10)			not null, 
//	descript		char(16)			not null
//)
//exec sp_primarykey ytorrepo, date, type, modu_id, foliono, groupno, araccnt, empno
//create unique index index1 on ytorrepo(date, type, modu_id, foliono, groupno, araccnt, empno)
//;
//
if exists (select * from sysobjects where name ='p_gl_audit_torrepo' and type ='P')
	drop proc p_gl_audit_torrepo;
create proc p_gl_audit_torrepo
//	@isyes			char(1)
as

declare
	@bdate			datetime, 
	@duringaudit	char(1), 
	@torcode			char(3)

truncate table torrepo
select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
//if charindex('tTyY', @isyes) > 0
//	select @bdate = dateadd(day, 1, @bdate)
select @torcode = pccode from pccode where deptno2 = 'TOR'
// 临时挂帐客人
insert torrepo (type, foliono, empno, descript) 
	select 'S', a.accnt, max(a.billno), '临时挂帐' from billno a, master_till b
	where a.billno like 'S%' and a.accnt = b.accnt and a.bdate = @bdate and b.sta = 'S'
	group by a.accnt
update torrepo set empno = a.empno1 from billno a where torrepo.empno = a.billno
update torrepo set amount1 = isnull((select sum(a.credit) from account a 
	where a.accnt=torrepo.foliono and billno = ''), 0)
update torrepo set amount2 = isnull((select sum(a.charge) from account a 
	where a.accnt=torrepo.foliono and a.billno = '' and a.pccode < '02'), 0)
update torrepo set amount3 = isnull((select sum(a.charge) from account a 
	where a.accnt=torrepo.foliono and a.billno = '' and a.pccode >= '10' and a.pccode <= '39'), 0)
update torrepo set amount4 = isnull((select sum(a.charge) from account a 
	where a.accnt=torrepo.foliono and a.billno = '' and a.pccode like '6[8,9]%'), 0)
update torrepo set amount = isnull((select sum(a.charge) from account a 
	where a.accnt=torrepo.foliono and a.billno = ''), 0)
// 前台转应收帐客人
insert torrepo (foliono, groupno, araccnt, empno, descript) 
	select distinct accntof, accntof, accnt, empno, '前台转应收帐' from gltemp 
	where tofrom='FM' and accnt like 'A%' and accntof like '[G,M]%'
insert torrepo (foliono, araccnt, empno, descript) 
	select distinct accntof, accnt, empno, '前台转应收帐' from gltemp 
	where tofrom='FM' and accnt like 'A%' and accntof like '[C,F]%'
update torrepo set amount1 = isnull((select sum(a.credit) from gltemp a 
	where a.accnt=torrepo.araccnt and a.accntof=torrepo.foliono and a.tofrom='FM'), 0) where type = ''
update torrepo set amount2 = isnull((select sum(a.charge) from gltemp a 
	where a.accnt=torrepo.araccnt and a.accntof=torrepo.foliono and a.tofrom='FM' and a.pccode < '02'), 0) where type = ''
update torrepo set amount3 = isnull((select sum(a.charge) from gltemp a 
	where a.accnt=torrepo.araccnt and a.accntof=torrepo.foliono and a.tofrom='FM' and a.pccode >= '10' and a.pccode <= '39'), 0) where type = ''
update torrepo set amount4 = isnull((select sum(a.charge) from gltemp a 
	where a.accnt=torrepo.araccnt and a.accntof=torrepo.foliono and a.tofrom='FM' and a.pccode like '6[8,9]%'), 0) where type = ''
update torrepo set amount = isnull((select sum(a.charge) from gltemp a 
	where a.accnt=torrepo.araccnt and a.accntof=torrepo.foliono and a.tofrom='FM'), 0) where type = ''
// 应收帐中录入
insert torrepo (araccnt, empno, descript) 
	select distinct accnt, empno, '应收帐中录入' from gltemp 
	where tofrom='' and modu_id = '02' and accnt like 'A%' and not billno like 'C%'
update torrepo set amount1 = isnull((select sum(a.credit) from gltemp a 
	where a.accnt=torrepo.araccnt and a.tofrom='' and a.modu_id = '02'), 0) where type = '' and foliono = ''
update torrepo set amount2 = isnull((select sum(a.charge) from gltemp a 
	where a.accnt=torrepo.araccnt and a.tofrom='' and a.modu_id = '02' and a.pccode < '02'), 0) where type = '' and foliono = ''
update torrepo set amount3 = isnull((select sum(a.charge) from gltemp a 
	where a.accnt=torrepo.araccnt and a.tofrom='' and a.modu_id = '02' and a.pccode >= '10' and a.pccode <= '39'), 0) where type = '' and foliono = ''
update torrepo set amount4 = isnull((select sum(a.charge) from gltemp a 
	where a.accnt=torrepo.araccnt and a.tofrom='' and a.modu_id = '02' and a.pccode like '6[8,9]%'), 0) where type = '' and foliono = ''
update torrepo set amount = isnull((select sum(a.charge) from gltemp a 
	where a.accnt=torrepo.araccnt and a.tofrom='' and a.modu_id = '02'), 0) where type = '' and foliono = ''
// 餐饮转应收帐客人
insert torrepo (modu_id, foliono, name, araccnt, amount3, amount, empno, descript) 
	select '04', a.menu, c.descript + a.menu, substring(a.remark, 1, 7), a.amount, a.amount, a.empno, '餐饮部转应收帐'
	from pos_tpay a, pos_tmenu b, pos_pccode c
	where a.crradjt = 'NR' and a.paycode = @torcode and a.menu = b.menu and b.pccode = c.pccode
//	where a.sta = '0' and a.paycode = @torcode and a.menu = b.menu and b.pccode = c.pccode
// 商务中心(客房中心)转应收帐客人
insert torrepo (modu_id, foliono, name, araccnt, amount5, amount, empno, descript) 
	select a.modu, setnumb, substring(b.descript, 1, 8) + setnumb, accnt, amount, amount, empno, substring(b.descript, 1, 8) + '转应收帐' 
	from bos_haccount a, auth_module b 
	where bdate = @bdate and code = @torcode and a.modu = b.moduno
//
update torrepo set roomno = a.roomno, name = b.name from master_till a, guest b where torrepo.foliono = a.accnt and a.haccnt = b.no
update torrepo set grpname = b.name from master_till a, guest b where torrepo.groupno = a.accnt and a.haccnt = b.no
update torrepo set grpname = c.name from master_till a, master_till b, guest c
	where torrepo.foliono = a.accnt and a.groupno = b.accnt and b.haccnt = c.no
update torrepo set arname = b.name from master_till a, guest b where torrepo.araccnt = a.accnt and a.haccnt = b.no
update torrepo set amount5 = amount + amount1 - amount2 - amount3 - amount4, date = @bdate
delete ytorrepo where date = @bdate
insert ytorrepo select * from torrepo
return 0
;
