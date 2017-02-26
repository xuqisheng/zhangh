
if exists (select * from sysobjects where name ='p_gl_audit_mstbalrep' and type ='P')
	drop proc p_gl_audit_mstbalrep;
create proc p_gl_audit_mstbalrep
as
--------------------------------------------------------
-- 简易余额表, 支持新应收
--------------------------------------------------------

declare
	@bdate			datetime,
	@duringaudit	char(1)

-- 
select @duringaudit = audit from gate
if @duringaudit = 'T'
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead

-- 
delete mstbalrep

-- Master
insert mstbalrep (date,accnt, roomno, groupno, sta, name, arr, dep, tillbl,payment,ref)
	select @bdate, a.accnt, a.roomno, a.groupno, a.sta, isnull(b.name, ''), a.arr, a.dep, a.charge - a.credit, a.paycode, a.ref
	from master_till a, guest b where a.sta != 'D' and a.haccnt *= b.no
update mstbalrep set group_des = a.groupno, cus_des = a.cusno, agent_des = a.agent, source_des = a.source
	from master_des a where mstbalrep.accnt = a.accnt
update mstbalrep set lastbl = a.charge - a.credit from master_last a where mstbalrep.accnt = a.accnt

-- Ar_Master
insert mstbalrep (date, accnt, roomno, groupno, sta, name, arr, dep, tillbl,payment,ref,artag1,artag1_grp)
	select @bdate, a.accnt, '', '', a.sta, isnull(b.name, ''), a.arr, a.dep, a.charge - a.credit, a.paycode, a.ref, a.artag1, isnull(c.grp,'')  
	from ar_master_till a, guest b, basecode c where a.sta != 'D' and a.haccnt *= b.no and a.artag1*=c.code and  c.cat='artag1' 
update mstbalrep set lastbl = a.charge - a.credit from ar_master_last a where mstbalrep.accnt = a.accnt

--
update mstbalrep set charge = (select isnull(sum(a.charge), 0) from gltemp a where a.accnt = mstbalrep.accnt)
update mstbalrep set credit = (select isnull(sum(a.credit), 0) from gltemp a where a.accnt = mstbalrep.accnt)

--
delete mstbalrep where tillbl=0 and charge=0 and credit=0 and lastbl=0 

-- 
update mstbalrep set date = @bdate
delete ymstbalrep where  date = @bdate
insert ymstbalrep select * from mstbalrep

return 0
;

//exec p_gl_audit_mstbalrep; 
//select * from mstbalrep; 
//select * from ymstbalrep; 
