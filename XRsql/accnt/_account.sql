if exists(select * from sysobjects where type ="U" and name = "account")
   drop table account;

create table account
(
	accnt			char(10)		not null,							/* �˺� */
	subaccnt		integer		default 0 not null,				/* ���˺�(���������������һ�㣿) */
	number		integer		not null,							/* �������к�,ÿ���˺ŷֱ��1��ʼ */
	inumber		integer		not null,							/* �������к�(����,ת��ʱ����) */
	modu_id		char(2)		not null,							/* ģ��� */
	log_date		datetime		default getdate() not null,	/* �������� */
	bdate			datetime		not null,							/* Ӫҵ���� */
	date			datetime		default getdate() not null,	/* ��Ʊ���� */
	pccode		char(5)		not null,							/* Ӫҵ���� */
	argcode		char(3)		default '' null,					/* �ı���(��ӡ���˵��Ĵ���) */
	quantity		money			default 0 not null,				/* ���� */
	charge		money			default 0 not null,				/* �跽��,��¼�������� */
	charge1		money			default 0 not null,				/* �跽��(������) */
	charge2		money			default 0 not null,				/* �跽��(�Żݷ�) */
	charge3		money			default 0 not null,				/* �跽��(�����) */
	charge4		money			default 0 not null,				/* �跽��(˰�����ӷ�) */
	charge5		money			default 0 not null,				/* �跽��(����) */
	package_d	money			default 0 not null,				/* ʵ��ʹ��Package�Ľ��,��ӦPackage_Detail.charge */
	package_c	money			default 0 not null,				/* Package�������ѵĽ��,��ӦPackage.credit,Package_Detail.credit */
	package_a	money			default 0 not null,				/* Package��ʵ�ʽ��,��ӦPackage.amount */
	credit		money			default 0 not null,				/* ������,��¼���˶��𼰽���� */
	balance		money			default 0 not null,				/* �¼��ֶ� */
//
	shift			char(1)		not null,							/* ����Ա��� */
	empno			char(10)		not null,							/* ����Ա���� */
	crradjt		char(2)		default '' not null,				/* �����־(���˵����) */
	waiter		char(3)		default '' not null,				/* ���ÿ�ˢ���д��� */
	tag			char(3)		null,									/* �г��� */
	reason		char(3)		null,									/* �Ż����� */
	tofrom		char(2)		default '' not null,				/* ת�˷���,"TO"��"FM" */
	accntof		char(10)		default '' not null,				/* ת����Դ��Ŀ�� */
	subaccntof	integer		default 0 not null,				/* ת�����˺�(���������������һ�㣿) */
	ref			char(24)		default '' null,					/* ���ã��������� */
	ref1			char(10)		default '' null,					/* ���� */
	ref2			char(50)		default '' null,					/* ժҪ */
	roomno		char(5)		default '' not null,				/* ���� */
	groupno		char(10)		default '' not null,				/* �ź� */
	mode			char(10)		null,									/* ������ϸ��Ϣ */
	billno		char(10)		default '' not null,				/* ���˵��� */
// �����ֶκ��������Ҫ�ˣ�
	empno0		char(10)		null,									/* ���ˣ����ţ� */
	date0			datetime		null,									/* ���ˣ�ʱ�䣩 */
	shift0		char(1)		null,									/* ���ˣ���ţ� */
	mode1			char(10)		null,									/* ������ */
	pnumber		integer		default 0 null,					/* ͬһ�����ĺ������һ����inumber��ͬ */
	package		char(3)		null									/* ���˱�־ */
)
;
exec   sp_primarykey account, accnt, number
create unique index index1 on account(accnt, number)
create index index2 on account(billno, accnt, subaccnt, pccode)
create index index3 on account(tofrom, accntof, subaccntof)
create index index4 on account(bdate, shift, empno)
;
insert account select accnt, 1, number, inumber, modu_id, log_date, bdate, date, pccode + servcode, pccode, 1, charge, 
	0, 0, 0, 0, 0,	0, 0, 0, credit, balance, shift, empno, crradjt, waiter, tag, tag1, tofrom, accntof, 0, 
	substring(ref + '        ', 1, 8) + ref1, '', ref2, isnull(roomno, ''), isnull(groupno, ''), mode, billno, empno0, date0, shift0, mode1, pnumber, package
	from a_account;
update account set billno = 'B' + substring(billno, 2, 9) where billno like '[OP]%';
//
update account set pccode = substring(pccode, 1, 2) + '0' where substring(pccode, 3, 1) = 'A';
update account set pccode = substring(pccode, 1, 2) + '1' where substring(pccode, 3, 1) = 'Z';
update account set pccode = substring(pccode, 1, 2) + '2' where substring(pccode, 3, 1) = 'B';
update account set pccode = substring(pccode, 1, 2) + '3' where substring(pccode, 3, 1) = 'C';
update account set pccode = substring(pccode, 1, 2) + '4' where substring(pccode, 3, 1) = 'D';
update account set pccode = substring(pccode, 1, 2) + '5' where substring(pccode, 3, 1) = 'E';
update account set pccode = substring(pccode, 1, 2) + '6' where substring(pccode, 3, 1) = 'F';
update account set pccode = substring(pccode, 1, 2) + '7' where substring(pccode, 3, 1) = 'S';
update account set pccode = substring(pccode, 1, 2) + '8' where substring(pccode, 3, 1) = 'T';
update account set pccode = substring(pccode, 1, 2) + '9' where substring(pccode, 3, 1) = 'H';
update account set crradjt = '' where crradjt = 'NR';
update account set pccode = '00' + substring(pccode, 3, 1) where pccode like '02%';
update account set argcode = '98' where pccode in ('050', '060');
update account set argcode = '99' where pccode in ('030');
update account set pccode = a.pccode from pccode a where account.tag = a.deptno2;

//update account set billno = '' where billno = '  ' + accnt + '0'
//update account set pnumber = a.number, log_date = a.log_date from hry_account a
//	where account.pccode='02' and account.accnt = a.accnt
//	and (account.accntof = a.accntof or (rtrim(account.accntof) is null and rtrim(a.accntof) is null))
//	and account.pccode = a.pccode and account.bdate = a.bdate and a.servcode = 'A';
//update account set tag = tag1, tag1 = '' where pccode in ('03','05','06');
//update account set ref2 = ref1, ref1 = a.descript2 from paymth a where account.tag = a.descript1
//update account set package = ' ' + pccode where rtrim(package) is null
//update account set ref2 = ref1 + ref2 where modu_id <> '02';
//update account set ref1 = a.descript2 from chgcod a
//	where account.modu_id <> '02' and account.pccode = a.pccode and account.servcode = a.servcode;
