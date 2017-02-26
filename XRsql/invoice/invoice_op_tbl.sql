/*��� O����|RԤ��|X����*/
if not exists (select 1 from  basecode_cat  where cat = 'invoice_sta')
	insert basecode_cat(cat,descript,descript1,len) select 'invoice_sta', '��Ʊ���', 'Invoice Sta', 1 
;
delete from basecode where cat = 'invoice_sta'
;
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) 
	select 'invoice_sta', 'O', '����', '����', 'F', 'F', 0, '', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) 
	select 'invoice_sta', 'R', 'Ԥ��', 'Ԥ��', 'F', 'F', 0, '', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) 
	select 'invoice_sta', 'X', '����', '����', 'F', 'F', 0, '', 'F' ,'FOX',getdate() 
;

/*��־ �û��Զ��壬��basecode(invoice_tag) ��ά��,��ѡ*/
if not exists (select 1 from  basecode_cat  where cat = 'invoice_tag')
	insert basecode_cat(cat,descript,descript1,len) select 'invoice_tag', '��Ʊ������־', 'Invoice Op Tag', 10 
;
delete from basecode where cat = 'invoice_tag'
;
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) 
	select 'invoice_tag', 'YK', '�ѿ�δ���ͻ�', '�ѿ�δ���ͻ�', 'F', 'F', 0, '', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) 
	select 'invoice_tag', 'BK', '����', '����', 'F', 'F', 0, '', 'F' ,'FOX',getdate() 
;

/*��Ʊ�� basecode=invoice_place*/
if not exists (select 1 from  basecode_cat  where cat = 'invoice_place')
	insert basecode_cat(cat,descript,descript1,len) select 'invoice_place', '��Ʊ��Ʊ��', 'Invoice Op Place', 10 
;
delete from basecode where cat = 'invoice_place'
;
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) 
	select 'invoice_place', '011', 'ǰ̨-001', 'ǰ̨-001', 'F', 'F', 0, '02', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) 
	select 'invoice_place', '012', 'ǰ̨-002', 'ǰ̨-002', 'F', 'F', 0, '02', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) 
	select 'invoice_place', '021', '����-001', '����-001', 'F', 'F', 0, '06', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) 
	select 'invoice_place', '022', '����-002', '����-002', 'F', 'F', 0, '06', 'F' ,'FOX',getdate() 
;


if not exists(select 1 from sys_extraid where cat='INN')
	insert sys_extraid(cat,descript,id) select 'INN', 'invoice op id', 0
;
update sys_extraid set id = 0 where cat = 'INN'
;

/* ��Ʊ��Ʊ���¼ */
if exists(select * from sysobjects where type = 'U' and name = 'invoice_place')
   drop table invoice_place;

create table invoice_place
(
	pc_id				char(4)			not null,
	invplace			char(10)			not null, /*��Ʊ�� basecode=invoice_place */  
	inno0        	int			 	not null, /*��Ʊ�ţ���ʼ*/
	inno1        	int 				not null, /*��Ʊ�ţ���ֹ*/
	inno        	int 				not null, /*��Ʊ�ţ���ǰ*/
	cby				char(10)				 null,
	changed			datetime				 null,
	logmark			int		default 0 null
)
exec sp_primarykey invoice_place, pc_id
create unique index index1 on invoice_place(pc_id)
;

/* ��Ʊ������¼ */
if exists(select * from sysobjects where type = 'U' and name = 'invoice_op')
   drop table invoice_op;

create table invoice_op
(
	id					varchar(10)		not null,/*��Ʊ��ˮ*/
	sta				char(1)			not null,/*��� ����basecode(invoice_sta) ��ά��,��ѡ   O����|RԤ��|X���� */
	tag				varchar(254)	not null,/*��־ �û��Զ��壬��basecode(invoice_tag) ��ά��,��ѡ*/

	moduno			char(2)			not null,/*Ӫҵ�� basecode=moduno*/
	invplace			char(10)			not null,/*��Ʊ�� basecode=invoice_place */  

	billno			char(10)				 null,/*�÷�Ʊ��Ӧ�Ľ��˵���*/   
	accnt       	char(10)  			 null,/*�÷�Ʊ��Ӧ���˺�*/
	unitno       	char(10)  			 null,/*��Ʊ��λ = guest.no */
	unitname      	varchar(50)  	not null,/*��Ʊ��λ���� = guest.name or free input */


	quantity			int				not null,/*��Ʊ��*/
	billcredit 		money     		not null,/*�÷�Ʊ��Ӧ�Ľ��˽��*/ 
	credit     		money     		not null,/*���*/ 

	empno				varchar(10)		not null,/*�û�*/
	crtdate			datetime 		not null,/*ʱ��*/

	remark			varchar(254)		 null,/*��ע*/

	isaudit			char(1)			not null,/*��˱�� T|F*/
	adtempno			varchar(10)			 null,/*�����*/
	adtdate			datetime				 null,/*���ʱ��*/
	adtinfo			varchar(254)		 null,/*�����Ϣ*/

	haccnt		char(7)		default '' 	 null,	/* ���͵�����  */
	name		   varchar(50)	 				 null,	/* ����: ���� */
	roomno		char(5)		default ''	 null,  	/* ���� */
	arr			datetime	   				 null,	/* ��������=arrival */
	dep			datetime	   				 null,	/* �������=departure */
	rmrate		money			default 0	 null,	/* ���� */
	agent			char(7)		default '' 	 null,	/* ������ */
	cusno			char(7)		default '' 	 null,   /* ��˾ */
	source		char(7)		default '' 	 null,   /* �������� */

	cby			char(10)						null,
	changed		datetime						null,
	logmark		int		default 0		null

)
exec sp_primarykey invoice_op, id
create unique index index1 on invoice_op(id)
;

/* ��Ʊ������¼��ϸ */
if exists(select * from sysobjects where type = 'U' and name = 'invoice_opdtl')
   drop table invoice_opdtl;

create table invoice_opdtl
(
	id					varchar(10)		not null,/*��Ʊ��ˮ*/
	inno        	varchar(16) 	not null, /*��Ʊ��*/
	credit     		money     		not null,/*���*/ 
	remark			varchar(254)		 null,/*��ע*/
	empno				varchar(10)		not null,/*�û�*/
	crtdate			datetime 		not null,/*ʱ��*/
	pc_id				char(4)			not null,

	cby				char(10)						null,
	changed			datetime						null,
	logmark			int		default 0		null
)
exec sp_primarykey invoice_opdtl, inno
create unique index index1 on invoice_opdtl(inno)
;




/* Ȩ�� */
if not exists (select 1 from  sys_function  where fun_des like 'invoice!op%')
begin
	exec p_cyj_add_function 'A','12','invoice!opq','��Ʊ�����ѯ','��Ʊ�����ѯ_e'
	exec p_cyj_add_function 'A','12','invoice!opi','��Ʊ��������','��Ʊ��������_e'
	exec p_cyj_add_function 'A','12','invoice!opu','��Ʊ�����޸�','��Ʊ�����޸�_e'
	exec p_cyj_add_function 'A','12','invoice!opd','��Ʊ����ɾ��','��Ʊ����ɾ��_e'
end
;

