if exists(select 1 from sysobjects where name = "p_gds_sc_grid_block")
	drop proc p_gds_sc_grid_block;
create proc p_gds_sc_grid_block
	@accnt		char(10),
	@type			char(5),
	@date			datetime,	-- block 时间
	@quan			int,
	@rate			money,
	@remark		varchar(50),
	@empno		char(10),
	@retmode		char(1),			-- S, R
	@ret        int	output,
   @msg        varchar(60) output
as
----------------------------------------------------------------------------------------------
--		客房资源管理程序 - grid block 
--
--			占房处理 
----------------------------------------------------------------------------------------------

declare
	@sta			char(1),
	@arr			datetime,	-- 记录包含时间的日期
	@dep			datetime,
	@begin		datetime,
	@end			datetime,
	@rmrate		money,
	@rtreason	char(3),
	@ratecode   char(10),
	@src			char(3),
	@market		char(3),
	@packages	char(50),
	@srqs		   varchar(30),
	@amenities  varchar(30),
	@gstno		int,
	@id			int,
	@quan0		int,
	@status	char(10)

select @ret=0, @msg='sc!'

begin tran
save 	tran rsvsrc_grid_block

if @quan < 0 
begin
	select @ret=1, @msg='客房预留数量不能 < 0'
	goto gout
end
select @sta=sta, @arr=arr, @dep=dep,@ratecode=ratecode,@market=market,@status=status, 
    @src=src,@packages=packages,@srqs=srqs,@amenities=amenities from sc_master where accnt=@accnt 
if @@rowcount = 0 
begin
	select @ret=1, @msg='The group master is not exists.'
	goto gout
end
if datediff(dd,@arr,@date)<0 or datediff(dd,@dep,@end)>=0
begin
	select @ret=1, @msg='客房预留区间不能超过主单的抵离日期'
	goto gout
end
if @sta not in ('R', 'W', 'I')
begin
	select @ret=1, @msg='当前状态不能进行客房预留操作'
	goto gout
end


select @rate = isnull(@rate, 0)
select @date = convert(datetime,convert(char(8),@date,1))
select @begin = @date, @end = dateadd(dd, 1, @date)
select @rmrate=0, @rtreason='', @gstno=1

--
if @sta = 'W' 
begin
	select @id = id from rsvsrc_wait where accnt=@accnt and type=@type and begin_=@begin and end_=@end and blkmark='T'
	if @@rowcount > 0
		delete rsvsrc_wait where accnt=@accnt and id=@id 
	if @quan > 0 
	begin
		select @id = isnull((select max(id) from rsvsrc_wait where accnt=@accnt), 0) + 1
		insert rsvsrc_wait (accnt,id,type,roomno,blkmark,begin_,end_,quantity,gstno,rate,remark,saccnt,master,rateok,arr,dep,
					rmrate,rtreason,ratecode,src,market,packages,srqs,amenities,cby,changed,logmark)
			values(@accnt,@id,@type,'','T',@begin,@end,@quan,@gstno,@rate,@remark,'','','F',@begin,@end,
					@rate,'',@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,getdate(),0)
	end 
end
else
begin
	select @quan0 = quantity, @id = id from rsvsrc where accnt=@accnt and type=@type and begin_=@begin and end_=@end and blkmark='T'
	if @@rowcount = 0
	begin
		if @quan > 0 
		begin
			exec p_gds_reserve_rsv_add @accnt,@type,'','T',@begin,@end,@quan,@gstno,@rate,@remark,
				@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,'R',@ret output, @msg output
		end 
	end
	else
	begin
		if @quan = 0 
			exec p_gds_reserve_rsv_del @accnt,@id,'R',@empno,@ret output, @msg output
		else
			exec p_gds_reserve_rsv_mod @accnt,@id,@type,'','T',@begin,@end,@quan,@gstno,@rate,@remark,
				@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,'R',@ret output, @msg output
	end
end

gout:

-- end 
if @ret <> 0
	rollback tran rsvsrc_grid_block
---- 一下语句放到客户端，放在这里太消耗资源 
--else
--begin 
--	declare 	@def		char(1)
--	select @def=definite from sc_ressta where code=@status 
--	if @def='T' 
--	begin 
--			insert rsvsrc_blkinit 
--				select a.* from rsvsrc a 
--					where a.accnt=@accnt 
--						and a.accnt+a.type+convert(char(10),a.begin_,111) 
--							not in (select b.accnt+b.type+convert(char(10),b.begin_,111) from rsvsrc_blkinit b where a.accnt=b.accnt)
--	end 
--end
commit tran 


if @retmode='S'
	select @ret, @msg
return @ret
;