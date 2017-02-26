// ------------------------------------------------------------------------------
// --  auditprg 
// ------------------------------------------------------------------------------
//exec sp_rename auditprg, a_auditprg ;
if exists (select * from sysobjects where name='auditprg' and type='U')
   drop table auditprg;
create table auditprg
(
	exec_order  	int     		default 0		not null,
	prgname     	char(11)		default ''		not null,
	descript    	varchar(60)	default ''		not null,
	descript1    	varchar(60)	default ''		not null,
	callform    	varchar(85)	default ''		not null,
	hasdone     	char(1) 		default 'F'		not null,
	starttime   	datetime							null,
	duration    	int     		default 0		not null,
	pduration   	int     		default 0		not null,
	moduname    	char(2) 		default ''		not null,
	needinst    	char(1) 		default 'T'		not null,
	retotal   		char(1) 		default 'F'		not null,
	decdbf      	varchar(50)	default ''		null
)
exec sp_primarykey auditprg,exec_order
create unique clustered index index1 on auditprg(exec_order);
//
//insert auditprg select exec_order,prgname,descript,descript,callform,hasdone,starttime,duration,pduration,
//	isnull(moduname,''),needinst,retotal,decdbf from a_auditprg;
//drop table a_auditprg;



// ------------------------------------------------------------------------------
//		adtrep
// ------------------------------------------------------------------------------
//exec sp_rename adtrep, a_adtrep;
if exists (select * from sysobjects where name = 'adtrep' and type ='U')
   drop table adtrep;
create table adtrep
(
   order_      int 				default 0		not null,
	descript    varchar(60)  	default ''		not null,
	descript1   varchar(60)  	default ''		not null,
   callform    varchar(140) 	default ''		not null,
	prtno       int 				default 0		not null,
	prtno1      int 				default 0		not null,
	parms       text									null,
   withhis     char(1) 			default 'F' 	not null,
   wpaper      char(1) 			default 'F' 	not null,
   allowmodus  varchar(90) 	default '99#' 	not null ,
	needinst    char(1) 			default 'F' 	not null,
	instready   char(1) 			default 'F' 	not null,
)
exec sp_primarykey adtrep,order_
create unique index index1 on adtrep(order_);
//
//insert adtrep select order_,repname,rtrim(repname)+'_eng',callform,prtno,prtno1,parms,withhis,wpaper,allowmodus,needinst,
//instready from a_adtrep;
//
//select * from adtrep;



// ------------------------------------------------------------------------------
// ����Ĳ��ű���
// ------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "auto_dept")
	drop table auto_dept;
create table auto_dept
(
	code			char(10)				not null,  // ���--���ʮ��
   descript		varchar(30)     	not null,  // ��ʶ
   descript1	varchar(30)     	not null,  // ��ʶ
	sys			char(1)	default 'F'	not null,
	halt			char(1)	default 'F'	not null,
	sequence		int		default 0	not null
)
exec sp_primarykey auto_dept,code
create unique index index1 on auto_dept(code)
create index index2 on auto_dept(descript)
create index index3 on auto_dept(descript1)
;


// ------------------------------------------------------------------------------
// �����¼
// ------------------------------------------------------------------------------
//exec sp_rename auto_report, a_auto_report;
if exists(select * from sysobjects where name = "auto_report")
	drop table auto_report;
create table auto_report
(
	dept			char(10)			default 'A'	not null,			// ���--���ʮ��
	wtype			char(3)			default 'tab' not null,			// ��������: tab, grf, crs
	id				char(30)			not null,							// ��ʶ
	rid			char(30)			default '' not null,				// ������
	descript		char(60)			not null,							// ����
	descript1	char(60)			not null,							// ����
	remark		varchar(255)	default '' not null,				// ��Ҫ˵��
	allowmodus	varchar(90)		null,
	orientation	char(1)			default "0" not null,			// �ݴ򡢺��
	source		text				not null,							// �������ݶ���
	condition	text				not null,							// �����������ݴ��ڶ���
	lic_buy		char(20)			default "" not null,				// ��������ϵͳģ��
	sys			char(1)			default "F" not null,			// ϵͳ����?
	halt			char(1)			default "F" not null,			// ��Ч?
	crby			char(10)			default "" not null,				// ��������
	crdate		datetime			default getdate() not null,	// ������ʱ��
	expby			char(10)			default "" not null,				// �����޸���
	expdate		datetime			default getdate() not null,	// �����޸�ʱ��
)
exec sp_primarykey auto_report,id
create unique index index1 on auto_report(id)
create index index2 on auto_report(descript)
create index index3 on auto_report(descript1)
;
//
//insert auto_report select dept, wtype, id, title, rtrim(title)+'_eng', allowmodus, source from a_auto_report;
//drop table a_auto_report;
//

// ------------------------------------------------------------------------------
// �������� 						--  GaoLiang 2005/06/02
// ------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "auto_batch")
	drop table auto_batch;
create table auto_batch
(
	code			char(10)			not null,							// ����
	descript		varchar(60)		not null,							// ���ı���
	descript1	varchar(60)		not null,							// Ӣ�ı���
	condition	text				not null,							// �����������ݴ��ڶ���
	sys			char(1)			default "F" not null,			// ϵͳ����?
	halt			char(1)			default "F" not null,			// ��Ч?
	cby			char(10)			default "" not null,				// �޸���
	changed		datetime			default getdate() not null,	// �޸�ʱ��
)
exec sp_primarykey auto_batch, code
create unique index index1 on auto_batch(code)
;
//insert auto_batch select code,descript, descript1, '', 'T', 'F', 'FOX', getdate()
//	from basecode where cat = 'adtrep';

// ------------------------------------------------------------------------------
// �ҵı���(My Reports)��¼	--  GaoLiang 2005/05/26
// ------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "auto_empno")
	drop table auto_empno;
create table auto_empno
(
	empno			char(10)			not null,							// �û���
	id				char(30)			not null,							// �����ʶ
	prtno       integer			default 0 not null,				// Ԥ�����
	prtno1      integer			default 0 not null,				// ��ӡ����
	cby			char(10)			default "" not null,				// �޸���
	changed		datetime			default getdate() not null,	// �޸�ʱ��
)
exec sp_primarykey auto_empno, empno, id
create unique index index1 on auto_empno(empno, id)
;

//insert sys_function values ('0015', '00', '������������', '������������_e', 'repdef!batch');	
//insert auto_report select 'A', 'tab', 'rep!' + ltrim(convert(char(10), order_)), '', descript, descript1, '','02',
//	'dataobject:' + rtrim(callform) + ';' + convert(char(255), parms), '', '', 'T', 'F', 'GL', getdate(), 'GL', getdate()
//	from adtrep where callform like 'd_%';
//insert auto_report select 'A', 'tab', 'rep!' + ltrim(convert(char(10), order_)), '', descript, descript1, '','02',
//	rtrim(callform) + '(' + rtrim(convert(char(255), parms)) + ')', '', '', 'T', 'F', 'GL', getdate(), 'GL', getdate()
//	from adtrep where callform like 'f_%';
