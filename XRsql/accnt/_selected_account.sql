/* 记录需要一起处理的账号或账务(临时) */

if exists(select * from sysobjects where type ="U" and name = "selected_account")
   drop table selected_account;

create table selected_account
(
	type			char(1)		not null,	/* 类型	1.明细账目查询专用
																2.需要一起处理的账号(结账,部分结账等)
																3.post_charge专用
																4.rmpost专用
																5.需要一起打印账单的账号
																6.需要一起处理的信用卡单号(部分结账) 
																s.短信
																d.门卡发行
																g.前台状态处理，fit-mem 
																m.团体成员批量处理 
																s.同住处理
																c.佣金处理
*/
	pc_id			char(4)		not null,	/* IP地址 */
	mdi_id		integer		not null,	/* 账务处理窗口的ID号 */
	accnt			char(10)		not null,	/* 账号 */
	number		integer		not null		/* 账次 */
)
exec   sp_primarykey selected_account, type, pc_id, mdi_id, accnt, number
create unique index index1 on selected_account(type, pc_id, mdi_id, accnt, number)
;
