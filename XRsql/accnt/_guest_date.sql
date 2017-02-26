// ���˼����ն����
if exists(select * from sysobjects where type ="U" and name = "guest_date")
   drop table guest_date;

create table guest_date
(
	no						char(7)			not null,								/* ���˺� */
	type					char(3)			not null,								/* ���� */
	date					datetime			not null,								/* ������ */
	ref					varchar(30)		null,										/* ��ע */
	cby					char(10)			not null,								/* ���� */
	changed				datetime			default getdate() not null,		/* ʱ�� */
);
exec sp_primarykey guest_date, no, type, date
create unique index index1 on guest_date(no, type, date)
;

INSERT INTO basecode VALUES ('guest_date','100','����','Birthday','F','F',100,'');
INSERT INTO basecode VALUES ('guest_date','200','�������','Birthday','F','F',100,'');

insert into sysdefault values ('d_gl_guest_date_edit', 'type', '100');
insert into sysdefault values ('d_gl_guest_date_edit', 'date', '#bdate#');
insert into sysdefault values ('d_gl_guest_date_edit', 'cby', '#empno#');
insert into sysdefault values ('d_gl_guest_date_edit', 'changed', '#sysdate#');
