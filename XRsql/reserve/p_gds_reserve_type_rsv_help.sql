
if  exists(select * from sysobjects where name = "p_gds_reserve_type_rsv_help" and type = "P")
	drop proc p_gds_reserve_type_rsv_help;
create proc p_gds_reserve_type_rsv_help
	@s_time			datetime,       	-- 开始时间
	@e_time			datetime       	-- 结束时间
as

create table #inventory
(
	date		datetime,
	type		char(5),
	quan		int
)

-- ------------------------------------------------------------------------------------
--  房类预留辅助 --- 显示可用数
-- ------------------------------------------------------------------------------------

while	@s_time < @e_time
begin
	insert #inventory 	
		select 	@s_time, 
					a.type, 
					a.quantity - (select isnull(sum(b.blockcnt),0) 
						from rsvtype b 
								where b.begin_ <= @s_time 
									and b.end_ > @s_time
									and a.type = b.type
					)
			from typim a where tag='K' 

	-- 维修房记录提取修改为 from rm_ooo 
--	update #inventory
--		set #inventory.quan = #inventory.quan - (select isnull(count(1),0)
--						from rmsta b
--							where  b.locked='L' 
--									and b.futbegin <= @s_time 
--									and (b.futend > @s_time or b.futend is null)
--									and #inventory.type=b.type
--					)
--				where #inventory.date = @s_time

	update #inventory
		set #inventory.quan = #inventory.quan - (select isnull(count(1),0)
						from rm_ooo a, rmsta b
							where  a.status='I' and a.sta='O' 
									and a.dbegin <= @s_time and a.dend > @s_time
									and a.roomno=b.roomno and #inventory.type=b.type
					)
				where #inventory.date = @s_time

	select @s_time = dateadd(day, 1, @s_time)
end

create table #goutput
(
	type			char(5)	not null,
	descript 	char(20)	default '' not null,
	quanall		int default 0 not null,  -- 房类总房数
	quan			int default 0 not null,  -- 可用数
	quantity		int default 0 not null,  -- 预留
	rate			money default 0 not null,  -- 房价
	guest			int default 1 not null,    -- 每间房间人数
	remark 		char(50)	default '' not null   -- 备注说明
)

insert #goutput (type) select distinct type from #inventory
update #goutput set quan = isnull((select min(a.quan) from #inventory a where a.type=#goutput.type),0)
update #goutput set quanall=a.quantity, descript=a.descript, rate=a.rate from typim a where a.type=#goutput.type

select type,descript,quanall,quan,quantity,rate,guest,remark from #goutput order by type
return 0
;