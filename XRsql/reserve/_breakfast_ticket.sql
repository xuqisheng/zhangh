/* ���ȯ������ϸ��ϸ */

if exists(select * from sysobjects where type ="U" and name = "breakfast_ticket")
	drop table breakfast_ticket
;
create table breakfast_ticket
(
	accnt			char(10)		not null,								/* �ʺ� */
	roomno		char(5)		default '' not null,					/* ���� */
	startno		char(10)		not null,								/* ��ʼ��� */
	starting		datetime		null,										/* ��ʼ���� */
	quantity		integer		default 1 not null,					/* ���� */
	endno			char(10)		not null,								/* ��ֹ��� */
	ending		datetime		null,										/* ��ֹ���� */
	tag			char(1)		default '0' not null,				/* ״̬:0.����;5.����;9.ʹ��*/
	empno1		char(10)		not null,								/* ����/ʹ�ù��� */
	bdate1		datetime		not null,								/* ����/ʹ��Ӫҵ���� */
	shift1		char(1)		not null,								/* ����/ʹ�ð�� */
	log_date1	datetime		default getdate() not null,		/* ����/ʹ��ʱ�� */
	empno2		char(10)		null,										/* ���Ϲ��� */
	bdate2		datetime		null,										/* ����Ӫҵ���� */
	shift2		char(1)		null,										/* ���ϰ�� */
	log_date2	datetime		null										/* ����ʱ�� */
)
exec sp_primarykey breakfast_ticket, accnt, log_date1
create unique index index1 on breakfast_ticket(accnt, log_date1)
;

/* ���ȯ�û����ձ� */

if exists(select * from sysobjects where type ="U" and name = "breakfast_empno")
	drop table breakfast_empno
;
create table breakfast_empno
(
	empno			char(10)		not null,								/* ���Ź��� */
	no				char(10)		not null									/* ��ʼ��� */
)
exec sp_primarykey breakfast_empno, empno
create unique index index1 on breakfast_empno(empno)
;
insert basecode values ('breakfast_ticket_tag', '0', '����', '', 'T', 'F', 10, '', 'F');
insert basecode values ('breakfast_ticket_tag', '5', '����', '', 'T', 'F', 20, '', 'F');
insert basecode values ('breakfast_ticket_tag', '9', 'ʹ��', '', 'T', 'F', 30, '', 'F');
