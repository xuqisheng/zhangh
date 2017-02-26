exec sp_rename account, account_old;
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
insert account select * from account_old
;
exec   sp_primarykey account, accnt, number
create unique index index1 on account(accnt, number)
create index index2 on account(billno, accnt, subaccnt, pccode)
create index index3 on account(tofrom, accntof, subaccntof)
create index index4 on account(bdate, empno, shift)
;
drop table account_old;
//--------------------
exec sp_rename gltemp, gltemp_old;
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
;
insert gltemp select * from gltemp_old
;
exec   sp_primarykey gltemp, accnt, number
create unique index index1 on gltemp(accnt, number)
;
drop table gltemp_old;
//-------------------
exec sp_rename haccount, haccount_old;
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
;
insert haccount select * from haccount_old
;
exec   sp_primarykey haccount, accnt, number
create unique index index1 on haccount(accnt, number)
create index index2 on haccount(billno, accnt, subaccnt, pccode)
create index index3 on haccount(tofrom, accntof, subaccntof)
create index index4 on haccount(bdate, empno, shift)
;
drop table haccount_old
;
//-------------------
exec sp_rename outtemp, outtemp_old;
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
;
insert outtemp select * from outtemp_old
;
exec   sp_primarykey outtemp, accnt, number
create unique index index1 on outtemp(accnt, number)
;
drop table outtemp_old;
//-------------------
exec sp_rename account_detail, account_detail_old;

create table account_detail
(
	date				datetime,										/* Ӫҵ���� */
	modu_id			char(2)	not null,							/* ģ��� */
	accnt				char(10)	not null,							/* �ʺ�(ǰ̨)
																				�˵���(�ۺ�����)
																				��ˮ��(��������) */
	number			integer	default 0 not null,				/* �д� */
	pccode			char(5)	not null,							/* ������ */
	refer				char(15) null,									/* tag(ǰ̨)
																				code(�ۺ�����) */
	charge			money		default 0 not null,				/* ��� */
	paycode			char(5)	default '' not null,				/* ���ʽ(�ۿ�Ϊ'') */
	key0				char(3)	default '' not null,				/* �Ż���Ա���� */
	billno			char(10)	default '' not null,				/* ���ʵ���(ǰ̨����) */
	jierep			char(8)	null,									/* �ױ��� */
	tail				char(2)	null									/* �ױ��� */
)
;
insert account_detail select * from account_detail_old
;
exec sp_primarykey account_detail, modu_id, accnt, number, paycode, key0
create unique index index1 on account_detail(modu_id, accnt, number, paycode, key0)
;
drop table account_detail_old;
//--------------------------
exec sp_rename accredit, accredit_old
;
create table accredit
(
	accnt			char(10)		not null,								/* �ʺ� */
	number		integer		default 1 not null,					/* ��� */
	pccode		char(5)		not null,								/* ���ÿ����� */
	cardno		char(20)		not null,								/* ���� */
	expiry_date	datetime		not null,								/* ���ÿ���Ч�� */
	foliono		char(10)		default '' not null,					/* ˮ���� */
	creditno		char(10)		default '' not null,					/* ��Ȩ�� */
	amount		money			default 0 not null,					/* ��� */
	tag			char(1)		default '0' not null,				/* ״̬:0.δ��;5.ȡ��;9.ʹ��*/
	empno1		char(10)		not null,								/* �ռ����� */
	bdate1		datetime		not null,								/* �ռ�Ӫҵ���� */
	shift1		char(1)		not null,								/* �ռ���� */
	log_date1	datetime		default getdate() not null,		/* �ռ�ʱ�� */
	empno2		char(10)		null,										/* ʹ�ù��� */
	bdate2		datetime		null,										/* ʹ��Ӫҵ���� */
	shift2		char(1)		null,										/* ʹ�ð�� */
	log_date2	datetime		null,										/* ʹ��ʱ�� */
	partout		integer		default 1 not null,					/* ���ֽ���ת��ʱ�� */
	billno		char(10)		default '' not null					/* ʹ�ø����ÿ����ʵ��� */
)
;
insert accredit select * from accredit_old
;
exec sp_primarykey accredit, accnt, number
create unique index index1 on accredit(accnt, number)
;
drop table accredit_old;
//--------------------
/* ��̯����ʱ�� */
exec sp_rename apportion_jie, apportion_jie_old;

create table apportion_jie
(
	pc_id				char(4)	not null,							/* IP��ַ */
	accnt				char(10)	not null,							/* �ʺ�(ǰ̨)
																				�˵���(�ۺ�����)
																				��ˮ��(��������) */
	number			integer	default 0 not null,				/* �д� */
	pccode			char(5)	not null,							/* ������ */
	refer				char(15) null,									/* tag(ǰ̨)
																				code(�ۺ�����) */
	charge			money		default 0 not null				/* ��� */
)
;
insert apportion_jie select * from apportion_jie_old
;
exec sp_primarykey apportion_jie, pc_id, accnt, number
create unique index index1 on apportion_jie(pc_id, accnt, number)
;
drop table apportion_jie_old;
//-----------------------
exec sp_rename apportion_dai, apportion_dai_old;

create table apportion_dai
(
	pc_id				char(4)	not null,							/* IP��ַ */
	paycode			char(5)	not null,							/* ���ʽ */
	credit			money		default 0 not null,				/* ��� */
	key0				char(3)	null,									/* �Ż���Ա���� */
	accnt				char(10)	not null								/* �ʺ�(ǰ̨)
																				�˵���(�ۺ�����)
																				��ˮ��(��������) */
)
;
insert apportion_dai select * from apportion_dai_old
;
exec sp_primarykey apportion_dai, pc_id, paycode, key0, accnt
create unique index index1 on apportion_dai(pc_id, paycode, key0, accnt)
;
drop table apportion_dai_old;
//-----------------------
exec sp_rename apportion_jiedai, apportion_jiedai_old;

create table apportion_jiedai
(
	pc_id				char(4)	not null,							/* IP��ַ */
	accnt				char(10)	not null,							/* �ʺ�(ǰ̨)
																				�˵���(�ۺ�����)
																				��ˮ��(��������) */
	number			integer	default 0 not null,				/* �д� */
	pccode			char(5)	not null,							/* ������ */
	refer				char(15) null,									/* tag(ǰ̨)
																				code(�ۺ�����) */
	charge			money		default 0 not null,				/* ��� */
	paycode			char(5)	not null,							/* ���ʽ */
	key0				char(3)	default '' null					/* �Ż���Ա���� */
)
;
insert apportion_jiedai select * from apportion_jiedai_old
;
exec sp_primarykey apportion_jiedai, pc_id, accnt, number, paycode, key0
create unique index index1 on apportion_jiedai(pc_id, accnt, number, paycode, key0)
;
drop table apportion_jiedai_old;
//--------------------------
exec sp_rename bankcard, bankcard_old;

create table bankcard
(
	pccode			char(5)	not null,
	bankcode			char(3)	not null,
	commission		money		default 0 not null,		/* �����еĻؿ���(�����ÿ���Ч) */
)
;
insert bankcard select * from bankcard_old
;
exec sp_primarykey bankcard, pccode, bankcode
create unique index index1 on bankcard(pccode, bankcode)
;
drop table bankcard_old;

//------------------------����ΪBOS_TABLE
/*

 bosϵͳ �� �ڶ�����ϵͳ �� ��������ϵͳ  ���� 
 modu = '09'
 �ͷ����ģ��������� �����˲��ô�ģ��
				2001/05/10			

bos_folio			���õ�
bos_hfolio
bos_dish
bos_hdish

bos_account			����
bos_haccount
bos_partout

bos_reason			�Ż�����
bos_partfolio		ǰ̨��

bos_plu_class        ->>>>>>>>>  ʲô��������д���۵���sysoption ����
bos_plu				����
bos_sort

bos_posdef			վ�㶨��
bos_station

bos_mode_name		ģʽ

bos_tblsta			�ص�
bos_tblav

bos_empno			����

bos_itemdef			���붨��

bos_extno			�������ķֻ�
bos_tmpdish			����������ʱ��

bosjie; ybosjie
bosdai; ybosdai

*/


/*
	bos���û��ܱ�
*/
exec sp_rename bos_folio, bos_folio_old;

create table bos_folio
(
	log_date    datetime    default getdate()   not null,   /*�������*/
	bdate    	datetime   	not null,	/*�����������޸�Ӫҵ��,��������folionoʶ��*/
	bdate1      datetime   	null    ,	/*�������ʻ򱻳���Ӫҵ��*/
	foliono		char(10)	   not null,	/*���к�*/
	sfoliono		varchar(10)	default '' null,
	site			char(5)	   null,			/*�ص�*/
	sta			char(1)		not null,	/*״̬,"M"�ֹ�����δ��,"P",�绰ת��δ��, "H",�绰ת��δ��,"O"�ѽ�,"C"����,"X"����,"T"ֱ����̨��*/
   setnumb     char(10)    null    ,   /*�������*/ 
	modu			char(2)		not null,	/*ģ���*/
	pccode		char(5)		not null,	/*������*/
	name	   	char(24)		null,			/*����������*/
	posno       char(3)     not null,
	mode	      char(3)		null,			/* ϵͳ��*/

	fee			money	default 0 		not null,   /*�����ܶ�*/
	fee_base	   money	default 0 	   not null,	/*������*/
	fee_serve	money	default 0 	   not null,	/*�����*/
	fee_tax  	money	default 0 	   not null,	/*���ӷ�*/
	fee_disc 	money	default 0 	   not null,	/*�ۿ۷�*/

	serve_type 	char(1)	default '0' not null,	/*����ѷ�ʽ   0:���� 1:���*/
	serve_value money		default 0   not null,	/*�������ֵ*/
	tax_type  	char(1)	default '0' not null,	/*���ӷѷ�ʽ   0:���� 1:���*/
	tax_value  	money		default 0   not null,	/*���ӷ���ֵ*/
	disc_type   char(1)	default '0' not null,	/*�Żݷ�ʽ   0:���� 1:���*/
	disc_value	 money	default 0 	not null,	/*�Żݱ���*/
	reason		char(3)					null,			/*�Ż�ԭ��*/

	pfee		   money	default 0 	   not null,   /*ԭ�����ܶ�*/
	pfee_base	money	default 0 	   not null,	/*ԭ������*/
	pfee_serve	money	default 0 	   not null,	/*ԭ�����*/
	pfee_tax 	money	default 0 	   not null,	/*ԭ���ӷ�*/

	refer		   varchar(40)	   null,			/*��ע -- ���Էŵ绰���� */
	empno1		char(10)			not null,	/*¼����޸Ĺ���*/
	shift1		char(1)			not null,	/*���*/
	empno2		char(10)			null,			/*���ʻ��������*/
	shift2		char(1)			null,			/*���*/
	checkout	   char(4)			null,			/*����������־λ*/
	site0	   	char(5) default '' not null			/**/
)
;
insert bos_folio select * from bos_folio_old
;
exec sp_primarykey bos_folio,foliono
create unique index index1 on bos_folio(foliono)
create unique index index2 on bos_folio(setnumb,foliono)
create index index3 on bos_folio(sta)
;
drop table bos_folio_old;
/*
	bos��ʷ���û��ܱ�
*/
exec sp_rename bos_hfolio, bos_hfolio_old;

create table bos_hfolio
(
	log_date    datetime    default getdate()   not null,   /*�������*/
	bdate    	datetime   	not null,	/*�����������޸�Ӫҵ��,��������folionoʶ��*/
	bdate1      datetime   	null    ,	/*�������ʻ򱻳���Ӫҵ��*/
	foliono		char(10)	   not null,	/*���к�*/
	sfoliono		varchar(10)	default '' null,
	site			char(5)	   null,			/*�ص�*/
	sta			char(1)		not null,	/*״̬,"M"�ֹ�����δ��,"P",�绰ת��δ��, "H",�绰ת��δ��,"O"�ѽ�,"C"����, "T"ֱ����̨��*/
   setnumb     char(10)    null    ,   /*�������*/ 
	modu			char(2)		not null,	/*ģ���*/
	pccode		char(5)		not null,	/*������*/
	name	   	char(24)		null,			/*����������*/
	posno       char(3)     not null,
	mode	      char(3)		null,			/* ϵͳ��*/

	fee			money	default 0 		not null,   /*�����ܶ�*/
	fee_base	   money	default 0 	   not null,	/*������*/
	fee_serve	money	default 0 	   not null,	/*�����*/
	fee_tax  	money	default 0 	   not null,	/*���ӷ�*/
	fee_disc 	money	default 0 	   not null,	/*�ۿ۷�*/

	serve_type 	char(1)	default '0' not null,	/*����ѷ�ʽ   0:���� 1:���*/
	serve_value money		default 0   not null,	/*�������ֵ*/
	tax_type  	char(1)	default '0' not null,	/*���ӷѷ�ʽ   0:���� 1:���*/
	tax_value  	money		default 0   not null,	/*���ӷ���ֵ*/
	disc_type   char(1)	default '0' not null,	/*�Żݷ�ʽ   0:���� 1:���*/
	disc_value	 money	default 0 	not null,	/*�Żݱ���*/
	reason		char(3)					null,			/*�Ż�ԭ��*/

	pfee		   money	default 0 	   not null,   /*ԭ�����ܶ�*/
	pfee_base	money	default 0 	   not null,	/*ԭ������*/
	pfee_serve	money	default 0 	   not null,	/*ԭ�����*/
	pfee_tax 	money	default 0 	   not null,	/*ԭ���ӷ�*/

	refer		   varchar(40)	   null,			/*��ע*/
	empno1		char(10)			not null,	/*¼����޸Ĺ���*/
	shift1		char(1)			not null,	/*���*/
	empno2		char(10)			null,			/*���ʻ��������*/
	shift2		char(1)			null,			/*���*/
	checkout	   char(4)			null,			/*����������־λ*/
	site0	   	char(5) default '' not null			/**/
)
;
insert bos_hfolio select * from bos_hfolio_old
;
exec sp_primarykey bos_hfolio,foliono
create unique index index1 on bos_hfolio(foliono)
create unique index index2 on bos_hfolio(setnumb,foliono)
create index index4 on bos_hfolio(bdate1);
create index index3 on bos_hfolio(sta)
;
drop table bos_hfolio_old;
/*
	bos������ϸ��
*/
exec sp_rename bos_dish, bos_dish_old;

