---------------------------------------------------
-- basecode�����־���� by zhj 2008-03-05
---------------------------------------------------
---------------------------------------------------
-- basecode��׷��: �����޸�����Ϣ
-- basecode.sql�д��������Ѿ��޸ģ����������Ϊ��������
---------------------------------------------------
if not exists (select 1 from  syscolumns  where  id = object_id('basecode') and name = 'cby')
begin
	alter table basecode add cby	  char(10)	default '!'  		not null
	alter table basecode add changed datetime	default getdate()	not null 
end
;
---------------------------------------------------
-- lgfl��׷��: ������Ϣ
---------------------------------------------------
if not exists (select 1 from  syscolumns  where  id = object_id('lgfl') and name = 'ext')
begin
	alter table lgfl add ext	  varchar(128)	default ''  		null
end
; 
---------------------------------------------------
---------------------------------------------------
---------------------------------------------------
if not exists (select 1 from  basecode_cat  where cat = 'lgfl_type')
	insert basecode_cat(cat,descript,descript1,len) select 'lgfl_type', '��־���', 'Log Type', 1
;
delete from basecode where cat = 'lgfl_type'
;

insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_type', 'A', '����', 'Account', 'F', 'F', 0, '', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_type', 'C', 'ά��', 'Configration', 'F', 'F', 0, '', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_type', 'O', '����', 'Other', 'F', 'F', 0, '', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_type', 'P', '���͵���', 'Guest Profile', 'F', 'F', 0, '', 'F','FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_type', 'K', '�ͻ�����', 'Company Profile', 'F', 'F', 0, '', 'F','FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_type', 'B', 'Ԥ����', 'Resrv Block', 'F', 'F', 0, '', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_type', 'R', 'Ԥ����', 'Reservations', 'F', 'F', 0, '', 'F','FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_type', 'S', '����Ա', 'Sales', 'F', 'F', 0, '', 'F','FOX',getdate() 
;

if not exists (select 1 from  basecode_cat  where cat = 'lgfl_prefix')
	insert basecode_cat(cat,descript,descript1,len) select 'lgfl_prefix', '��־��Ŀ', 'Log Prefix', 10
;
delete from basecode where cat = 'lgfl_prefix'
;
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'a_', 'ǰ̨����', 'Account', 'F', 'F', 0, 'A', 'F','FOX',getdate() 

insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'ar_', 'Ӧ������', 'AR Master', 'F', 'F', 0, 'R', 'F','FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'e_', '���', 'Event', 'F', 'F', 0, 'R', 'F','FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'fc_', '�̶�֧��', 'Fix charge', 'F', 'F', 0, 'R', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'fec_', '��Ҷһ���', 'F-Currency Rate', 'F', 'F', 0, 'R', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'fefo_', '��Ҷһ���', 'F-Currency Folio', 'F', 'F', 0, 'R', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'm_', 'Ԥ������', 'Master', 'F', 'F', 0, 'R', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'np_', 'POS����', 'POS Menu', 'F', 'F', 0, 'R', 'F','FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'pr_', 'POSԤ����', 'POS Resrv.', 'F', 'F', 0, 'R', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'r_', '����', 'Roomno', 'F', 'F', 0, 'R', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'sa_', '���˻�', 'Sub Accnt', 'F', 'F', 0, 'R', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'sys_', 'ϵͳ����', 'Sys. Other', 'F', 'F', 0, 'R', 'F' ,'FOX',getdate() 

insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'g_', '�ͻ�����', 'Profile', 'F', 'F', 0, 'P', 'F' ,'FOX',getdate() 

insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 's_', '����Ա', 'Sale Agent', 'F', 'F', 0, 'S', 'F','FOX',getdate() 

insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'v_', '��Ա��', 'Vip Card', 'F', 'F', 0, 'O', 'F','FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'RPN_', 'Ԥ�����', 'RSV Plan', 'F', 'F', 0, 'O', 'F','FOX',getdate() 

insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'basecode_', '��������', 'Base Code', 'F', 'F', 0, 'C', 'F','FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'gtype_', '����', 'General Room Type', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'mktcode_', '�г���', 'Market Code', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'restype_', 'Ԥ������', 'Resrv. Type', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'srccode_', '��Դ��', 'Source Code', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'sysoption_', 'ϵͳ����', 'Sys. Params', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'rmrc_','���۴���','Room Rate Code', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'rmrcl_','��������ϸ','Rm Rate Code Detail', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'rmrd_','���۶�����ϸ','Rm Rate Define', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'rmrs_','���ۼ�����','Rm Rate Season Code', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'rmrdl_','���۶�����ϸ','Rm Rate Define Detail', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'rmrf_','������������','Rm  Rate Factor', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'rmrcal_','��������','Rm Rate Calendar', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'typim_', '����', 'Room Type', 'F', 'F', 0, 'C', 'F','FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'cmsc_', 'Ӷ�����', 'Commision Code', 'F', 'F', 0, 'C', 'F','FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'cmscl_', 'Ӷ������Ӧ��ϸ', 'Commision Code Detail Ref.', 'F', 'F', 0, 'C', 'F','FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'cmsd_', 'Ӷ�������ϸ', 'Commision Detail Define', 'F', 'F', 0, 'C', 'F','FOX',getdate() 
;



---------------------------------------------------
-- basecode 
-- sysoption 
-- mktcode
-- srccode
-- restype
-- gtype
-- typim
---------------------------------------------------
---------------------------------------------------
-- ����������
---------------------------------------------------
delete from  lgfl_des  where  columnname like 'basecode_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'basecode_','��������','Base Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'basecode_code','����','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'basecode_des','����','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'basecode_des1','����1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'basecode_sys','ϵͳ���','SystemTag','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'basecode_halt','ͣ��','Halt','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'basecode_seq','����','Sequence','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'basecode_grp','����','Group','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'basecode_crs','CRS���','CRS Tag','C'
;
delete from  lgfl_des  where  columnname like 'sysoption_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'sysoption_','ϵͳ����','Sys Parm.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'sysoption_cat','���','Class','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'sysoption_item','��Ŀ','Item','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'sysoption_val','ֵ','Value','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'sysoption_def','ȱʡ','Default','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'sysoption_des','����','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'sysoption_des1','����1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'sysoption_add','������','Creator','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'sysoption_addtm','����ʱ��','CreateTime','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'sysoption_lic','֤��','License','C'
;

delete from  lgfl_des  where  columnname like 'mktcode_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'mktcode_','�г���','Market Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'mktcode_code','����','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'mktcode_des','����','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'mktcode_des1','����1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'mktcode_grp','���','Group','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'mktcode_jierep','�ױ���','JieRep','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'mktcode_flag','���','Tag','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'mktcode_halt','ͣ��','Halt','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'mktcode_seq','����','Sequence','C'
;
delete from  lgfl_des  where  columnname like 'srccode_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'srccode_','��Դ��','Source Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'srccode_code','����','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'srccode_des','����','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'srccode_des1','����1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'srccode_tag','���','Tag','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'srccode_halt','ͣ��','Halt','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'srccode_seq','����','Sequence','C'
;
delete from  lgfl_des  where  columnname like 'restype_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'restype_','Ԥ������','Res. Type','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'restype_code','����','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'restype_des','����','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'restype_des1','����1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'restype_def','ȷ��','DefInite','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'restype_arr','����ʱ��','Arr','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'restype_card','���ÿ�','Card','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'restype_credit','Ѻ��','Credit','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'restype_halt','ͣ��','Halt','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'restype_seq','����','Sequence','C'
;
delete from  lgfl_des  where  columnname like 'gtype_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'gtype_','����','General Type','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'gtype_code','����','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'gtype_des','����','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'gtype_des1','����1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'gtype_tag','���','Tag','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'gtype_halt','ͣ��','Halt','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'gtype_seq','����','Sequence','C'
;
delete from  lgfl_des  where  columnname like 'typim_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_','����','Room Type','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_type','����','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_des','����','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_des1','����1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_des2','����','Descript2','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_des3','����','Descript3','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_des4','����','Descript4','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_qty','Quantity','Quantity','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_oq','��������','Over Qty','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_fd','��������','Future Date','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_aq','��������','Adjust Qty','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_rc','������','Rate Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_fr','Ԥ��۸�','Future Rate','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_rate','�۸�','Rate','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_begin','��������','Begin Date','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_htl','�Ƶ����','Hotel Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_gtype','����','Room Type','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_tag','���','Tag','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_halt','ͣ��','Halt','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_seq','����','Sequence','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_int','Internal','Internal','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_ya','Yield Able','Yield Able','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_yc','Yield cat','Yield cat','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_cthr','crsthr','crsthr','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_cper','crsper','crsper','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_pic','Picture','Picture','C'
;
/*
������ 
*/
------------------------------------------------------------------
-- rmratecode---���۴���� code
------------------------------------------------------------------

