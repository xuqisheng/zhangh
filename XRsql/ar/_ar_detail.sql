// AR�������
if exists(select * from sysobjects where type ="U" and name = "ar_detail")
   drop table ar_detail;

create table ar_detail
(
	accnt			char(10)		not null,							/* �˺� */
	subaccnt		integer		default 0 not null,				/* ���˺� */
	number		integer		not null,							/* �������к�,ÿ���˺ŷֱ��1��ʼ */
	inumber		integer		not null,							/* Account.Number & �������к�(����,ת��ʱ����) */
	modu_id		char(2)		not null,							/* ģ��� */
	log_date		datetime		default getdate() not null,	/* �������� */
	bdate			datetime		not null,							/* Ӫҵ���� */
	date			datetime		default getdate() not null,	/* ��Ʊ���� */
	pccode		char(5)		not null,							/* Ӫҵ���� */
	argcode		char(3)		default '' null,					/* �ı���(��ӡ���˵��Ĵ���) */
	quantity		money			default 0 not null,				/* ���� */
	charge		money			default 0 not null,				/* �跽��,��¼��������,ǰ̨ת��ļ������� */
	credit		money			default 0 not null,				/* ������,��¼���˶��𼰽����,ǰ̨ת��ļ������� */
	balance		money			default 0 not null,				/* �¼��ֶ� */
	charge0		money			default 0 not null,				/* �跽��,��¼�����Ŀ������� */
	credit0		money			default 0 not null,				/* ������,��¼�����Ŀ��˶��𼰽����,AR¼��ļ������� */
	charge1		money			default 0 not null,				/* �跽��,��¼δ������ȷ�ϵĿ�������,AR¼��ļ������� */
	credit1		money			default 0 not null,				/* ������,��¼δ������ȷ�ϵĵĿ��˶��𼰽���� */
	charge9		money			default 0 not null,				/* �跽��,��¼�Ѿ������Ŀ������� */
	credit9		money			default 0 not null,				/* ������,��¼�Ѿ������Ŀ��˶��𼰽���� */
	balance9		money			default 0 not null,				/* �¼��ֶ� */
	disputed		money			default 0 not null,				/* ������ */
	invoice_id	char(10)		default '' null,					/* �ѿ���Ʊ�� */
	invoice		money			default 0 not null,				/* �ѿ���Ʊ�Ľ�� */
	guestname	varchar(50)	default '' not null,				/* �������� */
	guestname2	varchar(50)	default '' not null,				/* �������� */
//
	shift			char(1)		not null,							/* ����Ա��� */
	empno			char(10)		not null,							/* ����Ա���� */
	crradjt		char(2)		default '' not null,				/* �����־(���˵����) */
	reason		char(3)		null,									/* �Ż����� */
	tofrom		char(2)		default '' not null,				/* ת�˷���,"TO"��"FM" */
	accntof		char(10)		default '' not null,				/* ת����Դ��Ŀ�� */
	subaccntof	integer		default 0 not null,				/* ת�����˺�(���������������һ�㣿) */
	ref			char(24)		default '' null,					/* ���ã��������� */
	ref1			char(10)		default '' null,					/* ���� */
	ref2			char(50)		default '' null,					/* ժҪ */
	roomno		char(5)		default '' not null,				/* ���� */
	billno		char(10)		default '' not null,				/* ���˵��� */
	tag			char(1)		default 'P' null,					/* �������:A.����;P.ǰ̨ת��;T.��̨ת��;Z.ѹ����Ŀ */
	audit			char(1)		default '1' not null,			/* ��˱�־:0.δ��Ӧ����;2.δ�����ÿ���;:1.������; */
// �����ֶκ��������Ҫ�ˣ�
	empno0		char(10)		null,									/* ���ȷ�ϣ����ţ� */
	date0			datetime		null,									/* ���ȷ�ϣ�ʱ�䣩 */
	shift0		char(1)		null,									/* ���ȷ�ϣ���ţ� */
	mode1			char(10)		default '' null,					/* ������ */
	pnumber		integer		default 0 null,					/* ѹ������Ŀ��number�� */
	package		char(3)		null									/* ���˱�־ */
)
;
exec   sp_primarykey ar_detail, accnt, number, pnumber, audit
create unique index index1 on ar_detail(accnt, number, pnumber, audit)
create index index2 on ar_detail(billno, accnt, subaccnt, pccode)
create index index3 on ar_detail(tofrom, accntof, subaccntof)
create index index4 on ar_detail(bdate, shift, empno)
;

