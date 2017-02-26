if object_id('p_hbb_market_statistics_repo') is not null
	drop proc p_hbb_market_statistics_repo;

create proc p_hbb_market_statistics_repo
	@date				datetime,
	@langid			integer = 0

as

create table #repo(
	date    			datetime      NULL,
	grp     			char(10)      NOT NULL,
	grpdes			varchar(60)	  NULL,
	grp_seq			integer		  DEFAULT 0 	 NOT NULL,
	code    			char(10)      NOT NULL,
	codedes			varchar(30)	  NULL,
	code_seq			integer		  DEFAULT 0 	 NOT NULL,
	pquan   			integer       DEFAULT 0 	 NOT NULL,
	rquan   			numeric(10,1) DEFAULT 0 	 NOT NULL,
	rincome 			money         DEFAULT 0 	 NOT NULL,
	m_pquan   		integer       DEFAULT 0 	 NOT NULL,
	m_rquan  	 	numeric(10,1) DEFAULT 0 	 NOT NULL,
	m_rincome 		money         DEFAULT 0 	 NOT NULL,
	y_pquan   		integer       DEFAULT 0 	 NOT NULL,
	y_rquan   		numeric(10,1) DEFAULT 0 	 NOT NULL,
	y_rincome 		money         DEFAULT 0 	 NOT NULL
)

declare
	@monthbeg		datetime,
	@yearbeg			datetime,
	@isfstday		char(1),
	@isyfstday		char(1)

-- 计算月初及年初
select @monthbeg = @date, @yearbeg = @date,@isfstday = 'F',@isyfstday = 'F'

begin
exec p_hry_audit_fstday @monthbeg, @isfstday out, @isyfstday out
while @isfstday = 'F'
	begin
	select @monthbeg = dateadd(dd, -1, @monthbeg)
	exec p_hry_audit_fstday @monthbeg, @isfstday out, @isyfstday out
	end
end

begin
exec p_hry_audit_fstday @yearbeg, @isfstday out, @isyfstday out
while @isyfstday = 'F'
	begin
	select @yearbeg = dateadd(dd, -1, @yearbeg)
	exec p_hry_audit_fstday @yearbeg, @isfstday out, @isyfstday out
	end
end

insert into #repo(date,grp,code,pquan,rquan,rincome)
	select date,grp,code,pquan,rquan,rincome - rsvc from ymktsummaryrep where date = @date and class = 'M'

update #repo set grp_seq  = a.sequence from basecode a where #repo.grp = a.code and a.cat = 'market_cat'

update #repo set code_seq = a.sequence from mktcode a where #repo.code = a.code 

-- 月累
update #repo set m_pquan = 
	isnull((select sum(a.pquan) from ymktsummaryrep a	where a.date >= @monthbeg and a.date <= @date 
		and #repo.grp = a.grp and #repo.code = a.code),0)

update #repo set m_rquan = 
	isnull((select sum(a.rquan) from ymktsummaryrep a	where a.date >= @monthbeg and a.date <= @date 
		and #repo.grp = a.grp and #repo.code = a.code),0)

update #repo set m_rincome = 
	isnull((select sum(a.rincome - a.rsvc) from ymktsummaryrep a	where a.date >= @monthbeg and a.date <= @date 
		and #repo.grp = a.grp and #repo.code = a.code),0)

-- 年累
update #repo set y_pquan = 
	isnull((select sum(a.pquan) from ymktsummaryrep a	where a.date >= @yearbeg and a.date <= @date 
		and #repo.grp = a.grp and #repo.code = a.code),0)

update #repo set y_rquan = 
	isnull((select sum(a.rquan) from ymktsummaryrep a	where a.date >= @yearbeg and a.date <= @date 
		and #repo.grp = a.grp and #repo.code = a.code),0)

update #repo set y_rincome = 
	isnull((select sum(a.rincome - a.rsvc) from ymktsummaryrep a	where a.date >= @yearbeg and a.date <= @date 
		and #repo.grp = a.grp and #repo.code = a.code),0)

if @langid = 0
	begin 
	update #repo set grpdes  = a.descript from basecode a where #repo.grp  = a.code and a.cat = 'market_cat'
	update #repo set codedes = a.descript from mktcode  a where #repo.code = a.code 
	end
else
	begin 
	update #repo set grpdes  = a.descript1 from basecode a where #repo.grp  = a.code and a.cat = 'market_cat'
	update #repo set codedes = a.descript1 from mktcode  a where #repo.code = a.code 
	end


select grpdes,codedes,rquan,rincome,pquan,m_rquan,m_rincome,m_pquan,y_rquan,y_rincome,y_pquan from #repo order by grp_seq,grp,code_seq,code

return ;