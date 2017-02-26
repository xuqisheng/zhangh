
if exists (select * from sysobjects where name ='p_zk_gzhx_stt_day' and type ='P')
	drop proc p_zk_gzhx_stt_day;
create proc p_zk_gzhx_stt_day
	@begin			datetime,
	@code_type		char(10),
	@code_class		char(1) = 'D',
	@sd				char(1) = 'D'
	
as
	
---------------------------------------------
-- �ۺ����ݷ�������(�ձ�)
---------------------------------------------
declare
	@bdate		datetime,
	@mbegin		datetime,
	@mend			datetime,
	@ybegin		datetime,
	@yend			datetime,
	@the_dat		datetime,
	@num			int,
	@totalfee		money,
	@totalrn		money,
	@sumrm		int,
	@long			int,
	@cday			datetime,
	@temp			char(10),
	@cnum			int

select @mbegin=convert(datetime,substring(convert(char(8),dateadd(mm,0,@begin),112),1,6)+'01')
select @mend=dateadd(dd,-1,dateadd(mm,1,convert(datetime,substring(convert(char(8),dateadd(mm,0,@begin),112),1,6)+'01')))

select @ybegin = convert(datetime,substring(convert(char(8),dateadd(mm,-12,@begin),112),1,6)+'01')
select @yend = dateadd(dd,-1,dateadd(mm,1,convert(datetime,substring(convert(char(8),dateadd(mm,-12,@begin),112),1,6)+'01')))

//select @mbegin,@mend,@ybegin,@yend

create table #t1
		(code_d		char(50),
		 code			char(10),
		 class_d		char(50),
		 class		char(10),
		 flag			char(1),
		 drn			money,	--����
		 drate		money,	--����
		 dtv			money,	--����
		 drn_s		integer,	--����
		 dpn			integer,	--����
		 dpn_s		money,	--�˴�
		 dpv			money,	--����
		 mrn			money,
		 mrate		money,
		 mtv			money,
		 mrn_s		integer,
		 mpn			integer,
		 mpn_s		money,
		 mpv			money,
		 yrn			money null,
		 yrate		money,
		 ytv			money,
		 yrn_s		integer,
		 ypn			integer,
		 ypn_s		money,
		 ypv			money,
		 seq			integer)


if @code_type = 'mktcode'
	begin
	insert #t1 select rtrim(code) +' - '+ descript,code,'',grp,'D',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,sequence from mktcode where halt = 'F'
	update #t1 set class_d =  rtrim(basecode.code) +' - '+ basecode.descript from basecode where cat = 'market_cat' and rtrim(basecode.code) = rtrim(#t1.class)
	end
else if @code_type = 'src'
	begin
	insert #t1 select rtrim(code) +' - '+ descript,code,'',grp,'D',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,sequence from srccode where halt = 'F'
	update #t1 set class_d =  rtrim(basecode.code) +' - '+ basecode.descript from basecode where cat = 'src_cat' and rtrim(basecode.code) = rtrim(#t1.class)
	end
else if @code_type = 'ratecode'
	begin
	insert #t1 select rtrim(code) +' - '+ descript,code,'',cat,'D',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,sequence from rmratecode where halt = 'F'
	update #t1 set class_d =  rtrim(basecode.code) +' - '+ basecode.descript from basecode where cat = 'rmratecat' and rtrim(basecode.code) = rtrim(#t1.class)
	end
else if @code_type = 'type'
	begin
	insert #t1 select rtrim(type) +' - '+ descript,type,'',gtype,'D',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,sequence from typim where halt = 'F'
	update #t1 set class_d =  rtrim(gtype.code) +' - '+ gtype.descript from gtype where rtrim(gtype.code) = rtrim(#t1.class)
	end