create table bos_dish
(
	foliono		char(10)	   not null,	/*bos_folio��*/
	id          int         not null,   /*���к�*/       
	sta			char(1)		not null,		/*״̬,'M'��;"C"����*/
	log_date    datetime    default getdate()   not null,   /*�������*/
	bdate    	datetime   	not null,	/*�����������޸�Ӫҵ��,��������folionoʶ��*/
	bdate1      datetime   	null    ,	/*�������ʻ򱻳���Ӫҵ��*/
	pccode		char(5)		not null,	/*������*/
   code     	char(8)     not null,   /*������ϸ��*/ 
	name	   	varchar(18)	null,			/*��������*/
	price       money       not null,   /*����*/  
	number      money  default 0 not null,   /*����*/
	unit        char(4)     null,   		/*��λ*/  

	fee			money	default 0 		not null,   /*�����ܶ�*/
	fee_base	   money	default 0 	   not null,	/*������*/
	fee_serve	money	default 0 	   not null,	/*�����*/
	fee_tax  	money	default 0 	   not null,	/*���ӷ�*/
	fee_disc 	money	default 0 	   not null,	/*�ۿ۷�*/

	serve_type 	char(1)	default '0' not null,	/*����ѷ�ʽ   0:���� 1:���*/
	serve_value money		default 0   not null,	/*�������ֵ*/
	tax_type  	char(1)	default '0' not null,	/*���ӷѷ�ʽ   0:���� 1:���*/
	tax_value  	money		default 0   not null,	/*���ӷ���ֵ*/
	disc_type   char(1)	default '0' not null,	/*�Żݷ�ʽ   0:���� 1:���*/
	disc_value	 money	default 0 	not null,	/*�Żݱ���*/
	reason		char(3)					null,			/*�Ż�ԭ��*/

	pfee		   money	default 0 	   not null,   /*ԭ�����ܶ�*/
	pfee_base	money	default 0 	   not null,	/*ԭ������*/
	pfee_serve	money	default 0 	   not null,	/*ԭ�����*/
	pfee_tax 	money	default 0 	   not null,	/*ԭ���ӷ�*/

	refer		   varchar(80)	   null,		/*��ע -- �����绰��˵�� */
	empno1		char(10)		not null,	/*¼����޸Ĺ���*/
	shift1		char(1)		not null,	/*���*/
	empno2		char(10)		null,		/*���ʻ��������*/
	shift2		char(1)		null,		/*���*/
	amount0		money default 0  not null
)
;
insert bos_dish select * from bos_dish_old
;
exec sp_primarykey bos_dish,foliono,id
create unique index index1 on bos_dish(foliono,id)
create index index2 on bos_dish(sta)
;
drop table bos_dish_old;

/*
	bos��ʷ������ϸ��
*/
exec sp_rename bos_hdish, bos_hdish_old;

create table bos_hdish
(
	foliono		char(10)	   not null,	/*bos_folio��*/
	id          int         not null,   /*���к�*/       
	sta			char(1)		not null,		/*״̬,'M'��;"C"����*/
	log_date    datetime    default getdate()   not null,   /*�������*/
	bdate    	datetime   	not null,	/*�����������޸�Ӫҵ��,��������folionoʶ��*/
	bdate1      datetime   	null    ,	/*�������ʻ򱻳���Ӫҵ��*/
	pccode		char(5)		not null,	/*������*/
   code     	char(8)     not null,   /*������ϸ��*/ 
	name	   	varchar(18)	null,			/*��������*/
	price       money       not null,   /*����*/  
	number      money  default 0 not null,   /*����*/
	unit        char(4)     null,   		/*��λ*/  

	fee			money	default 0 		not null,   /*�����ܶ�*/
	fee_base	   money	default 0 	   not null,	/*������*/
	fee_serve	money	default 0 	   not null,	/*�����*/
	fee_tax  	money	default 0 	   not null,	/*���ӷ�*/
	fee_disc 	money	default 0 	   not null,	/*�ۿ۷�*/

	serve_type 	char(1)	default '0' not null,	/*����ѷ�ʽ   0:���� 1:���*/
	serve_value money		default 0   not null,	/*�������ֵ*/
	tax_type  	char(1)	default '0' not null,	/*���ӷѷ�ʽ   0:���� 1:���*/
	tax_value  	money		default 0   not null,	/*���ӷ���ֵ*/
	disc_type   char(1)	default '0' not null,	/*�Żݷ�ʽ   0:���� 1:���*/
	disc_value	 money	default 0 	not null,	/*�Żݱ���*/
	reason		char(3)					null,			/*�Ż�ԭ��*/

	pfee		   money	default 0 	   not null,   /*ԭ�����ܶ�*/
	pfee_base	money	default 0 	   not null,	/*ԭ������*/
	pfee_serve	money	default 0 	   not null,	/*ԭ�����*/
	pfee_tax 	money	default 0 	   not null,	/*ԭ���ӷ�*/

	refer		   varchar(80)	   null,		/*��ע -- �����绰��˵�� */
	empno1		char(10)		not null,	/*¼����޸Ĺ���*/
	shift1		char(1)		not null,	/*���*/
	empno2		char(10)		null,		/*���ʻ��������*/
	shift2		char(1)		null,		/*���*/
	amount0		money default 0  not null
)
;
insert bos_hdish select * from bos_hdish_old
;
exec sp_primarykey bos_hdish,foliono,id
create unique index index1 on bos_hdish(foliono,id)
create index index2 on bos_hdish(sta)
;
drop table bos_hdish_old;

/*
	�������Ľ�����ʱ�����
*/

exec sp_rename bos_partout, bos_partout_old;

create table bos_partout
(
	log_date    datetime    default getdate()   not null,   /*�������*/
	bdate    	datetime   	not null,				/*Ӫҵʱ��*/
	setnumb     char(10)    null    ,   			/*�������*/
	code		   char(5)		not null,				/*�ڲ���*/
	code1	 	   char(5)		not null,				/*�ⲿ��*/
	reason	   char(3)		default '' not null,	/*�ۿۿ������*/
	name		   char(24)	   null,		   			/*����������*/
	amount		money	default 0 not null,			/*���*/
	empno		   char(10)		not null,				/*����*/
	shift		   char(1)		not null,				/*���*/
	room		   char(5)		null,						/*ת�ʷ���*/
	accnt		   char(10)		null,						/*ת���ʺ�*/
	tranlog     char(10)    null,						/*Э����*/
	cusno       char(7)     null,						/*��λ��*/
	cardno      char(7)     null,						/*����*/
	modu			char(2)		null,
	checkout	   char(4)		null						/*����������־λ*/
)
;
insert bos_partout select * from bos_partout_old
;
exec sp_primarykey bos_partout,checkout,code
create unique index index1 on bos_partout(checkout,code)
;
drop table bos_partout_old;


/*
	�������Ŀ����
*/

exec sp_rename bos_account, bos_account_old;

create table bos_account
(
	log_date    datetime    default getdate()   not null,   /*�������*/
	bdate    	datetime   	not null,				/*Ӫҵʱ��*/
	setnumb     char(10)    null    ,   			/*�������*/
	code		   char(5)		not null,				/*�ڲ���*/
	code1	 	   char(5)		not null,				/*�ⲿ��*/
	reason	   char(3)		default '' not null,	/*�ۿۿ������*/
	name		   char(24)	   null,		   			/*����������*/
	amount		money	default 0 not null,			/*���*/
	empno		   char(10)		not null,				/*����*/
	shift		   char(1)		not null,				/*���*/
	room		   char(5)		null,						/*ת�ʷ���*/
	accnt		   char(10)		null,						/*ת���ʺ�*/
	tranlog     char(10)    null,						/*Э����*/
	cusno       char(7)     null,						/*��λ��*/
	cardno      char(7)     null,						/*����*/
	modu			char(2)		null,
	checkout	   char(4)		null						/*����������־λ*/
)
;
insert bos_account select * from bos_account_old
;
exec sp_primarykey bos_account,setnumb,code
create unique index index1 on bos_account(setnumb,code)
;
drop table bos_account_old;

/*
	����������ʷ�����
*/

exec sp_rename bos_haccount, bos_haccount_old;

create table bos_haccount
(
	log_date    datetime    default getdate()   not null,   /*�������*/
	bdate    	datetime   	not null,				/*Ӫҵʱ��*/
	setnumb     char(10)    null    ,   			/*�������*/
	code		   char(5)		not null,				/*�ڲ���*/
	code1	 	   char(5)		not null,				/*�ⲿ��*/
	reason	   char(3)		default '' not null,	/*�ۿۿ������*/
	name		   char(24)	   null,		   			/*����������*/
	amount		money	default 0 not null,			/*���*/
	empno		   char(10)		not null,				/*����*/
	shift		   char(1)		not null,				/*���*/
	room		   char(5)		null,						/*ת�ʷ���*/
	accnt		   char(10)		null,						/*ת���ʺ�*/
	tranlog     char(10)    null,						/*Э����*/
	cusno       char(7)     null,						/*��λ��*/
	cardno      char(7)     null,						/*����*/
	modu			char(2)		null,
	checkout	   char(4)		null						/*����������־λ*/
)
;
insert bos_haccount select * from bos_haccount_old
;
exec sp_primarykey bos_haccount,setnumb,code
create unique index index1 on bos_haccount(setnumb,code)
;
drop table bos_haccount_old;

/////*
////	�Ż�����
////*/
////if exists(select * from sysobjects where name = "bos_reason" and type ="U")
////	drop table bos_reason;
////create table bos_reason
////(
////	code		char(3)		not null,	/*����*/
////	key0		char(3)		not null,	/*refer to reason0*/
////	descript	varchar(16)		not null,	/*����*/
////	percent	money			not null,	/*����*/
////	day		money			default 0 	not null,
////	month		money			default 0 	not null,
////	year		money			default 0 	not null,
////)
////exec sp_primarykey bos_reason,code
////create unique index index1 on bos_reason(code)
////;
////insert bos_reason values ('01','A01','����Ż�',0,0,0,0)
////insert bos_reason values ('02','A02','����Ң�Ż�',0,0,0,0)
////;
//
//
///*
//	��̨�ֹ��������,bos����ϸ���ձ�
//*/
//if exists(select * from sysobjects where name = "bos_partfolio" and type="U")
//	drop table bos_partfolio;
//
//create table bos_partfolio
//(
//	accnt        char(10) not null,     /*�˺�*/ 
//	number       int     not null,     /*�ʴ�*/
//	foliono      char(10) not null     /*bos_folio*/
//);
//exec sp_primarykey bos_partfolio,accnt,number 
//create unique index index1 on bos_partfolio(accnt,number);
//create unique index index2 on bos_partfolio(foliono);
//
///*
//	bos�˵� ���
//*/
//if exists(select * from sysobjects where name = "bos_plu_class" and type ="U")
//	drop table bos_plu_class;
//create table bos_plu_class
//(
//   code     	char(3)     	not null,   /*����*/
//	descript		varchar(18)		not null,	/*����*/
//	descript1	varchar(30)		null			/*����*/
//)
//exec sp_primarykey bos_plu_class,code
//create unique index index1 on bos_plu_class(code)
//;
//insert bos_plu_class select '0', '����', ''
//insert bos_plu_class select '1', '����', ''
//;
//

/*
	bos�˵�
*/
exec sp_rename bos_plu, bos_plu_old;
create table bos_plu
(
	pccode   char(5)		not null,	/*Ӫҵ��*/
   code     char(8)     not null,   /*����*/
	name		varchar(18)		not null,	/*����*/
	ename		varchar(30)		null,			/*����*/
	helpcode	varchar(10)		null,			/*���Ƿ�*/
	standent	varchar(12)		null,			/*���,����!!!*/
	unit		char(4)		null,			/*��λ*/
	sort		char(4)		not null,	/*����*/
	hlpcode	varchar(8)		null,			/*�������Ƿ�*/
	price		money			not null,	/*�۸�*/
	menu		char(4)		not null,	/*��,��,��,ҹ�Ĺ���*/
   dscmark  char(1)     null,       /*�ۿ��������־*/
	surmark  char(1)     null,       /*T:���շ����,F:���շ����*/
	taxmark  char(1)     null,       /*T:���ո���˰,F:���ո���˰*/
	discmark char(1)     null,       /*T:�ɴ���,F:������*/
	provider	char(7)		default '' null,
	number	money	default 0 not null,  // ��������ͽ��
	amount	money default 0 not null,
	site		varchar(8) default '' null,  // ��ŵص�
	class		char(3)	 	not null			// ���
)
;
insert bos_plu select * from bos_plu_old
;
exec sp_primarykey bos_plu,pccode,code
create unique index index1 on bos_plu(pccode,code)
// create unique index index2 on bos_plu(pccode,name)
create index index3 on bos_plu(pccode,helpcode)
;
drop table bos_plu_old;

