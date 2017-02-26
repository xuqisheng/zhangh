
/*
	ÿ�췿��Ԥ���
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
	type			char(5)			null,								/*��������*/
	market		char(3)			null,								/*�۱���*/
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
	posted		char(1)			default 'F'	not null,		/*��ʾ���ʷ�*/
	rmpostdate	datetime			not null, 
	// ������Ϣ
	logmark		integer			not null,						/* �����ѵ�ʱ����־ָ�� */
	empno			char(10)			not null, 						/* ����Ա */
	shift			char(1)			not null,  						/* ���ʰ�� */
	date			datetime			default getdate() not null	/* ����ʱ�� */
)
create index index1 on rmpostbucket(rmpostdate, accnt);
create index index2 on rmpostbucket(rmpostdate, groupno);
create index index3 on rmpostbucket(rmpostdate, posted);

//	ÿ�췿��Ԥ�����1(Packageר��)

if exists(select * from sysobjects where name = 'rmpostpackage')
	drop table rmpostpackage;

create table rmpostpackage
(
	pc_id					char(4)			not null, 
	mdi_id				integer			not null, 
	accnt					char(10)			not null,							/* �˺� */
	number				integer			not null,							/* �ؼ��� */
	roomno				char(5)			default '' not null,				/* ���� */
	code					char(4)			default '' not null,				/* ���� */
	pccode				char(5)			not null, 
	argcode				char(3)			default '' not null, 
	amount				money				not null,
	quantity				money				default 1 not null,
	rule_calc			char(10)			not null,
	starting_date		datetime			default '2000/1/1' not null,		/* ��Ч��ʼ���� */
	closing_date		datetime			default '2038/12/31' not null,	/* ��Ч��ֹ���� */
	starting_time		char(8)			default '00:00:00' not null,		/* ÿ�����Ч������ʼʱ�� */
	closing_time		char(8)			default '23:59:59' not null,		/* ÿ�����Ч���˽�ֹʱ�� */
	descript				char(30)			not null,							/* ���� */
	descript1			char(30)			default '' not null,				/* Ӣ������ */
	pccodes				varchar(255)	default '' not null,				/* ���Թ�����Ӫҵ������� */
	pos_pccode			char(5)			default '' not null,				/* �����޶�󣬼���Account��Ӫҵ������� */
	credit				money				default 0 not null,				/* ����ת�˵Ľ�� */
)
exec sp_primarykey rmpostpackage, pc_id, mdi_id, accnt, number
create unique index index1 on rmpostpackage(pc_id, mdi_id, accnt, number);

//	ÿ�췿��Ԥ�����2(�����ȫ�ⷿר��)

if exists(select * from sysobjects where name = 'rmpostvip')
	drop table rmpostvip;

create table rmpostvip
(
	pc_id			char(4)			not null, 
	mdi_id		integer			not null, 
	accnt			char(10)			not null,					// �˺�
	cusid			char(10)			not null, 					//	Э���
	number1		integer			default 0 not null, 		//	������
	number2		integer			default 0 not null,		//	������
	accnts		varchar(255)	default '' not null 		//	�����ʺ�
)
exec sp_primarykey rmpostvip, pc_id, mdi_id, accnt, cusid
create unique index index1 on rmpostvip(pc_id, mdi_id, accnt, cusid);

