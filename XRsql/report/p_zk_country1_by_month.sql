
if exists (select * from sysobjects where name ='p_zk_country1_by_month' and type ='P')
	drop proc p_zk_country1_by_month;
create proc p_zk_country1_by_month
	@cday			datetime
	
as
	
---------------------------------------------
-- 国家月统计报表
---------------------------------------------
declare
	@mons				datetime,
	@mone				datetime,
	@lys				datetime,
	@lye				datetime,
	@d_rmtt			money,
	@m_rmtt			money,
	@y_rmtt			money,
	@rmtt				money,
	@tmp_day			datetime
	
select @d_rmtt = 0 , @m_rmtt = 0 , @y_rmtt = 0	
select @mons=convert(datetime,substring(convert(char(8),dateadd(mm,0,@cday),112),1,6)+'01')
select @mone=dateadd(dd,-1,dateadd(mm,1,convert(datetime,substring(convert(char(8),dateadd(mm,0,@cday),112),1,6)+'01')))
select @lys = convert(datetime,substring(convert(char(8),dateadd(yy,-1,@cday),112),1,4)+'0101')
select @lye = convert(datetime,substring(convert(char(8),dateadd(yy,-1,@cday),112),1,4)+'1231')

select @rmtt = count(1) from rmsta where tag='K'
select @d_rmtt = @rmtt - count(1) from rm_ooo where sta='O' and dbegin <= @cday and dend >= @cday

select @tmp_day = @mons
while @tmp_day <= @mone
	begin
	select @m_rmtt = @rmtt - count(1) + @m_rmtt from rm_ooo where sta='O' and dbegin <= @tmp_day and dend >= @tmp_day
	select @tmp_day = dateadd(dd,1,@tmp_day)
	end

select @tmp_day = @lys
while @tmp_day <= @lye
	begin
	select @y_rmtt = @rmtt - count(1) + @y_rmtt from rm_ooo where sta='O' and dbegin <= @tmp_day and dend >= @tmp_day
	select @tmp_day = dateadd(dd,1,@tmp_day)
	end


create table #country ( country  char(50)  not null,
							 code  char(10) not null,
							 rms   money  not null,
							 rmocc	money  not null,
							 prs		money		 not null,
							 procc   money  not null,
							 lrms	money  not null,
							 lpms   money  not null,
							 seq	int	)

insert #country select descript1,code ,0,0,0,0,0,0,sequence from countrycode
			where code in (select country from ycus_xf where date >=@lys and date<=@mone ) order by sequence


//当月统计
update #country set rms = isnull((select sum(a.rquan) from ymktsummaryrep_detail a,guest b 
		where a.haccnt = b.no and date >= @mons and date <= @mone and b.country = #country.code ),0)
update #country set prs = isnull((select sum(a.pquan) from ymktsummaryrep_detail a,guest b 
		where a.haccnt = b.no and date >= @mons and date <= @mone and rtrim(b.country) = rtrim(#country.code) ),0)

update #country set 	rmocc = round(isnull(rms*100 / sum(rms),0),3) where (select sum(rms) from #country) > 0
update #country set 	procc = round(isnull(prs*100 / sum(prs),0),3) where (select sum(prs) from #country) > 0

//去年统计
update #country set lrms = isnull((select sum(a.rquan) from ymktsummaryrep_detail a,guest b 
		where a.haccnt = b.no and date >= @lys and date <= @lye and b.country = #country.code ),0)
update #country set lpms = isnull((select sum(a.pquan) from ymktsummaryrep_detail a,guest b 
		where a.haccnt = b.no and date >= @lys and date <= @lye and b.country = #country.code  ),0)

 
select country,code,rms,rmocc,prs,procc,lrms,lpms from #country order by seq
;




