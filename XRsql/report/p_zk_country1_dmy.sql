
if exists (select * from sysobjects where name ='p_zk_country1_dmy' and type ='P')
	drop proc p_zk_country1_dmy;
create proc p_zk_country1_dmy
	@cday			datetime,
	@langid		int = 0
	
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


create table #country ( country  char(50)  not null,
								code 		char(10)		not null,
							 class  char(20) not null,
							 d   money  not null,
							 m	money  not null,
							 y		money		 not null,
							 seq	int	)

if @langid = 0
	begin
	insert #country select '['+descript+']',code,'Rooms' ,0,0,0 ,sequence*10+1 from countrycode
				where code in (select country from ycus_xf where date >=@ys and date<=@ye ) order by sequence
	insert #country select '['+descript+']',code,'Room Revenue' ,0,0,0 ,sequence*10+2 from countrycode
				where code in (select country from ycus_xf where date >=@ys and date<=@ye ) order by sequence
	insert #country select '['+descript+']',code,'Average Room Rate' ,0,0,0 ,sequence*10+3 from countrycode
				where code in (select country from ycus_xf where date >=@ys and date<=@ye ) order by sequence
	insert #country select '['+descript+']',code,'F&B Revanue' ,0,0,0 ,sequence*10+4 from countrycode
				where code in (select country from ycus_xf where date >=@ys and date<=@ye ) order by sequence
	insert #country select '['+descript+']',code,'Other Revanue' ,0,0,0 ,sequence*10+5 from countrycode
				where code in (select country from ycus_xf where date >=@ys and date<=@ye ) order by sequence
	insert #country select '['+descript+']',code,'Total Revanue' ,0,0,0 ,sequence*10+6 from countrycode
				where code in (select country from ycus_xf where date >=@ys and date<=@ye ) order by sequence
	end
else 
	begin
	insert #country select '['+descript1+']',code,'Rooms' ,0,0,0 ,sequence*10+1 from countrycode
				where code in (select country from ycus_xf where date >=@ys and date<=@ye ) order by sequence
	insert #country select '['+descript1+']',code,'Room Revenue' ,0,0,0 ,sequence*10+2 from countrycode
				where code in (select country from ycus_xf where date >=@ys and date<=@ye ) order by sequence
	insert #country select '['+descript1+']',code,'Average Room Rate' ,0,0,0 ,sequence*10+3 from countrycode
				where code in (select country from ycus_xf where date >=@ys and date<=@ye ) order by sequence
	insert #country select '['+descript1+']',code,'F&B Revanue' ,0,0,0 ,sequence*10+4 from countrycode
				where code in (select country from ycus_xf where date >=@ys and date<=@ye ) order by sequence
	insert #country select '['+descript1+']',code,'Other Revanue' ,0,0,0 ,sequence*10+5 from countrycode
				where code in (select country from ycus_xf where date >=@ys and date<=@ye ) order by sequence
	insert #country select '['+descript1+']',code,'Total Revanue' ,0,0,0 ,sequence*10+6 from countrycode
				where code in (select country from ycus_xf where date >=@ys and date<=@ye ) order by sequence
	end

insert #country select '[Total]','[Total]','Rooms' ,0,0,0 ,100001
insert #country select '[Total]','[Total]','Room Revenue' ,0,0,0 ,100002
insert #country select '[Total]','[Total]','Average Room Rate' ,0,0,0 ,100003
insert #country select '[Total]','[Total]','F&B Revanue' ,0,0,0 ,100004
insert #country select '[Total]','[Total]','Other Revanue' ,0,0,0 ,100005
insert #country select '[Total]','[Total]','Total Revanue' ,0,0,0 ,100006

