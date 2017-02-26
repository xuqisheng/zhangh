if exists(select * from sysobjects where type ="U" and name = "ar_account")
   drop table ar_account;

create table ar_account
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
	package		char(3)		null,									/* ���˱�־ */
// �����ֶ���ר��ΪAR�����ӵ�
	ar_accnt		char(10)		default '' not null,				/* AR�˺� */
	ar_subaccnt	integer		default 0 not null,				/* ���˺�(���������������һ�㣿) */
	ar_number	integer		default 0 not null,				/* �������к�,ÿ���˺ŷֱ��1��ʼ */
	ar_inumber	integer		default 0 not null,				/* ����ar_detail�����к� */
	ar_tag		char(1)		default 'P' not null,			/* �������:A.����;P.ǰ̨ת��;p.ǰ̨ת��ķ�����ϸ;T.��̨ת��;t.��̨ת�ʵķ�����ϸ;Z.ѹ����Ŀ;t.ѹ����Ŀ�ķ�����ϸ */
	ar_subtotal	char(1)		default 'F' not null,			/* ��ǰ���Ƿ�����ϸ����:F.û��;T.�� */
	ar_pnumber	integer		default 0 null,					/* ��ǰ������һ�еķ�����ϸ��ֻ��ar_tagΪΪСд��ĸʱ����ֵ������Ϊ�� */
	charge9		money			default 0 not null,				/* �跽��,��¼�Ѿ�����Ŀ������� */
	credit9		money			default 0 not null				/* ������,��¼�Ѿ�����Ŀ��˶��𼰽���� */
)
;
exec   sp_primarykey ar_account, ar_accnt, ar_number
create unique index index1 on ar_account(ar_accnt, ar_number)
create index index2 on ar_account(ar_accnt, ar_inumber, ar_tag, ar_subtotal)
create index index3 on ar_account(ar_accnt, ar_number, ar_tag, accnt, number)
create index index4 on ar_account(bdate, shift, empno, ar_tag)
;


if exists(select * from sysobjects where type ="U" and name = "har_account")
   drop table har_account;

create table har_account
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
	package		char(3)		null,									/* ���˱�־ */
// �����ֶ���ר��ΪAR�����ӵ�
	ar_accnt		char(10)		default '' not null,				/* AR�˺� */
	ar_subaccnt	integer		default 0 not null,				/* ���˺�(���������������һ�㣿) */
	ar_number	integer		default 0 not null,				/* �������к�,ÿ���˺ŷֱ��1��ʼ */
	ar_inumber	integer		default 0 not null,				/* ����ar_detail�����к� */
	ar_tag		char(1)		default 'P' not null,			/* �������:A.����;P.ǰ̨ת��;p.ǰ̨ת��ķ�����ϸ;T.��̨ת��;t.��̨ת�ʵķ�����ϸ;Z.ѹ����Ŀ;t.ѹ����Ŀ�ķ�����ϸ */
	ar_subtotal	char(1)		default 'F' not null,			/* ��ǰ���Ƿ�����ϸ����:F.û��;T.�� */
	ar_pnumber	integer		default 0 null,					/* ��ǰ������һ�еķ�����ϸ��ֻ��ar_tagΪΪСд��ĸʱ����ֵ������Ϊ�� */
	charge9		money			default 0 not null,				/* �跽��,��¼�Ѿ�����Ŀ������� */
	credit9		money			default 0 not null				/* ������,��¼�Ѿ�����Ŀ��˶��𼰽���� */
)
;
exec   sp_primarykey har_account, ar_accnt, ar_number
create unique index index1 on har_account(ar_accnt, ar_number)
create index index2 on har_account(ar_accnt, ar_inumber, ar_tag, ar_subtotal)
create index index3 on har_account(ar_accnt, ar_number, ar_tag, accnt, number)
create index index4 on har_account(bdate, shift, empno, ar_tag)
;