if @code_type = 'mktcode'
	begin	
	update #t1 set drn = isnull((select sum(quantity) from rmuserate where date = @begin and rtrim(market) = rtrim(#t1.code) group by date,market),0)
	update #t1 set drate = isnull((select sum(rmrate) from rmuserate where date = @begin and rtrim(market) = rtrim(#t1.code) group by date,market),0)
	update #t1 set dtv = drate/drn where drn <> 0
	update #t1 set drn_s = isnull((select count(distinct roomno) from ycus_xf where date = @begin and rtrim(market) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' ),0)
	update #t1 set dpn = isnull((select sum(gstno) from ycus_xf where date = @begin and rtrim(market) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' group by date,market),0)
	update #t1 set dpn_s = isnull((select sum(gstno) from ycus_xf where date = @begin and rtrim(market) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by date,market),0)
	update #t1 set dpv = isnull((select sum(datediff(dd,arr,dep)) from ycus_xf where date = @begin and rtrim(market) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by date,market),0)/dpn_s where dpn_s <> 0
	
	update #t1 set mrn = isnull((select sum(quantity) from rmuserate where date >= @mbegin and date <= @mend and rtrim(market) = rtrim(#t1.code) group by market),0)
	update #t1 set mrate = isnull((select sum(rmrate) from rmuserate where date >= @mbegin and date <= @mend and rtrim(market) = rtrim(#t1.code) group by market),0)
	update #t1 set mtv = mrate/mrn where mrn <> 0
	update #t1 set mrn_s = isnull((select count(distinct roomno) from ycus_xf where date >= @mbegin and date <= @mend and rtrim(market) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T'),0)
	update #t1 set mpn = isnull((select sum(gstno) from ycus_xf where date >= @mbegin and date <= @mend and rtrim(market) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' group by market),0)
	update #t1 set mpn_s = isnull((select sum(gstno) from ycus_xf where date >= @mbegin and date <= @mend and rtrim(market) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by market),0)
	update #t1 set mpv = isnull((select sum(datediff(dd,arr,dep)) from ycus_xf where date >= @mbegin and date <= @mend and rtrim(market) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by market),0)/mpn_s where mpn_s <> 0

	update #t1 set yrn = isnull((select sum(quantity) from rmuserate where date >= @ybegin and date <= @yend and rtrim(market) = rtrim(#t1.code) group by market),0)
	update #t1 set yrate = isnull((select sum(rmrate) from rmuserate where date >= @ybegin and date <= @yend and rtrim(market) = rtrim(#t1.code) group by market),0)
	update #t1 set ytv = yrate/yrn where yrn <> 0
	update #t1 set yrn_s = isnull((select count(distinct roomno) from ycus_xf where date >= @ybegin and date <= @yend and rtrim(market) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T'),0)
	update #t1 set ypn = isnull((select sum(gstno) from ycus_xf where date >= @ybegin and date <= @yend and rtrim(market) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' group by market),0)
	update #t1 set ypn_s = isnull((select sum(gstno) from ycus_xf where date >= @ybegin and date <= @yend and rtrim(market) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by market),0)
	update #t1 set ypv = isnull((select sum(datediff(dd,arr,dep)) from ycus_xf where date >= @ybegin and date <= @yend and rtrim(market) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by market),0)/ypn_s where ypn_s <> 0
	end
