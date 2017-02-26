----------------------------------------
--	下方还有过程 ： 批量转移数据  p_666 
----------------------------------------


IF OBJECT_ID('p_gds_master_tosc') IS NOT NULL
    DROP PROCEDURE p_gds_master_tosc
;
create proc p_gds_master_tosc
   @accnt  	char(10),
   @empno  	char(10),
	@retmode	char(1) = 'S',
	@ret		int				output,
	@msg		varchar(60)		output
as
--------------------------------------------------------------------
--	master to sc --> send to SC  system 
--	酒店曾经没有使用 sc, 新启用的时候, 把fo 里面的后期不确定团体预定转移到 sc , 就可以使用该过程 .
-- 
-- 使用前, 请通读并且针对性修改.
--------------------------------------------------------------------
declare
   @sta       	char(1),
	@bdate		datetime,
	@haccnt		char(7),
	@extra		char(15),
	@name			varchar(50),
	@name2		varchar(50),
	@restype		char(3),
	@ratecode	char(10),
	@status		char(10),
	@type			char(5),
	@arr			datetime,
	@dep			datetime,
	@date			datetime,
	@quan			int,
	@quan0		int,
	@gstno		int,
	@rate			money,
	@remark		varchar(50)

select @ret = 0,@msg = ""
select @bdate = bdate1 from sysdata

-- 
CREATE TABLE #rsvsrc 
(
	accnt     char(10)    NOT NULL,
	id        int         DEFAULT 0	 NOT NULL,
	type      char(5)     NOT NULL,
	roomno    char(5)     DEFAULT ''	 NOT NULL,
	blkmark   char(1)     DEFAULT ''	 NOT NULL,
	begin_    datetime    NOT NULL,
	end_      datetime    NOT NULL,
	quantity  int         DEFAULT 0	 NOT NULL,
	gstno     int         DEFAULT 0	 NOT NULL,
	rmrate    money       DEFAULT 0	 NOT NULL,
	rate      money       DEFAULT 0	 NOT NULL,
	rtreason  char(3)     DEFAULT ''	 NOT NULL,
	remark    varchar(50) DEFAULT ''	 NOT NULL,
	saccnt    char(10)    DEFAULT ''	 NOT NULL,
	master    char(10)    DEFAULT ''	 NOT NULL,
	rateok    char(1)     DEFAULT 'F'	 NOT NULL,
	arr       datetime    NOT NULL,
	dep       datetime    NOT NULL,
	ratecode  char(10)    DEFAULT '' 	 NOT NULL,
	src       char(3)     DEFAULT '' 	 NOT NULL,
	market    char(3)     DEFAULT '' 	 NOT NULL,
	packages  char(50)    DEFAULT ''	 NOT NULL,
	srqs      varchar(30) DEFAULT ''	 NOT NULL,
	amenities varchar(30) DEFAULT ''	 NOT NULL,
	exp_m     money       NULL,
	exp_dt    datetime    NULL,
	exp_s1    varchar(20) NULL,
	exp_s2    varchar(20) NULL,
	cby       char(10)    NULL,
	changed   datetime    NULL,
	logmark   int         DEFAULT 0		 NULL
)

begin tran
save  tran p_gds_master_tosc_s1

select @sta=sta, @haccnt=haccnt, @extra=extra, @restype=restype from master where accnt=@accnt
if @@rowcount = 0 
begin
	select @ret=1, @msg='当前账户不存在'
	goto gout 
end
if @sta<>'R'
begin
	select @ret=1, @msg='当前账户非有效预订状态'
	goto gout 
end
if exists(select 1 from master where groupno=@accnt)
begin
	select @ret=1, @msg='该团体成员已经开始分配,不能转入 SC'
	goto gout 
end


update master set sta = sta where accnt = @accnt

-- 注意几个对应关系 
--			master.extra = 14=grid block 15=sc 
--			master.exp_s2 = sc_master.contact 
--			master.exp_dt1 = sc_master.cutoff 
select @extra = stuff(@extra, 14, 2, '10')
select @name=name, @name2=name2 from guest where no=@haccnt
if exists(select 1 from restype where code=@restype and definite='T')
	select @status='DEF'
else
	select @status='TEN'

-- 
select @rate = setrate, @ratecode=ratecode from master where accnt=@accnt 
if exists(select 1 from rsvsrc where accnt=@accnt and id>0)
	select @rate = isnull((select max(rate) from rsvsrc where accnt=@accnt and id>0), 0)
if exists(select 1 from sysoption where catalog='hotel' and item='hotelid' and value='BJGBJD')
	select @ratecode = 'GROUP'