delete from  lgfl_des  where  columnname like 'rmrc_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_','���۴���','Room Rate Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_code','����','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_cat','���','Cat','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_descript','����','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_descript1','����1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_private','˽��','Private','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_mode','ģʽ','Mode','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_inher_fo','������','Refers','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_folio','�ʵ�','Folio','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_src','������Դ','Source','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_market','�г�����','Market Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_packages','����','Packages','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_amenities','���䲼��','Amenities','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_begin_','��ʼ','begin','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_end_','����','End','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_calendar','��������','Calendar','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_yieldable','���Ʋ���','Yield Able','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_yieldcat','yieldcat','yieldcat','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_bucket','bucket','bucket','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_arrmin','arrmin','arrmin','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_arrmax','arrmax','arrmax','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_thoughmin','thoughmin','thoughmin','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_thoughmax','thoughmax','thoughmax','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_staymin','staymin','staymin','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_staymax','staymax','staymax','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_multi','multi','multi','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_addition','����','addition','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_pccode','pccode','pccode','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_halt','ͣ��','Halt','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_sequence','����','sequence','C'
;
------------------------------------------------------------------
-- rmratecode_link ---���۴������ϸ���� code, pri
------------------------------------------------------------------
delete from  lgfl_des  where  columnname like 'rmrcl_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrcl_','��������ϸ','Rm Rate Code Detail','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrcl_code','����','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrcl_pri','���ȼ�','PRI','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrcl_rmcode','���۶�����ϸ','RMCode','C'
;

------------------------------------------------------------------
-- rmratedef - ���۶�����ϸ�� code
------------------------------------------------------------------
delete from  lgfl_des  where  columnname like 'rmrd_%'
;
insert into lgfl_des(columnname,descript,descript1,tag) select 'rmrd_','���۶�����ϸ','Rm Rate Define','C'
insert into lgfl_des(columnname,descript,descript1,tag) select 'rmrd_code','����','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_descript','����','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_descript1','����1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_begin_','��ʼ','Begin','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_end_','����','End','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_packages','����','Packages','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_amenities','���䲼��','Amenities','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_market','�г�����','Market Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_src','������Դ','Source','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_year','��','Year','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_month','��','Month','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_day','��','Day','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_week','����','Week','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_stay','stay','stay','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_hall','¥��','Hall','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_gtype','����','General Type','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_type','����','Type','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_flr','¥��','floor','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_roomno','����','Room No','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_rmnums','����','Room Number','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_ratemode','����ģʽ','Rate Mode','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_stay_cost','�ο�','Reference','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_fix_cost','fix_cost','fix_cost','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_prs_cost','prs_cost','prs_cost','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_rate1','1�˼�','1 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_rate2','2�˼�','2 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_rate3','3�˼�','3 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_rate4','4�˼�','4 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_rate5','5�˼�','5 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_rate6','6�˼�','6 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_extra','�Ӵ�','Extra Bed','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_child','С����','Children','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_crib','Ӥ����','Baby Cot','C'
;

------------------------------------------------------------------
-- rmrate_season - ���ۼ���code
------------------------------------------------------------------
delete from  lgfl_des  where  columnname like 'rmrs_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrs_','���ۼ�����','Rm Rate Season Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrs_code','����','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrs_begin_','��ʼ','Begin','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrs_end_','����','End','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrs_descript','����','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrs_descript1','����1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrs_day','��','Day','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrs_week','����','Week','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrs_sequence','����','sequence','C'
;

