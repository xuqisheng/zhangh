
if exists(select * from sysobjects where name = "p_gds_reserve_rsvlimit_list")
   drop proc p_gds_reserve_rsvlimit_list
;
create proc p_gds_reserve_rsvlimit_list
	@dbegin	datetime,
	@dend		datetime 
as

-- rsvlimit 列表 - 显示每日 overbooking 

create table #goutput (
	date			datetime		not null,
	gtype			char(5)		not null,
	seq1			int		default 0	null,
	type			char(5)		not null,
	seq2			int		default 0	null,
	quan			int		default 0	not null,
	overbook		int			not null,
	bmodi			int		default 1 not null 	-- 能否修改 0=no  1=yes 
)

-- data ready 
insert #goutput(date,gtype,type,overbook)
	select date,gtype,type,overbook
		from rsvlimit
		where (@dbegin is null or date>=@dbegin) 
			and  (@dend is null or date<=@dend) 
update #goutput set quan=isnull((select sum(a.quantity) from typim a 
		where (#goutput.gtype='' or #goutput.gtype=a.gtype)
				and (#goutput.type='' or #goutput.type=a.type)
				and tag='K' ), 0) 

-- seq 
update #goutput set seq1=a.sequence from gtype a where #goutput.gtype=a.code and #goutput.type='' 
update #goutput set seq2=a.sequence from typim a where #goutput.type=a.type and #goutput.gtype='' 

--
declare	@bdate	datetime
select @bdate = bdate1 from sysdata
update #goutput set bmodi=0 where date<@bdate 

-- output 
select date,gtype,type,quan,overbook,tosell=quan+overbook, bmodi  
	from #goutput
	order by date, seq1, seq2 

return 0
;
