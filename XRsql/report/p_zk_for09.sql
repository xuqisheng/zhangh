
if exists (select * from sysobjects where name ='p_zk_for09' and type ='P')
	drop proc p_zk_for09;
create proc p_zk_for09
	@begin			datetime,
	@end				datetime,
	@type				char(5),
	@proom			char(1),
	@mkt			   char(200)
	
as
	
---------------------------------------------
-- ÊÐ³¡Ô¤²â
---------------------------------------------

	
if @mkt = ''
	select @mkt = '%'

--
create table #for09 ( mkt  char(10)  not null,
							 rnum   money  not null,
							 rsum	money  not null,
							 vrate		money		 not null,
							 rnum1   money  not null,
							 rsum1	money  not null,
							 vrate1		money		 not null,
							 rnum2   money  not null,
							 rsum2	money  not null,
							 vrate2		money		 not null,
							 rnum3   money  not null,
							 rsum3	money  not null,
							 vrate3		money		 not null)

insert #for09 select code,0,0,0,0,0,0,0,0,0,0,0,0 from mktcode where (charindex(code,@mkt)>0 or @mkt = '%') order by sequence ,code



update #for09 set rnum=isnull((select sum(a.quantity) from rsvsaccnt a, master b where a.begin_<>a.end_ and @begin <= a.begin_ and a.type not in (select type from typim where tag='P') and @end >= a.begin_ and a.accnt=b.accnt
											and b.restype in (select code from restype where definite = 'T') and rtrim(#for09.mkt)=rtrim(b.market) and b.class = 'F'),0)
update #for09 set rnum=rnum+isnull((select sum(a.quantity) from rsvsaccnt a, sc_master b where a.begin_<>a.end_ and @begin <= a.begin_ and a.type not in (select type from typim where tag='P') and @end >= a.begin_ and a.accnt=b.accnt
											and b.restype in (select code from restype where definite = 'T') and rtrim(#for09.mkt)=rtrim(b.market) and b.class = 'F'),0)
update #for09 set rsum=isnull((select sum(a.rate*a.quantity) from rsvsrc a,master b where a.accnt = b.accnt and @begin <= a.begin_ and a.type not in (select type from typim where tag='P') and @end >= a.begin_ and rtrim(#for09.mkt)=rtrim(a.market)
											and b.restype in (select code from restype where definite = 'T') and b.class = 'F'),0)
update #for09 set rsum=rsum+isnull((select sum(a.rate*a.quantity) from rsvsrc a,sc_master b where a.accnt = b.accnt and @begin <= a.begin_ and a.type not in (select type from typim where tag='P') and @end >= a.begin_ and rtrim(#for09.mkt)=rtrim(a.market)
											and b.restype in (select code from restype where definite = 'T') and b.class = 'F'),0)

update #for09 set rnum1=isnull((select sum(a.quantity) from rsvsaccnt a, master b where a.begin_<>a.end_ and @begin <= a.begin_ and a.type not in (select type from typim where tag='P') and @end >= a.begin_ and a.accnt=b.accnt
											and b.restype not in (select code from restype where definite = 'T') and rtrim(#for09.mkt)=rtrim(b.market) and b.class = 'F'),0)
update #for09 set rnum1=rnum1+isnull((select sum(a.quantity) from rsvsaccnt a, sc_master b where a.begin_<>a.end_ and @begin <= a.begin_ and a.type not in (select type from typim where tag='P') and @end >= a.begin_ and a.accnt=b.accnt
											and b.restype not in (select code from restype where definite = 'T') and rtrim(#for09.mkt)=rtrim(b.market) and b.class = 'F'),0)
update #for09 set rsum1=isnull((select sum(a.rate*a.quantity) from rsvsrc a,master b where a.accnt = b.accnt and @begin <= a.begin_ and a.type not in (select type from typim where tag='P') and @end >= a.begin_ and rtrim(#for09.mkt)=rtrim(a.market)
											and b.restype not in (select code from restype where definite = 'T') and b.class = 'F'),0)
