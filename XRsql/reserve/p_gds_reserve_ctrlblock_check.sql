if  exists(select * from sysobjects where name = "p_gds_reserve_ctrlblock_check" and type = "P")
	drop proc p_gds_reserve_ctrlblock_check;
create proc p_gds_reserve_ctrlblock_check
	@s_time			datetime,
	@e_time			datetime,
	@retmode			char(1),
	@value			int		output  -- 0=没有超出，或者不用判断 1=超出了
as
-- ------------------------------------------------------------------------------------
--  客房使用总体控制 - 兼顾 sysoptin & rsvlimit 控制 
-- ------------------------------------------------------------------------------------

declare		@cntlblock		char(1),	-- flag
				@cntlquan		int,		-- 总体可超数量
				@avl				int

select @value = 0   -- Init 
select @s_time = convert(datetime,convert(char(8),@s_time,1))
select @e_time = convert(datetime,convert(char(8),@e_time,1))

-- 需要总量控制吗 ?
select @cntlblock = rtrim(value) from sysoption where catalog = "reserve" and item = "cntlblock"
if @@rowcount = 0 or @cntlblock is null
   select @cntlblock = 'F'
if charindex(@cntlblock, 'TtYy') = 0   -- 不用判断
begin
	goto gout
end
select @cntlquan = convert(int,value) from sysoption where catalog = "reserve" and item = "cntlquan"
if @@rowcount = 0 or @cntlquan is null
   select @cntlquan = 0
--if @cntlquan <= 0   -- 不用判断.     根据何老师建议调整，只要勾上总量控制，就生效 
--begin
--	goto gout
--end

-- 计算可用数字，注意参数 2
exec p_gds_reserve_type_avail '',@s_time,@e_time,'2','R',@avl output

if @avl < 0 
begin
	select @value = 1   -- 超出 !
	goto gout
end

-- Output
gout:
if @retmode = 'S'
	select @value
return 0
;