/*
	bos����
*/

exec sp_rename bos_sort, bos_sort_old;
create table bos_sort
(
	pccode		char(5)			not null,	/*Ӫҵ��*/
	sort			char(8)			not null,	/*���*/
	name			varchar(12)		not null,	/*����*/
	ename			varchar(20)		null,			/*����*/
	hlpcode		varchar(8)		null,			/*���Ƿ�*/
	surmark     char(1)     	null,       /*T:���շ����,F:���շ����*/
	taxmark     char(1)     	null,       /*T:���ո���˰,F:���ո���˰*/
	discmark    char(1)     	null,       /*T:�ɴ���,F:������*/
)
;
insert bos_sort select * from bos_sort_old
;
exec sp_primarykey bos_sort,pccode,sort
create unique index index1 on bos_sort(pccode,sort)
create unique index index2 on bos_sort(pccode,name)
;
drop table bos_sort_old;

/*
	�������,����ÿ���������Ͻ��Ӫҵ��
*/

exec sp_rename bos_posdef, bos_posdef_old;
create table bos_posdef
(
	posno			char(2)				not null,	/*��������*/
	modu			char(2)				not null,	/*ģ���*/
	mode			char(1)				not null,	/*0-all, 1-folio, 2-dish*/
	descript		varchar(20)			not null,	/*��������*/
	descript1	varchar(20)			not null,	/*��������*/
   pccodes		varchar(120)		null,	 	   /*Ӫҵ�㼯��*/		
	fax1			char(5)				null,			/*���ʹ���ķ����� ����*/
	fax2			char(5)				null,			/*���ʹ���ķ����� ����*/
	sites			varchar(100) default ''	not null			/*��̨����*/
)
;
insert bos_posdef select * from bos_posdef_old
;
exec sp_primarykey bos_posdef,posno,modu
create unique index index1 on bos_posdef(posno,modu)
;
drop table bos_posdef_old
;

///*
//	����վ��
//*/
//if exists(select * from sysobjects where name = "bos_station" and type ="U")
//	drop table bos_station;
//create table bos_station
//(
//	netaddress	char(4)		not null,	/*�����ַ*/
//	posno			char(2)		not null,	/*������*/
//   printer		char(1)		not null,	/*��δ�."T"/"F"*/
//	adjuhead		int			default 0	not null,	/*��ӡ����*/
//	adjurow		int			default 0	not null,	/*��ӡ����*/
//)
//exec sp_primarykey bos_station,netaddress,posno
//create unique index index1 on bos_station(netaddress,posno)
//;
//insert bos_station(netaddress,posno,printer)
//	values('1.01', '01', 'T')
//;
//
//
///*
//	ģʽ���뼰����
//*/
//if exists(select * from sysobjects where name = "bos_mode_name" and type ="U")
//	drop table bos_mode_name;
//
//create table bos_mode_name
//(
//	code			char(3)			not null,	/*����*/
//	descript		varchar(20)		not null,	/*��������*/
//	descript1	varchar(30)		null,			/*Ӣ������*/
//	remark		varchar(255)	null,			/*����*/
//)
//exec sp_primarykey bos_mode_name,code
//create unique index index1 on bos_mode_name(code)
//;
//
//
///*
//	�ص�
//*/
//if exists(select * from sysobjects where name = "bos_tblsta" and type ="U")
//	drop table bos_tblsta;
////create table bos_tblsta
////(
////	tableno		char(4)		not null,							/*����*/
////	type			char(3)		null,									/*���*/
////	pccode		char(5)		not null,							/*Ӫҵ��*/
////	descript1	char(10)		null,									/*����1*/
////	descript2	char(10)		null,									/*����2*/
////	maxno			integer		default	0	not null,			/*ϯλ��*/
////	sta			char(1)		default	'N'	not null,
////	mode			char(1)		default	'0'	not null,		/*�������ģʽ*/
////	amount		money			default	0	not null,			/*������ѽ��*/
////	code			char(15)		default '' not null				/*��ͷȥ��*/
////)
////exec sp_primarykey bos_tblsta,tableno
////create unique index index1 on bos_tblsta(tableno)
////create index index2 on bos_tblsta(pccode, tableno)
////;
//
///*
//	ϯλ״̬��
//*/
//if exists(select * from sysobjects where name = "bos_tblav" and type ="U")
//	drop table bos_tblav;
////create table bos_tblav
////(
////	menu				char(10)		not null,								/*������*/
////	tableno			char(4)		not null,								/*����*/
////	id					integer		default 0 not null,
////	bdate				datetime		not null,								/*����*/
////	shift				char(1)		not null,								/*���*/
////	sta				char(1)		not null,								/*״̬*/
////	begin_time		datetime		default	getdate()	not null,	/*��ʱ��ʼʱ��*/
////	end_time			datetime		null										/*��ʱ��ֹʱ��*/
////)
////exec sp_primarykey bos_tblav,menu,tableno,id
////create unique index index1 on bos_tblav(menu,tableno,id)
////;
//
///*
//	BOS ���Ŷ���
//*/
//if exists(select * from sysobjects where name = "bos_empno" and type ="U")
//	drop table bos_empno;
//create table bos_empno
//(
//	empno		char(10)		not null,	/*����*/
//	name		char(20)		not null,	/*����*/
//)
//exec sp_primarykey bos_empno,empno
//create unique index index1 on bos_empno(empno)
//;
//
///*
//	BOS ���˽��������
//*/
//if exists(select * from sysobjects where name = "bos_itemdef" and type ="U")
//	drop table bos_itemdef;
//create table bos_itemdef
//(
//	posno		char(2)			not null,	/*������   ZZ = �ͷ����Ŀ������˶��塶ϵͳ�ڶ���*/
//	define	varchar(20)		null			/*����ʾ�Ķ���*/
//)
//exec sp_primarykey bos_itemdef,posno
//create unique index index1 on bos_itemdef(posno)
//;
//
//
///*
//	�������ķֻ��趨
//*/
//if exists(select * from sysobjects where name = "bos_extno" and type ="U")
//	drop table bos_extno;
//create table bos_extno
//(
//	code		char(8)			not null,
//	posno		char(2)			not null
//)
//exec sp_primarykey bos_extno,code
//create unique index index1 on bos_extno(code)
//;
//
///*
//	bos ��ʱ��
//*/
//if exists(select * from sysobjects where name = "bos_tmpdish" and type="U")
//	drop table bos_tmpdish;
//
//create table bos_tmpdish
//(
//	modu_id		char(2)		not null,
//	pc_id			char(4)		not null,
//	id          int         not null,      /*���к�*/
//	sta			char(1)		not null,		/*״̬,'I'=���� 'M'=�� "C"=���� */
//   code     	char(8)     not null,   /*������ϸ��*/ 
//	name	   	varchar(18)	null,			/*��������*/
//	price       money       not null,   /*����*/  
//	number      money  default 0 not null,   /*����*/
//	unit        char(4)     null,   		/*��λ*/  
//	pfee_base	money	default 0 	   not null,	/*ԭ������*/
//	serve_type 	char(1)	default '0' not null,	/*����ѷ�ʽ   0:���� 1:���*/
//	serve_value money		default 0   not null,	/*�������ֵ*/
//	tax_type  	char(1)	default '0' not null,	/*���ӷѷ�ʽ   0:���� 1:���*/
//	tax_value  	money		default 0   not null,	/*���ӷ���ֵ*/
//	disc_type   char(1)	default '0' not null,	/*�Żݷ�ʽ   0:���� 1:���*/
//	disc_value	 money	default 0 	not null		/*�Żݱ���*/
//)
//exec sp_primarykey bos_tmpdish,modu_id, pc_id, id
//create unique index index1 on bos_tmpdish(modu_id, pc_id, id)
//;
//
exec sp_rename bosjie, bosjie_old;
create table bosjie
(
   date          datetime default getdate(),
   shift         char(1)  default '' not null,
	empno         char(10)  default '' not null,
	code          char(5)  default '' not null,
	descript      char(24)  default '' not null,
	fee_bas       money    default 0  not null,
	fee_sur       money    default 0  not null,
	fee_tax       money    default 0  not null,
	fee_dsc	      money    default 0  not null,
	fee_ent	      money    default 0  not null,
	fee_ttl	      money    default 0  not null,
	fee_basm      money    default 0  not null,
	fee_surm      money    default 0  not null,
	fee_taxm      money    default 0  not null,
	fee_dscm      money    default 0  not null,
	fee_entm      money    default 0  not null,
	fee_ttlm      money    default 0  not null,
	daymark       char(1)  default '' not null
)
;
insert bosjie select * from bosjie_old
;
exec sp_primarykey bosjie,shift,empno,code
create unique index index1 on bosjie(shift,empno,code)
;
drop table bosjie_old
;
exec sp_rename ybosjie, ybosjie_old;
create table ybosjie
(
   date          datetime default getdate(),
   shift         char(1)  default '' not null,
	empno         char(10)  default '' not null,
	code          char(5)  default '' not null,
	descript      char(24)  default '' not null,
	fee_bas       money    default 0  not null,
	fee_sur       money    default 0  not null,
	fee_tax       money    default 0  not null,
	fee_dsc	     money    default 0  not null,
	fee_ent	     money    default 0  not null,
	fee_ttl	     money    default 0  not null,
	fee_basm      money    default 0  not null,
	fee_surm      money    default 0  not null,
	fee_taxm      money    default 0  not null,
	fee_dscm      money    default 0  not null,
	fee_entm      money    default 0  not null,
	fee_ttlm      money    default 0  not null,
	daymark       char(1)  default '' not null
)
;
insert ybosjie select * from ybosjie_old
;
exec sp_primarykey ybosjie,date,shift,empno,code;
create unique index index1 on ybosjie(date,shift,empno,code)
;
drop table ybosjie_old;

exec sp_rename bosdai, bosdai_old;
create table bosdai
(
   date          datetime default    getdate(),
   shift         char(1)  default '' not null,
	empno         char(10)  default '' not null,
	paycode       char(5)  default '' not null,
	paytail       char(1)  default '' not null,
	descript1     char(5)  default '' not null,
	descript      char(12) default '' not null,
	creditd       money    default 0  not null,
	creditm       money    default 0  not null,
	daymark       char(1)  default '' not null
)
;
insert bosdai select * from bosdai_old
;
exec sp_primarykey bosdai,shift,empno,paycode,paytail
create unique index index1 on bosdai(shift,empno,paycode,paytail)
;
drop table bosdai_old;

exec sp_rename ybosdai, ybosdai_old;
create table ybosdai
(
   date          datetime default    getdate(),
   shift         char(1)  default '' not null,
	empno         char(10)  default '' not null,
	paycode       char(5)  default '' not null,
	paytail       char(1)  default '' not null,
	descript1     char(5)  default '' not null,
	descript      char(12) default '' not null,
	creditd       money    default 0  not null,
	creditm       money    default 0  not null,
	daymark       char(1)  default '' not null
)
;
insert ybosdai select * from ybosdai_old
;
exec sp_primarykey ybosdai,date,shift,empno,paycode,paytail
create unique index index1 on ybosdai(date,shift,empno,paycode,paytail)
;
drop table ybosdai_old;
//------------------------����ΪBOS_TABLE
// -----------------------����ΪBOS_KCTABLE
//		BOS ���������
//
//			bos_pccode
//
//			bos_provider_class
//			bos_provider_mkt
//			bos_provider			
//
//			payment
//
//			bos_site
//			bos_site_sort
//
//			bos_kcmenu
//			bos_kcdish
//			bos_store
//			bos_hstore
//
//			bos_detail
//			bos_hdetail
//			bos_tmpdetail 
// ------------------------------------------------------------------------------
//		����  &  ���� ����������-- ���������޸ĳɱ��� !
// ------------------------------------------------------------------------------


// ------------------------------------------------------------------------------------
//	bos_pccode	:  BOS Ӫҵ�㶨��
// ------------------------------------------------------------------------------------
exec sp_rename bos_pccode, bos_pccode_old;
create table bos_pccode
(
	pccode		char(5)					not null,
	descript		varchar(24)				not null,
	descript1	varchar(24)				not null,
	sortlen		int default 2 			not null,	// ���������ĳ���
	site			int default 0  		not null,  	// �Ƿ��еص�Ĺ���: 0-��; 1-�ͷ�; 2-����
	jxc			int default 0  		not null,  	// �Ƿ��н��������: 0-no, 1-yes
	smode			char(1)	default '%' not null,	// �����   -- ȴʡֵ
	svalue		money		default 0 	not null,
	tmode			char(1)	default '%' not null,	// ���ӷ�
	tvalue		money		default 0 	not null,
	dmode			char(1)	default '%' not null,	// �ۿ�
	dvalue		money		default 0 	not null,
	site0			char(5)	 				not null,	// ȴʡ�ĵص�
	tag			char(1)	default ''	not null,	// S=shop
	chgcod		char(5)					not null		//  code in pccode
)
;
insert bos_pccode select * from bos_pccode_old
;
exec sp_primarykey bos_pccode, pccode
create unique index index1 on bos_pccode(pccode)
create unique index index2 on bos_pccode(chgcod)
;
drop table bos_pccode_old;


