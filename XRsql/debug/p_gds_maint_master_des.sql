
if exists(select * from sysobjects where name='p_gds_master_des_reb' and type ='P')
   drop proc p_gds_master_des_reb;
create proc p_gds_master_des_reb
as
-- ------------------------------------------------------------------------
-- 系统维护程序之 master_des
--
-- Rebuld All 
-- ------------------------------------------------------------------------

declare	@bdate		datetime
select @bdate = bdate1 from sysdata

truncate table master_des

-- Insert 
insert master_des(accnt,sta_o,sta,haccnt_o,groupno_o,arr,dep,agent_o,cusno_o,source_o,src_o,market_o,restype_o,channel_o,
	artag1_o,artag2_o,ratecode_o,rtreason_o,paycode_o,wherefrom_o,whereto_o,saleid_o)
select accnt,sta,sta,haccnt,groupno,arr,dep,agent,cusno,source,src,market,restype,channel,
	artag1,artag2,ratecode,rtreason,paycode,wherefrom,whereto,saleid 
	from master

-- Insert from sc 
insert master_des(accnt,sta_o,sta,haccnt_o,groupno_o,arr,dep,agent_o,cusno_o,source_o,src_o,market_o,restype_o,channel_o,
	artag1_o,artag2_o,ratecode_o,rtreason_o,paycode_o,wherefrom_o,whereto_o,saleid_o)
select accnt,sta,sta,haccnt,'',arr,dep,agent,cusno,source,src,market,restype,channel,
	'','',ratecode,'',paycode,wherefrom,whereto,saleid 
	from sc_master 

-- Update
update master_des set haccnt=a.name, unit=a.unit from guest a, master b where master_des.accnt=b.accnt and b.haccnt=a.no
update master_des set haccnt=a.name, unit=a.unit from guest a, sc_master b where master_des.accnt=b.accnt and b.haccnt=a.no
update master_des set haccnt=b.name from sc_master b where b.haccnt='' and master_des.accnt=b.accnt

update master_des set groupno=haccnt where accnt like '[GM]%'  -- 是否为 groupno_o 

update master_des set groupno=isnull((select b.name from master a, guest b where a.haccnt=b.no and a.accnt=master_des.groupno_o), '') where groupno_o<>'' and groupno=''
update master_des set groupno=isnull((select b.name from sc_master a, guest b where a.haccnt=b.no and a.accnt=master_des.groupno_o), '') where groupno_o<>'' and groupno='' -- sc 
update master_des set groupno=isnull((select a.name from sc_master a where a.accnt=master_des.groupno_o), '') where groupno_o<>'' and groupno=''  -- sc 

update master_des set arr = convert(datetime, convert(char(10), arr, 111))
update master_des set dep = convert(datetime, convert(char(10), dep, 111))

update master_des set agent=a.name from guest a where master_des.agent_o=a.no
update master_des set cusno=a.name from guest a where master_des.cusno_o=a.no
update master_des set cusno=a.unit from guest a where master_des.haccnt_o=a.no and master_des.cusno=''  -- profile unit
update master_des set source=a.name from guest a where master_des.source_o=a.no

update master_des set src=a.descript from srccode a where master_des.src_o=a.code
update master_des set market=a.descript from mktcode a where master_des.market_o=a.code
update master_des set restype=a.descript from restype a where master_des.restype_o=a.code
update master_des set channel=a.descript from basecode a where master_des.channel_o=a.code and a.cat='channel'

update master_des set artag1=a.descript from basecode a where master_des.artag1_o=a.code and a.cat='artag1'
update master_des set artag2=a.descript from basecode a where master_des.artag2_o=a.code and a.cat='artag2'

update master_des set ratecode=a.descript from rmratecode a where master_des.ratecode_o=a.code
update master_des set rtreason=a.descript from reason a where master_des.rtreason_o=a.code
update master_des set paycode=a.descript from pccode a where master_des.paycode_o=a.pccode
update master_des set wherefrom=a.descript from cntcode a where master_des.wherefrom_o=a.code
update master_des set whereto=a.descript from cntcode a where master_des.whereto_o=a.code
update master_des set saleid=a.name from saleid a where master_des.saleid_o=a.code

-- 维护状态
update master_des set sta='Walk In' 		from master a where a.accnt=master_des.accnt and a.sta='I' and a.class='F' 
															and substring(a.extra,9,1)='1' 

