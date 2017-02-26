IF OBJECT_ID('dbo.p_clg_act_bal_rep') IS NOT NULL
    DROP PROCEDURE dbo.p_clg_act_bal_rep
;
create proc p_clg_act_bal_rep
	@foset		char(1),
	@folist		char(60),
	@arset		char(1),
	@arlist		char(60),
	@checkout	char(1),
	@sta			char(10),
	@dbegin		datetime,
	@dend			datetime
as
declare
	@artags		char(30),
	@artag_grps	char(30),
	@pos			int,
	@tmp			char(255),
	@rm			money,
	@fb			money,
	@ot			money
---房价，信用，VIP，联房，房费，餐费，付款方式，公司，主单信息，档案信息
create table #gtmp	 (	accnt	char(10),
								rm			money null,
								fb			money null,
								ot			money null,
								charge	money		not null,
							  	credit	money 	not null )

if charindex(',AG', @arlist)>0 or charindex(',AT', @arlist)>0
	begin
	-- artag1
	if charindex(',AT*,', @arlist)>0 or charindex(',AT:', @arlist)=0
		select @artags = ''
	else if charindex(',AT:', @arlist)>0
	begin
		select @pos = charindex(',AT:', @arlist)
		select @tmp = stuff(@arlist, 1, @pos+3, '')
		select @pos = charindex(',', @tmp)
		select @artags = substring(@tmp, 1, @pos-1)
	end
	-- artag1 grp
	if charindex(',AG*,', @arlist)>0 or charindex(',AG:', @arlist)=0
		select @artag_grps = ''
	else if charindex(',AG:', @arlist)>0
	begin
		select @pos = charindex(',AG:', @arlist)
		select @tmp = stuff(@arlist, 1, @pos+3, '')
		select @pos = charindex(',', @tmp)
		select @artag_grps = substring(@tmp, 1, @pos-1)
	end
end


if @foset = 'T'
	begin
	insert into #gtmp(accnt,charge,credit) select a.accnt,sum(a.charge),sum(a.credit)
		from account a,master b where a.accnt=b.accnt and (datediff(dd,b.dep,@dbegin)<=0 or @dbegin='') and (datediff(dd,b.dep,@dend)>=0 or @dend='')
		 and ((@checkout='T' and a.billno<>'') or a.billno='') and (rtrim(@folist) is null or charindex(b.class,@folist)>0) and (charindex(b.sta,@sta)>0 or rtrim(@sta) is null) group by a.accnt order by a.accnt

	update #gtmp set rm = isnull((SELECT sum(a.charge) FROM account a,pccode b where #gtmp.accnt=a.accnt and ((@checkout='T' and a.billno<>'') or a.billno='') and a.pccode=b.pccode and b.deptno7='rm'),0)
	update #gtmp set fb = isnull((SELECT sum(a.charge) FROM account a,pccode b where #gtmp.accnt=a.accnt and ((@checkout='T' and a.billno<>'') or a.billno='') and a.pccode=b.pccode and b.deptno7='fb'),0)
	update #gtmp set ot = charge - rm - fb
	end
if @arset = 'T'
	begin
	insert into #gtmp(accnt,charge,credit) select a.ar_accnt,sum(a.charge),sum(a.credit)
		from ar_account a,ar_master c,basecode e where a.ar_accnt=c.accnt and a.ar_subtotal='F' and (@checkout='T' or (a.charge9=0 and a.credit9=0))
		  and (@artag_grps='' or charindex(rtrim(e.grp), @artag_grps)>0)	and (@artags='' or charindex(rtrim(c.artag1), @artags)>0)
			and c.artag1=e.code and  e.cat='artag1' group by a.ar_accnt order by a.ar_accnt

	update #gtmp set rm = isnull((SELECT sum(a.charge) FROM ar_account a,pccode b where #gtmp.accnt=a.ar_accnt and a.ar_subtotal='F' and (@checkout='T' or (a.charge9=0 and a.credit9=0)) and a.pccode=b.pccode and b.deptno7='rm'),0)
	update #gtmp set fb = isnull((SELECT sum(a.charge) FROM ar_account a,pccode b where #gtmp.accnt=a.ar_accnt and a.ar_subtotal='F' and (@checkout='T' or (a.charge9=0 and a.credit9=0)) and a.pccode=b.pccode and b.deptno7='fb'),0)
	update #gtmp set ot = charge - rm - fb
	end

if @foset = 'T'
	select b.sta,a.accnt,a.rm,a.fb,a.ot,a.charge,a.credit,a.charge - a.credit,b.arr,b.dep,b.roomno,b.setrate,b.pcrec,b.paycode,b.limit,c.haccnt,c.cusno,e.descript from #gtmp a,master b,master_des c,guest d,basecode e where a.accnt=b.accnt and b.accnt=c.accnt and b.haccnt=d.no and d.vip=e.code and e.cat='vip' order by a.accnt
else
	select b.sta,a.accnt,a.rm,a.fb,a.ot,a.charge,a.credit,a.charge - a.credit,b.arr,b.dep,b.paycode,b.limit,c.name from #gtmp a,ar_master b,guest c where a.accnt=b.accnt and b.haccnt=c.no order by a.accnt
;