//// ------------------------------------------------------------------------------
////  ��Ӧ�� CLASS
//// ------------------------------------------------------------------------------
//if exists(select * from sysobjects where type ="U" and name = "bos_provider_class")
//	drop table bos_provider_class;
//create table bos_provider_class
//(
//	code			char(1)	default '1' not null,					// ���� 
//	descript		char(20)					not null,					// ���� 
//	descript1	char(20)	default ''	not null
//)
//exec sp_primarykey bos_provider_class, code
//create unique index index1 on bos_provider_class(code)
//;
//insert bos_provider_class select 'N', '��ͨ��Ӧ��',''
//insert bos_provider_class select 'V', 'VIP��Ӧ��',''
//;
//
//// ------------------------------------------------------------------------------
//// bos_provider_mkt	��Ӧ���г���
//// ------------------------------------------------------------------------------
//if exists(select * from sysobjects where name = "bos_provider_mkt")
//   drop table bos_provider_mkt;
//create table bos_provider_mkt
//(
//	code			char(5)			not null,		// ���� 
//	descript    varchar(30)		not null, 		// ���� 
//	descript1   varchar(30)		not null, 		// ���� 
//	remark    	varchar(30)		not null 		// ���� 
//)
//exec sp_primarykey bos_provider_mkt,code
//create unique index index1 on bos_provider_mkt(code);
//insert bos_provider_mkt select 'A', '����', 'CITY',''
//insert bos_provider_mkt select 'B', '����', 'OTHER',''
//;
//
//
//// ------------------------------------------------------------------------------------
//// bos_provider ----- ��Ӧ�̴���
//// ------------------------------------------------------------------------------------
//if exists(select * from sysobjects where name = "bos_provider")
//	drop table bos_provider;
//create table bos_provider
//(
//	accnt			char(7)		not null,			//�ʺ�:����
//	sta			char(1)		not null,			//״̬ I, O, 
//	nation      char(3) 		not null,       	//����
//	name			varchar(50)	not null,			//����
//	address  	varchar(60)	null,					//��ַ
//	phone			varchar(30)	null,					//�绰
//	fax  			varchar(20)	null,					//����
//	zip  			char(10)		null,					//�ʱ�
//	c_name		varchar(40)	null,					//��ϵ��
//	intinfo		varchar(50)	null,					//��������Ϣ
//	class			char(1)		null,					//����:
//	locksta     char(1)     null,       		//����״̬
//	limit			money			default 0 	not null,	//�޶�(������)
//	arr			datetime		null,					//��Ч����
//	dep			datetime		null,					//��Ч����,������Ϊֹ
//   mkt     		char(5)     null,       		//�г���
//	pccodes		varchar(20)	default '' not null,  //�����뷶Χ
//	resby			char(10)		not null,					//�����˹���
//	reserved		datetime	default getdate() not null, //����ʱ��,��ϵͳʱ��,�����޸�
//	cby			char(10)		null,							//�޸��˹���
//	changed		datetime		null,							//�޸�ʱ��
//	ref			varchar(90)	null,							//��ע
//	exp_m			money				null,
//	exp_dt		datetime			null,
//	exp_s			varchar(10)		null,
//	logmark     int default 0 not null
//);
//exec sp_primarykey bos_provider,accnt
//create unique index index1 on bos_provider(accnt)
//create index index2 on bos_provider(name)
//;
//
//
// ------------------------------------------------------------------------------------
// payment ----- �����¼
// ------------------------------------------------------------------------------------
exec sp_rename payment, payment_old;
create table payment
(
	accnt			char(7)		not null,					//�ʺ�:����
	number		int			not null,			
	sta			char(1)		not null,					//״̬ I, C
	bdate			datetime		not null,					//Ӫҵ����
	date			datetime		not null,					//��������
	paycode		char(5)		not null,					//���ʽ
	amount		money		default 0	not null,	
	payref		varchar(20)	default '' null,			//���ע
	resman		varchar(50)	default '' null,
	sndman		varchar(50)	default '' null,
	ref			varchar(90)	null,							//��ע
	resby			char(10)		not null,					//�����˹���
	reserved		datetime	default getdate() not null, //����ʱ��,��ϵͳʱ��,�����޸�
	cby			char(10)		null,							//�޸��˹���
	changed		datetime		null,							//�޸�ʱ��
	logmark     int default 0 not null
)
;
insert payment select * from payment_old
;
exec sp_primarykey payment,accnt,number
create unique index index1 on payment(accnt,number)
;
drop table payment_old;

//------------------------------------------------------------------------------
// �ص��� -- �ֿ⣬��̨���������� ��
//------------------------------------------------------------------------------
exec sp_rename bos_site, bos_site_old;
create table  bos_site (
	pccode	char(5)			not null,
	tag		char(2)			not null, 	// ���:��(�ֿ�) - ��(��̨) - ��(�ڲ�����)
	site		char(5)			not null,  	// --- ע�⣺ �ڲ����ű����� pccode �޹أ�����
	name		varchar(24)		not null		//  	�п��ֿܷ��༭���ܸ��ã�
													//		��ʱ���ͳһ�����ڲ�ͬ��pccode �У�site һ��
)
;
insert bos_site select * from bos_site_old
;
exec sp_primarykey bos_site,site
create unique index site on bos_site(site);
;
drop table bos_site_old;

////------------------------------------------------------------------------------
//// �ص���ۻ����壺����õص��ܹ�����ʲô��Ʒ 
////------------------------------------------------------------------------------
//if exists (select 1 from sysobjects where name = 'bos_site_sort')
//	drop table bos_site_sort;
//create table  bos_site_sort (
//	site		char(5)			not null,
//	sort		varchar(20)	default '%' not null
//);
//exec sp_primarykey bos_site_sort,site,sort
//create unique index site on bos_site_sort(site,sort)
//;
//insert bos_site_sort select site,'%' from bos_site;
//
//------------------------------------------------------------------------------
//		
//		��Ʒ������������  ------- ��ǰ
//		��������: ��<��>��, ���, ����, �̴�, ����
//
//		����ĵ��ݺ����ɵ��Ե��ź��ֹ��������
//			����ֻ�ܡ��������͡��������ա������Բ���ҪLOG�ֶ�
//			��������ʱ,�ı�״̬,���������ֶμ���;
//
//------------------------------------------------------------------------------

// ����
exec sp_rename bos_kcmenu, bos_kcmenu_old
;
create table  bos_kcmenu (
	folio		char(10)			not null,				// ���Ե���(����+��ˮ��)
	pccode 	char(5)			not null,
	sfolio	varchar(20),								// �ֹ�����
	site0		char(5)			not null,				// ԭʼ�ص�
	site1		char(5)	default '' not null,  		// �ص�
	act_date	datetime			not null,				// ҵ��������
	bdate		datetime			not null,				// Ӫҵ����
	flag		char(2)			not null,				// ��������: ��<��>��, ���, ����, �̴�, ����
	sta		char(1)			not null,				// ״̬== I, X, O, D
	tag1		char(2)			null,						// ���ԭ��
	tag2		char(2)			null,						// �����ֶ�
	tag3		char(10)			null,						// �����ֶ�
	tag4		char(10)			null,						// �����ֶ�
	amount	money	default 0 not null,				// �ܽ��
	refer		varchar(50)		null,						// ��ע
	sby		char(10)			null,						// ���
	sdate		datetime			null,
	cby		char(10)			not null,				// ����
	cdate		datetime	default getdate()	not null,
	dby		char(10)			null,						// ����	
	ddate		datetime			null,
	dreason	varchar(20)		null,						// ����ԭ��
	pc_id		char(4)			null,						// ��ռ��־
	logmark	int default 0	not null
)
;
insert bos_kcmenu select * from bos_kcmenu_old
;
exec sp_primarykey bos_kcmenu, folio
create unique index fno on bos_kcmenu(folio)
create index sfno on bos_kcmenu(sfolio)
create index cby on bos_kcmenu(cby, folio)
create index bdate on bos_kcmenu(bdate, folio)
create index actdate on bos_kcmenu(act_date, folio)
;
drop table bos_kcmenu_old;
//
////------------------------------------------------------------------------------
//// ��ϸ����  -- Ҫ��ͬ���ݣ�����Ψһ
////				����������µ�
////------------------------------------------------------------------------------
//if exists (select 1 from sysobjects where name = 'bos_kcdish')
//	drop table bos_kcdish
//;
//create table  bos_kcdish (
//	folio		char(10)			not null,				// ���Ե���(����+��ˮ��)
//	code		char(8)			not null,				// ����
//	name		varchar(18)		null,						
//	number	money	default 0 not null,				// ����
//	price		money	default 0 not null,				// ����
//	amount	money	default 0 not null,				// �ɱ����
//	price1	money	default 0 not null,				// ���۵���
//	amount1	money	default 0 not null,				// ���۽��
//	profit	money	default 0 not null,				// �������
//	ref		varchar(20)		null						// ��ע
//)
//exec sp_primarykey bos_kcdish, folio, code
//create unique index code on bos_kcdish(folio,code)
//;
//// ----------> �ϰ汾�Ľṹ�޸� sql ����
////exec sp_rename 'bos_kcdish.number0', price1;
////exec sp_rename 'bos_kcdish.price0', amount1;
////exec sp_rename 'bos_kcdish.amount0', profit;
//
//
//------------------------------------------------------------------------------
//	��������¼����  ---  ʵʱ��Ϣ
//------------------------------------------------------------------------------
exec sp_rename bos_store, bos_store_old
;
create table  bos_store (
	id			char(6)		not null,
	pccode	char(5)		not null,
	site		char(5)		not null,			// �����
	code		char(8)		not null,			// ����
	number0	money	default 0	not null,	// ���ڽ���
	amount0	money	default 0 	not null,	// 
	sale0		money	default 0 	not null,	// 
	profit0	money	default 0 	not null,	// 
	number1	money	default 0	not null,	// ���
	amount1	money	default 0 	not null,	// 
	sale1		money	default 0 	not null,	// 
	profit1	money	default 0 	not null,	// 
	number2	money	default 0	not null,	// ���
	amount2	money	default 0 	not null,	// 
	sale2		money	default 0 	not null,	// 
	profit2	money	default 0 	not null,	// 
	number3	money	default 0	not null,	// �̴�
	amount3	money	default 0 	not null,	// 
	sale3		money	default 0 	not null,	// 
	profit3	money	default 0 	not null,	// 
	number4	money	default 0	not null,	// ����
	amount4	money	default 0 	not null,	// 
	sale4		money	default 0 	not null,	// 
	profit4	money	default 0 	not null,	// 
	number5	money	default 0	not null,	// ����
	amount5	money	default 0 	not null,	// 
	sale5		money	default 0 	not null,	// 
	disc		money	default 0 	not null,	// 
	profit5	money	default 0 	not null,	// 
	number6	money	default 0	not null,	// ����
	amount6	money	default 0 	not null,	// 
	sale6		money	default 0 	not null,	// 
	profit6	money	default 0 	not null,	// 
	number7	money	default 0	not null,	// ���ɱ���
	amount7	money	default 0 	not null,	// 
	sale7		money	default 0 	not null,	// 
	profit7	money	default 0 	not null,	// 
	number8	money	default 0	not null,	// �����ۼ�
	amount8	money	default 0 	not null,	// 
	sale8		money	default 0 	not null,	// 
	profit8	money	default 0 	not null,	// 
	number9	money	default 0	not null,	// ���
	amount9	money	default 0 	not null,	// 
	sale9		money	default 0 	not null,	// 
	profit9	money	default 0 	not null,	// 
	price0	money	default 0 	not null,	// ����
	price1	money	default 0 	not null		// �ۼ�
)
;
insert bos_store select * from bos_store_old
;
exec sp_primarykey bos_store, pccode,site,code
create unique index siteno on bos_store(pccode,site,code)
;
drop table bos_store_old;

//------------------------------------------------------------------------------
//	��������¼����  ---  ��ʷ��Ϣ
//------------------------------------------------------------------------------
exec sp_rename bos_hstore, bos_hstore_old
;
create table  bos_hstore (
	id			char(6)		not null,
	pccode	char(5)		not null,
	site		char(5)		not null,			// �����
	code		char(8)		not null,			// ����
	number0	money	default 0	not null,	// ���ڽ���
	amount0	money	default 0 	not null,	// 
	sale0		money	default 0 	not null,	// 
	profit0	money	default 0 	not null,	// 
	number1	money	default 0	not null,	// ���
	amount1	money	default 0 	not null,	// 
	sale1		money	default 0 	not null,	// 
	profit1	money	default 0 	not null,	// 
	number2	money	default 0	not null,	// ���
	amount2	money	default 0 	not null,	// 
	sale2		money	default 0 	not null,	// 
	profit2	money	default 0 	not null,	// 
	number3	money	default 0	not null,	// �̴�
	amount3	money	default 0 	not null,	// 
	sale3		money	default 0 	not null,	// 
	profit3	money	default 0 	not null,	// 
	number4	money	default 0	not null,	// ����
	amount4	money	default 0 	not null,	// 
	sale4		money	default 0 	not null,	// 
	profit4	money	default 0 	not null,	// 
	number5	money	default 0	not null,	// ����
	amount5	money	default 0 	not null,	// 
	sale5		money	default 0 	not null,	// 
	disc		money	default 0 	not null,	// 
	profit5	money	default 0 	not null,	// 
	number6	money	default 0	not null,	// ����
	amount6	money	default 0 	not null,	// 
	sale6		money	default 0 	not null,	// 
	profit6	money	default 0 	not null,	// 
	number7	money	default 0	not null,	// ���ɱ���
	amount7	money	default 0 	not null,	// 
	sale7		money	default 0 	not null,	// 
	profit7	money	default 0 	not null,	// 
	number8	money	default 0	not null,	// �����ۼ�
	amount8	money	default 0 	not null,	// 
	sale8		money	default 0 	not null,	// 
	profit8	money	default 0 	not null,	// 
	number9	money	default 0	not null,	// ���
	amount9	money	default 0 	not null,	// 
	sale9		money	default 0 	not null,	// 
	profit9	money	default 0 	not null,	// 
	price0	money	default 0 	not null,	// ����
	price1	money	default 0 	not null		// �ۼ�
)
;
insert bos_hstore select * from bos_hstore_old
;
exec sp_primarykey bos_hstore,id,pccode,site,code
create unique index siteno on bos_hstore(id,pccode,site,code)
;
drop table bos_hstore_old;

