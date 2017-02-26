/*����״̬��Ϣ*/

if exists(select * from sysobjects where name = "sp_plaav" and type ="U")
	  drop table sp_plaav;

create table sp_plaav
(
	menu				char(10)		not null,								/*��ˮ��*/
	inumber			integer		default 0  not null,
	menu1				char(10)		not null,								/*������ص������,�൱������*/
	tag				char(1)		default '' not null,					/*�������,1-��ס����,2-��Ա,3-ֱ������,4-��������*/					
	vipno				char(20)		default '' not null,					/*vipcard_no*/
	vipsno			char(20)		default '' not null,					/*vipcard_sno*/
	cno				char(7)		default '' not null,					/*unit_no*/
	hno				char(7)		default '' not null,					/*guest_no*/
	accnt				char(10)		default '' null,
	guests			money			default 0  null,
	placecode		char(5)		not null,								/*���غ�*/
	empno				char(3)		default '' not null,					/*����Ա*/
	bdate				datetime		not null,								/*����*/
	shift				char(1)		not null,								/*���*/
	sta				char(1)		not null,								/*״̬: R -- Ԥ����O -- ά�ޣ�X -- ȡ��; I -- ����ʹ��;H--ֱ�Ӽ�¼; D -- ����, G -- Ԥ��ת�Ǽ�*/
	sta1				char(1)		not null,								/*״̬: R -- Ԥ����O -- ά�ޣ�X -- ȡ��; I -- ����ʹ��;H--ֱ�Ӽ�¼; D -- ����, G -- Ԥ��ת�Ǽ�*/
	stime				datetime		default	getdate()	not null,	/*��ʼʱ��*/
	etime				datetime		null		,								/*��ֹʱ��*/
	amount			money			default 0   not null,				/*�����*/
	dishtype			char(1)		default 'F' not null,				/*�Ƿ�����־*/
	dnumber			int			default 0   not null,				/*���˺�dish.id,inumber*/	
	packcode			char(10)		default ''  null,
	packid			integer		default 0	null,
	used				money			default 0	not null,				/*�Ǵ�ʹ��*/
	resno				char(10)		default ''	null,
	sp_menu			char(10)		default ''	not null,						/*������*/
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






