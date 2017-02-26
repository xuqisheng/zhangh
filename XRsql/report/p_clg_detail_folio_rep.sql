IF OBJECT_ID('dbo.p_clg_detail_folio_rep') IS NOT NULL
    DROP PROCEDURE dbo.p_clg_detail_folio_rep
;
create proc p_clg_detail_folio_rep
	@reptype		char(1),			--L 明细；S汇总；Z复合
	@foset		char(1),
	@folist		char(60),
	@arset		char(1),
	@arlist		char(60),
	@checkout	char(1),
	@dbegin		datetime,
	@dend			datetime
as
declare
	@artags		char(30),
	@artag_grps	char(30),
	@pos			int,
	@tmp			char(255)
create table #gtmp	 (	code	int, 			--0 明细；1 汇总
								accnt	char(10),
								arr	datetime null,
								dep	datetime null,
								roomno  		char(05) null,
								name	char(50) null,
								pccode	char(5) null,
								date	datetime,
								ref			varchar(100) null,
								ref1	char(10) null,
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

if @reptype='L' or @reptype='Z'
	begin
	if @foset = 'T'
		begin
		insert into #gtmp select 1,a.accnt,c.arr,c.dep,c.roomno,b.haccnt,a.pccode,a.date,rtrim(a.ref)+' '+a.ref2,a.ref1,a.charge,a.credit
			from account a,master_des b,master c where a.accnt=b.accnt and b.accnt=c.accnt and datediff(dd,b.dep,@dbegin)<=0 and datediff(dd,b.dep,@dend)>=0
			 and ((@checkout='T' and a.billno<>'') or a.billno='') and (rtrim(@folist) is null or charindex(c.class,@folist)>0)
		end
	if @arset = 'T'
		begin
		insert into #gtmp select 1,c.accnt,c.arr,c.dep,'',d.name,a.pccode,a.date,rtrim(a.ref)+' '+a.ref2,a.ref1,a.charge+a.charge0 - a.charge9,a.credit+a.credit0 - a.credit9
--			from ar_account a,ar_master c,guest d,basecode e where a.ar_accnt=c.accnt and c.haccnt=d.no and a.ar_subtotal='F'
			-- modi by xjg 100115 用于显示摘要信息  ar_account不体现
			from ar_detail a,ar_master c,guest d,basecode e where a.accnt=c.accnt and c.haccnt=d.no --and a.ar_subtotal='F'
			-- modi by xjg 100115 (@checkout='T' or (a.charge9=0 and a.credit9=0)) -> 
		   and (@checkout='T' or ((a.charge9=0 and a.credit9=0) or (a.charge+a.charge0 - a.charge9<>0) or (a.credit+a.credit0 - a.credit9<>0))) and (@artag_grps='' or charindex(rtrim(e.grp), @artag_grps)>0)
			and (@artags='' or charindex(rtrim(c.artag1), @artags)>0) and c.artag1=e.code and  e.cat='artag1'
		end
	end
if @reptype='S' or @reptype='Z'
	begin
	if @foset = 'T'
		begin
		insert into #gtmp(code,accnt,pccode,date,charge,credit) select 0,a.accnt,a.pccode,null,sum(a.charge),sum(a.credit)
			from account a,master b where a.accnt=b.accnt and datediff(dd,b.dep,@dbegin)<=0 and datediff(dd,b.dep,@dend)>=0
			 and ((@checkout='T' and a.billno<>'') or a.billno='') and (rtrim(@folist) is null or charindex(b.class,@folist)>0) group by a.accnt,a.pccode order by a.accnt,a.pccode

		update #gtmp set arr=c.arr,dep=c.dep,roomno=c.roomno,name=b.haccnt,ref=a.ref from account a,master_des b,master c where #gtmp.accnt=a.accnt and a.accnt=b.accnt and b.accnt=c.accnt and #gtmp.pccode=a.pccode and #gtmp.code=0
		end
	if @arset = 'T'
		begin
		insert into #gtmp(code,accnt,pccode,date,charge,credit) select 0,a.accnt,a.pccode,null,sum(a.charge+a.charge0 - a.charge9),sum(a.credit+a.credit0 - a.credit9)
--			from ar_account a,ar_master c,basecode e where a.ar_accnt=c.accnt and a.ar_subtotal='F' and (@checkout='T' or (a.charge9=0 and a.credit9=0))
			from ar_detail a,ar_master c,guest d,basecode e where a.accnt=c.accnt and c.haccnt=d.no --and a.ar_subtotal='F'
				and (@checkout='T' or ((a.charge9=0 and a.credit9=0) or (a.charge+a.charge0 - a.charge9<>0) or (a.credit+a.credit0 - a.credit9<>0)))
			  and (@artag_grps='' or charindex(rtrim(e.grp), @artag_grps)>0)	and (@artags='' or charindex(rtrim(c.artag1), @artags)>0)
				and c.artag1=e.code and  e.cat='artag1' group by a.accnt,a.pccode order by a.accnt,a.pccode

		update #gtmp set arr=c.arr,dep=c.dep,roomno='',name=d.name,ref=a.ref from ar_account a,ar_master c,guest d where #gtmp.accnt=c.accnt and c.haccnt=d.no and #gtmp.pccode=a.pccode and #gtmp.code=0
		end
	end


select * from #gtmp order by accnt,code desc,pccode
;
