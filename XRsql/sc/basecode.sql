
-- moduno 
if not exists(select 1 from basecode where cat='moduno' and code='66')
	INSERT INTO basecode VALUES ('moduno','66','宴会与销售','S&C','T','F',0,'','F');

-- sysoption - sc_master edit 
INSERT INTO sysoption VALUES ('sc','master_edit_g1','d_gds_sc_master_profile','d_gds_sc_master_profile','master 主单编辑dw-团体1','master 主单编辑dw-团体1','GDS','1-1-2005 0:0:0.000','T','');
INSERT INTO sysoption VALUES ('sc','master_edit_g2','d_gds_sc_master11','d_gds_sc_master11','master 主单编辑dw-团体2','master 主单编辑dw-团体2','GDS','1-1-2005 0:0:0.000','T','');
INSERT INTO sysoption VALUES ('sc','master_edit_g3','d_gds_sc_master12','d_gds_sc_master12','master 主单编辑dw-团体3','master 主单编辑dw-团体3','GDS','1-1-2005 0:0:0.000','T','');

-- sysoption - sc_guest edit 
INSERT INTO sysoption VALUES ('sc','guest_edit_c1','d_gds_sc_guest31','d_gds_sc_guest31','档案编辑之一 -  单位','档案编辑之一 -  单位','GDS','1-1-2005 0:0:0.000','T','');
INSERT INTO sysoption VALUES ('sc','guest_edit_c2','d_gds_sc_guest32','d_gds_sc_guest32','档案编辑之二 - 单位','档案编辑之二 - 单位','GDS','1-1-2005 0:0:0.000','T','');
INSERT INTO sysoption VALUES ('sc','guest_edit_c3','d_gds_sc_guest33','d_gds_sc_guest33','档案编辑之三 - 单位','档案编辑之三 - 单位','GDS','1-1-2005 0:0:0.000','T','');
INSERT INTO sysoption VALUES ('sc','guest_edit_f1','d_gds_sc_guest11','d_gds_sc_guest11','档案编辑之一 -  散客','档案编辑之一 -  散客','GDS','1-1-2005 0:0:0.000','T','');
INSERT INTO sysoption VALUES ('sc','guest_edit_f2','d_gds_sc_guest12','d_gds_sc_guest12','档案编辑之二 - 散客','档案编辑之二 - 散客','GDS','1-1-2005 0:0:0.000','T','');
INSERT INTO sysoption VALUES ('sc','guest_edit_f3','d_gds_sc_guest13','d_gds_sc_guest13','档案编辑之三 - 散客','档案编辑之三 - 散客','GDS','1-1-2005 0:0:0.000','T','');
INSERT INTO sysoption VALUES ('sc','guest_edit_g1','d_gds_sc_guest21','d_gds_sc_guest21','档案编辑之一 -  团体','档案编辑之一 -  团体','GDS','1-1-2005 0:0:0.000','T','');
INSERT INTO sysoption VALUES ('sc','guest_edit_g2','d_gds_sc_guest22','d_gds_sc_guest22','档案编辑之二 - 团体','档案编辑之二 - 团体','GDS','1-1-2005 0:0:0.000','T','');
INSERT INTO sysoption VALUES ('sc','guest_edit_g3','d_gds_sc_guest23','d_gds_sc_guest23','档案编辑之三 - 团体','档案编辑之三 - 团体','GDS','1-1-2005 0:0:0.000','T','');

-- sysoption - saleid edit 
INSERT INTO sysoption VALUES ('sc','saleid_edit_1','d_gds_sc_saleid1','d_gds_sc_saleid1','saleid 主单编辑dw-1','saleid 主单编辑dw-1','GDS','1-1-2005 0:0:0.000','T','');
INSERT INTO sysoption VALUES ('sc','saleid_edit_2','d_gds_sc_saleid2','d_gds_sc_saleid2','saleid 主单编辑dw-2','saleid 主单编辑dw-2','GDS','1-1-2005 0:0:0.000','T','');

