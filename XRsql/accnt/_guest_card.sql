// �������ÿ������
if exists(select * from sysobjects where type ="U" and name = "guest_card")
   drop table guest_card;

create table guest_card
(
	no						char(7)			not null,								/* ���˺� */
	pccode				char(5)			not null,								/* ���ÿ��� */
	cardno				char(20)			not null,								/* ���ÿ��� */
	cardlevel			char(3)			null,										/* ���� */
	expiry_date			datetime			null,										/* ������Ч�� */
	cby					char(10)			not null,								/* ���� */
	changed				datetime			default getdate() not null,		/* ʱ�� */
);
exec sp_primarykey guest_card, no, pccode, cardno
create unique index index1 on guest_card(no, pccode, cardno)
;

insert basecode select 'guest_card', pccode, descript, descript1, 'F','F', convert(integer, substring(pccode, 2, 2) + '0'), ''
	from pccode where deptno4 = 'ISC';
insert basecode select 'guest_card', '500', "Я�̿�", '', 'F','F', 500, '';
insert basecode select 'guest_card', '510', "���Ƶ���֯�����", '', 'F','F', 510, '';

insert basecode select 'cardlevel', '100', "�׽�", '', 'F','F', 100, '';
insert basecode select 'cardlevel', '200', "��", '', 'F','F', 200, '';
insert basecode select 'cardlevel', '300', "����", '', 'F','F', 300, '';

insert into sysdefault values ('d_gl_guest_card_edit', 'pccode', '500');
insert into sysdefault values ('d_gl_guest_card_edit', 'cardlevel', '100');
insert into sysdefault values ('d_gl_guest_card_edit', 'expiry_date', '2005/1/1');
insert into sysdefault values ('d_gl_guest_card_edit', 'cby', '#empno#');
insert into sysdefault values ('d_gl_guest_card_edit', 'changed', '#sysdate#');
