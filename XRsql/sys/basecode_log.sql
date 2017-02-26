---------------------------------------------------
-- basecode相关日志处理 by zhj 2008-03-05
---------------------------------------------------
---------------------------------------------------
-- basecode列追加: 最新修改人信息
-- basecode.sql中创建代码已经修改，这里代码是为了升级等
---------------------------------------------------
if not exists (select 1 from  syscolumns  where  id = object_id('basecode') and name = 'cby')
begin
	alter table basecode add cby	  char(10)	default '!'  		not null
	alter table basecode add changed datetime	default getdate()	not null 
end
;
---------------------------------------------------
-- lgfl列追加: 附加信息
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
	insert basecode_cat(cat,descript,descript1,len) select 'lgfl_type', '日志类别', 'Log Type', 1
;
delete from basecode where cat = 'lgfl_type'
;

insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_type', 'A', '账务', 'Account', 'F', 'F', 0, '', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_type', 'C', '维护', 'Configration', 'F', 'F', 0, '', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_type', 'O', '其他', 'Other', 'F', 'F', 0, '', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_type', 'P', '宾客档案', 'Guest Profile', 'F', 'F', 0, '', 'F','FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_type', 'K', '客户档案', 'Company Profile', 'F', 'F', 0, '', 'F','FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_type', 'B', '预留房', 'Resrv Block', 'F', 'F', 0, '', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_type', 'R', '预订单', 'Reservations', 'F', 'F', 0, '', 'F','FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_type', 'S', '销售员', 'Sales', 'F', 'F', 0, '', 'F','FOX',getdate() 
;

if not exists (select 1 from  basecode_cat  where cat = 'lgfl_prefix')
	insert basecode_cat(cat,descript,descript1,len) select 'lgfl_prefix', '日志项目', 'Log Prefix', 10
;
delete from basecode where cat = 'lgfl_prefix'
;
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'a_', '前台帐务', 'Account', 'F', 'F', 0, 'A', 'F','FOX',getdate() 

insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'ar_', '应收主单', 'AR Master', 'F', 'F', 0, 'R', 'F','FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'e_', '宴会', 'Event', 'F', 'F', 0, 'R', 'F','FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'fc_', '固定支出', 'Fix charge', 'F', 'F', 0, 'R', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'fec_', '外币兑换率', 'F-Currency Rate', 'F', 'F', 0, 'R', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'fefo_', '外币兑换单', 'F-Currency Folio', 'F', 'F', 0, 'R', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'm_', '预订主单', 'Master', 'F', 'F', 0, 'R', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'np_', 'POS主单', 'POS Menu', 'F', 'F', 0, 'R', 'F','FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'pr_', 'POS预订单', 'POS Resrv.', 'F', 'F', 0, 'R', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'r_', '房号', 'Roomno', 'F', 'F', 0, 'R', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'sa_', '分账户', 'Sub Accnt', 'F', 'F', 0, 'R', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'sys_', '系统其他', 'Sys. Other', 'F', 'F', 0, 'R', 'F' ,'FOX',getdate() 

insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'g_', '客户档案', 'Profile', 'F', 'F', 0, 'P', 'F' ,'FOX',getdate() 

insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 's_', '销售员', 'Sale Agent', 'F', 'F', 0, 'S', 'F','FOX',getdate() 

insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'v_', '会员卡', 'Vip Card', 'F', 'F', 0, 'O', 'F','FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'RPN_', '预订配额', 'RSV Plan', 'F', 'F', 0, 'O', 'F','FOX',getdate() 

insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'basecode_', '基础代码', 'Base Code', 'F', 'F', 0, 'C', 'F','FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'gtype_', '大房类', 'General Room Type', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'mktcode_', '市场码', 'Market Code', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'restype_', '预定类型', 'Resrv. Type', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'srccode_', '来源码', 'Source Code', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'sysoption_', '系统参数', 'Sys. Params', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'rmrc_','房价代码','Room Rate Code', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'rmrcl_','房价码明细','Rm Rate Code Detail', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'rmrd_','房价定义明细','Rm Rate Define', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'rmrs_','房价季节码','Rm Rate Season Code', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'rmrdl_','房价定义明细','Rm Rate Define Detail', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'rmrf_','房价日历代码','Rm  Rate Factor', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'rmrcal_','房价日历','Rm Rate Calendar', 'F', 'F', 0, 'C', 'F' ,'FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'typim_', '房类', 'Room Type', 'F', 'F', 0, 'C', 'F','FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'cmsc_', '佣金代码', 'Commision Code', 'F', 'F', 0, 'C', 'F','FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'cmscl_', '佣金代码对应明细', 'Commision Code Detail Ref.', 'F', 'F', 0, 'C', 'F','FOX',getdate() 
insert into basecode ( cat, code, descript, descript1, sys, halt, sequence, grp, center, cby, changed ) select 'lgfl_prefix', 'cmsd_', '佣金代码明细', 'Commision Detail Define', 'F', 'F', 0, 'C', 'F','FOX',getdate() 
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
-- 列描述定义
---------------------------------------------------
delete from  lgfl_des  where  columnname like 'basecode_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'basecode_','基本代码','Base Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'basecode_code','代码','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'basecode_des','描述','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'basecode_des1','描述1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'basecode_sys','系统标记','SystemTag','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'basecode_halt','停用','Halt','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'basecode_seq','排序','Sequence','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'basecode_grp','归类','Group','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'basecode_crs','CRS标记','CRS Tag','C'
;
delete from  lgfl_des  where  columnname like 'sysoption_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'sysoption_','系统参数','Sys Parm.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'sysoption_cat','类别','Class','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'sysoption_item','项目','Item','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'sysoption_val','值','Value','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'sysoption_def','缺省','Default','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'sysoption_des','描述','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'sysoption_des1','描述1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'sysoption_add','增加人','Creator','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'sysoption_addtm','增加时间','CreateTime','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'sysoption_lic','证书','License','C'
;

delete from  lgfl_des  where  columnname like 'mktcode_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'mktcode_','市场码','Market Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'mktcode_code','代码','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'mktcode_des','描述','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'mktcode_des1','描述1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'mktcode_grp','组别','Group','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'mktcode_jierep','底表行','JieRep','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'mktcode_flag','标记','Tag','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'mktcode_halt','停用','Halt','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'mktcode_seq','排序','Sequence','C'
;
delete from  lgfl_des  where  columnname like 'srccode_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'srccode_','来源码','Source Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'srccode_code','代码','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'srccode_des','描述','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'srccode_des1','描述1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'srccode_tag','标记','Tag','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'srccode_halt','停用','Halt','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'srccode_seq','排序','Sequence','C'
;
delete from  lgfl_des  where  columnname like 'restype_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'restype_','预订类型','Res. Type','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'restype_code','代码','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'restype_des','描述','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'restype_des1','描述1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'restype_def','确认','DefInite','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'restype_arr','到达时间','Arr','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'restype_card','信用卡','Card','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'restype_credit','押金','Credit','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'restype_halt','停用','Halt','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'restype_seq','排序','Sequence','C'
;
delete from  lgfl_des  where  columnname like 'gtype_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'gtype_','大房类','General Type','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'gtype_code','代码','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'gtype_des','描述','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'gtype_des1','描述1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'gtype_tag','标记','Tag','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'gtype_halt','停用','Halt','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'gtype_seq','排序','Sequence','C'
;
delete from  lgfl_des  where  columnname like 'typim_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_','房类','Room Type','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_type','代码','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_des','描述','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_des1','描述1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_des2','描述','Descript2','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_des3','描述','Descript3','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_des4','描述','Descript4','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_qty','Quantity','Quantity','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_oq','超出数量','Over Qty','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_fd','调整日期','Future Date','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_aq','调整数量','Adjust Qty','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_rc','房价码','Rate Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_fr','预设价格','Future Rate','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_rate','价格','Rate','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_begin','启用日期','Begin Date','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_htl','酒店代码','Hotel Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_gtype','大房类','Room Type','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_tag','标记','Tag','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_halt','停用','Halt','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_seq','排序','Sequence','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_int','Internal','Internal','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_ya','Yield Able','Yield Able','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_yc','Yield cat','Yield cat','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_cthr','crsthr','crsthr','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_cper','crsper','crsper','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'typim_pic','Picture','Picture','C'
;
/*
房价码 
*/
------------------------------------------------------------------
-- rmratecode---房价代码表 code
------------------------------------------------------------------

