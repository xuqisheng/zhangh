if  exists(select * from sysobjects where name = "p_gds_reserve_ctrlblock_check" and type = "P")
	drop proc p_gds_reserve_ctrlblock_check;
create proc p_gds_reserve_ctrlblock_check
	@s_time			datetime,
	@e_time			datetime,
	@retmode			char(1),
	@value			int		output  -- 0=û�г��������߲����ж� 1=������
as
-- ------------------------------------------------------------------------------------
--  �ͷ�ʹ��������� - ��� sysoptin & rsvlimit ���� 
-- ------------------------------------------------------------------------------------

declare		@cntlblock		char(1),	-- flag
				@cntlquan		int,		-- ����ɳ�����
				@avl				int

select @value = 0   -- Init 
select @s_time = convert(datetime,convert(char(8),@s_time,1))
select @e_time = convert(datetime,convert(char(8),@e_time,1))

-- ��Ҫ���������� ?
select @cntlblock = rtrim(value) from sysoption where catalog = "reserve" and item = "cntlblock"
if @@rowcount = 0 or @cntlblock is null
   select @cntlblock = 'F'
if charindex(@cntlblock, 'TtYy') = 0   -- �����ж�
begin
	goto gout
end
select @cntlquan = convert(int,value) from sysoption where catalog = "reserve" and item = "cntlquan"
if @@rowcount = 0 or @cntlquan is null
   select @cntlquan = 0
--if @cntlquan <= 0   -- �����ж�.     ���ݺ���ʦ���������ֻҪ�����������ƣ�����Ч 
--begin
--	goto gout
--end

-- ����������֣�ע����� 2
exec p_gds_reserve_type_avail '',@s_time,@e_time,'2','R',@avl output

if @avl < 0 
begin
	select @value = 1   -- ���� !
	goto gout
end

-- Output
gout:
if @retmode = 'S'
	select @value
return 0
;