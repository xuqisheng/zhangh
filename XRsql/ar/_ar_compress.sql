/* ѹ��AR����ʹ�õ���ʱ�� */

if exists (select * from sysobjects where name ='ar_compress' and type ='U')
	drop table ar_compress;
create table ar_compress
(
	pc_id			char(4)		not null, 
	mdi_id		integer		not null, 
	pccode		char(5)		not null,
	bdate			datetime		not null,
	ref1			char(10)		not null,
	ref2			char(50)		not null,
	ar_subtotal	char(1)		not null,
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
	charge9		money			default 0 not null,				/* �跽��,��¼�Ѿ�����Ŀ������� */
	credit9		money			default 0 not null				/* ������,��¼�Ѿ�����Ŀ��˶��𼰽���� */
)
create index index1 on ar_compress(pc_id, mdi_id)
;


