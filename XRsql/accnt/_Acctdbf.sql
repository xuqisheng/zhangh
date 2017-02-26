/* GaoLiang 1999/04/19
	    ���������,���ڼ�¼ÿ���˺ŵ���ϸ��
	��һ�ʽ������ڿ��˵�����ʱ,������charge�ֶ�,�������pccode,
servcode�ֶ�,��tag,tag1�м�һЩ�������,����tag������¼���������,
��ɢ��,����,������,AR��,tag1������¼���ֽ���״̬.
	��һ�ʽ������ڿ���֧���Ŀ���ʱ,������credit�ֶ�,�������tag,
tag1�ֶ�,pccode�м�¼"03","05","06",�ֱ��Ӧ�������,����,����,
waiter�����ǲ��ֽ���״̬.

*����********************************************************************
			�������				���������			��ʾ	���Զ�ת��	
-------------------------------------------------------------------------
tag		paymth.paycode		���ʽ&�������	N		as src
tag1		paymth.descript	"��"+reason			Y		as src
ref		chgcod��������		chgcod��������		Y		as src		
ref1		bill_no				chgcod����			Y		as src		
ref2		NULL					bill_no				Y		as src
waiter	NULL					NULL					Y		NULL
*����********************************************************************
			�Բ���ת��(����)		����ת��
-------------------------------------------------------------------------
tag		catalog					as src
tag1		"תP"						as src      
ref		chgcod��������			as src		
ref1		chgcod����				as src		
ref2		NULL						as src      
waiter	NULL						NULL
*/

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
exec   sp_primarykey account, accnt, number
create unique index index1 on account(accnt, number)
create index index2 on account(billno, accnt, subaccnt, pccode)
create index index3 on account(tofrom, accntof, subaccntof)
create index index4 on account(bdate, shift, empno)
;
//��ʷ�����
if exists(select * from sysobjects where type ="U" and name = "haccount")
	drop table haccount
;
create table haccount
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
exec   sp_primarykey account, accnt, number
create unique index index1 on account(accnt, number)
create index index2 on account(billno, accnt, subaccnt, pccode)
create index index3 on account(tofrom, accntof, subaccntof)
create index index4 on account(bdate, shift, empno)
;

//������������
if exists(select * from sysobjects where type ="U" and name = "outtemp")
	drop table outtemp
;
create table outtemp
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
create index index1 on outtemp(billno,accnt,number)
;

//������̨�����
if exists(select * from sysobjects where type ="U" and name = "gltemp")
	drop table gltemp
;
create table gltemp
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
exec sp_primarykey gltemp,accnt,number
create unique index index1 on gltemp(accnt,number)
;

if exists (select * from sysobjects where name='allouts' and type='U')
	drop table allouts;

create table allouts
(
	accnt				char(7)		not null,
	sta				char(1)		not null,
	stabacktoi		char(1)		not null,
	empno				char(3)		not null,
	date				datetime		default getdate() not null,
	billno			char(10)		not null,
)
exec sp_primarykey allouts,accnt
create unique index index1 on allouts(accnt)
;

if exists (select * from sysobjects where name='lallouts' and type='U')
   drop table lallouts;
create table lallouts
(
	accnt				char(7)		not null,
	sta				char(1)		not null,
	stabacktoi		char(1)		not null,
	empno				char(3)		not null,
	date				datetime		default getdate() not null,
	billno			char(10)		not null,
)
exec sp_primarykey lallouts,accnt
create unique index index1 on lallouts(accnt)
;

/*
  �Զ�ת��(�������)��Ŀ��
*/

if exists(select * from sysobjects where type ="U" and name = "transfer")
	drop table transfer
;
create table transfer
(
	type			char(1)	default '1' not null,					/* ����:1.�Զ�ת��,
																						  2.�������,
																						  3.AB��,
																						  4.��ʾ��Ŀ,
																						  5.��ʾ�绰�� */
	accnt			char(10)	not null,
	to_accnt		char(10)	default '' not null,
	pccode		char(10)	not null,									/* deptno + pccode + '%'*/
	percent		money		default 1 not null,						/* ���� */
	amount		money		default 0 not null,						/* ���� */
	empno			char(10)	not null,									/* ���� */
	date			datetime	default getdate() not null,			/* ʱ�� */
)
exec sp_primarykey transfer, type, accnt, pccode, to_accnt
create unique index index1 on transfer(type, accnt, pccode, to_accnt)
;

/*
	�����Ա�����޸�   --  ������˿�����ʱ��
*/

if exists(select * from sysobjects where type ="U" and name = "transfer_mem")
	drop table transfer_mem
;
create table transfer_mem
(
	modu_id		char(2)	not null,
	pc_id			char(4)	not null,
	pccode		char(10)	not null,									/* deptno2 + pccode + '%'*/
	percent		money		default 1 not null,						/* ���� */
	amount		money		default 0 not null,						/* ���� */
	empno			char(10)	not null,									/* ���� */
	date			datetime	default getdate() not null,			/* ʱ�� */
)
exec sp_primarykey transfer_mem, modu_id, pc_id, pccode
create unique index index1 on transfer_mem(modu_id, pc_id, pccode)
;


/*
	�����Ƿ����������־
*/
insert sysoption values ('account', 'postcharge0', 'F');
insert sysoption values ('account', 'postcredit0', 'F');

