// guest_diary定义表
if exists(select * from sysobjects where type ="U" and name = "guest_diary")
   drop table guest_diary;

create table guest_diary
(
	id						integer			not null,						/* 关键字 */
	no						char(7)			default '' not null,			/* 客人号 */
	cusno					char(7)			default '' not null,			/* 单位号 */
	date					datetime			not null,						/* 日期 */
	item					char(3)			not null,						/* 项目 */
	ref					text				null,								/* 备注 */
	amount				money				default 0 not null,			/* 成本 */
	tag					char(1)			default '' not null,			/* 标志 */
	saleid				char(10)			not null,						/* 销售员 */
	cby					char(10)			not null,						/* 用户 */
	changed				datetime			not null							/* 日期 */
);
exec sp_primarykey guest_diary, id
create unique index index1 on guest_diary(id)
create index index2 on guest_diary(no)
create index index3 on guest_diary(cusno)
;
//insert guest_diary select '2000337','2000/12/11', '100', '2000/12/11 -- 2000/12/15入住本酒店1608房间，合计消费1206.5元', '', '', 'HRY', '2000/12/15 11:34:23'
//insert guest_diary select '2000337','2001/02/22', '100', '2001/02/22 -- 2001/02/23入住本酒店1709房间，合计消费435.8元', '', '', 'HRY', '2001/02/23 10:31:12'
//insert guest_diary select '2000337','2002/01/20', '200', '销售部王尧电话拜访', '', 'HRY', '2002/01/21 12:00:00'
//insert guest_diary select '2000337','2002/09/16', '110', '客户打电话咨询国庆期间的房价, 马俊杰答复门市价上浮20%', '', '', 'HRY', '2002/09/16 12:00:00'
//insert guest_diary select '2000337','2003/05/20', '100', '2003/05/20 -- 2003/05/22入住本酒店1709房间，合计消费688元', '', '', 'HRY', '2003/05/20 09:13:31'
//;
//
insert basecode values ('guest_diary_item', '', '所有', '', 'T', 'F', 10, '');
insert basecode values ('guest_diary_item', '100', '电话联系', '', 'T', 'F', 20, '');
insert basecode values ('guest_diary_item', '200', '上门拜访', '', 'T', 'F', 30, '');
//
insert basecode values ('guest_diary_tag', '1', '有效', '', 'T', 'F', 10, '');
insert basecode values ('guest_diary_tag', '2', '待确认', '', 'T', 'F', 20, '');
//
insert into sysdefault values ('d_gl_guest_diary_edit', 'item', '100');
insert into sysdefault values ('d_gl_guest_diary_edit', 'tag', '1');
insert into sysdefault values ('d_gl_guest_diary_edit', 'date', '#bdate#');