else if @code_type = 'src'
	begin	
	update #t1 set drn = isnull((select sum(quantity) from rmuserate where date = @begin and rtrim(src) = rtrim(#t1.code) group by date,src),0)
	update #t1 set drate = isnull((select sum(rmrate) from rmuserate where date = @begin and rtrim(src) = rtrim(#t1.code) group by date,src),0)
	update #t1 set dtv = drate/drn where drn <> 0
	update #t1 set drn_s = isnull((select count(distinct roomno) from ycus_xf where date = @begin and rtrim(src) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T'),0)
	update #t1 set dpn = isnull((select sum(gstno) from ycus_xf where date = @begin and rtrim(src) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' group by date,src),0)
	update #t1 set dpn_s = isnull((select sum(gstno) from ycus_xf where date = @begin and rtrim(src) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by date,src),0)
	update #t1 set dpv = isnull((select sum(datediff(dd,arr,dep)) from ycus_xf where date = @begin and rtrim(src) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by date,src),0)/dpn_s where dpn_s <> 0
	
	update #t1 set mrn = isnull((select sum(quantity) from rmuserate where date >= @mbegin and date <= @mend and rtrim(src) = rtrim(#t1.code) group by src),0)
	update #t1 set mrate = isnull((select sum(rmrate) from rmuserate where date >= @mbegin and date <= @mend and rtrim(src) = rtrim(#t1.code) group by src),0)
	update #t1 set mtv = mrate/mrn where mrn <> 0
	update #t1 set mrn_s = isnull((select count(distinct roomno) from ycus_xf where date >= @mbegin and date <= @mend and rtrim(src) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T'),0)
	update #t1 set mpn = isnull((select sum(gstno) from ycus_xf where date >= @mbegin and date <= @mend and rtrim(src) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' group by src),0)
	update #t1 set mpn_s = isnull((select sum(gstno) from ycus_xf where date >= @mbegin and date <= @mend and rtrim(src) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by src),0)
	update #t1 set mpv = isnull((select sum(datediff(dd,arr,dep)) from ycus_xf where date >= @mbegin and date <= @mend and rtrim(src) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by src),0)/mpn_s where mpn_s <> 0

	update #t1 set yrn = isnull((select sum(quantity) from rmuserate where date >= @ybegin and date <= @yend and rtrim(src) = rtrim(#t1.code) group by src),0)
	update #t1 set yrate = isnull((select sum(rmrate) from rmuserate where date >= @ybegin and date <= @yend and rtrim(src) = rtrim(#t1.code) group by src),0)
	update #t1 set ytv = yrate/yrn where yrn <> 0
	update #t1 set yrn_s = isnull((select count(distinct roomno) from ycus_xf where date >= @ybegin and date <= @yend and rtrim(src) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T'),0)
	update #t1 set ypn = isnull((select sum(gstno) from ycus_xf where date >= @ybegin and date <= @yend and rtrim(src) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' group by src),0)
	update #t1 set ypn_s = isnull((select sum(gstno) from ycus_xf where date >= @ybegin and date <= @yend and rtrim(src) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by src),0)
	update #t1 set ypv = isnull((select sum(datediff(dd,arr,dep)) from ycus_xf where date >= @ybegin and date <= @yend and rtrim(src) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by src),0)/ypn_s where ypn_s <> 0
	end
else if @code_type = 'ratecode'
	begin	
	update #t1 set drn = isnull((select sum(quantity) from rmuserate where date = @begin and rtrim(ratecode) = rtrim(#t1.code) group by date,ratecode),0)
	update #t1 set drate = isnull((select sum(rmrate) from rmuserate where date = @begin and rtrim(ratecode) = rtrim(#t1.code) group by date,ratecode),0)
	update #t1 set dtv = drate/drn where drn <> 0
	update #t1 set drn_s = isnull((select count(distinct roomno) from ycus_xf where date = @begin and rtrim(ratecode) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' ),0)
	update #t1 set dpn = isnull((select sum(gstno) from ycus_xf where date = @begin and rtrim(ratecode) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' group by date,ratecode),0)
	update #t1 set dpn_s = isnull((select sum(gstno) from ycus_xf where date = @begin and rtrim(ratecode) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by date,ratecode),0)
	update #t1 set dpv = isnull((select sum(datediff(dd,arr,dep)) from ycus_xf where date = @begin and rtrim(ratecode) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by date,ratecode),0)/dpn_s where dpn_s <> 0
	
	update #t1 set mrn = isnull((select sum(quantity) from rmuserate where date >= @mbegin and date <= @mend and rtrim(ratecode) = rtrim(#t1.code) group by ratecode),0)
	update #t1 set mrate = isnull((select sum(rmrate) from rmuserate where date >= @mbegin and date <= @mend and rtrim(ratecode) = rtrim(#t1.code) group by ratecode),0)
	update #t1 set mtv = mrate/mrn where mrn <> 0
	update #t1 set mrn_s = isnull((select count(distinct roomno) from ycus_xf where date >= @mbegin and date <= @mend and rtrim(ratecode) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T'),0)
	update #t1 set mpn = isnull((select sum(gstno) from ycus_xf where date >= @mbegin and date <= @mend and rtrim(ratecode) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' group by ratecode),0)
	update #t1 set mpn_s = isnull((select sum(gstno) from ycus_xf where date >= @mbegin and date <= @mend and rtrim(ratecode) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by ratecode),0)
	update #t1 set mpv = isnull((select sum(datediff(dd,arr,dep)) from ycus_xf where date >= @mbegin and date <= @mend and rtrim(ratecode) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by ratecode),0)/mpn_s where mpn_s <> 0

	update #t1 set yrn = isnull((select sum(quantity) from rmuserate where date >= @ybegin and date <= @yend and rtrim(ratecode) = rtrim(#t1.code) group by ratecode),0)
	update #t1 set yrate = isnull((select sum(rmrate) from rmuserate where date >= @ybegin and date <= @yend and rtrim(ratecode) = rtrim(#t1.code) group by ratecode),0)
	update #t1 set ytv = yrate/yrn where yrn <> 0
	update #t1 set yrn_s = isnull((select count(distinct roomno) from ycus_xf where date >= @ybegin and date <= @yend and rtrim(ratecode) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T'),0)
	update #t1 set ypn = isnull((select sum(gstno) from ycus_xf where date >= @ybegin and date <= @yend and rtrim(ratecode) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' group by ratecode),0)
	update #t1 set ypn_s = isnull((select sum(gstno) from ycus_xf where date >= @ybegin and date <= @yend and rtrim(ratecode) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by ratecode),0)
	update #t1 set ypv = isnull((select sum(datediff(dd,arr,dep)) from ycus_xf where date >= @ybegin and date <= @yend and rtrim(ratecode) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by ratecode),0)/ypn_s where ypn_s <> 0
	end
