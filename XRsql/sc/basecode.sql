
-- moduno 
if not exists(select 1 from basecode where cat='moduno' and code='66')
	INSERT INTO basecode VALUES ('moduno','66','���������','S&C','T','F',0,'','F');

-- sysoption - sc_master edit 
INSERT INTO sysoption VALUES ('sc','master_edit_g1','d_gds_sc_master_profile','d_gds_sc_master_profile','master �����༭dw-����1','master �����༭dw-����1','GDS','1-1-2005 0:0:0.000','T','');
INSERT INTO sysoption VALUES ('sc','master_edit_g2','d_gds_sc_master11','d_gds_sc_master11','master �����༭dw-����2','master �����༭dw-����2','GDS','1-1-2005 0:0:0.000','T','');
INSERT INTO sysoption VALUES ('sc','master_edit_g3','d_gds_sc_master12','d_gds_sc_master12','master �����༭dw-����3','master �����༭dw-����3','GDS','1-1-2005 0:0:0.000','T','');

-- sysoption - sc_guest edit 
INSERT INTO sysoption VALUES ('sc','guest_edit_c1','d_gds_sc_guest31','d_gds_sc_guest31','�����༭֮һ -  ��λ','�����༭֮һ -  ��λ','GDS','1-1-2005 0:0:0.000','T','');
INSERT INTO sysoption VALUES ('sc','guest_edit_c2','d_gds_sc_guest32','d_gds_sc_guest32','�����༭֮�� - ��λ','�����༭֮�� - ��λ','GDS','1-1-2005 0:0:0.000','T','');
INSERT INTO sysoption VALUES ('sc','guest_edit_c3','d_gds_sc_guest33','d_gds_sc_guest33','�����༭֮�� - ��λ','�����༭֮�� - ��λ','GDS','1-1-2005 0:0:0.000','T','');
INSERT INTO sysoption VALUES ('sc','guest_edit_f1','d_gds_sc_guest11','d_gds_sc_guest11','�����༭֮һ -  ɢ��','�����༭֮һ -  ɢ��','GDS','1-1-2005 0:0:0.000','T','');
INSERT INTO sysoption VALUES ('sc','guest_edit_f2','d_gds_sc_guest12','d_gds_sc_guest12','�����༭֮�� - ɢ��','�����༭֮�� - ɢ��','GDS','1-1-2005 0:0:0.000','T','');
INSERT INTO sysoption VALUES ('sc','guest_edit_f3','d_gds_sc_guest13','d_gds_sc_guest13','�����༭֮�� - ɢ��','�����༭֮�� - ɢ��','GDS','1-1-2005 0:0:0.000','T','');
INSERT INTO sysoption VALUES ('sc','guest_edit_g1','d_gds_sc_guest21','d_gds_sc_guest21','�����༭֮һ -  ����','�����༭֮һ -  ����','GDS','1-1-2005 0:0:0.000','T','');
INSERT INTO sysoption VALUES ('sc','guest_edit_g2','d_gds_sc_guest22','d_gds_sc_guest22','�����༭֮�� - ����','�����༭֮�� - ����','GDS','1-1-2005 0:0:0.000','T','');
INSERT INTO sysoption VALUES ('sc','guest_edit_g3','d_gds_sc_guest23','d_gds_sc_guest23','�����༭֮�� - ����','�����༭֮�� - ����','GDS','1-1-2005 0:0:0.000','T','');

-- sysoption - saleid edit 
INSERT INTO sysoption VALUES ('sc','saleid_edit_1','d_gds_sc_saleid1','d_gds_sc_saleid1','saleid �����༭dw-1','saleid �����༭dw-1','GDS','1-1-2005 0:0:0.000','T','');
INSERT INTO sysoption VALUES ('sc','saleid_edit_2','d_gds_sc_saleid2','d_gds_sc_saleid2','saleid �����༭dw-2','saleid �����༭dw-2','GDS','1-1-2005 0:0:0.000','T','');

-- basecode - sc_ressta --->>> ת�Ƶ������ı� sc_ressta 
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
INSERT  basecode VALUES ('htljob','GM','�ܾ���','General Manager','F','F',50,'W','F');
INSERT  basecode VALUES ('htljob','SMG','���۾���','Sales Manager','F','F',100,'R','F');
INSERT  basecode VALUES ('htljob','SAL','����Ա','Sales Staff','F','F',200,'X','F');

-- basecode - territory 
delete basecode where cat like 'scterritory';
delete basecode_cat where cat like 'scterritory';
insert basecode_cat (cat,descript,descript1) values('scterritory', '��������', 'Sales Territory');
INSERT  basecode VALUES ('scterritory','NA','*Not Applicable','*Not Applicable','F','F',50,'','F');
INSERT  basecode VALUES ('scterritory','AS','Asia','Asia','F','F',100,'','F');
INSERT  basecode VALUES ('scterritory','EU','Europe','Europe','F','F',200,'','F');
INSERT  basecode VALUES ('scterritory','IN','International-other','International-other','F','F',300,'','F');
INSERT  basecode VALUES ('scterritory','JA','Japan','Japan','F','F',400,'','F');


----------------------------------------------------------------------------
--  basecode : sc_note_own  -- SC ��ע�� own
----------------------------------------------------------------------------
update basecode set sys='F' where cat='sc_note_owner';
delete basecode where cat='sc_note_owner';
delete basecode_cat where cat='sc_note_owner';
insert basecode_cat(cat,descript,descript1,len) select 'sc_note_owner', 'SC Note Owner', 'SC Note Owner', 10;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'sc_note_owner', 'BOOKING', 'Ԥ������', 'Booking Master','T',100;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'sc_note_owner', 'EVENT', '���', 'Event','T',200;
insert basecode(cat,code,descript,descript1,sys,sequence) select 'sc_note_owner', 'ACTIVITY', '�', 'Activity','T',300;

delete basecode where cat='sc_note_type';
delete basecode_cat where cat='sc_note_type';
insert basecode_cat(cat,descript,descript1,len) select 'sc_note_type', 'SC ��ע�����', 'SC Notes Type', 10;
insert basecode(cat,code,descript,descript1,grp,sequence) select 'sc_note_type', 'MSTBLK', 'SC �ͷ���ע', 'SC Booking Note', 'BOOKING',100;
insert basecode(cat,code,descript,descript1,grp,sequence) select 'sc_note_type', 'MSTEVT', 'SC  ��ᱸע', 'SC Event Note', 'BOOKING',200;
insert basecode(cat,code,descript,descript1,grp,sequence) select 'sc_note_type', 'MSTAGR', 'SC Agreement', 'SC Agreement Note', 'BOOKING',300;
insert basecode(cat,code,descript,descript1,grp,sequence) select 'sc_note_type', 'EVT1', '��ᱸע', 'Event Note', 'EVENT',400;
insert basecode(cat,code,descript,descript1,grp,sequence) select 'sc_note_type', 'ACT1', '���ע', 'Activitiy Note', 'ACTIVITY',500 ;

