// AR�˺�����
if exists(select * from sysobjects where type ="U" and name = "ar_apply")
   drop table ar_apply;

create table ar_apply
(
	d_accnt		char(10)		not null,							/* �跽�˺� */
	d_number		integer		not null,							/* �跽ar_detail�е��˴� */
	d_inumber	integer		not null,							/* �跽ar_account�е��˴� */
	c_accnt		char(10)		not null,							/* �����˺� */
	c_number		integer		not null,							/* ����ar_detail�е��˴� */
	c_inumber	integer		not null,							/* ����ar_account�е��˴� */
	amount		money			default 0 not null,				/* ������� */
	billno		char(10)		not null,							/* �������� */
	log_date		datetime		default getdate() not null,	/* �������� */
	bdate			datetime		not null,							/* Ӫҵ���� */
	shift			char(1)		not null,							/* ����Ա��� */
	empno			char(10)		not null,							/* ����Ա���� */
)
;
exec   sp_primarykey ar_apply, d_accnt, d_number, d_inumber, c_accnt, c_number, c_inumber, billno
create unique index index1 on ar_apply(d_accnt, d_number, d_inumber, c_accnt, c_number, c_inumber, billno)
create index index2 on ar_apply(billno, d_accnt, c_accnt)
;