else if @code_type = 'type'
	begin	
	update #t1 set drn = isnull((select sum(quantity) from rmuserate where date = @begin and rtrim(type) = rtrim(#t1.code) group by date,type),0)
	update #t1 set drate = isnull((select sum(rmrate) from rmuserate where date = @begin and rtrim(type) = rtrim(#t1.code) group by date,type),0)
	update #t1 set dtv = drate/drn where drn <> 0
	update #t1 set drn_s = isnull((select count(distinct roomno) from ycus_xf where date = @begin and rtrim(type) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T'),0)
	update #t1 set dpn = isnull((select sum(gstno) from ycus_xf where date = @begin and rtrim(type) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' group by date,type),0)
	update #t1 set dpn_s = isnull((select sum(gstno) from ycus_xf where date = @begin and rtrim(type) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by date,type),0)
	update #t1 set dpv = isnull((select sum(datediff(dd,arr,dep)) from ycus_xf where date = @begin and rtrim(type) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by date,type),0)/dpn_s where dpn_s <> 0
	
	update #t1 set mrn = isnull((select sum(quantity) from rmuserate where date >= @mbegin and date <= @mend and rtrim(type) = rtrim(#t1.code) group by type),0)
	update #t1 set mrate = isnull((select sum(rmrate) from rmuserate where date >= @mbegin and date <= @mend and rtrim(type) = rtrim(#t1.code) group by type),0)
	update #t1 set mtv = mrate/mrn where mrn <> 0
	update #t1 set mrn_s = isnull((select count(distinct roomno) from ycus_xf where date >= @mbegin and date <= @mend and rtrim(type) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T'),0)
	update #t1 set mpn = isnull((select sum(gstno) from ycus_xf where date >= @mbegin and date <= @mend and rtrim(type) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' group by type),0)
	update #t1 set mpn_s = isnull((select sum(gstno) from ycus_xf where date >= @mbegin and date <= @mend and rtrim(type) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by type),0)
	update #t1 set mpv = isnull((select sum(datediff(dd,arr,dep)) from ycus_xf where date >= @mbegin and date <= @mend and rtrim(type) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by type),0)/mpn_s where mpn_s <> 0

	update #t1 set yrn = isnull((select sum(quantity) from rmuserate where date >= @ybegin and date <= @yend and rtrim(type) = rtrim(#t1.code) group by type),0)
	update #t1 set yrate = isnull((select sum(rmrate) from rmuserate where date >= @ybegin and date <= @yend and rtrim(type) = rtrim(#t1.code) group by type),0)
	update #t1 set ytv = yrate/yrn where yrn <> 0
	update #t1 set yrn_s = isnull((select count(distinct roomno) from ycus_xf where date >= @ybegin and date <= @yend and rtrim(type) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T'),0)
	update #t1 set ypn = isnull((select sum(gstno) from ycus_xf where date >= @ybegin and date <= @yend and rtrim(type) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' group by type),0)
	update #t1 set ypn_s = isnull((select sum(gstno) from ycus_xf where date >= @ybegin and date <= @yend and rtrim(type) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by type),0)
	update #t1 set ypv = isnull((select sum(datediff(dd,arr,dep)) from ycus_xf where date >= @ybegin and date <= @yend and rtrim(type) = rtrim(#t1.code) and sta = 'I' and accnt like 'F%' and t_arr = 'T' group by type),0)/ypn_s where ypn_s <> 0
	end

