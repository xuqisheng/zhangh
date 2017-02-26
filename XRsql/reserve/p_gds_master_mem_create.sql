----------------------------------------------------------------------------------------------
--		团体直接生成成员
--		注意 虚拟房号
----------------------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = "p_gds_master_mem_create")
	drop proc p_gds_master_mem_create;
create proc p_gds_master_mem_create
	@accnt		char(10),
	@type			char(5),
	@roomno		char(5),
	@arr			datetime,
	@dep			datetime,
	@quan			int,
	@gstno		int,
	@rate			money,
	@remark		varchar(50),
-- New begin
	@rmrate		money,
	@rtreason	char(3),
	@ratecode   char(10),
	@src			char(3),
	@market		char(3),
	@packages	varchar(50),
	@srqs		   varchar(30),
	@amenities  varchar(30),
-- New end	
	@empno		char(10),
	@retmode		char(1),			-- S, R
	@ret        int	output,
   @msg        varchar(60) output
as
----------------------------------------------------------------------------------------------
--		团体直接生成成员
--		注意 虚拟房号
----------------------------------------------------------------------------------------------
declare	@maccnt		char(10),
			@class		char(1),
			@sta			char(1),
			@grparr		datetime,
			@grpdep		datetime,
			@over			int,
			@extra		char(30),
			@qtrate		money,
			@hall			char(1)

select @ret=0, @msg='', @maccnt='', @over=0, @qtrate=null

-- 检测参数的有效性
select @type=isnull(rtrim(@type), ''), @roomno=isnull(rtrim(@roomno), '')
if @type='' and @roomno=''
begin
	select @ret=1, @msg='请输入客房信息'
	goto gout
end
if datediff(dd,getdate(),@arr)<0 or @arr>@dep 
begin
	select @ret=1, @msg='日期错误'
	goto gout
end
if @rate is null or @rate<0 or @rate>100000
begin
	select @ret=1, @msg='房价错误'
	goto gout
end
if @gstno is null or @gstno<0 or @gstno>10
begin
	select @ret=1, @msg='人数错误'
	goto gout
end
if @roomno<>''
begin
	select @type = type, @qtrate=rate from rmsta where roomno=@roomno
	if @@rowcount = 0
	begin
		select @ret=1, @msg='房号不存在'
		goto gout
	end
end
if not exists(select 1 from typim where type=@type)
begin
	select @ret=1, @msg='房类不存在'
	goto gout
end
if @qtrate is null
	select @qtrate=rate from typim where type=@type

-- 检测团体主单账号的有效性
select @sta=sta, @class=class, @grparr=arr, @grpdep=dep from master where accnt=@accnt
if @@rowcount = 0
begin
	select @ret=1, @msg='主单不存在'
	goto gout
end
if charindex(@class, 'GM')=0
begin
	select @ret=1, @msg='非团体会议主单'
	goto gout
end
if charindex(@sta, 'RI')=0
begin
	select @ret=1, @msg='主单状态有误'
	goto gout
end

--  日期检测
if datediff(dd,@grparr,@arr)<0 or datediff(dd,@grpdep,@dep)>0
begin
	select @ret=1, @msg='成员日期不能超过团体日期'
	goto gout
end

-- master_middle
if not exists(select 1 from master_middle where accnt=@accnt)
	exec @ret = p_gds_master_grpmid @accnt,'R', @ret output, @msg output
if @ret <> 0 
	goto gout

-- quan 
if @roomno<>'' or @quan<=0 or @quan>100
	select @quan = 1

-- 不能放在事务里面
select * into #master from master where 1=2  

-- Mem extra
select @extra = substring(value,1,30) from sysoption where catalog='reserve' and item='mem_extra'
if @@rowcount=0 or rtrim(@extra) is null
	select @extra = '000000000000000000000000000000'
select @extra = substring(rtrim(@extra) + '000000000000000000000000000000', 1, 30)
-- hall adjustment 
select @hall = substring(@extra, 2, 1)
if not exists(select 1 from basecode where cat='hall' and code=@hall)
begin
	select @hall = min(code) from basecode where cat='hall'
	select @extra = stuff(@extra, 2, 1, @hall)
end

-- 开始进行：小事务
while @quan > 0
begin
	begin tran
	save 	tran mem_create
	
	delete #master
	insert #master select * from master_middle where accnt=@accnt
	exec p_GetAccnt1 'FIT', @maccnt output
	update #master set sta='R', osta=' ', accnt=@maccnt, master=@maccnt, type=@type,otype='',roomno=@roomno,oroomno='',rmnum=1, ormnum=0,
		resby=@empno,restime=getdate(),ciby='',citime=null,cby=@empno,changed=getdate(),logmark=0, groupno=@accnt,
		pcrec='',pcrec_pkg='',lastnumb=0,lastinumb=0,charge=0,credit=0,accredit=0,arr=@arr,dep=@dep,
		qtrate=@rmrate, rmrate=@rmrate, setrate=@rate, discount=0, discount1=0, gstno=@gstno, children=0,extra=@extra,
		rtreason=@rtreason,ratecode=@ratecode,src=@src,market=@market,packages=@packages,srqs=@srqs,amenities=@amenities

	if rtrim(@remark) is not null
		update #master set ref = @remark
	
	insert master select * from #master
	exec @ret = p_gds_reserve_chktprm @maccnt,'0','',@empno,'',1,1,@msg output
	if @ret = 0
	begin
		update master set logmark=logmark+1 where accnt=@maccnt
		exec p_gds_master_des_maint @maccnt
		select @over = @over + 1
	end
	else
	begin	
		rollback tran mem_create
		select @msg = '完成:%1^' + convert(char(3),@over) + '  ' + @msg
		goto gout
	end
	commit tran
	select @quan = @quan - 1
end

gout:
if @retmode='S'
	select @ret, @msg
return @ret
;

