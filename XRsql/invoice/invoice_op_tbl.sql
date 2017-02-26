/*类别 O结账|R预开|X作废*/
if not exists (select 1 from  basecode_cat  where cat = 'invoice_sta')
	insert basecode_cat(cat,descript,descript1,len) select 'invoice_sta', '发票类别', 'Invoice Sta', 1 
;
delete from basecode where cat = 'invoice_sta'
;
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) 
	select 'invoice_sta', 'O', '结账', '结账', 'F', 'F', 0, '', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) 
	select 'invoice_sta', 'R', '预开', '预开', 'F', 'F', 0, '', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) 
	select 'invoice_sta', 'X', '作废', '作废', 'F', 'F', 0, '', 'F' ,'FOX',getdate() 
;

/*标志 用户自定义，在basecode(invoice_tag) 中维护,多选*/
if not exists (select 1 from  basecode_cat  where cat = 'invoice_tag')
	insert basecode_cat(cat,descript,descript1,len) select 'invoice_tag', '发票操作标志', 'Invoice Op Tag', 10 
;
delete from basecode where cat = 'invoice_tag'
;
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) 
	select 'invoice_tag', 'YK', '已开未给客户', '已开未给客户', 'F', 'F', 0, '', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) 
	select 'invoice_tag', 'BK', '补开', '补开', 'F', 'F', 0, '', 'F' ,'FOX',getdate() 
;

/*开票点 basecode=invoice_place*/
if not exists (select 1 from  basecode_cat  where cat = 'invoice_place')
	insert basecode_cat(cat,descript,descript1,len) select 'invoice_place', '发票开票点', 'Invoice Op Place', 10 
;
delete from basecode where cat = 'invoice_place'
;
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) 
	select 'invoice_place', '011', '前台-001', '前台-001', 'F', 'F', 0, '02', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) 
	select 'invoice_place', '012', '前台-002', '前台-002', 'F', 'F', 0, '02', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) 
	select 'invoice_place', '021', '商务-001', '商务-001', 'F', 'F', 0, '06', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) 
	select 'invoice_place', '022', '商务-002', '商务-002', 'F', 'F', 0, '06', 'F' ,'FOX',getdate() 
;


if not exists(select 1 from sys_extraid where cat='INN')
	insert sys_extraid(cat,descript,id) select 'INN', 'invoice op id', 0
;
update sys_extraid set id = 0 where cat = 'INN'
;

/* 发票开票点记录 */
if exists(select * from sysobjects where type = 'U' and name = 'invoice_place')
   drop table invoice_place;

create table invoice_place
(
	pc_id				char(4)			not null,
	invplace			char(10)			not null, /*开票点 basecode=invoice_place */  
	inno0        	int			 	not null, /*发票号：起始*/
	inno1        	int 				not null, /*发票号：终止*/
	inno        	int 				not null, /*发票号：当前*/
	cby				char(10)				 null,
	changed			datetime				 null,
	logmark			int		default 0 null
)
exec sp_primarykey invoice_place, pc_id
create unique index index1 on invoice_place(pc_id)
;

/* 发票操作记录 */
if exists(select * from sysobjects where type = 'U' and name = 'invoice_op')
   drop table invoice_op;

create table invoice_op
(
	id					varchar(10)		not null,/*发票流水*/
	sta				char(1)			not null,/*类别 ，在basecode(invoice_sta) 中维护,单选   O结账|R预开|X作废 */
	tag				varchar(254)	not null,/*标志 用户自定义，在basecode(invoice_tag) 中维护,多选*/

	moduno			char(2)			not null,/*营业点 basecode=moduno*/
	invplace			char(10)			not null,/*开票点 basecode=invoice_place */  

	billno			char(10)				 null,/*该发票对应的结账单号*/   
	accnt       	char(10)  			 null,/*该发票对应的账号*/
	unitno       	char(10)  			 null,/*开票单位 = guest.no */
	unitname      	varchar(50)  	not null,/*开票单位名称 = guest.name or free input */


	quantity			int				not null,/*发票数*/
	billcredit 		money     		not null,/*该发票对应的结账金额*/ 
	credit     		money     		not null,/*金额*/ 

	empno				varchar(10)		not null,/*用户*/
	crtdate			datetime 		not null,/*时间*/

	remark			varchar(254)		 null,/*备注*/

	isaudit			char(1)			not null,/*审核标记 T|F*/
	adtempno			varchar(10)			 null,/*审核人*/
	adtdate			datetime				 null,/*审核时间*/
	adtinfo			varchar(254)		 null,/*审核信息*/

	haccnt		char(7)		default '' 	 null,	/* 宾客档案号  */
	name		   varchar(50)	 				 null,	/* 姓名: 本名 */
	roomno		char(5)		default ''	 null,  	/* 房号 */
	arr			datetime	   				 null,	/* 到店日期=arrival */
	dep			datetime	   				 null,	/* 离店日期=departure */
	rmrate		money			default 0	 null,	/* 房价 */
	agent			char(7)		default '' 	 null,	/* 旅行社 */
	cusno			char(7)		default '' 	 null,   /* 公司 */
	source		char(7)		default '' 	 null,   /* 订房中心 */

	cby			char(10)						null,
	changed		datetime						null,
	logmark		int		default 0		null

)
exec sp_primarykey invoice_op, id
create unique index index1 on invoice_op(id)
;

/* 发票操作记录明细 */
if exists(select * from sysobjects where type = 'U' and name = 'invoice_opdtl')
   drop table invoice_opdtl;

create table invoice_opdtl
(
	id					varchar(10)		not null,/*发票流水*/
	inno        	varchar(16) 	not null, /*发票号*/
	credit     		money     		not null,/*金额*/ 
	remark			varchar(254)		 null,/*备注*/
	empno				varchar(10)		not null,/*用户*/
	crtdate			datetime 		not null,/*时间*/
	pc_id				char(4)			not null,

	cby				char(10)						null,
	changed			datetime						null,
	logmark			int		default 0		null
)
exec sp_primarykey invoice_opdtl, inno
create unique index index1 on invoice_opdtl(inno)
;




/* 权限 */
if not exists (select 1 from  sys_function  where fun_des like 'invoice!op%')
begin
	exec p_cyj_add_function 'A','12','invoice!opq','发票处理查询','发票处理查询_e'
	exec p_cyj_add_function 'A','12','invoice!opi','发票处理增加','发票处理增加_e'
	exec p_cyj_add_function 'A','12','invoice!opu','发票处理修改','发票处理修改_e'
	exec p_cyj_add_function 'A','12','invoice!opd','发票处理删除','发票处理删除_e'
end
;

