
if exists (select * from sysobjects where name ='p_zk_country_stt' and type ='P')
	drop proc p_zk_country_stt;
create proc p_zk_country_stt
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


create table #country ( wcode		char(10)		not null,
								country  char(10)  not null,
							 code  char(10) not null,
							 dp1   integer  not null,
							 mp1	integer  not null,
							 yp1		integer		 not null,
							 dp2   integer  not null,
							 mp2	integer  not null,
							 yp2   integer  not null,
							 seq	int	)

insert #country select worldcode,descript,code ,0,0,0,0,0,0,sequence from countrycode where 
		 code in (select country from ycus_xf where date >=@ys and date<=@ye and sta = 'I' ) order by sequence
insert #country select '总人数','总人数','总人数' ,0,0,0,0,0,0,isnull(max(seq),0) + 1 from #country

//人数
update #country set dp1 = isnull((select sum(gstno) from master where arr = @cday and sta = 'I' and haccnt in (select no from guest where rtrim(country) = rtrim(#country.code)) and accnt like 'F%'),0)
update #country set mp1 = isnull((select count(distinct haccnt) from ycus_xf where date > @mons and sta = 'I' and date <= @mone and rtrim(country) = rtrim(#country.code) and accnt like 'F%'),0)
update #country set yp1 = isnull((select count(distinct haccnt) from ycus_xf where date > @ys and sta = 'I' and date <= @ye and rtrim(country) = rtrim(#country.code) and accnt like 'F%'),0)

update #country set dp1 = isnull((select sum(gstno) from master where arr = @cday and sta = 'I' and accnt like 'F%'),0) where code = '总人数'
update #country set mp1 = isnull((select count(distinct haccnt) from ycus_xf where date > @mons and sta = 'I' and date <= @mone and accnt like 'F%'),0) where code = '总人数'
update #country set yp1 = isnull((select count(distinct haccnt) from ycus_xf where date > @ys and sta = 'I' and date <= @ye and accnt like 'F%'),0) where code = '总人数'

//人天数（累计在住）
//人数
update #country set dp2 = isnull((select sum(gstno) from master where sta = 'I' and haccnt in (select no from guest where rtrim(country) = rtrim(#country.code)) and accnt like 'F%'),0) 
update #country set mp2 = isnull((select count(haccnt) from ycus_xf where sta = 'I' and date > @mons and date <= @mone and rtrim(country) = rtrim(#country.code) and accnt like 'F%'),0)
update #country set yp2 = isnull((select count(haccnt) from ycus_xf where sta = 'I' and date > @ys and date <= @ye and rtrim(country) = rtrim(#country.code) and accnt like 'F%'),0)

update #country set dp2 = isnull((select sum(gstno) from master where sta = 'I' and accnt like 'F%'),0)  where code = '总人数'
update #country set mp2 = isnull((select count(haccnt) from ycus_xf where sta = 'I' and accnt like 'F%'),0)  where code = '总人数'
update #country set yp2 = isnull((select count(haccnt) from ycus_xf where sta = 'I' and accnt like 'F%'),0)  where code = '总人数'

update #country set wcode = isnull((select descript from basecode b where rtrim(b.code) = rtrim(#country.wcode) and rtrim(b.cat) = 'worldcode'),wcode)
 
select * from #country order by wcode,seq
;