update master_des set sta='Due Out' 		from master a where a.accnt=master_des.accnt and a.sta='I' and a.class in ('F','G','M')
															and datediff(dd,a.dep,getdate())=0 

update master_des set sta='Day Use' 		from master a where a.accnt=master_des.accnt and a.sta='I' and a.class in ('F','G','M') 
															and datediff(dd,a.dep,getdate())=0 and datediff(dd,a.arr,getdate())=0

update master_des set sta='Checked In' 	from master a where a.accnt=master_des.accnt and master_des.sta='I' and a.class in ('F','G','M')
update master_des set sta='Checked Out' 	from master a where a.accnt=master_des.accnt and a.sta='O'
update master_des set sta='L-C/O' 	from master a where a.accnt=master_des.accnt and a.sta='D'
update master_des set sta='Expected' 		from master a where a.accnt=master_des.accnt and a.sta='R' and a.class in ('F','G','M')
update master_des set sta='CANCELED' 		from master a where a.accnt=master_des.accnt and a.sta='X' and a.class in ('F','G','M')
update master_des set sta='Suspend' 		from master a where a.accnt=master_des.accnt and a.sta='S' and a.class in ('F','G','M')
update master_des set sta='No-Show' 		from master a where a.accnt=master_des.accnt and a.sta='N' and a.class in ('F','G','M')
update master_des set sta='WaitList' 		from master a where a.accnt=master_des.accnt and a.sta='W' and a.class in ('F','G','M')


update master_des set sta=sta_o where sta=''
;



-- ------------------------------------------------------------------------
-- Rebuld One Master 
-- ------------------------------------------------------------------------
if exists(select * from sysobjects where name='p_gds_master_des_maint' and type ='P')
   drop proc p_gds_master_des_maint;
create proc p_gds_master_des_maint
	@accnt		char(10)
as
-- ------------------------------------------------------------------------
-- 系统维护程序之 master_des
--
-- 维护单个账号
-- ------------------------------------------------------------------------

declare	@bdate		datetime,
			@arr			datetime,
			@dep			datetime,
			@sc			char(1)

declare
	@sta_o		   char(1),				@sta		   	char(1),	
	@haccnt_o		char(7),				@haccnt			char(7),
	@groupno_o		char(10),			@groupno			char(10),
	@agent_o			char(7),				@agent			char(7),
	@cusno_o			char(7),				@cusno			char(7),
	@source_o		char(7),				@source			char(7),
	@src_o			char(3),				@src				char(3),
	@market_o		char(3),				@market			char(3),
	@restype_o		char(3),				@restype			char(3),
	@channel_o		char(3),				@channel			char(3),
	@artag1_o		char(3),				@artag1			char(3),
	@artag2_o		char(3),				@artag2			char(3),
	@ratecode_o		char(10),			@ratecode		char(10),
	@rtreason_o		char(3),				@rtreason		char(3),
	@paycode_o		char(3),				@paycode			char(3),
	@wherefrom_o	char(6),				@wherefrom		char(6),
	@whereto_o		char(6),				@whereto			char(6),
	@saleid_o		char(10),			@saleid			char(10)


select @bdate = bdate1 from sysdata

if exists(select 1 from master where accnt=@accnt)
	select @sc = 'F'
else if exists(select 1 from sc_master where accnt=@accnt)
	select @sc = 'T'
else
	return 0

-- Insert 
if not exists(select 1 from master_des where accnt=@accnt)
begin
	if @sc = 'F'
		insert master_des(accnt,arr,dep) select accnt,arr,dep	from master where accnt=@accnt
	else
		insert master_des(accnt,arr,dep) select accnt,arr,dep	from sc_master where accnt=@accnt
end

-- Update
select @sta_o=sta_o,@haccnt_o=haccnt_o,@groupno_o=groupno_o,@agent_o=agent_o,@cusno_o=cusno_o,@source_o=source_o,
	@src_o=src_o,@market_o=market_o,@restype_o=restype_o,@channel_o=channel_o,@artag1_o=artag1_o,@artag2_o=artag2_o,
	@ratecode_o=ratecode_o,@rtreason_o=rtreason_o,@paycode_o=paycode_o,@wherefrom_o=wherefrom_o,@whereto_o=whereto_o,
	@saleid_o=saleid_o from master_des where accnt=@accnt

