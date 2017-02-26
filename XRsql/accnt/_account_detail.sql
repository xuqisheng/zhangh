/* ���ָ��ʽ��ϸ��̯ */
if exists (select * from sysobjects where name ='account_detail' and type ='U')
	drop table account_detail;

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
exec sp_primarykey account_detail, modu_id, accnt, number, paycode, key0
create unique index index1 on account_detail(modu_id, accnt, number, paycode, key0)
;