

------------------------------------------------------------------
-- �˴��Ĺ����Ѿ����á���Ϊ�Ѿ��ϲ��� bill ���������ˣ�
------------------------------------------------------------------





//
//---------------------------------
//-- doc ģ���ӡ
//---------------------------------
//if exists (select * from sysobjects where name ='edoc' and type ='U')
//	drop table edoc;
//create table edoc
//(
//	code				varchar(30)	not null,							--
//	descript			varchar(60)	 default '' not null,
//	descript1		varchar(60)	 default '' not null,
//	datawindow		varchar(30)					not null,			-- ���ݴ������������ؼ���
//	template			varchar(255) default ''	not null,			-- ģ��
//	cat				varchar(30)	 default '' not null,			-- ����
//	flag				varchar(30)	 default '' not null,			-- Ԥ��
//	halt				char(1)		 default 'F' not null,
//	sequence			int			default 0		not null
//)
//exec sp_primarykey edoc, code
//create unique index index1 on edoc(code)
//;
//INSERT INTO edoc VALUES('RES01','Ԥ��ȷ�ϵ������ģ�','Conf Letter - C', 'd_confirmation_letter', 'C:\syhis\Templates\Conf Letter CN.dot', 'master', '','F',0);
//INSERT INTO edoc VALUES('RES02','Ԥ��ȷ�ϵ���Ӣ�ģ�','Conf Letter - E', 'd_confirmation_letter', 'C:\syhis\Templates\Conf Letter EN.dot', 'master', '','F',0);
//
//select * from edoc;
//
//--------------------------------------------------------------------------------
//--  edoc
//--------------------------------------------------------------------------------
//delete from basecode_cat where cat='edoc' ;
//insert basecode_cat(cat,descript,descript1,len) select 'edoc', 'edoc', 'edoc', 10 ;
//
//delete from basecode where cat='edoc'
//insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'edoc', 'master', 'Master', 'Master','T','T',0,'1';
//insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'edoc', 'profile', 'Profile', 'Profile','T','T',0,'1';
//
//INSERT INTO syscode_maint VALUES ('3Z','��ӡģ��','Print Template','','','','','');
//INSERT INTO syscode_maint VALUES ('3Z1','ģ�����','Template Class','hry','','','',	'cat=edoc');
//INSERT INTO syscode_maint VALUES ('3Z2','ģ���б�','Template List','response','','d_edoc_list','w_gl_public_code_list',	'��ӡģ���б�#w_edoc_edit#d_edoc_list');
//