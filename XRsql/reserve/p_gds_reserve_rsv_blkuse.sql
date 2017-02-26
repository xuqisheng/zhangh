
if exists(select 1 from sysobjects where name = "p_gds_reserve_rsv_blkuse")
	drop proc p_gds_reserve_rsv_blkuse;
create proc p_gds_reserve_rsv_blkuse
	@host_id		varchar(30),
	@blkcode		char(10),
	@type			char(5),
	@empno		char(10)
as
----------------------------------------------------------------------------------------------
--	  客房资源控制  block 应用 - 根据 rsvsrc_blk差异处理  
----------------------------------------------------------------------------------------------
declare
		@ret        int,
		@msg        varchar(60),
		@begin		datetime,
		@end			datetime,
		@quan			int,
		@count		int,
		@id			int,
		@quan0		int,
		@blkno   	char(10)

declare 
		@gstno		int,
		@rate			money,
		@remark		varchar(50),
		@rmrate		money,
		@rtreason	char(3),
		@ratecode   char(10),
		@src			char(3),
		@market		char(3),
		@packages	varchar(50),
		@srqs		   varchar(30),
		@amenities  varchar(30)

-- 
select @ret=0, @msg='', @count=0, @blkcode=isnull(rtrim(@blkcode), '')

begin tran 
save tran blkuse_t

if @blkcode = '' 
	select @blkcode = isnull((select min(blkcode) from rsvsrc_blk where host_id=@host_id and blkcode>'' ), '')

while @blkcode <> '' 
begin 
	if not exists(select 1 from rsvsrc_blk where host_id=@host_id and blkcode=@blkcode and type=@type and rmnum<>0) 
	begin 
		select @blkcode = isnull((select min(blkcode) from rsvsrc_blk where host_id=@host_id and blkcode>@blkcode ), '')
		continue 
	end 

	select @begin=min(date), @end=max(date) from rsvsrc_blk where host_id=@host_id and blkcode=@blkcode and type=@type 
	while @begin <= @end
	begin 
		select @quan=0, @quan0=0, @id=0 
		select @quan = rmnum from rsvsrc_blk where host_id=@host_id and blkcode=@blkcode and type=@type and date=@begin 
		if @quan <> 0 
		begin 
			select @count = @count + 1
			select @msg = 'sc!blkuse!'
			select @quan0 = quantity, @id=id from rsvsrc where accnt=@blkcode and type=@type and begin_=@begin
			if @@rowcount = 0
			begin
				if @quan<0 
					select @ret=1, @msg='超出 block 预留范围'
				else
				begin 
					select @gstno=1,@rate=rate,@remark='',@rmrate=rate,@rtreason='',@ratecode=ratecode,
							@src=src,@market=market,@packages=packages,@srqs=srqs,@amenities=amenities
						from rsvsrc_blkinit where accnt=@blkcode and type=@type and begin_=@begin 
					if @@rowcount = 0
						select @gstno=1,@rate=setrate,@remark='',@rmrate=setrate,@rtreason='',@ratecode=ratecode,
								@src=src,@market=market,@packages=packages,@srqs=srqs,@amenities=amenities
							from sc_master where accnt=@blkcode 
					exec p_gds_reserve_rsv_add @blkcode,@type,'','T',@begin,@begin,@quan,@gstno,@rate,@remark,
						@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,'R',@ret output, @msg output
				end 
			end 
			else
			begin
				select @gstno=1,@rate=rate,@remark='',@rmrate=rmrate,@rtreason='',@ratecode=ratecode,
						@src=src,@market=market,@packages=packages,@srqs=srqs,@amenities=amenities
					from rsvsrc where accnt=@blkcode and id=@id 

				select @quan = @quan + @quan0 
				if @quan = 0 
					exec p_gds_reserve_rsv_del @blkcode,@id,'R',@empno,@ret output, @msg output
				else if @quan > 0 
					exec p_gds_reserve_rsv_mod @blkcode,@id,@type,'','T',@begin,@begin,@quan,@gstno,@rate,@remark,
						@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,'R',@ret output, @msg output
				else
					select @ret=1, @msg='超出 block 预留范围'
			end 
			if @ret<>0 
				goto sout 
		end 
		select @begin = dateadd(dd, 1, @begin) 
	end 

	select @blkcode = isnull((select min(blkcode) from rsvsrc_blk where host_id=@host_id and blkcode>@blkcode ), '')
end 

sout:
if @ret<>0 
begin
	rollback tran blkuse_t
end 
commit tran 
return  @ret
;
