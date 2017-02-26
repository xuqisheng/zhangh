
/*
	每天房租预审表
*/

if exists(select * from sysobjects where name = 'rmpostbucket')
	drop table rmpostbucket;

create table rmpostbucket
(
	accnt			char(10)			not null, 
	roomno		char(5)			null, 
	src			char(3)			null, 
	class			char(1)			null, 
	groupno		char(10)			null, 
	headname		varchar(100)	null, 
	type			char(5)			null,								/*房间类型*/
	market		char(3)			null,								/*价别码*/
	name			varchar(50)		null, 
	fir			varchar(60)		null, 
	ratecode		char(10)			null, 
	packages		varchar(50)		null, 
	paycode		char(5)			null, 
	cmscode		varchar(10)		null, 
	rmrate		money				not null, 
	qtrate		money				not null, 
	setrate		money				not null, 
	charge1		money				not null, 
	charge2		money				not null, 
	charge3		money				not null, 
	charge4		money				not null, 
	charge5		money				not null, 
	package_c	money				not null, 
	rtreason		char(3)			null, 
	gstno			integer			null, 
	arr			datetime			not null, 
	dep			datetime			null, 
	today_arr	char(1)			default 'F'	not null, 
	w_or_h		integer			not null, 
	posted		char(1)			default 'F'	not null,		/*表示入帐否*/
	rmpostdate	datetime			not null, 
	// 入帐信息
	logmark		integer			not null,						/* 过房费当时的日志指针 */
	empno			char(10)			not null, 						/* 入帐员 */
	shift			char(1)			not null,  						/* 入帐班别 */
	date			datetime			default getdate() not null	/* 入帐时间 */
)
create index index1 on rmpostbucket(rmpostdate, accnt);
create index index2 on rmpostbucket(rmpostdate, groupno);
create index index3 on rmpostbucket(rmpostdate, posted);

//	每天房租预审表附表1(Package专用)

if exists(select * from sysobjects where name = 'rmpostpackage')
	drop table rmpostpackage;

create table rmpostpackage
(
	pc_id					char(4)			not null, 
	mdi_id				integer			not null, 
	accnt					char(10)			not null,							/* 账号 */
	number				integer			not null,							/* 关键字 */
	roomno				char(5)			default '' not null,				/* 房号 */
	code					char(4)			default '' not null,				/* 代码 */
	pccode				char(5)			not null, 
	argcode				char(3)			default '' not null, 
	amount				money				not null,
	quantity				money				default 1 not null,
	rule_calc			char(10)			not null,
	starting_date		datetime			default '2000/1/1' not null,		/* 有效起始日期 */
	closing_date		datetime			default '2038/12/31' not null,	/* 有效截止日期 */
	starting_time		char(8)			default '00:00:00' not null,		/* 每天的有效挂账起始时间 */
	closing_time		char(8)			default '23:59:59' not null,		/* 每天的有效挂账截止时间 */
	descript				char(30)			not null,							/* 描述 */
	descript1			char(30)			default '' not null,				/* 英文描述 */
	pccodes				varchar(255)	default '' not null,				/* 可以关联的营业点费用码 */
	pos_pccode			char(5)			default '' not null,				/* 超出限额后，记入Account的营业点费用码 */
	credit				money				default 0 not null,				/* 允许转账的金额 */
)
exec sp_primarykey rmpostpackage, pc_id, mdi_id, accnt, number
create unique index index1 on rmpostpackage(pc_id, mdi_id, accnt, number);

//	每天房租预审表附表2(贵宾卡全免房专用)

if exists(select * from sysobjects where name = 'rmpostvip')
	drop table rmpostvip;

create table rmpostvip
(
	pc_id			char(4)			not null, 
	mdi_id		integer			not null, 
	accnt			char(10)			not null,					// 账号
	cusid			char(10)			not null, 					//	协议号
	number1		integer			default 0 not null, 		//	可免数
	number2		integer			default 0 not null,		//	已免数
	accnts		varchar(255)	default '' not null 		//	已免帐号
)
exec sp_primarykey rmpostvip, pc_id, mdi_id, accnt, cusid
create unique index index1 on rmpostvip(pc_id, mdi_id, accnt, cusid);

