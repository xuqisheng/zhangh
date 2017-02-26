// guest_diary�����
if exists(select * from sysobjects where type ="U" and name = "guest_diary")
   drop table guest_diary;

create table guest_diary
(
	id						integer			not null,						/* �ؼ��� */
	no						char(7)			default '' not null,			/* ���˺� */
	cusno					char(7)			default '' not null,			/* ��λ�� */
	date					datetime			not null,						/* ���� */
	item					char(3)			not null,						/* ��Ŀ */
	ref					text				null,								/* ��ע */
	amount				money				default 0 not null,			/* �ɱ� */
	tag					char(1)			default '' not null,			/* ��־ */
	saleid				char(10)			not null,						/* ����Ա */
	cby					char(10)			not null,						/* �û� */
	changed				datetime			not null							/* ���� */
);
exec sp_primarykey guest_diary, id
create unique index index1 on guest_diary(id)
create index index2 on guest_diary(no)
create index index3 on guest_diary(cusno)
;
//insert guest_diary select '2000337','2000/12/11', '100', '2000/12/11 -- 2000/12/15��ס���Ƶ�1608���䣬�ϼ�����1206.5Ԫ', '', '', 'HRY', '2000/12/15 11:34:23'
//insert guest_diary select '2000337','2001/02/22', '100', '2001/02/22 -- 2001/02/23��ס���Ƶ�1709���䣬�ϼ�����435.8Ԫ', '', '', 'HRY', '2001/02/23 10:31:12'
//insert guest_diary select '2000337','2002/01/20', '200', '���۲���Ң�绰�ݷ�', '', 'HRY', '2002/01/21 12:00:00'
//insert guest_diary select '2000337','2002/09/16', '110', '�ͻ���绰��ѯ�����ڼ�ķ���, ���ܴ����м��ϸ�20%', '', '', 'HRY', '2002/09/16 12:00:00'
//insert guest_diary select '2000337','2003/05/20', '100', '2003/05/20 -- 2003/05/22��ס���Ƶ�1709���䣬�ϼ�����688Ԫ', '', '', 'HRY', '2003/05/20 09:13:31'
//;
//
insert basecode values ('guest_diary_item', '', '����', '', 'T', 'F', 10, '');
insert basecode values ('guest_diary_item', '100', '�绰��ϵ', '', 'T', 'F', 20, '');
insert basecode values ('guest_diary_item', '200', '���Űݷ�', '', 'T', 'F', 30, '');
//
insert basecode values ('guest_diary_tag', '1', '��Ч', '', 'T', 'F', 10, '');
insert basecode values ('guest_diary_tag', '2', '��ȷ��', '', 'T', 'F', 20, '');
//
insert into sysdefault values ('d_gl_guest_diary_edit', 'item', '100');
insert into sysdefault values ('d_gl_guest_diary_edit', 'tag', '1');
insert into sysdefault values ('d_gl_guest_diary_edit', 'date', '#bdate#');