//------------------------------------------------------------------------------
//		��Ʒ������ϸ�� --- ��ǰ
//------------------------------------------------------------------------------
exec sp_rename bos_detail, bos_detail_old;
create table  bos_detail (
	pccode 	char(5)			not null,
	site		char(5)			not null,				// �ص�
	code		char(8)			not null,				// ����
	id			char(6)			not null,				// ��������
	ii			int				not null,				// �������
	flag		char(2)			not null,				// �������� -- ��/��/��/��/��/��/��/��   -- + ��
	descript	varchar(20)		null,						// ����: ��-�����ͷ�/��-������
	folio		char(10)			not null,				// ���Ե���(����+��ˮ��)
	sfolio	varchar(20)		null,						// �ֹ�����
	fid		int	default 0	not null,			// �������
	rsite		char(5)	default '' not null,  		// ��صص�
	bdate		datetime			not null,				// Ӫҵ����
	act_date	datetime			not null,				// ҵ��������
	log_date	datetime			not null,				// ������������
	empno		char(10)			null,						// 

	number	money	default 0 not null,				// ����		-------- ��ǰҵ��
	amount0	money	default 0 not null,				// ����
	amount	money	default 0 not null,				// �ۼ�
	disc		money	default 0 not null,				// �ۿ�
	profit	money	default 0 not null,				// �������

	gnumber	money	default 0 not null,				// ����		---------  ���
	gamount0	money	default 0 not null,				// ����
	gamount	money	default 0 not null,				// �ۼ�
	gprofit	money	default 0 not null,				// �������

	price0	money	default 0 not null,				// ����
	price1	money	default 0 not null,				// �ۼ�
)
;
insert bos_detail select * from bos_detail_old
;
exec sp_primarykey bos_detail,pccode,site,code,ii
create unique index index1 on bos_detail(pccode,site,code,ii)
create index sfno on bos_detail(sfolio)
create index fno on bos_detail(folio)
create index bdate on bos_detail(bdate)
create index actdate on bos_detail(act_date)
create index code on bos_detail(code,folio)
create index empno on bos_detail(empno,folio)
;
drop table bos_detail_old;

//------------------------------------------------------------------------------
//		��Ʒ������ϸ�� --- ��ʷ
//------------------------------------------------------------------------------
exec sp_rename bos_hdetail, bos_hdetail_old;
create table  bos_hdetail (
	pccode 	char(5)			not null,
	site		char(5)			not null,				// �ص�
	code		char(8)			not null,				// ����
	id			char(6)			not null,				// ��������
	ii			int				not null,				// �������
	flag		char(2)			not null,				// �������� -- ��/��/��/��/��/��/��/��   -- + ��
	descript	varchar(20)		null,						// ����: ��-�����ͷ�/��-������
	folio		char(10)			not null,				// ���Ե���(����+��ˮ��)
	sfolio	varchar(20)		null,						// �ֹ�����
	fid		int	default 0	not null,			// �������
	rsite		char(5)	default '' not null,  		// ��صص�
	bdate		datetime			not null,				// Ӫҵ����
	act_date	datetime			not null,				// ҵ��������
	log_date	datetime			not null,				// ������������
	empno		char(10)			null,						// 

	number	money	default 0 not null,				// ����		-------- ��ǰҵ��
	amount0	money	default 0 not null,				// ����
	amount	money	default 0 not null,				// �ۼ�
	disc		money	default 0 not null,				// �ۿ�
	profit	money	default 0 not null,				// �������

	gnumber	money	default 0 not null,				// ����		---------  ���
	gamount0	money	default 0 not null,				// ����
	gamount	money	default 0 not null,				// �ۼ�
	gprofit	money	default 0 not null,				// �������

	price0	money	default 0 not null,				// ����
	price1	money	default 0 not null,				// �ۼ�
)
;
insert bos_hdetail select * from bos_hdetail_old
;
exec sp_primarykey bos_hdetail,id,pccode,site,code,ii
create unique index index1 on bos_hdetail(id,pccode,site,code,ii)
create index sfno on bos_hdetail(sfolio)
create index fno on bos_hdetail(folio)
create index bdate on bos_hdetail(bdate)
create index actdate on bos_hdetail(act_date)
create index code on bos_hdetail(code,folio)
create index empno on bos_hdetail(empno,folio)
;
drop table bos_hdetail_old;

//// ------------------------------------------------------------------------------
//// ��ʱ�� === ��ϸ����Դ --- �������� �� ���۵��� 
//// ------------------------------------------------------------------------------
//if exists (select 1 from sysobjects where name = 'bos_tmpdetail' and type='U')
//	drop table bos_tmpdetail;
//create table bos_tmpdetail 
//(
//	modu_id	char(2)			not null,
//	pc_id		char(4)			not null,
//	folio		char(10)			not null,				// ���Ե���(����+��ˮ��)
//	sfolio	varchar(20),								// �ֹ�����
//	site		char(5)	default '' not null,  		// �ص�
//	rsite		char(5)	default '' not null,  		// ��صص�
//	act_date	datetime			not null,				// ҵ��������
//	bdate		datetime			not null,				// Ӫҵ����
//	flag		char(2)			not null,				// ��������: ��<��>��, ���, ����, �̴�, ����
//	cby		char(10)			not null,				// ����
//	cdate		datetime	default getdate()	not null,
//	fid		int				not null,				// ��������=0  ���۵���=id
//	code		char(8)			not null,				// ����
//	number	money	default 0 not null,				// ����
//	amount	money	default 0 not null,				// �ɱ����
//	amount1	money	default 0 not null,				// ���۽��
//	disc		money	default 0 not null,				// �ۿ�
//	profit	money	default 0 not null,				// �������
//	ref		varchar(20)		null						// ��ע
//)
//exec sp_primarykey bos_tmpdetail,modu_id,pc_id,folio,site,code,fid
//create unique index index1 on bos_tmpdetail(modu_id,pc_id,folio,site,code,fid)
//;
// -----------------------����ΪBOS_KCTABLE
// -----------------------����ΪBOS_HS_INPUT
exec sp_rename bos_trans, bos_trans_old;
create table  bos_trans
(
	modu_id			char(2)				not null,
	pc_id				char(4)				not null,
	pccode			char(5)				not null,
	mode			 	char(3)				null,
   pfee_base	 	money	default 0 	not null,
   serve_type	 	char	default '0'	not null,
   serve_value	 	money	default 0 	not null,
   tax_type	 		char	default '0'	not null,
   tax_value	 	money	default 0 	not null,
   disc_type	 	char	default '0'	not null,
   disc_value	 	money	default 0 	not null,
	reason			char(3)				null
)
;
insert bos_trans select * from bos_trans_old
;
exec sp_primarykey bos_trans, modu_id, pc_id, pccode
create unique index index1 on bos_trans(modu_id, pc_id, pccode)
;
drop table bos_trans_old;
// -----------------------����ΪBOS_HS_INPUT
// -----------------------����ΪBOS_SHIFT
--		shiftbosjie
--		shiftbosdai
--
--		bos_jie
--		bos_dai
--		bos_jiedai
--
--		p_gds_bos_shiftrep
--		p_gds_bos_shiftrep_exp
--
-- ------------------------------------------------------------------------------

--   
--	BOS ����� 
--


exec sp_rename shiftbosjie, shiftbosjie_old;
create table shiftbosjie
(
	modu_id       char(2)	not null,
	pc_id         char(4)	not null,
	order_        int      default 0	,
	date          datetime default getdate(),
	code          char(5)  default '' not null,
	descript      char(24)  default '' not null,
	fee_bas       money    default 0  not null,
	fee_sur       money    default 0  not null,
	fee_tax       money    default 0  not null,
	fee_dsc	     money    default 0  not null,
	fee_ent	     money    default 0  not null,
	fee_ttl	     money    default 0  not null
)
;
insert shiftbosjie select * from shiftbosjie_old
;
exec sp_primarykey shiftbosjie,modu_id,pc_id,code
create unique index index1 on shiftbosjie(modu_id,pc_id,code)
;
drop table shiftbosjie_old;

exec sp_rename shiftbosdai, shiftbosdai_old;
create table shiftbosdai
(
	modu_id       char(2)	not null,
	pc_id         char(4)	not null,
	order_        int      default 0,
	date          datetime default    getdate(),
	paycode       char(5)  default '' not null,
	paytail       char(1)  default '' not null,
	descript1     char(5)  default '' not null,
	descript      char(24) default '' not null,
	creditd       money    default 0  not null
)
;
insert shiftbosdai select * from shiftbosdai_old
;
exec sp_primarykey shiftbosdai,modu_id,pc_id,paycode,paytail
create unique index index1 on shiftbosdai(modu_id,pc_id,paycode,paytail)
;
drop table shiftbosdai_old;

--  
--	�����ͳ����ʱ��
--
exec sp_rename bos_jie, bos_jie_old;
create table bos_jie
(
	modu_id  char(2) not null,
   pc_id    char(4) not null,
	jiecode  char(5) not null,            --  ����  
	amount   money   default 0 not null,  --  ������
	smount   money   default 0 not null,  --  �����
	tmount   money   default 0 not null,  --  ���ӷ�
	pmount   money   default 0 not null,  --  �ٷֱ��ۿ�
	dmount   money   default 0 not null,  --  ����
	emount   money   default 0 not null   --  ���
)
;
insert bos_jie select * from bos_jie_old
;
exec sp_primarykey bos_jie,modu_id,pc_id,jiecode
create unique index index1 on bos_jie (modu_id,pc_id,jiecode)
;
drop table bos_jie_old;

exec sp_rename bos_dai, bos_dai_old;
create table bos_dai
(
	modu_id       char(2) not null,
   pc_id       char(4) not null,
   daicode     char(5) not null,      --  ���� 
   daitail     char(1) default '',    --  ����� 
   distribute  char(4) default '',    --  ���̯��,ֻ�Խ����о�������� 
   amount      money   default 0  not null
)	 
;
insert bos_dai select * from bos_dai_old
;
exec sp_primarykey bos_dai,modu_id,pc_id,daicode,daitail
create unique index index1 on bos_dai (modu_id,pc_id,daicode,daitail)
;
drop table bos_dai_old;

exec sp_rename bos_jiedai, bos_jiedai_old;
create table bos_jiedai
(
   modu_id       char(2) not null,
   pc_id       char(4) not null,
   jiecode  char(5) default '',  --  ���� 
   daicode  char(5) default '',  --  ���� 
   amount   money   default 0  not null,
   smount   money   default 0  not null,
   tmount   money   default 0  not null
)
;
insert bos_jiedai select * from bos_jiedai_old
;
exec sp_primarykey bos_jiedai,modu_id,pc_id,daicode,jiecode
create unique index index1 on bos_jiedai (modu_id,pc_id,daicode,jiecode)
;
drop table bos_jiedai_old
// -----------------------����ΪBOS_SHIFT
/* �ֽ������ */

exec sp_rename cashrep, cashrep_old;
create table cashrep
(
	date		datetime		null,
	class		char(2)		default '' null, /* '01' ǰ��,'02' AR��,'03',��������,'04',�ۺ����� */
	descript char(10)		default '' null,
	shift		char(1)		default '' null,
	sname		char(6)		default '' null,
	empno		char(10)		default '' null,
	ename		char(12)		default '' null,
	cclass	char(1)		default '' null,
	ccode		char(5)		default '' null,
	credit	money			default 0 not null
)
;
insert cashrep select * from cashrep_old
;
exec sp_primarykey cashrep,class,shift,empno,cclass,ccode 
create unique index index1 on cashrep(class,shift,empno,cclass,ccode)
;
drop table cashrep_old;

exec sp_rename ycashrep, ycashrep_old;
create table ycashrep
(
	date		datetime		null,
	class		char(2)		default '' null, /* '01' ǰ��,'02' AR��,'03',��������,'04',�ۺ����� */
	descript char(10)		default '' null,
	shift		char(1)		default '' null,
	sname		char(6)		default '' null,
	empno		char(10)		default '' null,
	ename		char(12)		default '' null,
	cclass	char(1)		default '' null,
	ccode		char(5)		default '' null,
	credit	money			default 0 not null
)
;
insert ycashrep select * from ycashrep_old
;
exec sp_primarykey ycashrep,date,class,shift,empno,cclass,ccode 
create unique index index1 on ycashrep(date,class,shift,empno,cclass,ccode)
;
drop table ycashrep_old;

/* �ͷ�Ӫҵ(�����)�ձ��� for HZDS */
exec sp_rename dayrepo, dayrepo_old;
create table dayrepo
(
	bdate			datetime	not null, 
	class			char(1)	not null, 
	pccode		char(5)	default '' not null, 
	servcode		char(1)	default '' not null, 
	descript		char(16)	default '' not null, 
	last			money		default 0 not null,			/* ����ֹ��Ƿ */
	ddeb			money		default 0 not null,			/* ���շ���Ӧ�� */
	ddis			money		default 0 not null,			/* ���շ����Ż� */
	dcre			money		default 0 not null,			/* �����ջ� */
	dlos			money		default 0 not null,			/* ���շ������� */
	till			money		default 0 not null			/* ����ֹ��Ƿ */
)
;
insert dayrepo select * from dayrepo_old
;
exec sp_primarykey dayrepo, bdate, class, pccode, servcode
create unique index index1 on dayrepo(bdate, class, pccode, servcode)
;
drop table dayrepo_old
;

