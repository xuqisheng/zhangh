
-- Table 
//if exists(select 1 from sysobjects where name = 'grp_rmsource')  
//	drop table grp_rmsource ;
//create table grp_rmsource
//(	
//	bdate			datetime,   -- 2004/08/31
//	gaccnt		char(10) default '',
//	rmtype		char(4)	default '',
//	resnum		money		default 0,	  --预留的房数
//	cnum			money		default 0,	  --拆分的房数
//	cnum1			money		default 0,	  --拆分的房数(一房多人)
//	inum			money		default 0     --入住的房数
//);
//create unique index index1 on grp_rmsource(bdate,gaccnt,rmtype) ;
//create  index index2 on grp_rmsource(bdate,gaccnt,rmtype) ;

-- Proc
If object_id('dbo.p_wz_audit_grp_rmsource_create') Is Not null
	drop Procedure dbo.p_wz_audit_grp_rmsource_create
;
Create proc p_wz_audit_grp_rmsource_create
as
----------------------------------------------------------------------
-- 为了团队资源清单，需保存有效团队在本营业日期之前的资源情况
-- Modified By: wz	Date: 2006.01.09
----------------------------------------------------------------------
--放在夜审dllmaster过程之后,此过程允许重建
----------------------------------------------------------------------
Declare
	@accnt		char(10),
	@bdate		DateTime,
	@audit		char(1)

Create table #woutput0
(	date_			DateTime,   -- 2004/08/31
	rmtype		Char(4)	Default '',
	resnum		money		Default 0,	  --
	cnum			money		Default 0,	  --
	cnum1			money		Default 0,	  --拆分的房数(一房多人)
	inum			money		Default 0     --
)

Create table #woutput1
(	date_			DateTime,   -- 2004/08/31
	rmtype		Char(4)		Default '',
	resnum		money			Default 0,
	cnum			money			Default 0,	  --
	cnum1			money			Default 0,	  --拆分的房数(一房多人)
	inum			money			Default 0,     --
	gaccnt		char(10)		default ''
)

select @audit = audit from gate

if @audit = 'T'
	select @bdate = bdate from sysdata 
else
	select @bdate = dateadd(dd,-1,bdate) from sysdata

--init for rebuild
delete grp_rmsource where bdate = @bdate


declare c_grp_accnt cursor for select accnt from master_till where sta in ('R','I') and class in ('G','M') and datediff(dd,arr,@bdate) >= 0 And datediff(dd,dep,@bdate) < 0
open c_grp_accnt
fetch c_grp_accnt into @accnt 
while @@sqlstatus = 0
	begin
		
		Insert #woutput1(date_,rmtype,resnum,gaccnt) Select @bdate,b.type,sum(b.quantity),@accnt From rsvsrc_till b,master_till a
		Where a.accnt = @accnt And a.accnt = b.accnt And a.sta In ('R','I')
		And class In ('G','M')
		And datediff(dd,begin_,@bdate) >= 0 And datediff(dd,end_,@bdate) < 0
		Group By b.type
		
		Insert #woutput1(date_,rmtype,cnum,gaccnt) Select @bdate,a.type, sum(a.rmnum),@accnt From master_till a
		Where  a.sta = 'R' And a.class = 'F' And a.groupno = @accnt And roomno = ''
		And datediff(dd,a.arr,@bdate) >= 0 And datediff(dd,a.dep,@bdate) < 0
		Group By a.type
		
		Insert #woutput1(date_,rmtype,cnum1,gaccnt) Select @bdate,a.type, count(distinct a.roomno),@accnt From master_till a
		Where  a.sta = 'R' And a.class = 'F' And a.groupno = @accnt And roomno <> ''
		And datediff(dd,a.arr,@bdate) >= 0 And datediff(dd,a.dep,@bdate) < 0
		Group By a.type
		
		Insert #woutput1(date_,rmtype,inum,gaccnt) Select @bdate,a.type,sum(a.rmnum),@accnt From master_till a
		Where  a.sta = 'I' And a.class = 'F' And a.groupno = @accnt
		And datediff(dd,a.arr,@bdate) >= 0 And datediff(dd,a.dep,@bdate) < 0
		Group By a.type
		
		fetch c_grp_accnt into @accnt 	
	end
close c_grp_accnt
deallocate cursor c_grp_accnt

-- 
insert grp_rmsource(bdate,gaccnt,rmtype,resnum,cnum,cnum1,inum) 
		select date_,gaccnt,rmtype,sum(resnum),sum(cnum),sum(cnum1),sum(inum) from #woutput1
			group by date_,gaccnt,rmtype

return 0
;
	