if @sc = 'F'
	select @sta=sta,@haccnt=haccnt,@groupno=groupno,@agent=agent,@cusno=cusno,@source=source,
		@src=src,@market=market,@restype=restype,@channel=channel,@artag1=artag1,@artag2=artag2,
		@ratecode=ratecode,@rtreason=rtreason,@paycode=paycode,@wherefrom=wherefrom,@whereto=whereto,
		@saleid=saleid,@arr=arr,@dep=dep from master where accnt=@accnt
else
	select @sta=sta,@haccnt=haccnt,@groupno='',@agent=agent,@cusno=cusno,@source=source,
		@src=src,@market=market,@restype=restype,@channel=channel,@artag1='',@artag2='',
		@ratecode=ratecode,@rtreason='',@paycode=paycode,@wherefrom=wherefrom,@whereto=whereto,
		@saleid=saleid,@arr=arr,@dep=dep from sc_master where accnt=@accnt

if @haccnt_o <> @haccnt
begin
	update master_des set haccnt_o=@haccnt where accnt=@accnt
	if @sc='F'
		update master_des set haccnt=a.name, unit=a.unit from guest a where master_des.accnt=@accnt and master_des.haccnt_o=a.no
	else
		update master_des set haccnt=a.name, unit='' from sc_master a where master_des.accnt=@accnt and master_des.accnt=a.accnt

	if @accnt like '[GM]%'
		update master_des set groupno=haccnt where accnt=@accnt   -- 团体
end
else if @haccnt_o='' and @haccnt='' and @sc='T' 
	update master_des set haccnt=a.name, unit='' from sc_master a where master_des.accnt=@accnt and master_des.accnt=a.accnt

if @groupno_o <> @groupno
begin
	if @groupno=''
		update master_des set groupno_o='', groupno='' where accnt=@accnt
	else
	if @sc='F'
		update master_des set groupno_o=@groupno, groupno=isnull((select b.name from master a, guest b where a.haccnt=b.no and a.accnt=@groupno), @groupno) 
			where accnt=@accnt
	else
		update master_des set groupno_o=@groupno, groupno=a.name from sc_master a 
			where master_des.accnt=@accnt and master_des.accnt=a.accnt

end

update master_des set arr = convert(datetime, convert(char(10), @arr, 111)) where accnt=@accnt
update master_des set dep = convert(datetime, convert(char(10), @dep, 111)) where accnt=@accnt

if @agent_o <> @agent
begin
	if @agent=''
		update master_des set agent_o='', agent='' where accnt=@accnt
	else
		update master_des set agent_o=@agent, agent=isnull((select name from guest where no=@agent),@agent) where accnt=@accnt
end

if @cusno_o <> @cusno
begin
	if @cusno=''
		update master_des set cusno_o='', cusno='' where accnt=@accnt
	else
		update master_des set cusno_o=@cusno, cusno=isnull((select name from guest where no=@cusno),@cusno) where accnt=@accnt
	update master_des set cusno=a.unit from guest a 
		where master_des.accnt=@accnt and master_des.haccnt_o=a.no and master_des.cusno=''  -- profile unit
end

if @source_o <> @source
begin
	if @source=''
		update master_des set source_o='', source='' where accnt=@accnt
	else
		update master_des set source_o=@source, source=isnull((select name from guest where no=@source),@source) where accnt=@accnt
end

if @src_o <> @src
begin
	if @src=''
		update master_des set src_o='', src='' where accnt=@accnt
	else
		update master_des set src_o=@src, src=isnull((select descript from srccode where code=@src),@src) where accnt=@accnt
end
--
if @market_o <> @market
begin
	if @market=''
		update master_des set market_o='', market='' where accnt=@accnt
	else
		update master_des set market_o=@market, market=isnull((select descript from mktcode where code=@market),@market) where accnt=@accnt
end

if @restype_o <> @restype
begin
	if @restype=''
		update master_des set restype_o='', restype='' where accnt=@accnt
	else
		update master_des set restype_o=@restype, restype=isnull((select descript from restype where code=@restype),@restype) where accnt=@accnt
end

if @channel_o <> @channel
begin
	if @channel=''
		update master_des set channel_o='', channel='' where accnt=@accnt
	else
		update master_des set channel_o=@channel, channel=isnull((select descript from basecode where cat='channel' and code=@channel),@channel) where accnt=@accnt
end

if @artag1_o <> @artag1
begin
	if @artag1=''
		update master_des set artag1_o='', artag1='' where accnt=@accnt
	else
		update master_des set artag1_o=@artag1, artag1=isnull((select descript from basecode where cat='artag1' and code=@artag1),@artag1) where accnt=@accnt
