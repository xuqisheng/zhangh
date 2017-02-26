// �������ÿ������
if exists(select * from sysobjects where type ="U" and name = "credit_card")
   drop table credit_card;

create table credit_card
(
	no						char(7)			not null,								/* ���˺� */
	pccode				char(3)			not null,								/* ���ÿ��� */
	cardno				char(20)			not null,								/* ���ÿ��� */
	expiry_date			datetime			null,										/* ������Ч�� */
	cby					char(10)			not null,								/* ���� */
	changed				datetime			default getdate() not null,		/* ʱ�� */
);
exec sp_primarykey credit_card, no, pccode, cardno
create unique index index1 on credit_card(no, pccode, cardno)
;
INSERT INTO credit_card VALUES ('2000337','911','3301012092134','2038/1/1','HRY',getdate());
INSERT INTO credit_card VALUES ('2000337','912','8937458973345','2038/1/1','HRY',getdate());