if @sd = 'S'
	begin
	insert #t1 select class_d,class,class_d,class,'S',sum(drn),sum(drate),0,sum(drn_s),sum(dpn),sum(dpn_s),sum(dpn_s*dpv),
				sum(mrn),sum(mrate),0,sum(mrn_s),sum(mpn),sum(mpn_s),sum(mpn_s*mpv),sum(yrn),sum(yrate),0,sum(yrn_s),sum(ypn),sum(ypn_s),sum(ypn_s*ypv),sum(seq)
					from #t1 group by class_d,class
	update #t1 set dtv = drate/drn where drn <> 0
	update #t1 set mtv = mrate/mrn where mrn <> 0
	update #t1 set ytv = yrate/yrn where yrn <> 0
	update #t1 set dpv = dpv/dpn_s where dpn_s <> 0
	update #t1 set mpv = mpv/mpn_s where mpn_s <> 0
	update #t1 set ypv = ypv/ypn_s where ypn_s <> 0
	delete #t1 where flag = 'D'
	end

insert #t1 select '�ϼ�','','','','',sum(drn),sum(drate),0,sum(drn_s),sum(dpn),sum(dpn_s),sum(dpn_s*dpv),
				sum(mrn),sum(mrate),0,sum(mrn_s),sum(mpn),sum(mpn_s),sum(mpn_s*mpv),sum(yrn),sum(yrate),0,sum(yrn_s),sum(ypn),sum(ypn_s),sum(ypn_s*ypv),max(seq)+1
					from #t1
update #t1 set dtv = drate/drn where drn <> 0 and code_d = '�ϼ�'
update #t1 set mtv = mrate/mrn where mrn <> 0 and code_d = '�ϼ�'
update #t1 set ytv = yrate/yrn where yrn <> 0 and code_d = '�ϼ�'
update #t1 set dpv = dpv/dpn_s where dpn_s <> 0 and code_d = '�ϼ�'
update #t1 set mpv = mpv/mpn_s where mpn_s <> 0 and code_d = '�ϼ�'
update #t1 set ypv = ypv/ypn_s where ypn_s <> 0 and code_d = '�ϼ�'

insert #t1 select '���۷�','','','','',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,max(seq) + 1 from #t1
insert #t1 select '�۳���','','','','',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,max(seq) + 1 from #t1
insert #t1 select '�۷���','','','','',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,max(seq) + 1 from #t1

update #t1 set drn = isnull((select amount from yaudit_impdata where date = @begin and class = 'avl' ),0) where code_d = '���۷�'
update #t1 set mrn = isnull((select sum(amount) from yaudit_impdata where date >= @mbegin and date <= @mend and class = 'avl' ),0) where code_d = '���۷�'
update #t1 set yrn = isnull((select sum(amount) from yaudit_impdata where date >= @ybegin and date <= @yend and class = 'avl' ),0) where code_d = '���۷�'

update #t1 set drn = isnull((select amount from yaudit_impdata where date = @begin and class = 'sold' ),0) where code_d = '�۳���'
update #t1 set mrn = isnull((select sum(amount) from yaudit_impdata where date >= @mbegin and date <= @mend and class = 'sold' ),0) where code_d = '�۳���'
update #t1 set yrn = isnull((select sum(amount) from yaudit_impdata where date >= @ybegin and date <= @yend and class = 'sold' ),0) where code_d = '�۳���'

update #t1 set drn = isnull((select drn from #t1 where code_d = '�۳���')*100/(select drn from #t1 where code_d = '���۷�' and drn <> 0),0) where code_d = '�۷���'
update #t1 set mrn = isnull((select mrn from #t1 where code_d = '�۳���')*100/(select mrn from #t1 where code_d = '���۷�' and mrn <> 0),0) where code_d = '�۷���'
update #t1 set yrn = isnull((select yrn from #t1 where code_d = '�۳���')*100/(select yrn from #t1 where code_d = '���۷�' and yrn <> 0),0) where code_d = '�۷���'


select * from #t1 order by seq


;




