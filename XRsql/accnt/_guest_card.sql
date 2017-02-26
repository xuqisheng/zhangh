// 客人信用卡定义表
if exists(select * from sysobjects where type ="U" and name = "guest_card")
   drop table guest_card;

create table guest_card
(
	no						char(7)			not null,								/* 客人号 */
	pccode				char(5)			not null,								/* 信用卡型 */
	cardno				char(20)			not null,								/* 信用卡号 */
	cardlevel			char(3)			null,										/* 级别 */
	expiry_date			datetime			null,										/* 信用有效期 */
	cby					char(10)			not null,								/* 工号 */
	changed				datetime			default getdate() not null,		/* 时间 */
);
exec sp_primarykey guest_card, no, pccode, cardno
create unique index index1 on guest_card(no, pccode, cardno)
;

insert basecode select 'guest_card', pccode, descript, descript1, 'F','F', convert(integer, substring(pccode, 2, 2) + '0'), ''
	from pccode where deptno4 = 'ISC';
insert basecode select 'guest_card', '500', "携程卡", '', 'F','F', 500, '';
insert basecode select 'guest_card', '510', "名酒店组织贵宾卡", '', 'F','F', 510, '';

insert basecode select 'cardlevel', '100', "白金卡", '', 'F','F', 100, '';
insert basecode select 'cardlevel', '200', "金卡", '', 'F','F', 200, '';
insert basecode select 'cardlevel', '300', "银卡", '', 'F','F', 300, '';

insert into sysdefault values ('d_gl_guest_card_edit', 'pccode', '500');
insert into sysdefault values ('d_gl_guest_card_edit', 'cardlevel', '100');
insert into sysdefault values ('d_gl_guest_card_edit', 'expiry_date', '2005/1/1');
insert into sysdefault values ('d_gl_guest_card_edit', 'cby', '#empno#');
insert into sysdefault values ('d_gl_guest_card_edit', 'changed', '#sysdate#');
