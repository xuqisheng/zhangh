
IF OBJECT_ID('p_gds_reserve_strategy_rq') IS NOT NULL
    DROP PROCEDURE p_gds_reserve_strategy_rq
;
create proc p_gds_reserve_strategy_rq
	@pc_id			char(4),
	@s_time			datetime,
	@e_time			datetime,
	@gstno			int,
	@rmnum			int,
	@ratecode		char(10),
	@haccnt			char(7),
	@cusno			char(7),
	@agent			char(7),
	@source			char(7),
	@class			char(1),
	@rmnum_before	int
as
-- ------------------------------------------------------------------------------------
--  房价策略 - 房价查询过滤
--  对传入的 rate_query_filter 过滤即可 
-- ------------------------------------------------------------------------------------
declare		@id			char(10),
				@today		datetime,
				@gtypes		varchar(100),
				@rmtypes		varchar(100),
				@ratecats	varchar(100),
				@ratecodes	varchar(200),
				@cond_value	money, 
				@cond_parm	varchar(254),
				@pos			int,
				@pos1			int,
				@no			char(7),
				@begin		datetime,
				@end			datetime,
				@action		char(1)

//-- debug info 
//delete rate_query_filter 
//insert rate_query_filter select @pc_id, 'rmtype', gtype, type from typim where tag<>'P'
//insert rate_query_filter select @pc_id, 'ratecode', cat, code from rmratecode where halt<>'T' 

-- 
select @today = convert(datetime,convert(char(8),getdate(),1))
-- 目前只针对监控日期进行处理 
select @id = isnull((select min(id) from rmrate_strategy where halt='F' and wdate1 is not null and wdate2 is not null and @today>=wdate1 and @today<=wdate2), '') 
while @id<>''
begin 
	-- 内容过滤 
	select @gtypes=gtype, @rmtypes=rmtype, @ratecats=ratecat, @ratecodes=ratecode, @cond_parm=cond_parm, @cond_value=cond_value from rmrate_strategy where id=@id 
	if not exists(select 1 from rate_query_filter where pc_id=@pc_id 
							and (@gtypes='' or (class='rmtype' and charindex(grp,@gtypes)>0) )
							and (@rmtypes='' or (class='rmtype' and charindex(code,@rmtypes)>0) )
							and (@ratecats='' or (class='ratecode' and charindex(grp,@ratecats)>0) )
							and (@ratecodes='' or (class='ratecode' and charindex(code,@ratecodes)>0) )
						)
	begin 
		select @id = isnull((select min(id) from rmrate_strategy where halt='F' and wdate1 is not null and wdate2 is not null and @today>=wdate1 and @today<=wdate2 and id>@id), '') 
		continue
	end 
	-- 策略过滤 
	if @id = '3'	-- 特价房数量控制 
	begin 
		declare	@tjf_rc				varchar(100),
					@tjf_rm_limit		int,
					@tjf_rm				int

		select @pos = charindex('char99=', @cond_parm) 
		if @pos>0
		begin 
			select @cond_parm = substring(@cond_parm, @pos+7, 254)
			select @pos = charindex(';', @cond_parm)
			if @pos>0
			begin 
				select @tjf_rc = substring(@cond_parm, 1, @pos-1)  -- 获取特价房标示 - 房价码串 
				select @tjf_rm_limit = convert(int, @cond_value) 
				select @tjf_rm = isnull((select sum(a.quantity) from rsvsrc a
						where a.roomno='' and a.begin_<=@s_time and a.end_>@s_time and charindex(a.ratecode,@tjf_rc)>0),0)
				select @tjf_rm = @tjf_rm + isnull((select count(distinct a.roomno) from rsvsrc a
						where a.roomno<>'' and a.begin_<=@s_time and a.end_>@s_time and charindex(a.ratecode,@tjf_rc)>0),0)
				if @tjf_rm >= @tjf_rm_limit 
					delete rate_query_filter where pc_id=@pc_id 
							and (@gtypes='' or (class='rmtype' and charindex(grp,@gtypes)>0) )
							and (@rmtypes='' or (class='rmtype' and charindex(code,@rmtypes)>0) )
							and (@ratecats='' or (class='ratecode' and charindex(grp,@ratecats)>0) )
							and (@ratecodes='' or (class='ratecode' and charindex(code,@ratecodes)>0) )
				
