----------------------------------------------------------------------------------
--		ժҪ����
----------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "brief_help")
	drop table brief_help;
create table brief_help
(
	class				char(20)									not null,
	id					int										not null,
	brief				text			default ''				not null,
	sequence			int			default 0				not null,		// ����
	cby				char(10)		default '!' 			not null,	/* �����޸�����Ϣ */
	changed			datetime		default getdate()		not null 
)
exec sp_primarykey brief_help,class,id
create unique index index1 on brief_help(class,id)
;
--------------------------------------------------------------------------------
--  BriefClass
--------------------------------------------------------------------------------
if not exists(select 1 from basecode_cat where cat='BriefClass')
	insert basecode_cat(cat,descript,descript1,len) select 'BriefClass', 'ժҪ�������', 'BriefClass', 10;

if not exists(select 1 from basecode where cat='BriefClass' and code = '��������' )
	insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'BriefClass', '��������', '��������', '','T','T',0,'1';
if not exists(select 1 from basecode where cat='BriefClass' and code = '�ͷ�ά��' )
	insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'BriefClass', '�ͷ�ά��', '�ͷ�ά��', '','T','T',0,'1';
if not exists(select 1 from basecode where cat='BriefClass' and code = 'ǰ̨��ע' )
	insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'BriefClass', 'ǰ̨��ע', 'ǰ̨��ע', '','T','T',0,'1';

	--  GoodsAVHelp
if not exists(select 1 from basecode where cat='BriefClass' and code = 'GoodsAVHelp' )
	insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'BriefClass', 'GoodsAVHelp', '��Ʒ����ժҪ', '','T','T',0,'1';
	--  MeetAVHelp
if not exists(select 1 from basecode where cat='BriefClass' and code = 'MeetAVHelp' )
	insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'BriefClass', 'MeetAVHelp', '������Ԥ��ժҪ', '','T','T',0,'1';
	--  MeetOOOHelp
if not exists(select 1 from basecode where cat='BriefClass' and code = 'MeetOOOHelp' )
	insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'BriefClass', 'MeetOOOHelp', '������ά��ժҪ', '','T','T',0,'1';
	--  AffairHelp
if not exists(select 1 from basecode where cat='BriefClass' and code = 'AffairHelp' )
	insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'BriefClass', 'AffairHelp', '����ģ��', '','T','T',0,'1';


-- ά������  
DELETE FROM syscode_maint WHERE code in('19A','19B')

INSERT INTO syscode_maint VALUES ('19A','ժҪ����','','hry','res','','','cat=BriefClass')
INSERT INTO syscode_maint VALUES ('19B','ժҪ�������','','response','res','d_sm_brief_help_list','w_sm_brief_help_edit','')

;
