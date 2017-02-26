
// --------------------------------------------------------------------------
//  basecode : phone_grade  -- 电话等级
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='phone_grade')
	delete basecode_cat where cat='phone_grade';
insert basecode_cat select 'phone_grade', '电话等级', 'Phone Grade', 1;
delete basecode where cat='phone_grade';
insert basecode(cat,code,descript,descript1,sequence,sys) values('phone_grade', '0', '内线', '内线_eng', 10,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('phone_grade', '1', '市话', '市话_eng', 20,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('phone_grade', '2', '国内', '国内_eng', 30,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('phone_grade', '3', '国际', '国际_eng', 40,'T');


// --------------------------------------------------------------------------
//  basecode : vod_grade  -- VOD等级
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='vod_grade')
	delete basecode_cat where cat='vod_grade';
insert basecode_cat select 'vod_grade', 'VOD 等级', 'VOD Grade', 1;
delete basecode where cat='vod_grade';
insert basecode(cat,code,descript,descript1,sequence,sys) values('vod_grade', '0', '关闭', '关闭_eng', 10,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('vod_grade', '1', '一级', '一级_eng', 20,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('vod_grade', '2', '二级', '二级_eng', 30,'T');


// --------------------------------------------------------------------------
//  basecode : int_grade  -- Internet 等级
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='int_grade')
	delete basecode_cat where cat='int_grade';
insert basecode_cat select 'int_grade', 'Internet 等级', 'Internet Grade', 1;
delete basecode where cat='int_grade';
insert basecode(cat,code,descript,descript1,sequence,sys) values('int_grade', '0', '关闭', '关闭_eng', 10,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('int_grade', '1', '一级', '一级_eng', 20,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('int_grade', '2', '二级', '二级_eng', 30,'T');

// --------------------------------------------------------------------------
//  basecode : bar_grade  -- Mini Bar 等级
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='bar_grade')
	delete basecode_cat where cat='bar_grade';
insert basecode_cat select 'bar_grade', 'Mini Bar 等级', 'Mini Bar Grade', 1;
delete basecode where cat='bar_grade';
insert basecode(cat,code,descript,descript1,sequence,sys) values('bar_grade', '0', '关闭', '关闭_eng', 10,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('bar_grade', '1', '打开', '打开_eng', 20,'T');

