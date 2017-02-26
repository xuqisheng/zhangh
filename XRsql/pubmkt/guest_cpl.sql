
// guest_cpl  宾客投诉
if exists(select * from sysobjects where type ="U" and name = "guest_cpl")
   drop table guest_cpl
;
create table guest_cpl
(
	id						integer			not null,						/* 关键字 */
	no						char(7)			default '' not null,			/* 客人号 */
	cusno					char(7)			default '' not null,			/* 单位号 */
	cusname				varchar(50)		default '' not null,			/* 单位 */
	date					datetime			not null,						/* 发生日期 */
	item					char(3)			not null,						/* 项目 */
	ref					text				null,								/* 备注 */
	amount				money				default 0 not null,			/* 成本 */
	tag					char(1)			default '' not null,			/* 标志 */
	saleid				char(10)			not null,						/* 销售员 */

	alert					char(1)			default 'T' not null,			/* 提醒标志 */
	dby					varchar(30)		null,								/* 处理人 */	
	ddate					datetime			null,								/* 处理时间 */	
	dref					text				null,								/* 处理情况 */	

	cby					char(10)			not null,						/* 用户 */
	changed				datetime			not null,						/* 日期 */
	logmark				int				default 0 not null 
);
exec sp_primarykey guest_cpl, id
create unique index index1 on guest_cpl(id)
create index index2 on guest_cpl(no)
create index index3 on guest_cpl(cusno)
;

//
INSERT INTO basecode VALUES (	'guest_cpl_item',	'',	'所有',	'All',	'F',	'F',	0,	'',	'F');
INSERT INTO basecode VALUES (	'guest_cpl_item',	'1',	'卫生',	'Sanitation',	'F',	'F',	10,	'',	'F');
INSERT INTO basecode VALUES (	'guest_cpl_item',	'2',	'餐饮',	'F&B',	'F',	'F',	20,	'',	'F');
INSERT INTO basecode VALUES (	'guest_cpl_item',	'3',	'前台',	'FO',	'F',	'F',	30,	'',	'F');
INSERT INTO basecode VALUES (	'guest_cpl_item',	'4',	'客房',	'HSK',	'F',	'F',	40,	'',	'F');
//
insert basecode values ('guest_cpl_tag', '1', '有效', 'Valid', 'T', 'F', 10, '',	'F');
insert basecode values ('guest_cpl_tag', '2', '待确认', 'New', 'T', 'F', 20, '',	'F');
insert basecode values ('guest_cpl_tag', '3', '完成', 'Finished', 'T', 'F', 30, '',	'F');

//
insert into sysdefault values ('d_gds_guest_cpl_edit', 'item', '1');
insert into sysdefault values ('d_gds_guest_cpl_edit', 'tag', '1');
insert into sysdefault values ('d_gds_guest_cpl_edit', 'alert', 'T');
insert into sysdefault values ('d_gds_guest_cpl_edit', 'date', '#bdate#');
