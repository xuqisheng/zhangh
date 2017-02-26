IF OBJECT_ID('p_yb_nationality_analysis') IS NOT NULL
    DROP PROCEDURE p_yb_nationality_analysis
;
create proc p_yb_nationality_analysis
@date		char(7),
@lang		integer


as

declare
@year		integer,
@month	integer,
@rn_tl	money,
@lrn_tl	money,
@gsts_tl	money,
@lgsts_tl	money,
@yrn_tl	money,
@lyrn_tl	money,
@ygsts_tl	money,
@lygsts_tl	money,
@bdate		datetime,
@lastday		datetime


create table #gout
(
 order_	  	char(2),
 worldcode 	char(3),
 descript  	varchar(60),
 nation	 	char(3),
 descript1  varchar(40),
 gsts			money default 0,
 lgsts	  	money default 0,
 rn        	money default 0,
 lrn		  	money default 0,
 ygsts		money default 0,
 lygsts	  	money default 0,
 yrn        money default 0,
 lyrn		  	money default 0,
 sequence  	integer default 0,
 sequence1  integer default 0
)

select @year = convert(integer,(substring(@date,1,4))),@month = convert(integer,(substring(@date,6,2)))


if exists(select 1 from gate where audit = 'T')
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead


select @lastday = (SELECT lastday FROM firstdays WHERE year=@year and month=@month)
if @bdate<@lastday
	select @lastday=@bdate

insert #gout
select a.order_,'','',b.code,'',
mone10_1  =  isnull(a.mtc+a.mgc,0),
mone10_2  =  isnull((SELECT d.mtc+d.mgc FROM ygststa d WHERE d.gclass=a.gclass and d.order_=a.order_ and
d.nation=a.nation and d.date = (SELECT lastday FROM firstdays WHERE year=@year-1 and month=@month)),  0),
mone10_3  =  isnull(a.mtt+a.mgt,0),
mone10_4  =  isnull((SELECT d.mtt+d.mgt FROM ygststa d WHERE d.gclass=a.gclass and d.order_=a.order_ and
d.nation=a.nation and d.date =(SELECT lastday FROM firstdays WHERE year=@year-1 and month=@month)),  0),

mone10_5  =  isnull(a.ytc+a.ygc,0),
mone10_6  =  isnull((SELECT d.ytc+d.ygc FROM ygststa d WHERE d.gclass=a.gclass and d.order_=a.order_ and
d.nation=a.nation and d.date = (SELECT lastday FROM firstdays WHERE year=@year-1 and month=@month)), 0),

mone10_7  =  isnull(a.ytt+a.ygt,0),
mone10_8  =  isnull((SELECT d.ytt+d.ygt FROM ygststa d WHERE d.gclass=a.gclass and d.order_=a.order_ and
d.nation=a.nation and d.date = (SELECT lastday FROM firstdays WHERE year=@year-1 and month=@month)),  0),
0,
0


                                                                                                
from ygststa a,countrycode b where
a.date = @lastday and a.order_ in
('01',  '02',  '03',  '04')  and a.nation = b.code




insert #gout
select '00','','','CN','',
mone10_1  =  isnull(sum(a.mtc+a.mgc),0),
mone10_2  =  isnull((SELECT sum(d.mtc+d.mgc) FROM ygststa d WHERE d.gclass in ('2',  '3')
and d.date = (SELECT lastday FROM firstdays WHERE year=@year-1 and month=@month)),  0),
mone10_3  =  isnull(sum(a.mtt+a.mgt),0),
mone10_4  =  isnull((SELECT sum(d.mtt+d.mgt) FROM ygststa d WHERE d.gclass in ('2',  '3') and
d.date = (SELECT lastday FROM firstdays WHERE year=@year-1 and month=@month)),  0),

mone10_5  =  isnull(sum(a.ytc+a.ygc),0),
mone10_6  =  isnull((SELECT sum(d.ytc+d.ygc) FROM ygststa d WHERE d.gclass in ('2',  '3')
and d.date = (SELECT lastday FROM firstdays WHERE year=@year-1 and month=@month)),  0),
mone10_7  =  isnull(sum(a.ytt+a.ygt),0),
mone10_8  =  isnull((SELECT sum(d.ytt+d.ygt) FROM ygststa d WHERE d.gclass in ('2',  '3') and
d.date = (SELECT lastday FROM firstdays WHERE year=@year-1 and month=@month)),  0),
0,
0

from ygststa a where a.date = @lastday
and a.gclass in ('2',  '3')

select @gsts_tl = isnull((SELECT mtc+mgc FROM ygststa WHERE date = @lastday and gclass = '1' and order_ = '' and nation = ''),  1)
select @lgsts_tl = isnull((SELECT mtc+mgc FROM ygststa WHERE date = @lastday and gclass = '1' and order_ = '' and nation = ''),  1)
select @rn_tl = isnull((SELECT mtt+mgt FROM ygststa WHERE date = @lastday and gclass = '1' and order_ = '' and nation = ''),  1)
select @lrn_tl =isnull((SELECT mtt+mgt FROM ygststa WHERE date = @lastday and gclass = '1' and order_ = ''and nation = ''),  1)



select @ygsts_tl = isnull((SELECT ytc+ygc FROM ygststa WHERE date = @lastday and gclass = '1' and order_ = '' and nation = ''),  1)
select @lygsts_tl = isnull((SELECT ytc+ygc FROM ygststa WHERE date = @lastday and gclass = '1' and order_ = '' and nation = ''),  1)
select @yrn_tl = isnull((SELECT ytt+ygt FROM ygststa WHERE date = @lastday and gclass = '1' and order_ = '' and nation= ''),  1)
select @lyrn_tl = isnull((SELECT ytt+ygt FROM ygststa WHERE date = @lastday and gclass = '1' and order_ = '' and nation = ''),  1)


insert #gout( order_,worldcode,descript,nation,descript1) select '',worldcode,'',code,''
	from countrycode where code not in (select nation from #gout)


update #gout set worldcode= a.worldcode from countrycode a where a.code=#gout.nation
update #gout set sequence= a.sequence from basecode a where a.cat='worldcode' and a.code=#gout.worldcode
update #gout set sequence1= a.sequence from countrycode a where a.code=#gout.nation

if @lang=0
	begin
		update #gout set descript = a.descript from basecode a where a.cat='worldcode' and a.code=#gout.worldcode
		update #gout set descript1 = a.descript from countrycode a where a.code=#gout.nation
	end
else
	begin
		update #gout set descript = a.descript1 from basecode a where a.cat='worldcode' and a.code=#gout.worldcode
		update #gout set descript1 = a.descript1 from countrycode a where a.code=#gout.nation
	end


select descript,descript1,rn,round(rn/@rn_tl,4),lrn,round(lrn/@lrn_tl,4),yrn,round(yrn/@yrn_tl,4),lyrn,round(lyrn/@lyrn_tl,4)
	 from #gout order by sequence,sequence1


return 0
;