exec sp_rename ydayrepo, ydayrepo_old;
create table ydayrepo
(
	bdate			datetime	not null, 
	class			char(1)	not null, 
	pccode		char(5)	default '' not null, 
	servcode		char(1)	default '' not null, 
	descript		char(16)	default '' not null, 
	last			money		default 0 not null,			/* ����ֹ��Ƿ */
	ddeb			money		default 0 not null,			/* ���շ���Ӧ�� */
	ddis			money		default 0 not null,			/* ���շ����Ż� */
	dcre			money		default 0 not null,			/* �����ջ� */
	dlos			money		default 0 not null,			/* ���շ������� */
	till			money		default 0 not null			/* ����ֹ��Ƿ */
)
;
insert ydayrepo select * from ydayrepo_old
;
exec sp_primarykey ydayrepo, bdate, class, pccode, servcode
create unique index index1 on ydayrepo(bdate, class, pccode, servcode)
;
drop table ydayrepo_old
;

/* ���������ձ� */

exec sp_rename deptjie, deptjie_old;
create table deptjie
(
   date           datetime default getdate() not null,
	pccode         char(5)  default '' not null,
	shift          char(1)  default '' not null,
	empno          char(10)  default '' not null,
	code           char(5)  default '' not null,
	descript       char(24) default '' not null,
	daymark        char(1)  default '' not null,
	feed           money    default 0  not null,
	feem           money    default 0  not null
)
;
insert deptjie select * from deptjie_old
;
exec sp_primarykey deptjie,pccode,shift,empno,code
create unique index index1 on deptjie(pccode,shift,empno,code)
;
drop table deptjie_old;

exec sp_rename ydeptjie, ydeptjie_old;
create table ydeptjie
(
   date           datetime default getdate() not null,
	pccode         char(5)  default '' not null,
	shift          char(1)  default '' not null,
	empno          char(10)  default '' not null,
	code           char(5)  default '' not null,
	descript       char(24) default '' not null,
	daymark        char(1)  default '' not null,
	feed           money    default 0  not null,
	feem           money    default 0  not null
)
;
insert ydeptjie select * from ydeptjie_old
;
exec sp_primarykey ydeptjie,date,pccode,shift,empno,code
create unique index index1 on ydeptjie(date,pccode,shift,empno,code)
;
drop table ydeptjie_old;

exec sp_rename deptdai, deptdai_old;
create table deptdai
(
   date           datetime default getdate() not null,
	pccode         char(5)  default '' not null,
	shift          char(1)  default '' not null,
	empno          char(10)  default '' not null,
	descript1      char(5)  default '' not null,
	paycode        char(5)  default '' not null,
	paytail        char(1)  default '' not null,
	descript       char(24) default '' not null,
	daymark        char(1)  default '' not null,
	creditd        money    default 0  not null,
	creditm        money    default 0  not null
)
;
insert deptdai select * from deptdai_old
;
exec sp_primarykey deptdai,pccode,shift,empno,paycode,paytail
create unique index index1 on deptdai(pccode,shift,empno,paycode,paytail)
;
drop table deptdai_old;

exec sp_rename ydeptdai, ydeptdai_old;
create table ydeptdai
(
	date           datetime default getdate() not null,
	pccode         char(5)  default '' not null,
	shift          char(1)  default '' not null,
	empno          char(10)  default '' not null,
	descript1      char(5)  default '' not null,
	paycode        char(5)  default '' not null,
	paytail        char(1)  default '' not null,
	descript       char(24) default '' not null,
	daymark        char(1)  default '' not null,
	creditd        money    default 0  not null,
	creditm        money    default 0  not null
)
;
insert ydeptdai select * from ydeptdai_old
;
exec sp_primarykey ydeptdai,date,pccode,shift,empno,paycode,paytail
create unique index index1 on ydeptdai(date,pccode,shift,empno,paycode,paytail)
;
drop table ydeptdai_old;

/* �����Ż�,�ۿ�,�����ϸ */
exec sp_rename discount_detail, discount_detail_old;

create table discount_detail
(
	date				datetime,										/* Ӫҵ���� */
	modu_id			char(2)	not null,							/* ģ��� */
	accnt				char(10)	not null,							/* �ʺ�(ǰ̨)
																				�˵���(�ۺ�����)
																				��ˮ��(��������) */
	number			integer	default 0 not null,				/* �д� */
	pccode			char(5)	not null,							/* ������ */
	charge			money		default 0 not null,				/* ��� */
	paycode			char(5)	default '' not null,				/* ���ʽ(�ۿ�Ϊ'ZZZ') */
	key0				char(3)	default '' not null,				/* �Ż���Ա���� */
	billno			char(10)	default '' not null,				/* ���ʵ���(ǰ̨����) */
)
;
insert discount_detail select * from discount_detail_old
;
exec sp_primarykey discount_detail, modu_id, accnt, number, pccode, paycode, key0, billno
create unique index index1 on discount_detail(modu_id, accnt, number, pccode, paycode, key0, billno)
;
drop table discount_detail_old;

/* �����Ż�,�ۿ�,������ܱ� */
exec sp_rename discount, discount_old;
create table discount
(
	date				datetime,										/* Ӫҵ���� */
	key0				char(3)	not null,							/* �Ż���Ա���� */
	paycode			char(5)	default '' not null,				/* ���ʽ(�ۿ�Ϊ'ZZZ') */
	pccode			char(5)	not null,							/* ������ */
	day				money		default 0 not null,				/* ���� */
	month				money		default 0 not null,				/* ���� */
	year				money		default 0 not null				/* ���� */
)
;
insert discount select * from discount_old
;
exec sp_primarykey discount, key0, paycode, pccode
create unique index index1 on discount(key0, paycode, pccode)
;
drop table discount_old;

/* �����Ż�,�ۿ�,������ܱ� */
exec sp_rename ydiscount, ydiscount_old;
create table ydiscount
(
	date				datetime,										/* Ӫҵ���� */
	key0				char(3)	not null,							/* �Ż���Ա���� */
	paycode			char(5)	default '' not null,				/* ���ʽ(�ۿ�Ϊ'ZZZ') */
	pccode			char(5)	not null,							/* ������ */
	day				money		default 0 not null,				/* ���� */
	month				money		default 0 not null,				/* ���� */
	year				money		default 0 not null				/* ���� */
)
;
insert ydiscount select * from ydiscount
;
exec sp_primarykey ydiscount, date, key0, paycode, pccode
create unique index index1 on ydiscount(date, key0, paycode, pccode)
;
drop table ydiscount_old;

// fixed_charge�����
exec sp_rename fixed_charge, fixed_charge_old;

create table fixed_charge
(
	accnt					char(10)			not null,								/* �˺� */
	number				integer			not null,								/*  */
	pccode				char(5)			not null,								/* ������ */
	argcode				char(3)			default '' null,						/* �ı���(��ӡ���˵��Ĵ���) */
	amount				money				default 0 not null,					/* ��� */
	quantity				money				default 0 not null,					/* ���� */
	starting_time		datetime			default '2000-1-1' not null,					/* ��Ч����ʼ */
	closing_time		datetime			default '2000-1-1 23:59:59' not null,		/* ��Ч�ڽ�ֹ */
	cby					char(10)			not null,								/* ���� */
	changed				datetime			default getdate() not null,		/* ʱ�� */
	logmark				integer			default 0 not null
)
;
insert fixed_charge select * from fixed_charge_old
;
exec sp_primarykey fixed_charge, accnt, number
create unique index index1 on fixed_charge(accnt, number)
;
drop table fixed_charge_old;

// �������ÿ������
exec sp_rename guest_card, guest_card_old;
create table guest_card
(
	no						char(7)			not null,								/* ���˺� */
	pccode				char(5)			not null,								/* ���ÿ��� */
	cardno				char(20)			not null,								/* ���ÿ��� */
	cardlevel			char(3)			null,										/* ���� */
	expiry_date			datetime			null,										/* ������Ч�� */
	cby					char(10)			not null,								/* ���� */
	changed				datetime			default getdate() not null,		/* ʱ�� */
)
;
insert guest_card select * from guest_card_old
;
exec sp_primarykey guest_card, no, pccode, cardno
create unique index index1 on guest_card(no, pccode, cardno)
;
drop table guest_card_old;


/* ��Ʊ�� */
/* ��Ʊ������ϸ�� */

exec sp_rename in_detail, in_detail_old;
create table in_detail
(
	printtype   char(10)  default 'bill' not null, /* abill:2:ǰ̨�˵� check:��Ʊ 
																	  pbill:�����˵�*/ 
	inno        char(12) not null,             /*��Ʊ��*/
	bnumb       int      default 0 not null,   /*��Ʊ���������*/
	sta         char(1)  default '0' not null, /*0:û��;1:����;2:����*/
	accnt       char(10)  null,                /*�÷�Ʊ��Ӧ���˺�*/
	billno      char(10) null,                 /*�÷�Ʊ��Ӧ���˵���*/
	pccode      char(5)  null,
	modu        char(2)  null,
	bdate       datetime  null,					 /*����ʹ�õ���������*/		
	empno       char(10)   null,
	shift       char(1)   null,
	credit      money     null,              /*���*/ 
	modi        char(1) default 'F' not null,   /*���������Ƿ��иĶ�*/ 
	cdate			datetime null,
	cempno		char(10) null,
	logdate		datetime		null					 /*����ʹ�õ���������*/
)
;
insert in_detail select * from in_detail_old
;
create unique  index index1 on in_detail(printtype,inno) ;
create index index2 on in_detail(inno);
create index index3 on in_detail(empno,shift);
create index index4 on in_detail(accnt);
drop table in_detail_old;

/* ��Ʊ��ӡ��¼�� */
exec sp_rename in_print, in_print_old;
create table in_print
(
	printtype   char(10)  default 'abill' not null, /* abill:ǰ̨�˵� acheck:��Ʊ  pbill:�����˵�*/ 
	inno        char(12)  not null,             /*��Ʊ��*/
	accnt       char(10)  null,                /*�÷�Ʊ��Ӧ���˺�*/
	billno      char(10)  null,                 /*�÷�Ʊ��Ӧ���˵���*/
	pccode      char(5)   null,
	modu        char(2)   null,
	bdate       datetime  null,					 /*����ʹ�õ���������*/		
	empno       char(10)  null,
	shift       char(1)   null,
	credit      money     null,             	 /*���*/ 
	modi        char(1) 	 default 'F' not null,   /*���������Ƿ��иĶ�*/ 
	logdate		datetime	 null					 /*����ʹ�õ���������*/
)
;
insert in_print select * from in_print_old
;
create unique  index index1 on in_print(printtype,inno);
create index index2 on in_print(inno);
create index index3 on in_print(empno,shift);
create index index4 on in_print(accnt);
drop table in_print_old;

//// ǰ̨�˵���ϸ����
//if exists(select 1  from sysobjects where type ='U' and name ='in_bill_detail') 
//	drop table in_bill_detail ;
//create table in_bill_detail
//(
//	billno      char(10)  not null,                         /*����*/
//	printtype   char(10)  default 'abill' not null,         /* �˵���� ; */
//	inno        char(12)  default  '' not null,                 /*�˵���*/
//	code        char(5)   default  '' not null,                
//	charge      money     default 0,        
//	credit      money    default  0,       
//	item        varchar(100)  null ,
//	log_date    datetime  
//)
//;
//create unique  index index1 on in_bill_detail(printtype,inno,code,item,log_date) ;
//
//// ǰ̨�ʵ�ͷ
//if exists(select 1  from sysobjects where type ='U' and name ='in_bill_head') 
//	drop table in_bill_head ;
//create table in_bill_head
//(
//	billno      char(10)  not null,                         /*����*/
//	printtype   char(10)  default 'abill' not null,         /* �˵���� ; */
//	inno        char(12)  default  '' not null,                 /*�˵���*/
//	name        varchar(40)   default  '' not null,                
//	fir         varchar(60)   default '',        
//	room        char(5)   default  '',           
//	rooms       int,
//	guests      int,
//	arr         datetime,
//	dep         datetime,
//	qtrate      money default 0,
//	setrate     money default 0,
//	remark      varchar(200),
//	log_date    datetime
//)
//;
//create unique  index index1 on in_bill_head(printtype,inno,log_date) ;
//
//
//// ǰ̨�ʵ�ͷ�޸�����
//if exists(select 1  from sysobjects where type ='U' and name ='in_billmodi_head') 
//	drop table in_billmodi_head ;
//create table in_billmodi_head
//(
//	billno      char(10)  not null,                         /*����*/
//	printtype   char(10)  default 'abill' not null,         /* �˵���� ; */
//	inno        char(12)  default  '' not null,                 /*�˵���*/
//	name        varchar(40)   default  '' not null,                
//	fir         varchar(60)   default '',        
//	room        char(5)   default  '',           
//	rooms       int,
//	guests      int,
//	arr         datetime,
//	dep         datetime,
//	qtrate      money default 0,
//	setrate     money default 0,
//	remark      varchar(200),
//	log_date    datetime
//)
//;
//create unique  index index1 on in_billmodi_head(printtype,inno,log_date) ;
//
//
//// ǰ̨�˵���ϸ�޸�����
//
//if exists(select 1  from sysobjects where type ='U' and name ='in_billmodi_detail') 
//	drop table in_billmodi_detail ;
//create table in_billmodi_detail
//(
//	billno      char(10)  not null,                         /*����*/
//	printtype   char(10)  default 'abill' not null,         /* �˵���� ; */
//	inno        char(12)  default  '' not null,                 /*�˵���*/
//	code        char(5)   default  '' not null,                
//	charge      money     default 0,        
//	credit      money    default  0,       
//	item        varchar(100)  null ,
//	log_date    datetime,
//	modi        char(1)  default 'T'  
//)
//;
//create unique  index index1 on in_billmodi_detail(printtype,inno,code,item,log_date) ;

