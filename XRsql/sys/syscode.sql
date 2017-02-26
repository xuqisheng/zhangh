// --------------------------------------------------------------------------
//		basecode:		shift
//		table:			
//							
//
// --------------------------------------------------------------------------


// --------------------------------------------------------------------------
//  basecode : shift  -- 班次
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='shift')
	delete basecode_cat(cat,descript,descript1,len) where cat='shift';
insert basecode_cat select 'shift', '班次', 'shift', 1;
delete basecode where cat='shift';
insert basecode(cat,code,descript,descript1) select 'shift', '0', '所有', 'shift-0';
insert basecode(cat,code,descript,descript1) select 'shift', '1', '早班', 'shift-1';
insert basecode(cat,code,descript,descript1) select 'shift', '2', '中班', 'shift-2';
insert basecode(cat,code,descript,descript1) select 'shift', '3', '完班', 'shift-3';
insert basecode(cat,code,descript,descript1) select 'shift', '4', '夜班', 'shift-4';
insert basecode(cat,code,descript,descript1) select 'shift', '5', '消夜', 'shift-5';



// --------------------------------------------------------------------------
//  basecode : moduno  -- 帐务模块
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='moduno')
	delete basecode_cat(cat,descript,descript1,len) where cat='moduno';
insert basecode_cat select 'moduno', '帐务模块', 'moduno', 2;
delete basecode where cat='moduno';
insert basecode(cat,code,descript,descript1,sys) select 'moduno', '02', '前台帐务', '前台帐务', 'T';
insert basecode(cat,code,descript,descript1,sys) select 'moduno', '03', '客房中心', '客房中心', 'T';
insert basecode(cat,code,descript,descript1,sys) select 'moduno', '04', '综合收银', '综合收银', 'T';
insert basecode(cat,code,descript,descript1,sys) select 'moduno', '05', '电话计费', '电话计费', 'T';
insert basecode(cat,code,descript,descript1,sys) select 'moduno', '06', '商务中心', '商务中心', 'T';
insert basecode(cat,code,descript,descript1,sys) select 'moduno', '09', '商场', '商场', 'T';
insert basecode(cat,code,descript,descript1,sys) select 'moduno', '12', '贵宾卡', '贵宾卡', 'T';
insert basecode(cat,code,descript,descript1,sys) select 'moduno', '19', 'VOD', 'VOD',  'T';
insert basecode(cat,code,descript,descript1,sys) select 'moduno', '21', 'INTERNET', 'INTERNET', 'T';


// --------------------------------------------------------------------------
//  basecode : info_cat  -- 公共信息类别
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='info_cat')
	delete basecode_cat where cat='info_cat';
insert basecode_cat(cat,descript,descript1,len) select 'info_cat', '公共信息类别', 'info_cat', 10;
delete basecode where cat='info_cat';
insert basecode(cat,code,descript,descript1,sys,sequence) select 'info_cat', 'SERVICE', '酒店服务', 'Hotel Service', 'T',100;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'info_cat', 'VIEW', '景点', 'Viewport', 'T',200;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'info_cat', 'TRANS', '交通', 'Transport', 'T',300;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'info_cat', 'LEISURE', '休闲', 'Leisure', 'T',400;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'info_cat', 'ORGA', '机构', 'Organization', 'T',500;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'info_cat', 'SYSTEM', '酒店制度', 'Hotel Documents', 'T',600;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'info_cat', 'HIS', '人文历史', 'Culture & History', 'T',700;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'info_cat', 'TRAIN', '小课堂', 'Training', 'T',800;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'info_cat', 'PUB', '公共信息', 'Public Info.', 'T',900;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'info_cat', 'OTHER', '其他', 'Other', 'T',1000;






