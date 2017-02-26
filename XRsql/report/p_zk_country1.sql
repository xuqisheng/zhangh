
if exists (select * from sysobjects where name ='p_zk_country1' and type ='P')
	drop proc p_zk_country1;
create proc p_zk_country1
	@cday			datetime
	
as
	
---------------------------------------------
-- 国籍收入统计
---------------------------------------------
declare
	@mons				datetime,
	@mone				datetime,
	@ys				datetime,
	@ye				datetime,
	@d_rmtt			money,
	@m_rmtt			money,
	@y_rmtt			money,
	@rmtt				money,
	@tmp_day			datetime
	
select @d_rmtt = 0 , @m_rmtt = 0 , @y_rmtt = 0	
select @mons=convert(datetime,substring(convert(char(8),dateadd(mm,0,@cday),112),1,6)+'01')
select @mone=dateadd(dd,-1,dateadd(mm,1,convert(datetime,substring(convert(char(8),dateadd(mm,0,@cday),112),1,6)+'01')))
select @ys = convert(datetime,substring(convert(char(8),@cday,112),1,4)+'0101')
select @ye = convert(datetime,substring(convert(char(8),@cday,112),1,4)+'1231')

select @rmtt = count(1) from rmsta where tag='K'
select @d_rmtt = @rmtt - count(1) from rm_ooo where sta='O' and dbegin <= @cday and dend >= @cday

select @tmp_day = @mons
while @tmp_day <= @mone
	begin
	select @m_rmtt = @rmtt - count(1) + @m_rmtt from rm_ooo where sta='O' and dbegin <= @tmp_day and dend >= @tmp_day
	select @tmp_day = dateadd(dd,1,@tmp_day)
	end

select @tmp_day = @ys
while @tmp_day <= @ye
	begin
	select @y_rmtt = @rmtt - count(1) + @y_rmtt from rm_ooo where sta='O' and dbegin <= @tmp_day and dend >= @tmp_day
	select @tmp_day = dateadd(dd,1,@tmp_day)
	end


create table #country ( country  char(10)  not null,
							 code  char(10) not null,
							 drm   money  not null,
							 drev	money  not null,
							 dadr		money		 not null,
							 docc   money  not null,
							 dprs	money  not null,
							 mrm   money  not null,
							 mrev	money  not null,
							 madr		money		 not null,
							 mocc   money  not null,
							 mprs	money  not null,
							 yrm   money  not null,
							 yrev	money  not null,
							 yadr		money		 not null,
							 yocc   money  not null,
							 yprs	money  not null,
							 seq	int	)

insert #country select descript,code ,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,sequence from countrycode
			where code in (select country from ycus_xf where date >=@ys and date<=@ye ) order by sequence

//当日统计
update #country set drm = isnull((select sum(a.rquan) from ymktsummaryrep_detail a,guest b 
		where a.haccnt = b.no and date = @cday and b.country = #country.code ),0)
update #country set dprs = isnull((select sum(a.pquan) from ymktsummaryrep_detail a,guest b 
		where a.haccnt = b.no and date = @cday and b.country = #country.code ),0)
update #country set drev = isnull((select sum(xf_rm) from ycus_xf where date =@cday and ycus_xf.country = #country.code ),0)
					from ycus_xf where code = ycus_xf.country
update #country set 	dadr = drev/drm ,docc = drm/@d_rmtt where drm > 0

//当月统计
update #country set mrm = isnull((select sum(a.rquan) from ymktsummaryrep_detail a,guest b 
		where a.haccnt = b.no and date >= @mons and date <= @mone and b.country = #country.code ),0)
update #country set mprs = isnull((select sum(a.pquan) from ymktsummaryrep_detail a,guest b 
		where a.haccnt = b.no and date >= @mons and date <= @mone and b.country = #country.code ),0)
//update #country set mrm = isnull((select sum(quantity) from rmuserate where date >= @mons and date <= @mone and country = #country.code ),0)
//update #country set mprs = isnull((select sum(gstno) from rmuserate where date >= @mons and date <= @mone and country = #country.code and quantity > 0 ),0)
update #country set mrev = isnull((select sum(xf_rm) from ycus_xf where date >= @mons and date <= @mone and ycus_xf.country = #country.code ),0)
					from ycus_xf where code = ycus_xf.country
update #country set 	madr = mrev/mrm ,mocc = mrm/@m_rmtt where mrm > 0

//当年统计
update #country set yrm = isnull((select sum(a.rquan) from ymktsummaryrep_detail a,guest b 
		where a.haccnt = b.no and date >= @ys and date <= @ye and b.country = #country.code ),0)
update #country set yprs = isnull((select sum(a.pquan) from ymktsummaryrep_detail a,guest b 
		where a.haccnt = b.no and date >= @ys and date <= @ye and b.country = #country.code ),0)
//update #country set yrm = isnull((select sum(quantity) from rmuserate where date >= @ys and date <= @ye and country = #country.code ),0)
//update #country set yprs = isnull((select sum(gstno) from rmuserate where date >= @ys and date <= @ye and country = #country.code and quantity > 0 ),0)
update #country set yrev = isnull((select sum(xf_rm) from ycus_xf where date >= @ys and date <= @ye and ycus_xf.country = #country.code ),0)
					from ycus_xf where code = ycus_xf.country
update #country set 	yadr = yrev/yrm ,yocc = yrm/@y_rmtt where yrm > 0

 
select * from #country order by seq
;