update #for09 set rsum1=rsum1+isnull((select sum(a.rate*a.quantity) from rsvsrc a,sc_master b where a.accnt = b.accnt and @begin <= a.begin_ and a.type not in (select type from typim where tag='P') and @end >= a.begin_ and rtrim(#for09.mkt)=rtrim(a.market)
											and b.restype not in (select code from restype where definite = 'T') and b.class = 'F'),0)

update #for09 set rnum2=isnull((select sum(a.quantity) from rsvsaccnt a, master b where a.begin_<>a.end_ and @begin <= a.begin_ and a.type not in (select type from typim where tag='P') and @end >= a.begin_ and a.accnt=b.accnt
											and b.restype in (select code from restype where definite = 'T') and rtrim(#for09.mkt)=rtrim(b.market) and b.class <> 'F'),0)
update #for09 set rnum2=rnum2+isnull((select sum(a.quantity) from rsvsaccnt a, sc_master b where a.begin_<>a.end_ and @begin <= a.begin_ and a.type not in (select type from typim where tag='P') and @end >= a.begin_ and a.accnt=b.accnt
											and b.restype in (select code from restype where definite = 'T') and rtrim(#for09.mkt)=rtrim(b.market) and b.class <> 'F'),0)
update #for09 set rsum2=isnull((select sum(a.rate*a.quantity) from rsvsrc a,master b where a.accnt = b.accnt and @begin <= a.begin_ and a.type not in (select type from typim where tag='P') and @end >= a.begin_ and rtrim(#for09.mkt)=rtrim(a.market)
											and b.restype in (select code from restype where definite = 'T') and b.class <> 'F'),0)
update #for09 set rsum2=rsum2+isnull((select sum(a.rate*a.quantity) from rsvsrc a,sc_master b where a.accnt = b.accnt and @begin <= a.begin_ and a.type not in (select type from typim where tag='P') and @end >= a.begin_ and rtrim(#for09.mkt)=rtrim(a.market)
											and b.restype in (select code from restype where definite = 'T') and b.class <> 'F'),0)

update #for09 set rnum3=isnull((select sum(a.quantity) from rsvsaccnt a, master b where a.begin_<>a.end_ and @begin <= a.begin_ and a.type not in (select type from typim where tag='P') and @end >= a.begin_ and a.accnt=b.accnt
											and b.restype not in (select code from restype where definite = 'T') and rtrim(#for09.mkt)=rtrim(b.market) and b.class <> 'F'),0)
update #for09 set rnum3=rnum3+isnull((select sum(a.quantity) from rsvsaccnt a, sc_master b where a.begin_<>a.end_ and @begin <= a.begin_ and a.type not in (select type from typim where tag='P') and @end >= a.begin_ and a.accnt=b.accnt
											and b.restype not in (select code from restype where definite = 'T') and rtrim(#for09.mkt)=rtrim(b.market) and b.class <> 'F'),0)
update #for09 set rsum3=isnull((select sum(a.rate*a.quantity) from rsvsrc a,master b where a.accnt = b.accnt and @begin <= a.begin_ and a.type not in (select type from typim where tag='P') and @end >= a.begin_ and rtrim(#for09.mkt)=rtrim(a.market)
											and b.restype not in (select code from restype where definite = 'T') and b.class <> 'F'),0)
update #for09 set rsum3=rsum3+isnull((select sum(a.rate*a.quantity) from rsvsrc a,sc_master b where a.accnt = b.accnt and @begin <= a.begin_ and a.type not in (select type from typim where tag='P') and @end >= a.begin_ and rtrim(#for09.mkt)=rtrim(a.market)
											and b.restype not in (select code from restype where definite = 'T') and b.class <> 'F'),0)


update #for09 set vrate=rsum/rnum where rnum<>0
update #for09 set vrate1=rsum1/rnum1 where rnum1<>0
update #for09 set vrate2=rsum2/rnum2 where rnum2<>0
update #for09 set vrate3=rsum3/rnum3 where rnum3<>0


select * from #for09


;




