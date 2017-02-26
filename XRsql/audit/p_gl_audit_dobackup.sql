
if exists (select * from sysobjects where name = 'p_gl_audit_dobackup' and type ='P')
   drop proc p_gl_audit_dobackup;

create proc p_gl_audit_dobackup
as

begin tran 
save  tran p_gl_audit_dobackup_s1

-- 这里团体散客需要分开处理，待续... 
update master set qtrate = a.rate from rmsta a where master.accnt like 'F%' and master.roomno = a.roomno

-- master backup
delete master_last
insert master_last select * from master_till
delete master_till 
insert master_till select * from master

-- master_des backup
delete master_des_last
insert master_des_last select * from master_des_till
delete master_des_till 
insert master_des_till select * from master_des

-- ar_master backup
delete ar_master_last
insert ar_master_last select * from ar_master_till
delete ar_master_till 
insert ar_master_till select * from ar_master

-- rmsta backup
delete rmsta_last
insert rmsta_last select * from rmsta_till
delete rmsta_till 
insert rmsta_till select * from rmsta

-- rsvsrc backup
delete rsvsrc_last
insert rsvsrc_last select * from rsvsrc_till
delete rsvsrc_till 
insert rsvsrc_till select * from rsvsrc

-- sc_master backup
delete sc_master_last
insert sc_master_last select * from sc_master_till
delete sc_master_till 
insert sc_master_till select * from sc_master

commit tran 

return 0
;

