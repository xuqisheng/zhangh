// 分账户定义表
if exists(select * from sysobjects where type ="U" and name = "subaccnt")
   drop table subaccnt;

create table subaccnt
(
	roomno				char(5)			default '' not null,				/* 房号 */
	haccnt				char(7)			default '' not null,				/* 客人号 */
	accnt					char(10)			not null,							/* 账号 */
	subaccnt				integer			default 0 not null,				/* 子账号*/
	to_roomno			char(5)			default '' not null,				/* 转账房号 */
	to_accnt				char(10)			default '' not null,				/* 转账账号 */
	name					char(50)			not null,							/* 名称 */
	pccodes				varchar(255)	not null,							/* 费用码 */
	starting_time		datetime			default '2000/1/1' not null,	/* 有效期起始 */
	closing_time		datetime			default '2038/1/1' not null,	/* 有效期截止 */
	cby					char(10)			not null,							/* 工号 */
	changed				datetime			default getdate() not null,	/* 时间 */
	type					char(1)			default '1' not null,			/* 子(AB)账户的类别: 
																							0.允许记账
																							2.团体为成员付费(只有团体主单才有，成员以此为模版)
																							5.分账户(自动转账并入分账户) */
	tag					char(1)			default '0' not null,			/* 0.系统自动增加(不能修改)
																							1.系统自动增加(能修改、不能删除)
																							2.人工产生(能修改) */
	paycode				char(5)			default '' not null,				/* 付款方式 */
	ref					varchar(50)		default '' not null,				/* 备注 */
	logmark				integer			default 0 not null
);
exec sp_primarykey subaccnt, accnt, subaccnt, type, tag, starting_time, closing_time
create unique index index1 on subaccnt(accnt, subaccnt, type, tag, starting_time, closing_time)
create index index2 on subaccnt(to_accnt, type)
create index index3 on subaccnt(accnt, haccnt)
;
// 分账户log定义表
if exists(select * from sysobjects where type ="U" and name = "subaccnt_log")
   drop table subaccnt_log;

create table subaccnt_log
(
	roomno				char(5)			default '' not null,				/* 房号 */
	haccnt				char(7)			default '' not null,				/* 客人号 */
	accnt					char(10)			not null,							/* 账号 */
	subaccnt				integer			default 0 not null,				/* 子账号*/
	to_roomno			char(5)			default '' not null,				/* 转账房号 */
	to_accnt				char(10)			default '' not null,				/* 转账账号 */
	name					char(50)			not null,							/* 名称 */
	pccodes				varchar(255)	not null,							/* 费用码 */
	starting_time		datetime			default '2000/1/1' not null,	/* 有效期起始 */
	closing_time		datetime			default '2038/1/1' not null,	/* 有效期截止 */
	cby					char(10)			not null,							/* 工号 */
	changed				datetime			default getdate() not null,	/* 时间 */
	type					char(1)			default '1' not null,			/* 子(AB)账户的类别: 
																							0.允许记账
																							2.团体为成员付费(只有团体主单才有，成员以此为模版)
																							5.分账户(自动转账并入分账户) */
	tag					char(1)			default '0' not null,			/* 0.系统自动增加(不能修改)
																							1.系统自动增加(能修改、不能删除)
																							2.人工产生(能修改) */
	paycode				char(5)			default '' not null,				/* 付款方式 */
	ref					varchar(50)		default '' not null,				/* 备注 */
	logmark				integer			default 0 not null
);
exec sp_primarykey subaccnt_log, accnt, subaccnt, type, logmark
create unique index index1 on subaccnt_log(accnt, subaccnt, type, logmark)
;
//insert subaccnt select isnull(b.roomno, ''), a.accnt, convert(integer,isnull(a.subaccnt, '0')) + 1, isnull(c.roomno, ''),
//	a.to_accnt, a.name,a.pccodes,'2000/1/1','2038/1/1', a.empno,a.date, a.type, a.tag, '', '', 1
//	from foxhis3.dbo.subaccnt a, foxhis3.dbo.master b, foxhis3.dbo.master c
//	where a.accnt *= b.accnt and a.accnt *= c.accnt;
//delete subaccnt where type in ('2', '4');
//update subaccnt set type = '5' where type = '6';
//update subaccnt set pccodes = '+', tag = '0' where type = '5' and subaccnt = 1;
//update subaccnt set tag = '2' where type = '5' and subaccnt != 1;
////
//insert basecode (cat, code, descript, descript1)
//	select 'deptno'+type, deptno, deptname, isnull(descript1,'') from deptdef;
if exists(select * from sysobjects where type ="U" and name = "hsubaccnt")
   drop table hsubaccnt;

create table hsubaccnt
(
	roomno				char(5)			default '' not null,				/* 房号 */
	haccnt				char(7)			default '' not null,				/* 客人号 */
	accnt					char(10)			not null,							/* 账号 */
	subaccnt				integer			default 0 not null,				/* 子账号*/
	to_roomno			char(5)			default '' not null,				/* 转账房号 */
	to_accnt				char(10)			default '' not null,				/* 转账账号 */
	name					char(50)			not null,							/* 名称 */
	pccodes				varchar(255)	not null,							/* 费用码 */
	starting_time		datetime			default '2000/1/1' not null,	/* 有效期起始 */
	closing_time		datetime			default '2038/1/1' not null,	/* 有效期截止 */
	cby					char(10)			not null,							/* 工号 */
	changed				datetime			default getdate() not null,	/* 时间 */
	type					char(1)			default '1' not null,			/* 子(AB)账户的类别: 
																							0.允许记账
																							2.团体为成员付费(只有团体主单才有，成员以此为模版)
																							5.分账户(自动转账并入分账户) */
	tag					char(1)			default '0' not null,			/* 0.系统自动增加(不能修改)
																							1.系统自动增加(能修改、不能删除)
																							2.人工产生(能修改) */
	paycode				char(5)			default '' not null,				/* 付款方式 */
	ref					varchar(50)		default '' not null,				/* 备注 */
	logmark				integer			default 0 not null
);
exec sp_primarykey hsubaccnt, accnt, subaccnt, type, tag, starting_time, closing_time
create unique index index1 on hsubaccnt(accnt, subaccnt, type, tag, starting_time, closing_time)
create index index2 on hsubaccnt(to_accnt, type)
create index index3 on hsubaccnt(accnt, haccnt)
;