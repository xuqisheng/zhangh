if  exists(select * from sysobjects where name = "p_gds_reserve_ctrltype_check" and type = "P")
	drop proc p_gds_reserve_ctrltype_check;
create proc p_gds_reserve_ctrltype_check
	@type				char(5),
	@s_time			datetime,
	@e_time			datetime,
	@retmode			char(1),
	@value			int		output  -- 0=没有超出，或者不用判断 1=超出了
as
-- ------------------------------------------------------------------------------------
--  大房类预留控制判断 
-- ------------------------------------------------------------------------------------

declare		@gtype			char(3),
				@gquan			int,	-- 客房总数
				@gblock			int,	-- 总占房
				@gover			int	-- 超预订设置

select @value = 0
select @gtype = gtype from typim where type=@type 
if @@rowcount = 0 
	goto gout 

select @gquan = sum(quantity) from typim where gtype=@gtype 
while @s_time <= @e_time
begin
	select @gover=0, @gblock=0, @value = 0  
	select @gover = overbook from rsvlimit where date=@s_time and gtype=@gtype and type='' 
	if @@rowcount = 0
	begin
		select @s_time = dateadd(dd, 1, @s_time)
		continue 
	end

	select @gblock = isnull((select sum(a.blockcnt) from rsvtype a, typim b where a.type=b.type and b.gtype=@gtype and a.begin_>=@s_time and @s_time<a.end_), 0) 
	select @value = @gquan + @gover - @gblock
	if @value < 0 
	begin 
		select @value = 1 
		goto gout 
	end 

	select @s_time = dateadd(dd, 1, @s_time)
end
select @value = 0

-- Output
gout:
if @retmode = 'S'
	select @value
return 0
;