// AR����ʷ�����
if exists(select * from sysobjects where type ="U" and name = "har_detail")
   drop table har_detail;

create table har_detail
(
	accnt			char(10)		not null,							/* �˺� */
	subaccnt		integer		default 0 not null,				/* ���˺� */
	number		integer		not null,							/* �������к�,ÿ���˺ŷֱ��1��ʼ */
	inumber		integer		not null,							/* �������к�(����,ת��ʱ����) */
	modu_id		char(2)		not null,							/* ģ��� */
	log_date		datetime		default getdate() not null,	/* �������� */
	bdate			datetime		not null,							/* Ӫҵ���� */
	date			datetime		default getdate() not null,	/* ��Ʊ���� */
	pccode		char(5)		not null,							/* Ӫҵ���� */
	argcode		char(3)		default '' null,					/* �ı���(��ӡ���˵��Ĵ���) */
	quantity		money			default 0 not null,				/* ���� */
	charge		money			default 0 not null,				/* �跽��,��¼��������,ǰ̨ת��ļ������� */
	credit		money			default 0 not null,				/* ������,��¼���˶��𼰽����,ǰ̨ת��ļ������� */
	balance		money			default 0 not null,				/* �¼��ֶ� */
	charge0		money			default 0 not null,				/* �跽��,��¼�����Ŀ�������,AR¼��ļ������� */
	credit0		money			default 0 not null,				/* ������,��¼�����Ŀ��˶��𼰽����,AR¼��ļ������� */
	charge1		money			default 0 not null,				/* �跽��,��¼δ������ȷ�ϵĿ������� */
	credit1		money			default 0 not null,				/* ������,��¼δ������ȷ�ϵĵĿ��˶��𼰽���� */
	charge9		money			default 0 not null,				/* �跽��,��¼�Ѿ������Ŀ������� */
	credit9		money			default 0 not null,				/* ������,��¼�Ѿ������Ŀ��˶��𼰽���� */
	balance9		money			default 0 not null,				/* �¼��ֶ� */
	disputed		money			default 0 not null,				/* ������ */
	invoice_id	char(10)		default '' null,					/* �ѿ���Ʊ�� */
	invoice		money			default 0 not null,				/* �ѿ���Ʊ�Ľ�� */
	guestname	varchar(50)	default '' not null,				/* �������� */
	guestname2	varchar(50)	default '' not null,				/* �������� */
//
	shift			char(1)		not null,							/* ����Ա��� */
	empno			char(10)		not null,							/* ����Ա���� */
	crradjt		char(2)		default '' not null,				/* �����־(���˵����) */
	reason		char(3)		null,									/* �Ż����� */
	tofrom		char(2)		default '' not null,				/* ת�˷���,"TO"��"FM" */
	accntof		char(10)		default '' not null,				/* ת����Դ��Ŀ�� */
	subaccntof	integer		default 0 not null,				/* ת�����˺�(���������������һ�㣿) */
	ref			char(24)		default '' null,					/* ���ã��������� */
	ref1			char(10)		default '' null,					/* ���� */
	ref2			char(50)		default '' null,					/* ժҪ */
	roomno		char(5)		default '' not null,				/* ���� */
	billno		char(10)		default '' not null,				/* ���˵��� */
	tag			char(1)		default 'P' null,					/* �������:A.����;P.ǰ̨ת��;T.��̨ת��;Z.ѹ����Ŀ */
	audit			char(1)		default '1' not null,			/* ��˱�־:0.δ��Ӧ����;2.δ�����ÿ���;:1.������; */
// �����ֶκ��������Ҫ�ˣ�
	empno0		char(10)		null,									/* ���ȷ�ϣ����ţ� */
	date0			datetime		null,									/* ���ȷ�ϣ�ʱ�䣩 */
	shift0		char(1)		null,									/* ���ȷ�ϣ���ţ� */
	mode1			char(10)		default '' null,					/* ������ */
	pnumber		integer		default 0 null,					/* ѹ������Ŀ��number�� */
	package		char(3)		null									/* ���˱�־ */
)
;
exec   sp_primarykey har_detail, accnt, number, pnumber, audit
create unique index index1 on har_detail(accnt, number, pnumber, audit)
create index index2 on har_detail(billno, accnt, subaccnt, pccode)
create index index3 on har_detail(tofrom, accntof, subaccntof)
create index index4 on har_detail(bdate, shift, empno)
;

