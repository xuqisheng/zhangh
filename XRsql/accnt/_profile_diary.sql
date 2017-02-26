// profile_diary定义表
if exists(select * from sysobjects where type ="U" and name = "profile_diary")
   drop table profile_diary;

create table profile_diary
(
	no						char(7)			not null,						/*  */
	date					datetime			not null,						/* 日期 */
	item					char(3)			not null,						/* 项目 */
	ref					char(255)		null,								/* 备注 */
	tag					char(1)			default '' not null,			/* 标志 */
	cby					char(10)			not null,						/* 用户 */
	changed				datetime			not null							/* 日期 */
);
exec sp_primarykey profile_diary, no, date
create unique index index1 on profile_diary(no, date)
;
insert profile_diary select '2000337','2000/12/11', '100', '2000/12/11 -- 2000/12/15入住本酒店1608房间，合计消费1206.5元', '', 'HRY', '2000/12/15 11:34:23'
insert profile_diary select '2000337','2001/02/22', '100', '2001/02/22 -- 2001/02/23入住本酒店1709房间，合计消费435.8元', '', 'HRY', '2001/02/23 10:31:12'
insert profile_diary select '2000337','2002/01/20', '200', '销售部王尧电话拜访', '', 'HRY', '2002/01/21 12:00:00'
insert profile_diary select '2000337','2002/09/16', '110', '客户打电话咨询国庆期间的房价, 马俊杰答复门市价上浮20%', '', 'HRY', '2002/09/16 12:00:00'
insert profile_diary select '2000337','2003/05/20', '100', '2003/05/20 -- 2003/05/22入住本酒店1709房间，合计消费688元', '', 'HRY', '2003/05/20 09:13:31'
;

