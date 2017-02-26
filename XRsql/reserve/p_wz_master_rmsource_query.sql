IF OBJECT_ID('dbo.p_wz_master_rmsource_query') IS NOT NULL
    DROP PROCEDURE dbo.p_wz_master_rmsource_query
   ;
create proc p_wz_master_rmsource_query
		@accnt 		char(10),
		@language	integer
as
------------------------------------------------
--	团体客房资源显示 
------------------------------------------------
declare
	@arr			datetime,
	@dep			datetime,
	@wdate		datetime,
	@dategap		integer,
	@i				integer


create table #woutput0
(	date_			datetime,   -- 2004/08/31
	rmtype		char(4)	default '',
	resnum		money		default 0,	  --预留的房数
	cnum			money		default 0,	  --拆分的房数
	cnum1			money		default 0,	  --拆分的房数(一房多人)
	inum			money		default 0,    --入住的房数
	gaccnt		char(10) default ''
)

create table #woutput1
(	date_			datetime,   -- 2004/08/31
	rmtype		char(4)	default '',
	resnum		money		default 0,
	cnum			money		default 0,	  --拆分的房数
	cnum1			money		default 0,	  --拆分的房数(一房多人)
	inum			money		default 0,    --入住的房数
	gaccnt		char(10) default ''
)

if exists(select 1 from master where sta in ('I','R') and accnt = @accnt )
	select @arr = arr ,@dep = dep from master where sta in ('I','R') and accnt = @accnt

select @wdate = @arr

if datediff(dd,@arr,@dep) > 0
begin
	while datediff(dd,@wdate,@dep) >=0
	begin
--init data
		insert #woutput0 (date_,rmtype) select @wdate,type from typim order by type
--get data
		insert #woutput1(date_,rmtype,resnum) select @wdate,b.type,sum(b.quantity) from rsvsrc b,master a
			where a.accnt = @accnt and a.accnt = b.accnt and a.sta in ('R','I')
				and class in ('G','M')
				and datediff(dd,begin_,@wdate)>=0 and datediff(dd,end_,@wdate)<0
				group by b.type

		insert #woutput1(date_,rmtype,cnum) select @wdate,a.type, sum(a.rmnum) from master a
			where  a.sta ='R' and a.class = 'F' and a.groupno = @accnt and roomno = ''
				and datediff(dd,a.arr,@wdate)>=0 and datediff(dd,a.dep,@wdate)<0
				group by a.type

		insert #woutput1(date_,rmtype,cnum1) select @wdate,a.type, count(distinct a.roomno) from master a
			where  a.sta ='R' and a.class = 'F' and a.groupno = @accnt and roomno <> ''
				and datediff(dd,a.arr,@wdate)>=0 and datediff(dd,a.dep,@wdate)<0
				group by a.type

		insert #woutput1(date_,rmtype,inum) select @wdate,a.type,sum(a.rmnum) from master a
			where  a.sta ='I' and a.class = 'F' and a.groupno = @accnt and accnt = master
				and datediff(dd,a.arr,@wdate)>=0 and datediff(dd,a.dep,@wdate)<0
				group by a.type

		select @wdate = dateadd(dd,1,@wdate)
	end
end



update #woutput0 set resnum = a.resnum  from #woutput1 a
		where datediff(dd,#woutput0.date_,a.date_) = 0 and #woutput0.rmtype = a.rmtype

update #woutput0 set cnum = a.cnum from #woutput1 a
		where datediff(dd,#woutput0.date_,a.date_) = 0 and #woutput0.rmtype = a.rmtype
		and a.cnum > 0

update #woutput0 set cnum1 = a.cnum1 from #woutput1 a
		where datediff(dd,#woutput0.date_,a.date_) = 0 and #woutput0.rmtype = a.rmtype
		and a.cnum1 > 0

update #woutput0 set inum = a.inum   from #woutput1 a
		where datediff(dd,#woutput0.date_,a.date_) = 0 and #woutput0.rmtype = a.rmtype
		and a.inum > 0



--filter data = 0

update #woutput0 set resnum = a.resnum ,cnum = a.cnum ,cnum1 = a.cnum1 ,inum = a.inum
		from grp_rmsource  a
		where datediff(dd,#woutput0.date_,a.bdate) = 0 and  a.gaccnt = @accnt and #woutput0.rmtype = a.rmtype

delete #woutput0 where resnum = 0 and cnum = 0 and cnum1 = 0 and inum = 0


select convert(char(10),a.date_,111),b.sequence, a.rmtype,a.resnum,a.cnum+a.cnum1,a.inum from #woutput0 a, typim b
	where a.rmtype=b.type  order by a.date_,b.sequence, a.rmtype

return 0
;