delete from  lgfl_des  where  columnname like 'rmrc_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_','房价代码','Room Rate Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_code','代码','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_cat','类别','Cat','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_descript','描述','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_descript1','描述1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_private','私有','Private','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_mode','模式','Mode','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_inher_fo','引用自','Refers','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_folio','帐单','Folio','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_src','宾客来源','Source','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_market','市场代码','Market Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_packages','包价','Packages','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_amenities','房间布置','Amenities','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_begin_','开始','begin','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_end_','结束','End','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_calendar','房价日历','Calendar','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_yieldable','限制策略','Yield Able','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_yieldcat','yieldcat','yieldcat','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_bucket','bucket','bucket','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_arrmin','arrmin','arrmin','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_arrmax','arrmax','arrmax','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_thoughmin','thoughmin','thoughmin','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_thoughmax','thoughmax','thoughmax','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_staymin','staymin','staymin','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_staymax','staymax','staymax','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_multi','multi','multi','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_addition','附加','addition','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_pccode','pccode','pccode','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_halt','停用','Halt','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrc_sequence','排序','sequence','C'
;
------------------------------------------------------------------
-- rmratecode_link ---房价代码的明细定义 code, pri
------------------------------------------------------------------
delete from  lgfl_des  where  columnname like 'rmrcl_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrcl_','房价码明细','Rm Rate Code Detail','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrcl_code','代码','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrcl_pri','优先级','PRI','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrcl_rmcode','房价定义明细','RMCode','C'
;

------------------------------------------------------------------
-- rmratedef - 房价定义明细表 code
------------------------------------------------------------------
delete from  lgfl_des  where  columnname like 'rmrd_%'
;
insert into lgfl_des(columnname,descript,descript1,tag) select 'rmrd_','房价定义明细','Rm Rate Define','C'
insert into lgfl_des(columnname,descript,descript1,tag) select 'rmrd_code','代码','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_descript','描述','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_descript1','描述1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_begin_','开始','Begin','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_end_','结束','End','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_packages','包价','Packages','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_amenities','房间布置','Amenities','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_market','市场代码','Market Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_src','宾客来源','Source','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_year','年','Year','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_month','月','Month','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_day','日','Day','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_week','星期','Week','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_stay','stay','stay','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_hall','楼号','Hall','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_gtype','大房类','General Type','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_type','房类','Type','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_flr','楼层','floor','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_roomno','房号','Room No','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_rmnums','房数','Room Number','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_ratemode','定价模式','Rate Mode','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_stay_cost','参考','Reference','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_fix_cost','fix_cost','fix_cost','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_prs_cost','prs_cost','prs_cost','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_rate1','1人价','1 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_rate2','2人价','2 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_rate3','3人价','3 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_rate4','4人价','4 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_rate5','5人价','5 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_rate6','6人价','6 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_extra','加床','Extra Bed','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_child','小孩床','Children','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrd_crib','婴儿床','Baby Cot','C'
;

------------------------------------------------------------------
-- rmrate_season - 房价季节code
------------------------------------------------------------------
delete from  lgfl_des  where  columnname like 'rmrs_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrs_','房价季节码','Rm Rate Season Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrs_code','代码','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrs_begin_','开始','Begin','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrs_end_','结束','End','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrs_descript','描述','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrs_descript1','描述1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrs_day','日','Day','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrs_week','星期','Week','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrs_sequence','排序','sequence','C'
;

