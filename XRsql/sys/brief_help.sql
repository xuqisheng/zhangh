----------------------------------------------------------------------------------
--		摘要帮助
----------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "brief_help")
	drop table brief_help;
create table brief_help
(
	class				char(20)									not null,
	id					int										not null,
	brief				text			default ''				not null,
	sequence			int			default 0				not null,		// 次序
	cby				char(10)		default '!' 			not null,	/* 最新修改人信息 */
	changed			datetime		default getdate()		not null 
)
exec sp_primarykey brief_help,class,id
create unique index index1 on brief_help(class,id)
;
--------------------------------------------------------------------------------
--  BriefClass
--------------------------------------------------------------------------------
if not exists(select 1 from basecode_cat where cat='BriefClass')
	insert basecode_cat(cat,descript,descript1,len) select 'BriefClass', '摘要帮助类别', 'BriefClass', 10;

if not exists(select 1 from basecode where cat='BriefClass' and code = '宾客留言' )
	insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'BriefClass', '宾客留言', '宾客留言', '','T','T',0,'1';
if not exists(select 1 from basecode where cat='BriefClass' and code = '客房维护' )
	insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'BriefClass', '客房维护', '客房维护', '','T','T',0,'1';
if not exists(select 1 from basecode where cat='BriefClass' and code = '前台备注' )
	insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'BriefClass', '前台备注', '前台备注', '','T','T',0,'1';

	--  GoodsAVHelp
if not exists(select 1 from basecode where cat='BriefClass' and code = 'GoodsAVHelp' )
	insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'BriefClass', 'GoodsAVHelp', '物品租赁摘要', '','T','T',0,'1';
	--  MeetAVHelp
if not exists(select 1 from basecode where cat='BriefClass' and code = 'MeetAVHelp' )
	insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'BriefClass', 'MeetAVHelp', '会议室预订摘要', '','T','T',0,'1';
	--  MeetOOOHelp
if not exists(select 1 from basecode where cat='BriefClass' and code = 'MeetOOOHelp' )
	insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'BriefClass', 'MeetOOOHelp', '会议室维修摘要', '','T','T',0,'1';
	--  AffairHelp
if not exists(select 1 from basecode where cat='BriefClass' and code = 'AffairHelp' )
	insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) select 'BriefClass', 'AffairHelp', '事务模板', '','T','T',0,'1';


-- 维护代码  
DELETE FROM syscode_maint WHERE code in('19A','19B')

INSERT INTO syscode_maint VALUES ('19A','摘要种类','','hry','res','','','cat=BriefClass')
INSERT INTO syscode_maint VALUES ('19B','摘要输入帮助','','response','res','d_sm_brief_help_list','w_sm_brief_help_edit','')

;
