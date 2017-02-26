----------------------------------------------------------------------------------------------
--		�ͷ���Դ������� - grid block
----------------------------------------------------------------------------------------------
if exists(select 1 from sysobjects where name = "p_gds_reserve_grid_block")
	drop proc p_gds_reserve_grid_block;
create proc p_gds_reserve_grid_block
	@accnt		char(10),
	@type			char(5),
	@date			datetime,	-- block ʱ��
	@quan			int,
	@rate			money,
	@remark		varchar(50),
	@empno		char(10),
	@retmode		char(1),			-- S, R
	@ret        int	output,
   @msg        varchar(60) output
as

declare
	@class		char(1),		-- �˺���� Fit, Grp, Met, Csm
	@sta			char(1),
	@arr			datetime,	-- ��¼����ʱ�������
	@dep			datetime,
	@begin		datetime,
	@end			datetime,
	@rmrate		money,
	@rtreason	char(3),
	@ratecode   char(10),
	@src			char(3),
	@market		char(3),
	@packages	varchar(50),
	@srqs		   varchar(30),
	@amenities  varchar(30),
	@gstno		int,
	@id			int,
	@quan0		int

select @ret=0, @msg=''

begin tran
save 	tran rsvsrc_grid_block

if @quan < 0 
begin
	select @ret=1, @msg='�ͷ�Ԥ���������� < 0'
	goto gout
end
select @sta=sta, @class=class, @arr=arr, @dep=dep,@ratecode=ratecode,@market=market,
    @src=src,@packages=packages,@srqs=srqs,@amenities=amenities from master where accnt=@accnt 
if @@rowcount = 0 
begin
	select @ret=1, @msg='The group master is not exists.'
	goto gout
end
if @class not in ('G', 'M')  -- �����ʲ����漰�ͷ���  ����̫���� ?
begin
	select @ret=1, @msg='���ʺ����Ͳ��� grid block �ͷ���Դ'
	goto gout
end
if datediff(dd,@arr,@date)<0 or datediff(dd,@dep,@end)>=0
begin
	select @ret=1, @msg='�ͷ�Ԥ�����䲻�ܳ��������ĵ�������'
	goto gout
end

select @rate = isnull(@rate, 0)
select @date = convert(datetime,convert(char(8),@date,1))
select @begin = @date, @end = dateadd(dd, 1, @date)
select @rmrate=0, @rtreason='', @gstno=1

--
select @quan0 = quantity, @id = id from rsvsrc where accnt=@accnt and type=@type and begin_=@begin and end_=@end and blkmark='T'
if @@rowcount = 0
begin
	if @quan > 0 
		exec p_gds_reserve_rsv_add @accnt,@type,'','T',@begin,@end,@quan,@gstno,@rate,@remark,
			@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,'R',@ret output, @msg output
end
else
begin
	if @quan = @quan0
		select @id = 0 -- ������Ĭ��ͨ��ʵ��û���޸�
	else if @quan = 0 
		exec p_gds_reserve_rsv_del @accnt,@id,'R',@empno,@ret output, @msg output
	else
		exec p_gds_reserve_rsv_mod @accnt,@id,@type,'','T',@begin,@end,@quan,@gstno,@rate,@remark,
			@rmrate,@rtreason,@ratecode,@src,@market,@packages,@srqs,@amenities,@empno,'R',@ret output, @msg output
end

gout:

-- end 
if @ret <> 0
	rollback tran rsvsrc_grid_block
commit tran 

if @retmode='S'
	select @ret, @msg
return @ret
;