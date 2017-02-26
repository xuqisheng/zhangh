
// --------------------------------------------------------------------------
//  basecode : phone_grade  -- �绰�ȼ�
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='phone_grade')
	delete basecode_cat where cat='phone_grade';
insert basecode_cat select 'phone_grade', '�绰�ȼ�', 'Phone Grade', 1;
delete basecode where cat='phone_grade';
insert basecode(cat,code,descript,descript1,sequence,sys) values('phone_grade', '0', '����', '����_eng', 10,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('phone_grade', '1', '�л�', '�л�_eng', 20,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('phone_grade', '2', '����', '����_eng', 30,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('phone_grade', '3', '����', '����_eng', 40,'T');


// --------------------------------------------------------------------------
//  basecode : vod_grade  -- VOD�ȼ�
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='vod_grade')
	delete basecode_cat where cat='vod_grade';
insert basecode_cat select 'vod_grade', 'VOD �ȼ�', 'VOD Grade', 1;
delete basecode where cat='vod_grade';
insert basecode(cat,code,descript,descript1,sequence,sys) values('vod_grade', '0', '�ر�', '�ر�_eng', 10,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('vod_grade', '1', 'һ��', 'һ��_eng', 20,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('vod_grade', '2', '����', '����_eng', 30,'T');


// --------------------------------------------------------------------------
//  basecode : int_grade  -- Internet �ȼ�
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='int_grade')
	delete basecode_cat where cat='int_grade';
insert basecode_cat select 'int_grade', 'Internet �ȼ�', 'Internet Grade', 1;
delete basecode where cat='int_grade';
insert basecode(cat,code,descript,descript1,sequence,sys) values('int_grade', '0', '�ر�', '�ر�_eng', 10,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('int_grade', '1', 'һ��', 'һ��_eng', 20,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('int_grade', '2', '����', '����_eng', 30,'T');

// --------------------------------------------------------------------------
//  basecode : bar_grade  -- Mini Bar �ȼ�
// --------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat='bar_grade')
	delete basecode_cat where cat='bar_grade';
insert basecode_cat select 'bar_grade', 'Mini Bar �ȼ�', 'Mini Bar Grade', 1;
delete basecode where cat='bar_grade';
insert basecode(cat,code,descript,descript1,sequence,sys) values('bar_grade', '0', '�ر�', '�ر�_eng', 10,'T');
insert basecode(cat,code,descript,descript1,sequence,sys) values('bar_grade', '1', '��', '��_eng', 20,'T');