//				select @@rowcount, @tjf_rm, @tjf_rm_limit 
				//delete gdsmsg 
				//insert gdsmsg select convert(char(10),@@rowcount)+ convert(char(10),@tjf_rm) + convert(char(10), @tjf_rm_limit )
			end 
		end 
	end 

	select @id = isnull((select min(id) from rmrate_strategy where halt='F' and wdate1 is not null and wdate2 is not null and @today>=wdate1 and @today<=wdate2 and id>@id), '') 
end

-- ------------------------------------------------------------------------------------
--  配额房量控制
--  if gzhx_rsv_plan.leaf = 2 
--	 by zk 2008-8-22
-- ------------------------------------------------------------------------------------


if rtrim(@cusno) <> null
	select @no = @cusno
else if rtrim(@agent) <> null
	select @no = @agent
else if rtrim(@source) <> null
	select @no = @source

if datediff(dd,@s_time,@e_time) > 0
	select @s_time = @s_time , @e_time = dateadd(dd,-1,@e_time)
else
	select @s_time = @s_time , @e_time = @e_time

exec p_zk_room_plan_check @pc_id,@s_time,@e_time,@no,'D',@rmnum,@class,@rmnum_before;

//select @action = exp_s1 from guest where no = @no
//if @action < '2'
//	return
//
//if datediff(dd,@s_time,@e_time) > 0
//	select @begin = @s_time , @end = dateadd(dd,-1,@e_time)
//else
//	select @begin = @s_time , @end = @e_time
//
//insert #room_plan select a.date,a.flag,a.no,b.name,a.class,a.ratecodes,a.rmtypes,a.quan,a.lmt,0,0
//			from gzhs_rsv_plan a,guest b where a.no = b.no and a.date >= @begin and a.date <= @end and (a.no = @no or @no = '%')
//
//update #room_plan set a.used = (select isnull(sum(a.quantity),0) from rsvsrc_detail a,master b where a.accnt = b.accnt and a.date_ = #room_plan.date 
//									and (b.cusno = #room_plan.no or b.agent = #room_plan.no or b.source = #room_plan.no)
//									and (charindex(rtrim(a.ratecode) + ',',rtrim(#room_plan.ratecodes) + ',') > 0 or rtrim(#room_plan.ratecodes) = null)
//									and (charindex(rtrim(a.type) + ',',rtrim(#room_plan.rmtypes) + ',') > 0 or rtrim(#room_plan.rmtypes) = null))
//
//update #room_plan set leftn = quan - used
//update #room_plan set flag = '' where flag = 'F'
//update #room_plan set leftn = - used where flag = 'T' or (dateadd(dd, - lmt,date) < getdate() and lmt > 0)
//if exists (select 1 from #room_plan where leftn < 0)
//	delete rate_query_filter from #room_plan b where pc_id=@pc_id 
//							and (rate_query_filter.class = 'ratecode' and charindex(rtrim(code),b.ratecodes) > 0)
							


;


//select * from rmrate_strategy; 
//
//select * from rmratecode; 
//exec p_gds_reserve_strategy_rq 'pcid', '2008.8.15', '2008.8.18', 2, 2, '', '', '', '', ''; 
//	@pc_id			char(4),
//	@s_time			datetime,
//	@e_time			datetime,
//	@gstno			int,
//	@rmnum			int,
//	@ratecode		char(10),
//	@haccnt			char(7),
//	@cusno			char(7),
//	@agent			char(7),
//	@source			char(7)