-- basecode - sc_ressta --->>> 转移到单独的表 sc_ressta 
delete basecode where cat like 'sc_ressta';
//INSERT  basecode VALUES ('sc_ressta','INQ','Inquiry','Inquiry','T','F',50,'W','F');
//INSERT  basecode VALUES ('sc_ressta','ACT','Actual','Actual','T','F',100,'R','F');
//INSERT  basecode VALUES ('sc_ressta','CAN','Cancelled','Cancelled','T','F',200,'X','F');
//INSERT  basecode VALUES ('sc_ressta','DEF','Definite','Definite','T','F',300,'R','F');
//INSERT  basecode VALUES ('sc_ressta','LEA','Leads','Leads','T','F',400,'R','F');
//INSERT  basecode VALUES ('sc_ressta','LOS','Lost','Lost','T','F',500,'X','F');
//INSERT  basecode VALUES ('sc_ressta','OPT','Option','Option','T','F',600,'R','F');
//INSERT  basecode VALUES ('sc_ressta','PEN','Pending','Pending','T','F',700,'R','F');
//INSERT  basecode VALUES ('sc_ressta','TDL','Turn down Lead','Turn down Lead','T','F',750,'X','F');
//INSERT  basecode VALUES ('sc_ressta','TEN','Tentative','Tentative','T','F',800,'R','F');
//INSERT  basecode VALUES ('sc_ressta','UNC','Unable to Confirm','Unable to Confirm','T','F',900,'R','F');
//select * from  basecode where cat like 'sc_ressta';


-- basecode - htljob 
delete basecode where cat like 'htljob';
INSERT  basecode VALUES ('htljob','GM','总经理','General Manager','F','F',50,'W','F');
INSERT  basecode VALUES ('htljob','SMG','销售经理','Sales Manager','F','F',100,'R','F');
INSERT  basecode VALUES ('htljob','SAL','销售员','Sales Staff','F','F',200,'X','F');

-- basecode - territory 
delete basecode where cat like 'scterritory';
delete basecode_cat where cat like 'scterritory';
insert basecode_cat (cat,descript,descript1) values('scterritory', '销售区域', 'Sales Territory');
INSERT  basecode VALUES ('scterritory','NA','*Not Applicable','*Not Applicable','F','F',50,'','F');
INSERT  basecode VALUES ('scterritory','AS','Asia','Asia','F','F',100,'','F');
INSERT  basecode VALUES ('scterritory','EU','Europe','Europe','F','F',200,'','F');
INSERT  basecode VALUES ('scterritory','IN','International-other','International-other','F','F',300,'','F');
INSERT  basecode VALUES ('scterritory','JA','Japan','Japan','F','F',400,'','F');


----------------------------------------------------------------------------
--  basecode : sc_note_own  -- SC 备注的 own
----------------------------------------------------------------------------
update basecode set sys='F' where cat='sc_note_owner';
delete basecode where cat='sc_note_owner';
delete basecode_cat where cat='sc_note_owner';
insert basecode_cat(cat,descript,descript1,len) select 'sc_note_owner', 'SC Note Owner', 'SC Note Owner', 10;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'sc_note_owner', 'BOOKING', '预订主单', 'Booking Master','T',100;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'sc_note_owner', 'EVENT', '宴会', 'Event','T',200;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'sc_note_owner', 'ACTIVITY', '活动', 'Activity','T',300;

delete basecode where cat='sc_note_type';
delete basecode_cat where cat='sc_note_type';
insert basecode_cat(cat,descript,descript1,len) select 'sc_note_type', 'SC 备注的类别', 'SC Notes Type', 10;
insert basecode(cat,code,descript,descript1,grp,sequence) select 'sc_note_type', 'MSTBLK', 'SC 客房备注', 'SC Booking Note', 'BOOKING',100;
insert basecode(cat,code,descript,descript1,grp,sequence) select 'sc_note_type', 'MSTEVT', 'SC  宴会备注', 'SC Event Note', 'BOOKING',200;
insert basecode(cat,code,descript,descript1,grp,sequence) select 'sc_note_type', 'MSTAGR', 'SC Agreement', 'SC Agreement Note', 'BOOKING',300;
insert basecode(cat,code,descript,descript1,grp,sequence) select 'sc_note_type', 'EVT1', '宴会备注', 'Event Note', 'EVENT',400;
insert basecode(cat,code,descript,descript1,grp,sequence) select 'sc_note_type', 'ACT1', '活动备注', 'Activitiy Note', 'ACTIVITY',500 ;

