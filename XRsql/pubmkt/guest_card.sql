// 1.
// basecode ----> guestcard_cat

// 2.
// basecode ----> guestcard_lev

// 3. Guest Card Type
if exists(select * from sysobjects where type ="U" and name = "guest_card_type")
   drop table guest_card_type;
create table guest_card_type
(
	code					char(10)								not null,
	descript				varchar(40)		default ''		not null,
	descript1			varchar(40)		default ''		not null,
	cat					char(3)			default ''		not null,
	flag					char(10)			default ''		not null,
	pccodes				varchar(30)		default ''		not null,
	sys					char(1)			default 'F'		not null,
	halt					char(1)			default 'F'		not null,
	remark				varchar(100)						null,
	sequence				int				default 0 		not null
);
exec sp_primarykey guest_card_type, code
create unique index index1 on guest_card_type(code)
;
insert guest_card_type select deptno2, descript, descript1, 'CC','',pccode,'F','F','',0
	from pccode where deptno4 = 'ISC';



// 4.Guest_card
if exists(select * from sysobjects where type ="U" and name = "guest_card")
   drop table guest_card;
create table guest_card
(
	no						char(7)						not null,								/* ���˺� */
	cardcode				char(10)						not null,								/* ���ÿ��� */
	cardno				char(20)		default ''	not null,								/* ���ÿ��� */
	cardlevel			char(3)		default ''	not null,								/* ���� */
	expiry_date			datetime						null,										/* ������Ч�� */
	halt					char(1)		default 'F'	not null,
	cby					char(10)						not null,								/* ���� */
	changed				datetime		default getdate() not null,					/* ʱ�� */
);
exec sp_primarykey guest_card, no, cardcode, cardno
create unique index index1 on guest_card(no, cardcode, cardno)
;


//insert into sysdefault values ('d_gl_guest_card_edit', 'pccode', '500');
//insert into sysdefault values ('d_gl_guest_card_edit', 'cardlevel', '100');
//insert into sysdefault values ('d_gl_guest_card_edit', 'expiry_date', '2005/1/1');
//insert into sysdefault values ('d_gl_guest_card_edit', 'cby', '#empno#');
//insert into sysdefault values ('d_gl_guest_card_edit', 'changed', '#sysdate#');
//