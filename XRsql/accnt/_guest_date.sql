// 客人纪念日定义表
if exists(select * from sysobjects where type ="U" and name = "guest_date")
   drop table guest_date;

create table guest_date
(
	no						char(7)			not null,								/* 客人号 */
	type					char(3)			not null,								/* 类型 */
	date					datetime			not null,								/* 纪念日 */
	ref					varchar(30)		null,										/* 备注 */
	cby					char(10)			not null,								/* 工号 */
	changed				datetime			default getdate() not null,		/* 时间 */
);
exec sp_primarykey guest_date, no, type, date
create unique index index1 on guest_date(no, type, date)
;

INSERT INTO basecode VALUES ('guest_date','100','生日','Birthday','F','F',100,'');
INSERT INTO basecode VALUES ('guest_date','200','周年店庆','Birthday','F','F',100,'');

insert into sysdefault values ('d_gl_guest_date_edit', 'type', '100');
insert into sysdefault values ('d_gl_guest_date_edit', 'date', '#bdate#');
insert into sysdefault values ('d_gl_guest_date_edit', 'cby', '#empno#');
insert into sysdefault values ('d_gl_guest_date_edit', 'changed', '#sysdate#');
