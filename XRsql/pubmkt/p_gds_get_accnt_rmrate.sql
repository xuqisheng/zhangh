if  exists(select * from sysobjects where name = "p_gds_get_accnt_rmrate")
	drop proc p_gds_get_accnt_rmrate;
create proc p_gds_get_accnt_rmrate
	@accnt			char(10),
	@rmrate			money			output,		-- 数值
	@msg				varchar(60)	output,
	@expdate			datetime	= null			-- 指定日期
as
-- ----------------------------------------------------------------------------------
--	根据帐号取得房价   (master)
--	@msg = 'fut' -- 表示获取未来价格 - 需要对比的
--      否则，表示直接获取协议价格
-- ----------------------------------------------------------------------------------
declare 
	@ret				int,
	@arr				datetime,
	@dep				datetime,
	@long				int,
	@type				char(5),
	@roomno			char(5),
	@rmnums			int,
	@gstno			int,
	@ratecode		char(10),
	@groupno			char(10),
	@bdate			datetime,
	@bfdate			datetime,
	@fut				char(1),
	@mkt				char(3),
	@setrate			money,
	@sta				char(1),
	@saccnt			char(10),
	@keydate			datetime, 	-- 价格参照日期 
	@keyrmrate		money,
	@keyrate			money,
	@mode				char(1),
   @count         int 

if rtrim(@msg) is null select @msg=''
if @msg='fut' 
	select @fut='1'
else
	select @fut='0'

select @ret=0, @rmrate=0, @msg=''
select @bdate = bdate1 from sysdata
select @bfdate=dateadd(dd,-1,@bdate)

//判断是否有每日房价,如果使用了每日房价,则相应的包价和房价需要从rsvsrc_detail中取
select @count=count(1) from rsvsrc_detail where accnt=@accnt and datediff(day,date_,@expdate)=0 and mode='M'
     if @count>0 
			begin
           select @arr=arr, @dep=dep, @type=type, @roomno=roomno, @groupno=groupno, @ratecode=ratecode, 
					@rmnums=rmnum, @gstno=gstno, @mkt=market, @setrate=setrate,@sta=sta, @saccnt=saccnt
				from master where accnt=@accnt
           select @setrate=rate from rsvsrc_detail where accnt=@accnt and date_=@expdate
         end  

else
		select @arr=arr, @dep=dep, @type=type, @roomno=roomno, @groupno=groupno, @ratecode=ratecode, 
					@rmnums=rmnum, @gstno=gstno, @mkt=market, @setrate=setrate,@sta=sta, @saccnt=saccnt
				from master where accnt=@accnt


if @@rowcount = 0
	select @ret=1, @msg='帐号不存在 !', @rmrate=@setrate
else if @sta<>'R' and @sta<>'I'
	select @ret=1, @msg='非有效账户状态', @rmrate=@setrate
else
begin
	-- 提取计算模式 - 0=维持主单价格 1=严格按照协议价格 2=差价 3=比率 
	select @mode = isnull((select substring(value,1,1) from sysoption where catalog = 'reserve' and item = 'rmrate_autochg_mode'), '0')
	if charindex(@mode, '0123') = 0 
		select @mode = '0'

	-- 关于日期
	select @arr = convert(datetime,convert(char(8),@arr,1))
	select @dep = convert(datetime,convert(char(8),@dep,1))
	select @long = datediff(dd, @arr, @dep)
	if @long <= 0	
		select @long = 1
	if @expdate is null
		select @expdate = @bdate

--	if @fut='1'  -- 对比取价, 自动变价的时候需要... 提前过房费需要, 长包房需要
--	begin
--		if @expdate<@arr 
--			select @expdate = @arr
--		if @expdate>@dep
--			select @expdate = @dep
		select @expdate = convert(datetime,convert(char(8),@expdate,1))

		if @expdate <= @bdate or @mode='0' 
		begin
			select @rmrate=@setrate 
		end 
		else if exists(select 1 from mktcode where code=@mkt and flag='LON')	
			and exists(select 1 from ls_master where accnt=@accnt)
		begin -- 长包房的价格进行了每日定义的时候，自动获取每日价格 
			select @rmrate=isnull((select rate from ls_detail where accnt=@accnt and date=@expdate), 0)
		end
		else
		begin
			-- 有些情况不用处理
			select @long=isnull((select count(1) from rsvsrc where saccnt=@saccnt and rate<>0), 0)
			if @long>1  -- 同住房价，多个主单都有价格的情况 
			begin
				select @rmrate=@setrate 
			end
			else
			begin
				-- 先获取参照信息 
				if @arr > @bdate
					select @keydate=@arr
				else
					select @keydate=@bdate 
				select @keyrate=@setrate
				exec @ret = p_gds_get_rmrate @keydate, @long, @type, @roomno, @rmnums, @gstno, @ratecode, @groupno, 'R', @keyrmrate output, @msg output
				if @ret = 0 
				begin
					if @expdate <= @keydate 
						select @rmrate = @setrate 
					else
					begin
						exec @ret = p_gds_get_rmrate @expdate, @long, @type, @roomno, @rmnums, @gstno, @ratecode, @groupno, 'R', @rmrate output, @msg output
						if @ret=0 
						begin
							if @keyrmrate=@rmrate 
								select @rmrate = @keyrate 
							else
							begin
								if @mode='1' 	-- 1=严格按照协议价格
								begin	
									if @keyrate<>@keyrmrate 
										select @rmrate=@keyrate 
								end
								else if @mode = '2'	-- 2=差价
								begin	
									select @rmrate=@keyrate - @keyrmrate + @rmrate 
								end
								else if @mode = '3'	-- 3=比率 
								begin	
									select @rmrate=round(@keyrate * @rmrate / @keyrmrate, 2) 
								end
							end 
						end
						else
							select @rmrate = @setrate -- 由于未来日期的协议价格无法获取，就直接用原来的价格 
					end 
				end
				else
					select @rmrate = @setrate -- 由于原来的协议价格无法获取，就直接用原来的价格 
			end
		end 
--	end
--	else		-- 仅仅用来获取'协议价'
--	begin
--		select @expdate = convert(datetime,convert(char(8),@expdate,1))
--		-- 散客的情况,是否要根据相同预订号 或者 联房 考虑-----> 房数和人数?
--		select @expdate = convert(datetime,convert(char(8),@expdate,1))
--		if @expdate <= @bdate 
--			select @rmrate = @setrate 
--		else
--			exec @ret = p_gds_get_rmrate @expdate, @long, @type, @roomno, @rmnums, @gstno, @ratecode, @groupno, 'R', @rmrate output, @msg output
--	end
end

return @ret
;

-- 
-- select accnt,setrate,arr,dep from master where class='F' and groupno='' and sta='I';
--
--      -------------->  测试的脚本
-- declare 
-- @ret           int,
-- @rmrate			money,
-- @msg		 varchar(60)
-- select @msg='fut'
-- delete gdsmsg
-- exec @ret = p_gds_get_accnt_rmrate 'F501160003',@rmrate output,@msg output,'2005/4/5'
-- if @ret=0
-- 	insert gdsmsg select convert(char(10), @rmrate)
-- else
-- 	insert gdsmsg select isnull(@msg, '')
-- ;
-- select * from gdsmsg;