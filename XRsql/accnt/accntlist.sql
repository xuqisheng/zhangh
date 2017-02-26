/* 记录需要一起处理的账号或账务(临时) */

if exists(select * from sysobjects where type ="U" and name = "selected_account")
   drop table selected_account;

create table selected_account
(
	type			char(1)		not null,							/* 类型	1.明细账目查询专用
																						2.需要一起处理的账号(结账,部分结账等)
																						3.post_charge专用
																						4.rmpost专用
																						5.需要一起打印账单的账号
																						6.需要一起处理的信用卡单号(部分结账) */
	pc_id			char(4)		not null,							/* IP地址 */
	mdi_id		integer		not null,							/* 账务处理窗口的ID号 */
	accnt			char(10)		not null,							/* 账号 */
	number		integer		not null								/* 账次 */
)
exec   sp_primarykey selected_account, type, pc_id, mdi_id, accnt, number
create unique index index1 on selected_account(type, pc_id, mdi_id, accnt, number)
;

if exists(select * from sysobjects where name = "accnt_set")
   drop table accnt_set;

create table accnt_set
(
	pc_id				char(4)			not null,					/* IP地址 */
	mdi_id			integer			not null,					/* 序号 */
	roomno			char(5)			not null,					/* 房号 */
	accnt				char(10)			not null,					/* 账号 */
	subaccnt			integer			not null,					/* 子账号 */
	haccnt			char(7)			not null,					/* 历史档案号 */
	name				char(50)			not null,					/* 描述 */
	sta				char(3)			not null,					/* 账户状态 */
	charge			money				not null,					/* 消费 */
	credit			money				not null,					/* 预付 */
	tree_level		integer			default 0 not null,		/* 状态 */
	tree_children	char(1)			not null,					/* */
	tree_picture	char(1)			not null,					/* 图标序号 */
	tag				char(1)			not null,					/* 显示状态 */
	csta				integer			default 0 not null		/* 临时使用 */
)
exec   sp_primarykey accnt_set, pc_id, mdi_id, roomno, accnt, subaccnt
create unique index index1 on accnt_set(pc_id, mdi_id, roomno, accnt, subaccnt)
;

// 临时账夹中的明细账务
if exists(select * from sysobjects where name = "account_folder")
   drop table account_folder;

create table account_folder
(
	pc_id				char(4)			not null,					/*IP地址*/
	mdi_id			integer			not null,					/*序号*/
	folder			integer			not null,					/*临时账夹的编号*/
	accnt				char(10)			not null,					/*账号*/
	number			integer			not null						/*账次*/
)
exec   sp_primarykey account_folder, pc_id, mdi_id, folder, accnt, number
create unique index index1 on account_folder(pc_id, mdi_id, folder, accnt, number)
;

// 临时中间表，用来存放当前账夹中的明细账务；由p_gl_accnt_list_account生成，p_gl_accnt_subtotal接着使用
if exists(select * from sysobjects where name = "account_temp")
   drop table account_temp;

create table account_temp
(
	pc_id				char(4)			not null,					/*IP地址*/
	mdi_id			integer			not null,					/*序号*/
	accnt				char(10)			not null,					/*账号*/
	number			integer			not null,					/*账次*/
	mode1				char(10)			default '' not null,		/*转帐单号*/
	billno			char(10)			default '' not null,		/*结账单号*/
	selected			integer			default 0 not null,		/*选择标志*/
	charge			money				default 0 not null,		/**/
	credit			money				default 0 not null		/**/
)
exec   sp_primarykey account_temp, pc_id, mdi_id, accnt, number
create unique index index1 on account_temp(pc_id, mdi_id, accnt, number)
create index index2 on account_temp(pc_id, mdi_id, selected)
;

// 临时中间表，用来存放转帐格式的明细账务；由p_gl_accnt_list_account_ar生成，p_gl_accnt_subtotal_ar接着使用
if exists(select * from sysobjects where name = "account_ar")
   drop table account_ar;

create table account_ar
(
	pc_id				char(4)			not null,					/*IP地址*/
	mdi_id			integer			not null,					/*序号*/
	sta				char(1)			null,
	accnt				char(10)			default ''	null,			/*账号*/
	number			integer			default 0	null,			/*账次*/
	fmaccnt			char(10)			default ''	null,			/*转帐的账号*/
	fmroomno			char(5)			default ''	null,			/*转帐的房号*/
	modu_id			char(2)			default ''	null,
	pccode			char(5)			default ''	null,
	charge			money				default 0	null,
	credit			money				default 0	null,
	amount			money				default 0	null,
	amount1			money				default 0	null,
	ref				char(24)			null,
	ref1				char(10)			null,							/*转帐的billno*/
	ref2				char(50)			null,
	bdate				datetime			default getdate() null,
	log_date			datetime			default getdate() null,
	shift				char(1)			default ''	null,
	empno				char(10)			default ''	null,
	billno			char(10)			null
)
create index index1 on account_ar(pc_id, mdi_id, accnt, number)
create index index2 on account_ar(pc_id, mdi_id, fmaccnt)
;
