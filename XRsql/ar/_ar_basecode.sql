// --------------------------------------------------------------------------
//		basecode:		
//							
//
// --------------------------------------------------------------------------


// --------------------------------------------------------------------------
//  basecode : aging_level  -- 帐龄表间隔
// --------------------------------------------------------------------------
delete basecode where cat='aging_level';
if exists(select 1 from basecode_cat where cat='aging_level')
	delete basecode_cat where cat='aging_level';
insert basecode_cat(cat,descript,descript1,len) select 'aging_level', '帐龄表间隔', 'aging_level', 10;
insert basecode(cat,code,descript,descript1,sequence) select 'aging_level', '30', '0-30', 'Up to 30',100;
insert basecode(cat,code,descript,descript1,sequence) select 'aging_level', '60', '31-60', '31-60',200;
insert basecode(cat,code,descript,descript1,sequence) select 'aging_level', '90', '61-90', '61-90',300;
insert basecode(cat,code,descript,descript1,sequence) select 'aging_level', '120', '91-120', '91-120',400;
insert basecode(cat,code,descript,descript1,sequence) select 'aging_level', '180', '121-180', '121-180',500;
insert basecode(cat,code,descript,descript1,sequence) select 'aging_level', 'OVER', 'Over 180', 'Over 180',1000;
