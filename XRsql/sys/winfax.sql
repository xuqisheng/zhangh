--------------------------------------------------------------------------------
--  winfax status
--------------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat = 'winfax_status')
	delete basecode_cat where cat = 'winfax_status';
insert basecode_cat(cat,descript,descript1,len) select 'winfax_status', '����״̬', 'winfax status', 1;

delete basecode where cat = 'winfax_status';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'winfax_status','2','δ֪','Unknow','T','F',2,'0';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'winfax_status','3','���','Complete','T','F',3,'0';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'winfax_status','4','ʧ��','Failed','T','F',4,'0';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'winfax_status','5','����','Holding','T','F',5,'0';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'winfax_status','6','�Ⱥ��ڷ�������','Waiting at server','T','F',6,'0';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'winfax_status','7','���ڽ���','Recurring','T','F',7,'0';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'winfax_status','8','���ڷ���','Sending','T','F',8,'0';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'winfax_status','9','Ⱥ��','Group Send','T','F',9,'0';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'winfax_status','10','δ����','pending','T','F',10,'0';
