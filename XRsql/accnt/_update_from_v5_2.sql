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
	pccode		char(3)		not null,							/* Ӫҵ���� */
	argcode		char(2)		default '' null,					/* �ı���(��ӡ���˵��Ĵ���) */
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
	empno0		char(10)		null,									/* ������ */
	date0			datetime		null,									/* ������ */
	shift0		char(1)		null,									/* ������ */
	mode1			char(10)		null,									/* ������ */
	pnumber		integer		default 0 null,					/* ͬһ�����ĺ������һ����inumber��ͬ */
	package		char(3)		null									/* ���Ĵ��� */
)
;
insert account select accnt, 1, number, inumber, modu_id, log_date, bdate, date, pccode + servcode, pccode, 1, charge, 
	0, 0, 0, 0, 0,	0, 0, 0, credit, balance, shift, empno, crradjt, waiter, tag, tag1, tofrom, accntof, 0, 
	substring(ref + '        ', 1, 8) + ref1, '', ref2, isnull(roomno, ''), isnull(groupno, ''), mode, billno, empno0, date0, shift0, mode1, pnumber, package
	from v5..account
;
exec   sp_primarykey account, accnt, number
create unique index index1 on account(accnt, number)
create index index2 on account(billno, accnt, subaccnt, pccode)
create index index3 on account(tofrom, accntof, subaccntof)
create index index4 on account(bdate, shift, empno)
update account set billno = 'B' + substring(billno, 2, 9) where billno like '[OP]%';
update account set quantity=0 where pccode<'03';
update account set quantity=1 where pccode='02A' and mode like '[B,J,N]%';
update account set quantity=0.5 where pccode='02A' and mode like '[b,j,P]%';
//
update account set pccode = a.pos_item,argcode = substring(a.pos_item,1,2) from a_chgcod a where account.pccode = a.old_pccode;
update account set crradjt = '' where crradjt = 'NR';
update account set argcode = '98' where argcode in ('05', '06');
update account set argcode = '99' where argcode in ('03');
update account set pccode = a.pccode from pccode a where account.tag = a.deptno2;
// JJH
update account set pccode = '921' where pccode='920';
update account set pccode = '916' where pccode in ('917', '919');
update account set pccode = '918' where pccode='917';
update account set charge1 = charge where reason = '';
update account set charge2 = - charge where reason <> '';