update #country set  d = isnull((select count(distinct roomno+convert(char(8),bdate,11)) from ycus_xf where date =@cday and ycus_xf.country = #country.code and accnt like 'F%' ),0),
							m = isnull((select count(distinct roomno+convert(char(8),bdate,11)) from ycus_xf where date >= @mons and date <= @mone and ycus_xf.country = #country.code and accnt like 'F%' ),0),
							y = isnull((select count(distinct roomno+convert(char(8),bdate,11)) from ycus_xf where date >= @ys and date <= @ye and ycus_xf.country = #country.code and accnt like 'F%' ),0)
		from ycus_xf where code = ycus_xf.country and class = 'Rooms'

update #country set  d = isnull((select sum(xf_rm) from ycus_xf where date =@cday and ycus_xf.country = #country.code and accnt like 'F%' ),0),
							m = isnull((select sum(xf_rm) from ycus_xf where date >= @mons and date <= @mone and ycus_xf.country = #country.code and accnt like 'F%' ),0),
							y = isnull((select sum(xf_rm) from ycus_xf where date >= @ys and date <= @ye and ycus_xf.country = #country.code and accnt like 'F%' ),0)
		from ycus_xf where code = ycus_xf.country and class = 'Room Revenue'

update #country set  d = isnull((select sum(xf_fb) from ycus_xf where date =@cday and ycus_xf.country = #country.code ),0),
							m = isnull((select sum(xf_fb) from ycus_xf where date >= @mons and date <= @mone and ycus_xf.country = #country.code ),0),
							y = isnull((select sum(xf_fb) from ycus_xf where date >= @ys and date <= @ye and ycus_xf.country = #country.code ),0)
		from ycus_xf where code = ycus_xf.country and class = 'F&B Revanue'

update #country set  d = isnull((select sum(xf_dtl - xf_rm - xf_fb) from ycus_xf where date =@cday and ycus_xf.country = #country.code ),0),
							m = isnull((select sum(xf_dtl - xf_rm - xf_fb) from ycus_xf where date >= @mons and date <= @mone and ycus_xf.country = #country.code ),0),
							y = isnull((select sum(xf_dtl - xf_rm - xf_fb) from ycus_xf where date >= @ys and date <= @ye and ycus_xf.country = #country.code ),0)
		from ycus_xf where code = ycus_xf.country and class = 'Other Revanue'

update #country set  d = isnull((select sum(xf_dtl) from ycus_xf where date =@cday and ycus_xf.country = #country.code ),0),
							m = isnull((select sum(xf_dtl) from ycus_xf where date >= @mons and date <= @mone and ycus_xf.country = #country.code),0),
							y = isnull((select sum(xf_dtl) from ycus_xf where date >= @ys and date <= @ye and ycus_xf.country = #country.code ),0)
		from ycus_xf where code = ycus_xf.country and class = 'Total Revanue'

update #country set  d = isnull((select sum(xf_rm)/count(distinct roomno+convert(char(8),bdate,11)) from ycus_xf where date =@cday and ycus_xf.country = #country.code and (select count(distinct roomno+convert(char(8),bdate,11)) from ycus_xf where date =@cday and ycus_xf.country = #country.code) > 0 ),0),
							m = isnull((select sum(xf_rm)/count(distinct roomno+convert(char(8),bdate,11)) from ycus_xf where date >= @mons and date <= @mone and ycus_xf.country = #country.code and (select count(distinct roomno+convert(char(8),bdate,11)) from ycus_xf where date >= @mons and date <= @mone and ycus_xf.country = #country.code) > 0),0),
							y = isnull((select sum(xf_rm)/count(distinct roomno+convert(char(8),bdate,11)) from ycus_xf where date >= @ys and date <= @ye and ycus_xf.country = #country.code and (select count(distinct roomno+convert(char(8),bdate,11)) from ycus_xf where date >= @ys and date <= @ye and ycus_xf.country = #country.code) > 0 ),0)
		from ycus_xf where code = ycus_xf.country and class = 'Average Room Rate'

//统计
update #country set  d = isnull((select sum(d) from #country where code <> '[Total]' and country <> '[Total]' and class = 'Rooms' ),0),
							m = isnull((select sum(m) from #country where code <> '[Total]' and country <> '[Total]' and class = 'Rooms' ),0),
							y = isnull((select sum(y) from #country where code <> '[Total]' and country <> '[Total]' and class = 'Rooms' ),0)
		from ycus_xf where code = '[Total]' and #country.country = '[Total]' and class = 'Rooms'

update #country set  d = isnull((select sum(d) from #country where code <> '[Total]' and country <> '[Total]' and class = 'Room Revenue' ),0),
							m = isnull((select sum(m) from #country where code <> '[Total]' and country <> '[Total]' and class = 'Room Revenue' ),0),
							y = isnull((select sum(y) from #country where code <> '[Total]' and country <> '[Total]' and class = 'Room Revenue' ),0)
		from ycus_xf where code = '[Total]' and #country.country = '[Total]' and class = 'Room Revenue'

update #country set  d = isnull((select sum(d) from #country where code <> '[Total]' and country <> '[Total]' and class = 'F&B Revanue' ),0),
							m = isnull((select sum(m) from #country where code <> '[Total]' and country <> '[Total]' and class = 'F&B Revanue' ),0),
							y = isnull((select sum(y) from #country where code <> '[Total]' and country <> '[Total]' and class = 'F&B Revanue' ),0)
		from ycus_xf where code = '[Total]' and #country.country = '[Total]' and class = 'F&B Revanue'

update #country set  d = isnull((select sum(d) from #country where code <> '[Total]' and country <> '[Total]' and class = 'Other Revanue' ),0),
							m = isnull((select sum(m) from #country where code <> '[Total]' and country <> '[Total]' and class = 'Other Revanue' ),0),
							y = isnull((select sum(y) from #country where code <> '[Total]' and country <> '[Total]' and class = 'Other Revanue' ),0)
		from ycus_xf where code = '[Total]' and #country.country = '[Total]' and class = 'Other Revanue'

update #country set  d = isnull((select sum(d) from #country where code <> '[Total]' and country <> '[Total]' and class = 'Total Revanue' ),0),
							m = isnull((select sum(m) from #country where code <> '[Total]' and country <> '[Total]' and class = 'Total Revanue' ),0),
							y = isnull((select sum(y) from #country where code <> '[Total]' and country <> '[Total]' and class = 'Total Revanue' ),0)
		from ycus_xf where code = '[Total]' and #country.country = '[Total]' and class = 'Total Revanue'

update #country set  d = isnull((select sum(d) from #country where code <> '[Total]' and country <> '[Total]' and class = 'Average Room Rate' ),0),
							m = isnull((select sum(m) from #country where code <> '[Total]' and country <> '[Total]' and class = 'Average Room Rate' ),0),
							y = isnull((select sum(y) from #country where code <> '[Total]' and country <> '[Total]' and class = 'Average Room Rate' ),0)
		from ycus_xf where code = '[Total]' and #country.country = '[Total]' and class = 'Average Room Rate'


 
select country,code,class,d,m,y from #country order by code,seq,country
--select * from #country order by code,seq,country
;