------------------------------------------------------------------
-- rmratedef_sslink - ���۶�����ϸ�� code,season
------------------------------------------------------------------
delete from  lgfl_des  where  columnname like 'rmrdl_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_','���۶�����ϸ','Rm Rate Define Detail','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_code','����','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_season','����','Season','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_rate1','1�˼�','1 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_rate2','2�˼�','2 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_rate3','3�˼�','3 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_rate4','4�˼�','4 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_rate5','5�˼�','5 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_rate6','6�˼�','6 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_extra','�Ӵ�','Extra Bed','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_child','С����','Children','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_packages','����','packages','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_amenities','���䲼��','amenities','C'
;
------------------------------------------------------------------
-- rmrate_factor --- ������������ code
------------------------------------------------------------------
delete from  lgfl_des  where  columnname like 'rmrf_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrf_','������������','Rm  Rate Factor','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrf_code','����','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrf_descript','����','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrf_descript1','����1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrf_multi','�˷�ϵ��','Multi','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrf_adder','�ӷ�ϵ��','Plus','C'
;

------------------------------------------------------------------
-- rmrate_calendar --- �������� date
------------------------------------------------------------------
delete from  lgfl_des  where  columnname like 'rmrcal_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrcal_','��������','Rm Rate Calendar','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrcal_date','����','Date','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrcal_factor','factor','factor','C'
;

------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
-- cmscode --- Ӷ����� code
------------------------------------------------------------------
delete from  lgfl_des  where  columnname like 'cmsc_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsc_','Ӷ�����','Commision Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsc_code','����','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsc_descript','����','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsc_descript1','����1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsc_halt','ͣ�ñ�־','Halt','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsc_upmode','���ݷ�Ӷʱ���','Up Mode','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsc_rmtype_s','���ݷ�Ӷ�ַ���ͳ�Ƽ���','rmtype_s','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsc_sequence','����','sequence','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsc_begin_','��ʼ����','Begin Date','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsc_end_','��������','End Date','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsc_flag','Flag','Flag','C'
;
------------------------------------------------------------------
-- cmscode_link ---Ӷ����� ��Ӧ ��ϸ���� code, pri
------------------------------------------------------------------
delete from  lgfl_des  where  columnname like 'cmscl_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmscl_','Ӷ������Ӧ��ϸ','Commision Code Detail Ref.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmscl_code','����','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmscl_pri','���ȼ�','PRI','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmscl_cmscode','Ӷ�������ϸ','Commision Code','C'
;

------------------------------------------------------------------
-- cms_defitem ---Ӷ����ϸ���� no 
------------------------------------------------------------------
delete from  lgfl_des  where  columnname like 'cmsd_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_','Ӷ����ϸ����','Commision Detail Define','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_no','��Ӷ���','No','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_unit','��Ӷ��λ','Unit','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_type','��Ӷ����','Type','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_rmtype','����','Rm Type','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_amount','��Ӷ','Amount','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_dayuse','����','DayUse','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_uproom1','���ݷ�Ӷ����1','Up Room1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_upamount1','��Ӷ��������1','Up Amount1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_uproom2','���ݷ�Ӷ����2','Up Room2','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_upamount2','��Ӷ��������2','Up Amount2','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_uproom3','���ݷ�Ӷ����3','Up Room3','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_upamount3','��Ӷ��������3','Up Amount3','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_uproom4','���ݷ�Ӷ����4','Up Room4','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_upamount4','��Ӷ��������4','Up Amount4','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_uproom5','���ݷ�Ӷ����5','Up Room5','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_upamount5','��Ӷ��������5','Up Amount5','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_uproom6','���ݷ�Ӷ����6','Up Room6','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_upamount6','��Ӷ��������6','Up Amount6','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_uproom7','���ݷ�Ӷ����7','Up Room7','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_upamount7','��Ӷ��������7','Up Amount7','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_rmtype_s','���ݷ�Ӷ�ַ���ͳ�Ƽ���','rmtype_s','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_name','����','Name','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_datecond','��Ӷ��������','Date Condition','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_extra','��չ���','Extra','C' 
;
