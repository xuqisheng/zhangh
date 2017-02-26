// δ���Ӧ���ʵ�ԭʼ��ϸ��
if exists(select * from sysobjects where type ="U" and name = "ar_audit")
   drop table ar_audit;

create table ar_audit
(
	pc_id			char(4)		not null,							/* IP��ַ */
	mdi_id		integer		not null,							/* �������ڵ�ID�� */
	type			char(1)		default 'F' not null,			/* ��˱�־:F.δ���Ӧ���ʵ�ԭʼ��ϸ��
																							T.δ���Ӧ���ʵĻ����� */
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
exec   sp_primarykey ar_audit, pc_id, mdi_id, type, accnt, number
create unique index index1 on ar_audit(pc_id, mdi_id, type, accnt, number)
;