-- Insert record 
--   	ref - 是否需要放到 notes ? 
--		how about master_till ?
insert sc_master(
	accnt,foact,haccnt,type,otype,rmnum,roomno,oroomno,bdate,sta,osta,sta_tm,arr,dep,oarr,odep,
	agent,cusno,source,class,src,market,restype,channel,gstno,children,ratecode,packages,setrate,paycode,
	limit,credcode,credman,credunit,araccnt,wherefrom,whereto,purpose,arrdate,arrinfo,arrcar,arrrate,depdate,depinfo,depcar,deprate,
	extra,charge,credit,accredit,lastnumb,lastinumb,srqs,amenities,master,saccnt,pcrec,pcrec_pkg,resno,crsno,ref,comsg,saleid,
	cmscode,cardcode,cardno,contact,name,name2,blkcode,status,btype,bscope,potential,saleid2,peakrms,avrate,
	cutoff,c_status,c_saleid,resby,restime,cby,changed,logmark
)
SELECT accnt,'',haccnt,type,otype,rmnum,roomno,oroomno,bdate,sta,osta,sta_tm,arr,dep,oarr,odep,
	agent,cusno,source,class,src,market,restype,channel,gstno,children,@ratecode,packages,@rate,paycode,
	limit,credcode,credman,credunit,araccnt,wherefrom,whereto,purpose,arrdate,arrinfo,arrcar,arrrate,depdate,depinfo,depcar,deprate,
	extra,charge,credit,accredit,lastnumb,lastinumb,srqs,amenities,master,saccnt,pcrec,pcrec_pkg,resno,crsno,ref,comsg,saleid,
	cmscode,cardcode,cardno,isnull(exp_s2,''),@name,@name2,'',@status,'','0','',saleid,0,0,
	exp_dt1,@status,saleid,resby,restime,cby,changed,logmark  
FROM master where accnt=@accnt
if @@rowcount = 1 
begin
	-- 客房资源转移
	if exists(select 1 from rsvsrc where accnt=@accnt and id>0)
	begin
		-- 记录 fo 资源
		insert #rsvsrc( accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,
			rmrate,rate,rtreason,remark,saccnt,master,rateok,arr,dep,ratecode,
			src,market,packages,srqs,amenities,exp_m,exp_dt,exp_s1,exp_s2,
			cby,changed,logmark)
		select accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,
			rmrate,rate,rtreason,remark,saccnt,master,rateok,arr,dep,ratecode,
			src,market,packages,srqs,amenities,exp_m,exp_dt,exp_s1,exp_s2,
			cby,changed,logmark from rsvsrc where accnt=@accnt and id>0
		
		-- 释放原来的 fo 资源
		exec @ret = p_gds_reserve_release_block  @accnt, @empno
		if @ret <> 0 
		begin
			select @msg = '资源释放错误'
			goto gout 
		end

		-- 重建资源 in SC 
		declare c_grid cursor for select type,begin_,end_,quantity,rate,remark from #rsvsrc
		open c_grid
		fetch c_grid into @type,@arr,@dep,@quan,@rate,@remark
		while @@sqlstatus = 0
		begin
			select @date = @arr 
			while @date < @dep
			begin
				-- 注意叠加
				select @quan0 = isnull((select sum(quantity) from rsvsrc where accnt=@accnt and type=@type and begin_=@date and blkmark='T'), 0)
				select @quan0 = @quan + @quan0

				-- 
				exec p_gds_sc_grid_block @accnt,@type,@date,@quan0,@rate,@remark,@empno,'R',@ret output,@msg output
				if @ret<>0 
				begin
					close c_grid
					deallocate cursor c_grid
					goto gout
				end
	
				select @date = dateadd(dd, 1, @date)
			end

			fetch c_grid into @type,@arr,@dep,@quan,@rate,@remark
		end
		close c_grid
		deallocate cursor c_grid

		-- 
		delete master where accnt=@accnt 
		if @@rowcount = 0
			select @ret=1, @msg='清除前台订单错误'
	end
end
else
begin
	select @ret=1, @msg='发送失败'
end

-- 
gout:
if @ret <> 0
   rollback tran p_gds_master_tosc_s1
commit tran

if @retmode = 'S'
	select @ret,@msg
return @ret
;


IF OBJECT_ID('p_666') IS NOT NULL
    DROP PROCEDURE p_666
;
create proc p_666
as
--------------------------------------------------------
--	批量转移数据 -- 两天以后的非确认预定全部转移
--------------------------------------------------------
declare	@accnt		char(10),
			@ret			int,
			@msg			varchar(60),
			@begin		datetime


delete gdsmsg 
select @begin = dateadd(dd, 2, getdate()) 

-- 重建资源 in SC 
declare c_tosc cursor for select accnt from master 
	where accnt like '[GM]%' and sta='R' and arr>@begin and restype='3' order by arr    -- 注意,这里的 restype 
open c_tosc
fetch c_tosc into @accnt
while @@sqlstatus = 0
begin
	exec p_gds_master_tosc @accnt, 'FOX', 'R', @ret output, @msg output 
	if @ret<>0 
		insert gdsmsg select @accnt + '  ' + @msg 
	else
		insert gdsmsg select @accnt + '  ok'
	
	fetch c_tosc into @accnt
end
close c_tosc
deallocate cursor c_tosc

return
;