/* ÿ��Ӧ�տ��ձ� */
exec sp_rename nbrepo, nbrepo_old;
create table nbrepo(
	deptno		char(3)		not null,					/* ��� */
	deptname		char(24)		null,							/* ������������� */
	pccode		char(5)		not null,					/*  */
	descript		char(24)    null,							/* �������� */
	f_in			money			default 0 	not null,	/* ǰ̨ */
	b_in  		money			default 0 	not null,	/* ��̨ */	/*¼��,����*/
	f_out			money			default 0 	not null,	/* ǰ̨ */
	b_out			money			default 0 	not null,	/* ��̨ */	/*�˿�,����*/
	f_tran      money			default 0 	not null,	/* ǰ̨ */
	b_tran      money			default 0 	not null,	/* ��̨ */	/*ת��,����*/
)
;
insert nbrepo select * from nbrepo_old
;
exec sp_primarykey nbrepo,pccode
create unique index index1 on nbrepo(pccode)
;
drop table nbrepo_old;


// Package�����
exec sp_rename package, package_old;
create table package
(
	code					char(4)			not null,								/* ���� */
	type					char(1)			not null,								/* ��� */
	descript				char(30)			not null,								/* ���� */
	descript1			char(30)			default '' not null,					/* Ӣ������ */
	pccode				char(5)			not null,								/* ������ */
	quantity				money				default 1 not null,					/* ���� */
	amount				money				default 0 not null,					/* ��� */
	rule_calc			char(10)			default '0000000000' not null,	/* ���㷽ʽѡ��
																								��һλ:0.���ù���Package_Detail��;1.���ù���Account��
																								�ڶ�λ:0.include;1.exclude
																								����λ:0.�����;1.������
																								����λ:0.�̶����;1.��������;2.������;3.����ͯ
																								����λ:0.���ⲻ��;1.������� */
	rule_post			char(3)			not null,								/* ���˷�ʽ */
	rule_parm			char(30)			default '' not null,					/* �������� */
	starting_days		integer			default 1 not null,					/* �����˺�ĵڼ��쿪ʼ��Ч */
	closing_days		integer			default 1 not null,					/* �ܵ���Ч���� */
	starting_time		char(8)			default '00:00:00' not null,		/* ÿ�����Ч������ʼʱ�� */
	closing_time		char(8)			default '23:59:59' not null,		/* ÿ�����Ч���˽�ֹʱ�� */
	pccodes				varchar(255)	default '' not null,					/* ���Թ�����Ӫҵ������� */
	pos_pccode			char(3)			default '' not null,					/* �����޶�󣬼���Account��Ӫҵ������� */
	credit				money				default 0 not null,					/* ����ת�˵Ľ�� */
	cby					char(10)			not null,								/* ���� */
	changed				datetime			default getdate() not null,		/* ʱ�� */
	logmark				integer			default 0 not null
)
;
insert package select * from package_old
;
exec sp_primarykey package, code
create unique index index1 on package(code)
;
drop table package_old;

// Package��ϸ��(˵��:��ʹʹ��Pakcage,��Account�ж���һ�н��Ϊ�����ϸ��)
// Master.LastinumbתΪPackage.Numberָ��
exec sp_rename package_detail, package_detail_old;
create table package_detail
(
	accnt					char(10)			not null,								/* �˺� */
	number				integer			not null,								/* �ؼ��� */
	roomno				char(5)			default '' not null,					/* ���� */
	code					char(4)			default '' not null,					/* ���� */
	descript				char(30)			not null,								/* ���� */
	descript1			char(30)			default '' not null,					/* Ӣ������ */
	bdate					datetime			not null,								/*  */
	starting_date		datetime			default '2000/1/1' not null,		/* ��Ч��ʼ���� */
	closing_date		datetime			default '2038/12/31' not null,	/* ��Ч��ֹ���� */
	starting_time		char(8)			default '00:00:00' not null,		/* ÿ�����Ч������ʼʱ�� */
	closing_time		char(8)			default '23:59:59' not null,		/* ÿ�����Ч���˽�ֹʱ�� */
	pccodes				varchar(255)	default '' not null,					/* ���Թ�����Ӫҵ������� */
	pos_pccode			char(5)			default '' not null,					/* �����޶�󣬼���Account��Ӫҵ������� */
	quantity				money				default 0 not null,					/* ���� */
	charge				money				default 0 not null,					/* ��ת�˵Ľ�� */
	credit				money				default 0 not null,					/* ����ת�˵Ľ�� */
	posted_accnt		char(10)			default '' not null,					/* ʵ��ת�˵��˺� */
	posted_roomno		char(5)			default '' not null,					/* ʵ��ת�˵ķ��� */
	posted_number		integer			default 0 not null,					/* ��Ӧ�ؼ���(ʵ��ʹ�õ�����һ��Package) */
	tag					char(1)			default '0' not null,				/* ��־��0.�Զ������Package(δ��);
																										1.�Զ������Package(������һ����);
																										2.�Զ������Package(���ù�);
																										5.�Զ������Package(�ѳ���);
																										9.ʵ��ʹ��Package����ϸ */
	account_accnt		char(10)			default '' not null,					/* �˺�(��ӦAccount.Accnt) */
	account_number		integer			default 0 not null,					/* �˴�(��ӦAccount.Number) */
	account_date		datetime			default getdate() not null			/* �˺�(��ӦAccount.log_date) */
)
;
insert package_detail select * from package_detail_old
;
exec sp_primarykey package_detail, accnt, number
create unique index index1 on package_detail(accnt, number)
create index index2 on package_detail(accnt, account_accnt)
create index index3 on package_detail(accnt, tag, starting_date, closing_date, starting_time, closing_time)
;
drop table package_detail_old;

exec sp_rename pccode, pccode_old;
create table pccode
(
	pccode		char(5)		not null,					/* Ӫҵ�� */
	descript		char(24)		default '',					/* �������� */
	descript1	char(50)		default '',					/* ������������ */
	descript2	char(50)		default '',					/* ������������ */
	descript3	char(50)		default '',					/* ������������ */
	modu			char(2)		default '',					/* ģ��� */
	jierep		char(8)		default '',					/* �ױ������� */
	tail			char(2)		default '',					/* �ױ������� */
	//
	commission	money			default 0 not null,		/* �����еĻؿ���(�����ÿ���Ч) */
	limit			money			default 0 not null,		/* �����޶� */
	reason		char(1)		default 'F' not null,	/* �Ƿ���Ҫ�����Ż����� */
	// deptno?Ϊ���ַ�����롢���д����Լ�ԭ���ʽ���еĸ���
	deptno		char(5)		default '',					/* ����Ӫҵ���� */
	deptno1		char(5)		default '' null,			/* ������ˡ��Զ�ת�ˡ����˻����� */
	deptno2		char(5)		default '' null,			/* Ԥ�� */
	deptno3		char(5)		default '' null,			/* Ԥ�� */
	deptno4		char(5)		default '' null,			/* �����ѯ���� */
	deptno5		char(5)		default '' null,			/* ��Ʊ���� */
	deptno6		char(5)		default '' null,			/* �����к� */	 
	deptno7		char(5)		default '' null,			/* ҵ��ͳ�� */
	deptno8		char(5)		default '' null,			/* ����:Rebate��־; ����:Distribute��־*/ 
	argcode		char(3)		default '' null,			/* ȱʡ���˵����� */
//	paycode		char(3)		not null,					/* �ڲ���,С��54Ϊ��Ч�ĸ��ʽ */
//	codecls		char(1)		not null,					/* ���ʽ���,refer to credcls */
//	tag1			char(3)		default '' null,			/*  */
//	tag2			char(3)		default '' null,			/*  */
//	tag3			char(3)		default '' null,			/*  */
//	tag4			integer 		default 0 null,			/*  */
//	distribute  char(4)     null,							/* ���̯����... */
	//
	pos_item		char(3)		default '' null
)
;
insert pccode select * from pccode_old
;
exec sp_primarykey pccode, pccode
create unique clustered index index1 on pccode(pccode)
;
drop table pccode_old;

/* ��ӡ��ʽ����*/
exec sp_rename pdeptrep, pdeptrep_old;
create table pdeptrep
(
	pc_id		char(4)		not null, 
	jiedai	char(1)		not null, 
	itemcnt  integer		default 0 not null, 
	code		char(10)		not null, 
	coden		char(1)		default '' null, 
	descript char(60)		default '', 
	v1			money			default 0 null, 
	v2			money			default 0 null, 
	v3			money			default 0 null, 
	v4			money			default 0 null, 
	v5			money			default 0 null, 
	v6			money			default 0 null, 
	v7			money			default 0 null, 
	v8			money			default 0 null, 
	v9			money			default 0 null, 
	v10		money			default 0 null, 
	v11		money			default 0 null, 
	v12		money			default 0 null, 
	v13		money			default 0 null, 
	v14		money			default 0 null, 
	v15		money			default 0 null, 
	v16		money			default 0 null, 
	v17		money			default 0 null, 
	v18		money			default 0 null, 
	v19		money			default 0 null, 
	v20		money			default 0 null, 
	v21		money			default 0 null, 
	v22		money			default 0 null, 
	v23		money			default 0 null, 
	v24		money			default 0 null, 
	v25		money			default 0 null, 
	v26		money			default 0 null, 
	v27		money			default 0 null, 
	v28		money			default 0 null, 
	v29		money			default 0 null, 
	v30		money			default 0 null, 
	v31		money			default 0 null, 
	v32		money			default 0 null, 
	v33		money			default 0 null, 
	v34		money			default 0 null, 
	v35		money			default 0 null, 
	v36		money			default 0 null, 
	v37		money			default 0 null, 
	v38		money			default 0 null, 
	v39		money			default 0 null, 
	v40		money			default 0 null, 
	vtl		money			default 0 null 
)
;
insert pdeptrep select * from pdeptrep_old
;
exec sp_primarykey pdeptrep, pc_id, jiedai, code, coden
create unique index index1 on pdeptrep(pc_id, jiedai, code, coden)
create index index2 on pdeptrep(pc_id, jiedai, itemcnt)
;
drop table pdeptrep_old;

/* ��ӡ��ʽ����*/
exec sp_rename pdeptrep1, pdeptrep1_old;
create table pdeptrep1
(
	pc_id			char(4)		not null, 
	pccode		char(5)		not null, 
	descript2	char(24)		not null, 
	shift			char(1)		default '' null, 
	descript		char(4)		default '', 
	v1				money			default 0 null, 
	v2				money			default 0 null, 
	v3				money			default 0 null, 
	v4				money			default 0 null, 
	v5				money			default 0 null, 
	v6				money			default 0 null, 
	v7				money			default 0 null, 
	v8				money			default 0 null, 
	v9				money			default 0 null, 
	v10			money			default 0 null, 
	v11			money			default 0 null, 
	v12			money			default 0 null, 
	v13			money			default 0 null, 
	v14			money			default 0 null, 
	v15			money			default 0 null, 
	v16			money			default 0 null, 
	v17			money			default 0 null, 
	v18			money			default 0 null, 
	v19			money			default 0 null, 
	v20			money			default 0 null, 
	v21			money			default 0 null, 
	v22			money			default 0 null, 
	v23			money			default 0 null, 
	v24			money			default 0 null, 
	v25			money			default 0 null, 
	v26			money			default 0 null, 
	v27			money			default 0 null, 
	v28			money			default 0 null, 
	v29			money			default 0 null, 
	v30			money			default 0 null, 
	v31			money			default 0 null, 
	v32			money			default 0 null, 
	v33			money			default 0 null, 
	v34			money			default 0 null, 
	v35			money			default 0 null, 
	v36			money			default 0 null, 
	v37			money			default 0 null, 
	v38			money			default 0 null, 
	v39			money			default 0 null, 
	v40			money			default 0 null, 
	vtl			money			default 0 null 
)
;
insert pdeptrep1 select * from pdeptrep1_old
;
exec sp_primarykey pdeptrep1, pc_id, pccode, shift
create unique index index1 on pdeptrep1(pc_id, pccode, shift)
;
drop table pdeptrep1_old;

/* ��ӡ��ʽ����*/
exec sp_rename pdeptrep2, pdeptrep2_old;
create table pdeptrep2
(
	pc_id			char(4)		not null, 
	pccode		char(5)		not null, 
	descript2	char(24)		not null, 
	shift			char(1)		default '' null, 
	descript		char(4)		default '', 
	d1				money			default 0 null, 			// ʳƷ
	d2				money			default 0 null, 			// ����
	d3				money			default 0 null,			// ����
	d4				money			default 0 null,			// �����
	d5				money			default 0 null,			// ����
	d6				money			default 0 null,			// ǰ̨����
	d7				money			default 0 null,			// ����		 
	d8				money			default 0 null,
	d9				money			default 0 null,			// ����
	//
	m1				money			default 0 null, 			// ʳƷ
	m2				money			default 0 null, 			// ����
	m3				money			default 0 null,			// ����
	m4				money			default 0 null,			// �����
	m5				money			default 0 null,			// ����
	m6				money			default 0 null,			// ǰ̨����
	m7				money			default 0 null,			// ���� 
	m8				money			default 0 null,
	m9				money			default 0 null				// ����
)
;
insert pdeptrep2 select * from pdeptrep2_old
;
exec sp_primarykey pdeptrep2, pc_id, pccode, shift
create unique index index1 on pdeptrep2(pc_id, pccode, shift)
;
drop table pdeptrep2_old;