end

if @artag2_o <> @artag2
begin
	if @artag2=''
		update master_des set artag2_o='', artag2='' where accnt=@accnt
	else
		update master_des set artag2_o=@artag2, artag2=isnull((select descript from basecode where cat='artag2' and code=@artag2),@artag2) where accnt=@accnt
end

if @ratecode_o <> @ratecode
begin
	if @ratecode=''
		update master_des set ratecode_o='', ratecode='' where accnt=@accnt
	else
		update master_des set ratecode_o=@ratecode, ratecode=isnull((select descript from rmratecode where code=@ratecode),@ratecode) where accnt=@accnt
end

if @rtreason_o <> @rtreason
begin
	if @rtreason=''
		update master_des set rtreason_o='', rtreason='' where accnt=@accnt
	else
		update master_des set rtreason_o=@rtreason, rtreason=isnull((select descript from reason where code=@rtreason),@rtreason) where accnt=@accnt
end

if @paycode_o <> @paycode
begin
	if @paycode=''
		update master_des set paycode_o='', paycode='' where accnt=@accnt
	else
		update master_des set paycode_o=@paycode, paycode=isnull((select descript from pccode where pccode=@paycode),@paycode) where accnt=@accnt
end

if @wherefrom_o <> @wherefrom
begin
	if @wherefrom=''
		update master_des set wherefrom_o='', wherefrom='' where accnt=@accnt
	else
		update master_des set wherefrom_o=@wherefrom, wherefrom=isnull((select descript from cntcode where code=@wherefrom),@wherefrom) where accnt=@accnt
end

if @whereto_o <> @whereto
begin
	if @whereto=''
		update master_des set whereto_o='', whereto='' where accnt=@accnt
	else
		update master_des set whereto_o=@whereto, whereto=isnull((select descript from cntcode where code=@whereto),@whereto) where accnt=@accnt
end

if @saleid_o <> @saleid
begin
	if @saleid=''
		update master_des set saleid_o='', saleid='' where accnt=@accnt
	else
		update master_des set saleid_o=@saleid, saleid=isnull((select name from saleid where code=@saleid),@saleid) where accnt=@accnt
end

-- 维护状态
if @sta_o <> @sta
begin
	update master_des set sta_o=@sta where accnt=@accnt

	if exists(select 1 from master where accnt=@accnt and sta='I' and class='F' and substring(extra,9,1)='1' and bdate=@bdate)
		update master_des set sta='Walk In' where accnt=@accnt
	else if exists(select 1 from master where accnt=@accnt and sta='I' and class in ('F','G','M') and datediff(dd,dep,getdate())=0)
		update master_des set sta='Due Out' where accnt=@accnt
	else if exists(select 1 from master where accnt=@accnt and sta='I' and class in ('F','G','M') and datediff(dd,dep,getdate())=0 and datediff(dd,arr,getdate())=0)
		update master_des set sta='Day Use' where accnt=@accnt
	else if exists(select 1 from master where accnt=@accnt and sta='I' and class in ('F','G','M'))
		update master_des set sta='Checked In' where accnt=@accnt
	else if exists(select 1 from master where accnt=@accnt and sta='O' and class in ('F','G','M'))
		update master_des set sta='Checked Out' where accnt=@accnt
	else if exists(select 1 from master where accnt=@accnt and sta='R' and class in ('F','G','M'))
		update master_des set sta='Expected' where accnt=@accnt
	else if exists(select 1 from master where accnt=@accnt and sta='X' and class in ('F','G','M'))
		update master_des set sta='CANCELED' where accnt=@accnt
	else if exists(select 1 from master where accnt=@accnt and sta='S' and class in ('F','G','M'))
		update master_des set sta='Suspend' where accnt=@accnt
	else if exists(select 1 from master where accnt=@accnt and sta='N' and class in ('F','G','M'))
		update master_des set sta='No-Show' where accnt=@accnt
	else if exists(select 1 from master where accnt=@accnt and sta='W' and class in ('F','G','M'))
		update master_des set sta='WaitList' where accnt=@accnt
	else if exists(select 1 from master where accnt=@accnt and sta='D' and class in ('F','G','M'))
		update master_des set sta='L-C/O' where accnt=@accnt
	else
		update master_des set sta=@sta where accnt=@accnt
end
;
