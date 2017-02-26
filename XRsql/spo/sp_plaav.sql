/*场地状态信息*/

if exists(select * from sysobjects where name = "sp_plaav" and type ="U")
	  drop table sp_plaav;

create table sp_plaav
(
	menu				char(10)		not null,								/*流水号*/
	inumber			integer		default 0  not null,
	menu1				char(10)		not null,								/*多个场地的联结号,相当于联单*/
	tag				char(1)		default '' not null,					/*客人类别,1-在住客人,2-会员,3-直接上门,4-其他客人*/					
	vipno				char(20)		default '' not null,					/*vipcard_no*/
	vipsno			char(20)		default '' not null,					/*vipcard_sno*/
	cno				char(7)		default '' not null,					/*unit_no*/
	hno				char(7)		default '' not null,					/*guest_no*/
	accnt				char(10)		default '' null,
	guests			money			default 0  null,
	placecode		char(5)		not null,								/*场地号*/
	empno				char(3)		default '' not null,					/*服务员*/
	bdate				datetime		not null,								/*日期*/
	shift				char(1)		not null,								/*班号*/
	sta				char(1)		not null,								/*状态: R -- 预定；O -- 维修；X -- 取消; I -- 开单使用;H--直接记录; D -- 结束, G -- 预定转登记*/
	sta1				char(1)		not null,								/*状态: R -- 预定；O -- 维修；X -- 取消; I -- 开单使用;H--直接记录; D -- 结束, G -- 预定转登记*/
	stime				datetime		default	getdate()	not null,	/*开始时间*/
	etime				datetime		null		,								/*截止时间*/
	amount			money			default 0   not null,				/*场租费*/
	dishtype			char(1)		default 'F' not null,				/*是否结算标志*/
	dnumber			int			default 0   not null,				/*入账后dish.id,inumber*/	
	packcode			char(10)		default ''  null,
	packid			integer		default 0	null,
	used				money			default 0	not null,				/*记次使用*/
	resno				char(10)		default ''	null,
	sp_menu			char(10)		default ''	not null,						/*主单号*/
	logdate			datetime		null,
	remark			char(255)	null
)
exec sp_primarykey sp_plaav, menu, placecode, inumber
create unique index index1 on sp_plaav(menu, inumber)
;
if exists(select * from sysobjects where name = "sp_hplaav" and type ="U")
	  drop table sp_hplaav;
select * into sp_hplaav from sp_plaav where 1=2;
create unique index index1 on sp_hplaav(menu, inumber)
;

if exists(select 1 from sysobjects where name = 't_sp_plaav_insert')
	drop trigger t_sp_plaav_insert
;

create trigger t_sp_plaav_insert
on sp_plaav for insert
as
declare 
	@menu			char(20),
	@inumber		integer,
	@placecode  char(5)

if not exists(select 1 from table_update where tbname= 'sp_plaav')
	insert table_update select 'sp_plaav',getdate()
update table_update set update_date = getdate() where tbname= 'sp_plaav'
;


if exists(select 1 from sysobjects where name = 't_sp_plaav_update')
	drop trigger t_sp_plaav_update
;

create trigger t_sp_plaav_update
on sp_plaav for update
as
declare 
	@menu			char(20),
	@inumber		integer,
	@placecode  char(5)

if not exists(select 1 from table_update where tbname= 'sp_plaav')
	insert table_update select 'sp_plaav',getdate()
if update(sta)	
	update table_update set update_date = getdate() where tbname= 'sp_plaav'
;