------------------------------------------------------------------
-- rmratedef_sslink - 房价定义明细表 code,season
------------------------------------------------------------------
delete from  lgfl_des  where  columnname like 'rmrdl_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_','房价定义明细','Rm Rate Define Detail','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_code','代码','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_season','季节','Season','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_rate1','1人价','1 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_rate2','2人价','2 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_rate3','3人价','3 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_rate4','4人价','4 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_rate5','5人价','5 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_rate6','6人价','6 pers.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_extra','加床','Extra Bed','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_child','小孩床','Children','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_packages','包价','packages','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrdl_amenities','房间布置','amenities','C'
;
------------------------------------------------------------------
-- rmrate_factor --- 房价日历代码 code
------------------------------------------------------------------
delete from  lgfl_des  where  columnname like 'rmrf_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrf_','房价日历代码','Rm  Rate Factor','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrf_code','代码','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrf_descript','描述','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrf_descript1','描述1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrf_multi','乘法系数','Multi','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrf_adder','加法系数','Plus','C'
;

------------------------------------------------------------------
-- rmrate_calendar --- 房价日历 date
------------------------------------------------------------------
delete from  lgfl_des  where  columnname like 'rmrcal_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrcal_','房价日历','Rm Rate Calendar','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrcal_date','日期','Date','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'rmrcal_factor','factor','factor','C'
;

------------------------------------------------------------------
------------------------------------------------------------------
------------------------------------------------------------------
-- cmscode --- 佣金代码 code
------------------------------------------------------------------
delete from  lgfl_des  where  columnname like 'cmsc_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsc_','佣金代码','Commision Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsc_code','代码','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsc_descript','描述','Descript','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsc_descript1','描述1','Descript1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsc_halt','停用标志','Halt','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsc_upmode','阶梯返佣时间段','Up Mode','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsc_rmtype_s','阶梯返佣分房类统计间天','rmtype_s','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsc_sequence','排序','sequence','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsc_begin_','开始日期','Begin Date','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsc_end_','结束日期','End Date','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsc_flag','Flag','Flag','C'
;
------------------------------------------------------------------
-- cmscode_link ---佣金代码 对应 明细代码 code, pri
------------------------------------------------------------------
delete from  lgfl_des  where  columnname like 'cmscl_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmscl_','佣金代码对应明细','Commision Code Detail Ref.','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmscl_code','代码','Code','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmscl_pri','优先级','PRI','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmscl_cmscode','佣金代码明细','Commision Code','C'
;

------------------------------------------------------------------
-- cms_defitem ---佣金明细代码 no 
------------------------------------------------------------------
delete from  lgfl_des  where  columnname like 'cmsd_%'
;
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_','佣金明细定义','Commision Detail Define','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_no','返佣编号','No','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_unit','返佣单位','Unit','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_type','返佣类型','Type','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_rmtype','房类','Rm Type','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_amount','返佣','Amount','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_dayuse','加收','DayUse','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_uproom1','阶梯返佣间数1','Up Room1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_upamount1','返佣比例或金额1','Up Amount1','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_uproom2','阶梯返佣间数2','Up Room2','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_upamount2','返佣比例或金额2','Up Amount2','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_uproom3','阶梯返佣间数3','Up Room3','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_upamount3','返佣比例或金额3','Up Amount3','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_uproom4','阶梯返佣间数4','Up Room4','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_upamount4','返佣比例或金额4','Up Amount4','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_uproom5','阶梯返佣间数5','Up Room5','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_upamount5','返佣比例或金额5','Up Amount5','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_uproom6','阶梯返佣间数6','Up Room6','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_upamount6','返佣比例或金额6','Up Amount6','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_uproom7','阶梯返佣间数7','Up Room7','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_upamount7','返佣比例或金额7','Up Amount7','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_rmtype_s','阶梯返佣分房类统计间天','rmtype_s','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_name','名称','Name','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_datecond','返佣日期条件','Date Condition','C'
insert into lgfl_des(columnname,descript,descript1,tag)	select 'cmsd_extra','扩展标记','Extra','C' 
;
