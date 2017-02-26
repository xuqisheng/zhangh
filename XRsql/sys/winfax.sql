--------------------------------------------------------------------------------
--  winfax status
--------------------------------------------------------------------------------
if exists(select 1 from basecode_cat where cat = 'winfax_status')
	delete basecode_cat where cat = 'winfax_status';
insert basecode_cat(cat,descript,descript1,len) select 'winfax_status', '传真状态', 'winfax status', 1;

delete basecode where cat = 'winfax_status';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'winfax_status','2','未知','Unknow','T','F',2,'0';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'winfax_status','3','完成','Complete','T','F',3,'0';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'winfax_status','4','失败','Failed','T','F',4,'0';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'winfax_status','5','挂起','Holding','T','F',5,'0';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'winfax_status','6','等侯在服务器端','Waiting at server','T','F',6,'0';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'winfax_status','7','正在接收','Recurring','T','F',7,'0';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'winfax_status','8','正在发送','Sending','T','F',8,'0';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'winfax_status','9','群发','Group Send','T','F',9,'0';
insert basecode(cat,code,descript,descript1,sys,halt,sequence,grp) 
	select 'winfax_status','10','未决的','pending','T','F',10,'0';