exec sp_rename rebaterep, rebaterep_old;
create table rebaterep
(
	date				datetime,
	paycode			char(5)	default '',
	class				char(8)	default '',
	day01				money		default 0,
	day02				money		default 0,
	day03				money		default 0,
	day04				money		default 0,
	day05				money		default 0,
	day06				money		default 0,
	day07				money		default 0,
	day08				money		default 0,
	day09				money		default 0,
	day99				money		default 0,
	month01			money		default 0,
	month02			money		default 0,
	month03			money		default 0,
	month04			money		default 0,
	month05			money		default 0,
	month06			money		default 0,
	month07			money		default 0,
	month08			money		default 0,
	month09			money		default 0,
	month99			money		default 0,
)
;
insert rebaterep select * from rebaterep_old
;
exec sp_primarykey rebaterep, paycode, class
create unique index index1 on rebaterep(paycode, class)
;
drop table rebaterep_old;

exec sp_rename yrebaterep, yrebaterep_old;
create table yrebaterep
(
	date				datetime,
	paycode			char(5)	default '',
	class				char(8)	default '',
	day01				money		default 0,
	day02				money		default 0,
	day03				money		default 0,
	day04				money		default 0,
	day05				money		default 0,
	day06				money		default 0,
	day07				money		default 0,
	day08				money		default 0,
	day09				money		default 0,
	day99				money		default 0,
	month01			money		default 0,
	month02			money		default 0,
	month03			money		default 0,
	month04			money		default 0,
	month05			money		default 0,
	month06			money		default 0,
	month07			money		default 0,
	month08			money		default 0,
	month09			money		default 0,
	month99			money		default 0,
)
;
insert yrebaterep select * from yrebaterep_old
;
exec sp_primarykey yrebaterep, date, paycode, class
create unique index index1 on yrebaterep(date, paycode, class)
;
drop table yrebaterep_old;


/* ÿ�췿��Ԥ��� */
exec sp_rename rmpostbucket, rmpostbucket_old;
create table rmpostbucket
(
	accnt			char(10)			not null, 
	roomno		char(5)			null, 
	src			char(3)			null, 
	class			char(1)			null, 
	groupno		char(10)			null, 
	headname		varchar(100)	null, 
	type			char(3)			null,								/*��������*/
	market		char(3)			null,								/*�۱���*/
	name			varchar(50)		null, 
	fir			varchar(60)		null, 
	ratecode		char(10)			null, 
	packages		char(20)			null, 
	paycode		char(5)			null, 
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
;
insert rmpostbucket select * from rmpostbucket
;
create index index1 on rmpostbucket(rmpostdate, accnt);
create index index2 on rmpostbucket(rmpostdate, groupno);
create index index3 on rmpostbucket(rmpostdate, posted)
;
drop table rmpostbucket_old;

//	ÿ�췿��Ԥ�����1(Packageר��)
exec sp_rename rmpostpackage, rmpostpackage_old;
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
;
insert rmpostpackage select * from rmpostpackage_old
;
exec sp_primarykey rmpostpackage, pc_id, mdi_id, accnt, number
create unique index index1 on rmpostpackage(pc_id, mdi_id, accnt, number)
;
drop table rmpostpackage_old;

/* rmratecode---���۴���� */
exec sp_rename rmratecode, rmratecode_old;
create table rmratecode
(
	code          char(10)	    					not null,  	// ����
	cat          	char(3)	    					not null,
   descript      varchar(60)      				not null,  	// ����  
   descript1     varchar(60)     default ''	not null,  	// ����  
   private       char(1) 			default 'T'	not null,  	// ˽�� or ����
   mode       	  char(1) 			default ''	not null,  	// ģʽ--�Ժ����������������۵�ȡ��
   folio       	varchar(30) 	default ''	not null, 	// �ʵ�
	src				char(3)			default ''	not null,	// ������Դ
	market			char(3)			default ''	not null,	// �г�����
	packages			char(20)			default ''	not null,	//	����
	begin_			datetime							null,
	end_				datetime							null,
	calendar			char(1)		default 'F'	not null,	// ��������
	yieldable		char(1)		default 'F'	not null,	// ���Ʋ���
	yieldcat			char(3)		default ''	not null,
	bucket			char(3)		default ''	not null,
	staymin			int			default 0	not null,
	staymax			int			default 0	not null,
	pccode			char(5)		default ''	not null,
	sequence			int			default 0	not null
)
;
insert rmratecode select * from rmratecode_old
;
exec sp_primarykey rmratecode,code;
create unique index index1 on rmratecode(code);
create unique index index2 on rmratecode(descript);
;
drop table rmratecode_old;

/* �Ĵ��������ۺϱ��� */
exec sp_rename sjourrep, sjourrep_old;
create table sjourrep
(
	date			datetime			not null,
	tag			char(1)			default '' not null, 
	deptno		char(5)			not null,
	pccode		char(5)			default '' not null,
	descript		char(24)			not null,
	balance_l	money				default 0 not null,			/* ����δ���� */
	day0			money				default 0 not null,			/* ���շ����� */
	month0		money				default 0 not null,			/* ���·����� */
	day1			money				default 0 not null,			/* ���ռ������ */
	month1		money				default 0 not null,			/* ���¼������ */
	day2			money				default 0 not null,			/* ���ն����ۿ� */
	month2		money				default 0 not null,			/* ���¶����ۿ� */
	day3			money				default 0 not null,
	month3		money				default 0 not null,
	day8			money				default 0 not null,			/* ����ʵ�ռ��˿� */
	month8		money				default 0 not null,			/* ����ʵ�ռ��˿� */
	day9			money				default 0 not null,			/* ����ʵ�տ� */
	month9		money				default 0 not null,			/* ����ʵ�տ� */
	balance_t	money				default 0 not null			/* ����δ���� */
)
;
insert sjourrep select * from sjourrep_old
;
exec sp_primarykey sjourrep, tag, deptno, pccode
create unique index index1 on sjourrep(tag, deptno, pccode)
;
drop table sjourrep_old;

exec sp_rename ysjourrep, ysjourrep_old;
create table ysjourrep
(
	date			datetime			not null,
	tag			char(1)			default '' not null, 
	deptno		char(5)			not null,
	pccode		char(5)			default '' not null,
	descript		char(24)			not null,
	balance_l	money				default 0 not null,			/* ����δ���� */
	day0			money				default 0 not null,			/* ���շ����� */
	month0		money				default 0 not null,			/* ���·����� */
	day1			money				default 0 not null,			/* ���ռ������ */
	month1		money				default 0 not null,			/* ���¼������ */
	day2			money				default 0 not null,			/* ���ն����ۿ� */
	month2		money				default 0 not null,			/* ���¶����ۿ� */
	day3			money				default 0 not null,
	month3		money				default 0 not null,
	day8			money				default 0 not null,			/* ����ʵ�ռ��˿� */
	month8		money				default 0 not null,			/* ����ʵ�ռ��˿� */
	day9			money				default 0 not null,			/* ����ʵ�տ� */
	month9		money				default 0 not null,			/* ����ʵ�տ� */
	balance_t	money				default 0 not null			/* ����δ���� */
)
;
insert ysjourrep select * from ysjourrep_old
;
exec sp_primarykey ysjourrep, date, tag, deptno, pccode
create unique index index1 on ysjourrep(date, tag, deptno, pccode)
;
drop table ysjourrep_old;

// ���˻������
exec sp_rename subaccnt, subaccnt_old;
create table subaccnt
(
	roomno				char(5)			default '' not null,				/* ���� */
	haccnt				char(7)			default '' not null,				/* ���˺� */
	accnt					char(10)			not null,							/* �˺� */
	subaccnt				integer			default 0 not null,				/* ���˺�*/
	to_roomno			char(5)			default '' not null,				/* ת�˷��� */
	to_accnt				char(10)			default '' not null,				/* ת���˺� */
	name					char(50)			not null,							/* ���� */
	pccodes				varchar(255)	not null,							/* ������ */
	starting_time		datetime			default '2000/1/1' not null,	/* ��Ч����ʼ */
	closing_time		datetime			default '2038/1/1' not null,	/* ��Ч�ڽ�ֹ */
	cby					char(10)			not null,							/* ���� */
	changed				datetime			default getdate() not null,	/* ʱ�� */
	type					char(1)			default '1' not null,			/* ��(AB)�˻������: 
																							0.�������
																							2.����Ϊ��Ա����(ֻ�������������У���Ա�Դ�Ϊģ��)
																							5.���˻�(�Զ�ת�˲�����˻�) */
	tag					char(1)			default '0' not null,			/* 0.ϵͳ�Զ�����(�����޸�)
																							1.ϵͳ�Զ�����(���޸ġ�����ɾ��)
																							2.�˹�����(���޸�) */
	paycode				char(5)			default '' not null,				/* ���ʽ */
	ref					varchar(50)		default '' not null,				/* ��ע */
	logmark				integer			default 0 not null
)
;
insert subaccnt select * from subaccnt_old
;
exec sp_primarykey subaccnt, accnt, subaccnt, type, starting_time, closing_time
create unique index index1 on subaccnt(accnt, subaccnt, type, starting_time, closing_time)
create index index2 on subaccnt(to_accnt, type)
create index index3 on subaccnt(accnt, haccnt)
;
drop table subaccnt_old;

exec sp_rename hsubaccnt, hsubaccnt_old;
create table hsubaccnt
(
	roomno				char(5)			default '' not null,				/* ���� */
	haccnt				char(7)			default '' not null,				/* ���˺� */
	accnt					char(10)			not null,							/* �˺� */
	subaccnt				integer			default 0 not null,				/* ���˺�*/
	to_roomno			char(5)			default '' not null,				/* ת�˷��� */
	to_accnt				char(10)			default '' not null,				/* ת���˺� */
	name					char(50)			not null,							/* ���� */
	pccodes				varchar(255)	not null,							/* ������ */
	starting_time		datetime			default '2000/1/1' not null,	/* ��Ч����ʼ */
	closing_time		datetime			default '2038/1/1' not null,	/* ��Ч�ڽ�ֹ */
	cby					char(10)			not null,							/* ���� */
	changed				datetime			default getdate() not null,	/* ʱ�� */
	type					char(1)			default '1' not null,			/* ��(AB)�˻������: 
																							0.�������
																							2.����Ϊ��Ա����(ֻ�������������У���Ա�Դ�Ϊģ��)
																							5.���˻�(�Զ�ת�˲�����˻�) */
	tag					char(1)			default '0' not null,			/* 0.ϵͳ�Զ�����(�����޸�)
																							1.ϵͳ�Զ�����(���޸ġ�����ɾ��)
																							2.�˹�����(���޸�) */
	paycode				char(5)			default '' not null,				/* ���ʽ */
	ref					varchar(50)		default '' not null,				/* ��ע */
	logmark				integer			default 0 not null
)
;
insert hsubaccnt select * from hsubaccnt_old
;
exec sp_primarykey hsubaccnt, accnt, subaccnt, type, starting_time, closing_time
create unique index index1 on hsubaccnt(accnt, subaccnt, type, starting_time, closing_time)
create index index2 on hsubaccnt(to_accnt, type)
create index index3 on hsubaccnt(accnt, haccnt)
;
drop table hsubaccnt_old;

// ����û��
///* �Զ�ת��(�������)��Ŀ�� */
//exec sp_rename transfer, transfer_old;
//create table transfer
//(
//	type			char(1)	default '1' not null,					/* ����:1.�Զ�ת��,
//																						  2.�������,
//																						  3.AB��,
//																						  4.��ʾ��Ŀ,
//																						  5.��ʾ�绰�� */
//	accnt			char(10)	not null,
//	to_accnt		char(10)	default '' not null,
//	pccode		char(10)	not null,									/* deptno + pccode + '%'*/
//	percent		money		default 1 not null,						/* ���� */
//	amount		money		default 0 not null,						/* ���� */
//	empno			char(10)	not null,									/* ���� */
//	date			datetime	default getdate() not null,			/* ʱ�� */
//)
//;
//insert transfer select * from transfer_old
//;
//exec sp_primarykey transfer, type, accnt, pccode, to_accnt
//create unique index index1 on transfer(type, accnt, pccode, to_accnt)
//;
//drop table transfer_old;
///* �����Ա�����޸�   --  ������˿�����ʱ�� */
//exec sp_rename transfer_mem, transfer_mem_old;
//create table transfer_mem
//(
//	modu_id		char(2)	not null,
//	pc_id			char(4)	not null,
//	pccode		char(10)	not null,									/* deptno2 + pccode + '%'*/
//	percent		money		default 1 not null,						/* ���� */
//	amount		money		default 0 not null,						/* ���� */
//	empno			char(10)	not null,									/* ���� */
//	date			datetime	default getdate() not null,			/* ʱ�� */
//)
//;
//insert transfer_mem select * from transfer_mem_old
//;
//exec sp_primarykey transfer_mem, modu_id, pc_id, pccode
//create unique index index1 on transfer_mem(modu_id, pc_id, pccode)
//;
//drop table transfer_mem_old;