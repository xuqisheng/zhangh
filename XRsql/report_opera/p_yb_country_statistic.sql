IF OBJECT_ID('p_yb_country_statistic') IS NOT NULL
    DROP PROCEDURE p_yb_country_statistic
;
create proc p_yb_country_statistic
@pc_id			char(4),
@year				integer,
@month			integer,
@type				char(1),
@index			char(1)

as

declare 
@type1			varchar(20),
@index1			varchar(20),
@indexs			varchar(255),
@date1			datetime,
@date2			datetime,
@rm_ttl			money,
@gsts_ttl		money,
@rm_ttl_ly			money,
@gsts_ttl_ly		money



create table #statistic

(	year			integer,
	month			char(10),
	code     	char(3) 	not null,
	descript   	char(30) 	null,
	descript1  	char(40) 	null,
	rooms			money	   	default 0 not null,
	rooms_per	money  		default 0 not null,
	gsts			money  		default 0 not null,
	gsts_per		money  		default 0 not null,
	rooms_ly		money  		default 0 not null,
	gsts_ly		money	 		default 0 not null
)

if @type='C'
	select @type1 = 'country'
else if @type='R'
	select @type1 = 'nation'

if @index='R'
	select @index1='rooms_nights'
else if @index='P'
	select @index1='persons_nights'


select @indexs=@type1+'_'+@index1+'-m,'+@type1+'_persons_adult-m,'+@type1+'_'+@index1+'-M12,'+@type1+'_persons_adult-M12,'



select @date1=convert(char(4),@year - 1)+'/'+convert(char(2),@month)+'/'+'01'
select @date2=dateadd(dd,-1,dateadd(mm,1,@date1))

exec p_gl_statistic_report @pc_id,@date1,@date2,'',@indexs,'',1


insert #statistic select @year - 1,datename(mm,@date1),a.code,a.descript,a.descript1,isnull(amount01,0),0,isnull(amount02,0),0,
								isnull(amount03,0),isnull(amount04,0) from countrycode a,statistic_p b 
									where a.code*=b.code and b.pc_id=@pc_id

select @date1=convert(char(4),@year)+'/'+convert(char(2),@month)+'/'+'01'
select @date2=dateadd(dd,-1,dateadd(mm,1,@date1))

exec p_gl_statistic_report @pc_id,@date1,@date2,'',@indexs,'',1

insert #statistic select @year,datename(mm,@date1),a.code,a.descript,a.descript1,isnull(amount01,0),0,isnull(amount02,0),0,
								isnull(amount03,0),isnull(amount04,0) from countrycode a,statistic_p b 
									where a.code*=b.code and b.pc_id=@pc_id

select @rm_ttl = isnull((select sum(rooms) from #statistic where year=@year),0)
select @gsts_ttl = isnull((select sum(gsts) from #statistic where year=@year),0)
select @rm_ttl_ly = isnull((select sum(rooms) from #statistic where year=@year - 1),0)
select @gsts_ttl_ly = isnull((select sum(gsts) from #statistic where year=@year - 1),0)

if @rm_ttl_ly <> 0
	update #statistic set rooms_per = round(rooms/@rm_ttl_ly,4) where year=@year - 1

if @gsts_ttl_ly <> 0
	update #statistic set rooms_per = round(gsts/@gsts_ttl_ly,4) where year=@year - 1

if @rm_ttl <> 0
	update #statistic set rooms_per = round(rooms/@rm_ttl,4) where year=@year

if @gsts_ttl <> 0
	update #statistic set rooms_per = round(gsts/@gsts_ttl,4) where year=@year


select * from #statistic order by year,month,code


return 0
;
