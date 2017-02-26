
// guest_cpl  ����Ͷ��
if exists(select * from sysobjects where type ="U" and name = "guest_cpl")
   drop table guest_cpl
;
create table guest_cpl
(
	id						integer			not null,						/* �ؼ��� */
	no						char(7)			default '' not null,			/* ���˺� */
	cusno					char(7)			default '' not null,			/* ��λ�� */
	cusname				varchar(50)		default '' not null,			/* ��λ */
	date					datetime			not null,						/* �������� */
	item					char(3)			not null,						/* ��Ŀ */
	ref					text				null,								/* ��ע */
	amount				money				default 0 not null,			/* �ɱ� */
	tag					char(1)			default '' not null,			/* ��־ */
	saleid				char(10)			not null,						/* ����Ա */

	alert					char(1)			default 'T' not null,			/* ���ѱ�־ */
	dby					varchar(30)		null,								/* ������ */	
	ddate					datetime			null,								/* ����ʱ�� */	
	dref					text				null,								/* ������� */	

	cby					char(10)			not null,						/* �û� */
	changed				datetime			not null,						/* ���� */
	logmark				int				default 0 not null 
);
exec sp_primarykey guest_cpl, id
create unique index index1 on guest_cpl(id)
create index index2 on guest_cpl(no)
create index index3 on guest_cpl(cusno)
;

//
INSERT INTO basecode VALUES (	'guest_cpl_item',	'',	'����',	'All',	'F',	'F',	0,	'',	'F');
INSERT INTO basecode VALUES (	'guest_cpl_item',	'1',	'����',	'Sanitation',	'F',	'F',	10,	'',	'F');
INSERT INTO basecode VALUES (	'guest_cpl_item',	'2',	'����',	'F&B',	'F',	'F',	20,	'',	'F');
INSERT INTO basecode VALUES (	'guest_cpl_item',	'3',	'ǰ̨',	'FO',	'F',	'F',	30,	'',	'F');
INSERT INTO basecode VALUES (	'guest_cpl_item',	'4',	'�ͷ�',	'HSK',	'F',	'F',	40,	'',	'F');
//
insert basecode values ('guest_cpl_tag', '1', '��Ч', 'Valid', 'T', 'F', 10, '',	'F');
insert basecode values ('guest_cpl_tag', '2', '��ȷ��', 'New', 'T', 'F', 20, '',	'F');
insert basecode values ('guest_cpl_tag', '3', '���', 'Finished', 'T', 'F', 30, '',	'F');

//
insert into sysdefault values ('d_gds_guest_cpl_edit', 'item', '1');
insert into sysdefault values ('d_gds_guest_cpl_edit', 'tag', '1');
insert into sysdefault values ('d_gds_guest_cpl_edit', 'alert', 'T');
insert into sysdefault values ('d_gds_guest_cpl_edit', 'date', '#bdate#');
