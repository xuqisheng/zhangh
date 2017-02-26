/* Ԥ�ȶ�����ܾ����ѯ */

if exists(select * from sysobjects where type = 'U' and name = 'info_msgraph')
   drop table info_msgraph;

create table info_msgraph
(
	id				integer			not null,					/*���*/
	descript		varchar(40)		not null,					/*����*/
	descript1	varchar(40)		not null,					/*����*/
	source		char(10)			not null,					/*����Դ*/
	parms			varchar(255)	null,							/*CLASS*/
	legend		char(3)			not null						/*ͼ��*/
)
exec sp_primarykey info_msgraph, id
create unique index index1 on info_msgraph(id)
create unique index index2 on info_msgraph(descript)
;
INSERT INTO info_msgraph VALUES (	0,	'���·�������','���·�������',	'jourrep',	'-D#010180;010190;010200;010210;010220#ƽ����������#����',	'060');
INSERT INTO info_msgraph VALUES (	110,	'�������������','�������������',	'jourrep',	'-D#010080;010090;010100;010110;010120#����������#����',	'070');
INSERT INTO info_msgraph VALUES (	120,	'�����������','�����������',	'jourrep',	'-D#000005;000010;000015;000018;000020#** ���꾻����**��ϸ#����',	'170');
INSERT INTO info_msgraph VALUES (	130,	'������������','������������',	'jourrep',	'-D#000050#���꾻��������#����',	'130');
INSERT INTO info_msgraph VALUES (	310,	'������Դ����','������Դ����',	'mktrep',	'class1#4',	'110');
INSERT INTO info_msgraph VALUES (	320,	'������Դ����(ɢ��)','������Դ����(ɢ��)',	'mktrep',	'A#4',	'110');
INSERT INTO info_msgraph VALUES (	330,	'������Դ����(����)','������Դ����(����)',	'mktrep',	'G#4',	'110');
INSERT INTO info_msgraph VALUES (	410,	'���͹��ɷ���','���͹��ɷ���',	'gststa',	'zt#nw',	'110');
INSERT INTO info_msgraph VALUES (	420,	'���͹��ɷ���(���)','���͹��ɷ���(���)',	'gststa',	'zt#jw',	'110');
INSERT INTO info_msgraph VALUES (	430,	'���͹��ɷ���(����)','���͹��ɷ���(����)',	'gststa',	'zt#jn',	'110');
INSERT INTO info_msgraph VALUES (	440,	'���͹��ɷ���(ʡ��)','���͹��ɷ���(ʡ��)',	'gststa',	'zt#sn',	'110');

/* Ԥ�ȶ����ͼ�� */

if exists(select * from sysobjects where type = 'U' and name = 'info_legend')
   drop table info_legend;

create table info_legend
(
	code			char(3)				not null,					/*ͼ��*/
	descript		varchar(60)			not null,					/*��������*/
	descript1	varchar(60)			not null,					/*Ӣ������*/
	filename		varchar(255)		not null						/*�ļ���*/
)
exec   sp_primarykey info_legend, code
create unique index index1 on info_legend(code)
;

insert info_legend values ( '010', '��Ȼ����ͼ', '��Ȼ����ͼ', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '020', '����ͼ', '����ͼ', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '030', '��״-���ͼ', '��״-���ͼ', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '040', '��������ͼ', '��������ͼ', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '050', '������-��ͼ', '������-��ͼ', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '060', '��-��ͼ', '��-��ͼ', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '070', 'ƽ��ֱ��ͼ', 'ƽ��ֱ��ͼ', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '080', 'Բ׶ͼ', 'Բ׶ͼ', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '090', '����ͼ', '����ͼ', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '100', '��״ͼ', '��״ͼ', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '110', '���ѵı�ͼ', '���ѵı�ͼ', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '120', '��ɫ�ѻ�ͼ', '��ɫ�ѻ�ͼ', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '130', '����ȵ�����ͼ', '����ȵ�����ͼ', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '140', '��ɫ��ͼ', '��ɫ��ͼ', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '150', '����������ͼ', '����������ͼ', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '160', '��ɫ����ͼ', '��ɫ����ͼ', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '170', '��ͼ�������ͼ', '��ͼ�������ͼ', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '180', '�ڰ�����ͼ��ʱ��̶�', '�ڰ�����ͼ��ʱ��̶�', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '190', '�ڰ����ͼ', '�ڰ����ͼ', 'c:\syhis\legend\foxhis.xls')
insert info_legend values ( '200', '�ڰױ�ͼ', '�ڰױ�ͼ', 'c:\syhis\legend\foxhis.xls')
;

/* INFO �ȽϷ���ʱ��� */

if exists(select * from sysobjects where name = 'diff_date')
	drop table diff_date;

create table diff_date
(
	pc_id			char(4)			not null,
	modu_id		char(2)			not null,
	s_date		datetime			not null,
	e_date		datetime			not null,
	t_des			varchar(20)		not null
)
exec sp_primarykey diff_date, pc_id, modu_id, s_date, e_date, t_des
create unique index index1 on diff_date(s_date, pc_id, modu_id, e_date, t_des)
;
/*  */

if exists ( select * from sysobjects where name = 'info_analyze' and type ='U')
	drop table info_analyze;
create table info_analyze
(
	pc_id			char(4)			not null, 
	modu_id		char(2)			not null, 
	date			datetime			not null,
	class			char(8)			not null,
	descriptx	char(16)			null,
	descripty	char(8)			null,
	value			money				default 0 null
)
exec sp_primarykey info_analyze, pc_id, modu_id, date, class
create unique index index1 on info_analyze(pc_id, modu_id, date, class)

/*  */

if exists ( select * from sysobjects where name = 'info_pmsgraph' and type ='U')
	drop table info_pmsgraph;
create table info_pmsgraph
(
	pc_id			char(4)		not null, 
	modu_id		char(2)		not null, 
	date			datetime		not null, 
	descript		char(16)		default '' null, 
	v1				money			default 0 null, 
	v2				money			default 0 null, 
	v3				money			default 0 null, 
	v4				money			default 0 null, 
	v5				money			default 0 null, 
	v6				money			default 0 null, 
	v7				money			default 0 null, 
	v8				money			default 0 null, 
	v9				money			default 0 null, 
	v10			money			default 0 null, 
	v11			money			default 0 null, 
	v12			money			default 0 null, 
	v13			money			default 0 null, 
	v14			money			default 0 null, 
	v15			money			default 0 null, 
	v16			money			default 0 null, 
	v17			money			default 0 null, 
	v18			money			default 0 null, 
	v19			money			default 0 null, 
	v20			money			default 0 null, 
	v21			money			default 0 null, 
	v22			money			default 0 null, 
	v23			money			default 0 null, 
	v24			money			default 0 null, 
	v25			money			default 0 null, 
	v26			money			default 0 null, 
	v27			money			default 0 null, 
	v28			money			default 0 null, 
	v29			money			default 0 null, 
	v30			money			default 0 null, 
	v31			money			default 0 null, 
	v32			money			default 0 null, 
	v33			money			default 0 null, 
	v34			money			default 0 null, 
	v35			money			default 0 null, 
	v36			money			default 0 null, 
	v37			money			default 0 null, 
	v38			money			default 0 null, 
	v39			money			default 0 null, 
	v40			money			default 0 null, 
	vtl			money			default 0 null 
)
exec sp_primarykey info_pmsgraph, pc_id, modu_id, date
create unique index index1 on info_pmsgraph(pc_id, modu_id, date)
;

