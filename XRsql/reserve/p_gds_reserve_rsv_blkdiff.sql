
if exists(select 1 from sysobjects where name = "p_gds_reserve_rsv_blkdiff")
	drop proc p_gds_reserve_rsv_blkdiff;
create proc p_gds_reserve_rsv_blkdiff
	@host_id		varchar(30),
	@blkcode		char(10),
	@type			char(5),
	@begin		datetime,
	@end			datetime,
	@mode			char(10)		-- before, before+, after, after+  
as
----------------------------------------------------------------------------------------------
--	  �ͷ���Դ����  block Ӧ�ò����¼
--
--		���´���ٶ� before, after ����� type, begin, end һ�� 
----------------------------------------------------------------------------------------------
declare
			@quan			int

-- 
if @mode='before' 
	delete rsvsrc_blk where host_id=@host_id

-- 
while @begin < @end 
begin
	-- ����׷������������ص��� 
	if @mode='before+' and exists(select 1 from rsvsrc_blk where host_id=@host_id and blkcode=@blkcode and type=@type and date=@begin)
	begin
		select @begin = dateadd(dd, 1, @begin)
		continue 
	end 
	
	-- �ȼ��� block �����Ĵ���
	select @quan = isnull((select sum(quantity) from rsvsrc where accnt=@blkcode and type=@type and begin_<=@begin and end_>@begin and roomno='' ), 0) 
	select @quan = @quan + isnull((select count(distinct roomno) from rsvsrc where accnt=@blkcode and type=@type	and begin_<=@begin and end_>@begin and roomno<>''),0)
	-- �ȼ��� block Ӧ�õĴ���
	select @quan = @quan + isnull((select sum(quantity) from rsvsrc where blkcode=@blkcode and type=@type and begin_<=@begin and end_>@begin and roomno='' ), 0) 
	select @quan = @quan + isnull((select count(distinct roomno) from rsvsrc where blkcode=@blkcode and type=@type	and begin_<=@begin and end_>@begin and roomno<>''),0)
	
	-- ��¼ 
	if @mode like 'before%'
		insert rsvsrc_blk(host_id,blkcode,type,date,rmnum1) values(@host_id,@blkcode,@type,@begin,@quan) 
	else 
		update rsvsrc_blk set rmnum2=@quan where host_id=@host_id and blkcode=@blkcode and type=@type and date=@begin 

	select @begin = dateadd(dd, 1, @begin)
end

--
if @mode like 'after%' 
	update rsvsrc_blk set rmnum=rmnum1 - rmnum2 where host_id=@host_id 

return ;
