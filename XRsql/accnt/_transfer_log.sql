/* תAR����ϸ */

if exists(select * from sysobjects where type ="U" and name = "transfer_log")
	drop table transfer_log
;
create table transfer_log
(
	accnt			char(10)		not null,								/* Դ�ʺ� */
	number		integer		default 0 not null,					/* Դ��� */
	charge		money			default 0 not null,					/* Դ���ѽ�� */
	credit		money			default 0 not null,					/* Դ������ */
	empno			char(10)		not null,								/* ת�˹��� */
	date			datetime		default getdate() not null,		/* ת��ʱ�� */
	//
	araccnt		char(10)		not null,								/* AR�ʺ� */
	arnumber		integer		default 1 not null,					/* AR��� */
	archarge		money			default 0 not null,					/* �ջ����ѽ�� */
	arcredit		money			default 0 not null,					/* �ջظ����� */
	arempno		char(10)		null,										/* �ջع��� */
	ardate		datetime		null,										/* �ջ�ʱ�� */
	//
	billno		char(10)		default '' not null					/* �ջ�ʱ���ʵ��� */
)
exec sp_primarykey transfer_log, accnt, number, araccnt, arnumber
create unique index index1 on transfer_log(accnt, number, araccnt, arnumber)
create index index2 on transfer_log(araccnt, arnumber)
;

