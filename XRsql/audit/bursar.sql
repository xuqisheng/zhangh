-- --------------------------------------------------------------------------
--  basecode : bursar_kind  �����¼���
-- --------------------------------------------------------------------------
delete basecode where cat='bursar_kind';
delete basecode_cat where cat='bursar_kind';
insert basecode_cat(cat,descript,descript1,len,flag,center) 
	select 'bursar_kind', '�����¼���', 'Finance Subject Class', 2, '', 'F';
insert basecode(cat,code,descript,descript1,sequence) values('bursar_kind', '��', '�ʲ���', '�ʲ���', 100);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_kind', '��', '��ծ��', '��ծ��', 200);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_kind', 'Ȩ', 'Ȩ����', 'Ȩ����', 300);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_kind', '��', '�ɱ���', '�ɱ���', 400);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_kind', '��', '������', '������', 500);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_kind', '��', '������', '������', 600);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_kind', '��', '����', '����', 700);

-- --------------------------------------------------------------------------
--  basecode : bursar_class  ����ƾ֤���
-- --------------------------------------------------------------------------
delete basecode where cat='bursar_class';
delete basecode_cat where cat='bursar_class';
insert basecode_cat(cat,descript,descript1,len,flag,center) 
	select 'bursar_class', '����ƾ֤���', 'Finance Bursar Class', 4, '', 'F';
insert basecode(cat,code,descript,descript1,sequence) values('bursar_class', '����', '����', '����', 100);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_class', '�տ�', '�տ�', '�տ�', 200);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_class', '����', '����', '����', 300);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_class', '����', '����', '����', 400);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_class', '����', '����', '����', 500);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_class', '����', '����', '����', 600);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_class', '�ָ�', '�ָ�', '�ָ�', 700);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_class', 'ת��', 'ת��', 'ת��', 800);


-- --------------------------------------------------------------------------
--  basecode : bursar_src  ����ƾ֤������Դ
-- --------------------------------------------------------------------------
delete basecode where cat='bursar_src';
delete basecode_cat where cat='bursar_src';
insert basecode_cat(cat,descript,descript1,len,flag,center) 
	select 'bursar_src', '����ƾ֤������Դ', 'Finance Bursar Data Source', 10, '', 'F';
insert basecode(cat,code,descript,descript1,sequence) values('bursar_src', 'jierep', '�ױ�����', '�ױ�����', 100);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_src', 'dairep', '�ױ��տ�', '�ױ��տ�', 200);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_src', 'deptjie', 'POS����', 'POS����', 300);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_src', 'deptdai', 'POS�տ�', 'POS�տ�', 400);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_src', 'act_bal', '�ʻ�', '�ʻ�', 500);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_src', 'pccode9', '�տ�', '�տ�', 800);
insert basecode(cat,code,descript,descript1,sequence) values('bursar_src', 'impdata', '����ָ��', '����ָ��', 900);


--------------------------------------------------------------
--		ǰ̨���ƾ֤����
--------------------------------------------------------------
if object_id('bursar') is not null
	drop table bursar
;
CREATE TABLE bursar (
	code 			char(20)								not null,
	descript 	varchar(30) 						not null,
	descript1 	varchar(30) default ''			not null,
	kind 			char(2)  	default '' 		not null,		-- basecode = bursar_kind
	src 			char(20) 	default ''		not null,		-- ������Դ -- ��ر��� jierep,dairep,yingjiao ....
	classes		varchar(255) default ''		not null
);
exec sp_primarykey bursar, code
create unique index index1 on bursar(code)
;

--------------------------------------------------------------
--		���ƾ֤����
--------------------------------------------------------------
if object_id('bursar_code') is not null
	drop table bursar_code
;
CREATE TABLE bursar_code (
	code 			char(15)							not null,
	descript 	varchar(30) 					not null,	-- ����
	descript1 	varchar(30) 					not null,	-- ����
	class 		char(4)  	default '' 		not null,	-- ƾ֤���  basecode = bursar_class
	no				varchar(20)	default '' 		not null,	-- ҵ�����
	instready	varchar(1)  default 'T'		not null		
);
exec sp_primarykey bursar_code, code
create unique index index1 on bursar_code(code)
;

--------------------------------------------------------------
--		���ƾ֤���� -- ��ϸ����
--------------------------------------------------------------
if object_id('bursar_def') is not null
	drop table bursar_def
;
CREATE TABLE bursar_def (
	code 			char(15)							not null,		-- ���ƾ֤����  bursar_code
	id				int								not null,
	remark		varchar(30)	 default '' 	null,				-- ժҪ
	bursar		char(20) 						not null,		-- ��Ŀ bursar
	tag 			char(2)  	 default '��' 	not null,		-- �� / ��
	src 			char(10)  	 default '' 	not null,		-- ����Դ���   basecode = bursar_src 
	classes		varchar(255) default '' 	not null			-- ����Դ����
);
exec sp_primarykey bursar_def, code, id
create unique index index1 on bursar_def(code, id)
;

--------------------------------------------------------------
--		���ƾ֤ -- ���ݸ��� bursar_def ����
--------------------------------------------------------------
if object_id('bursar_out') is not null
	drop table bursar_out
;
CREATE TABLE bursar_out (
	date			datetime							not null,
	code 			char(15)							not null,
	id				int								not null,
	remark		varchar(30)	 default '' 	null,				-- ժҪ
	bursar		char(20) 						not null,		-- ��Ŀ
	kind 			char(2)  	default '' 		not null,		-- basecode = bursar_kind
	tag 			char(2)  	 default '��' 	not null,		-- �� / ��
	amount		money 		 default 0 		not null
);
exec sp_primarykey bursar_out, code, id
create unique index index1 on bursar_out(code, id)
;


--------------------------------------------------------------
--		���ƾ֤
--------------------------------------------------------------
if object_id('ybursar_out') is not null
	drop table ybursar_out
;
CREATE TABLE ybursar_out (
	date			datetime							not null,
	code 			char(15)							not null,
	id				int								not null,
	remark		varchar(30)	 default '' 	null,				-- ժҪ
	bursar		char(20) 						not null,		-- ��Ŀ
	kind 			char(2)  	default '' 		not null,		-- basecode = bursar_kind
	tag 			char(2)  	 default '��' 	not null,		-- �� / ��
	amount		money 		 default 0 		not null
);
exec sp_primarykey ybursar_out, date, code, id
create unique index index1 on ybursar_out(date, code, id)
;

