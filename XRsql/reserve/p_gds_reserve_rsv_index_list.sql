if exists(select 1 from sysobjects where name = "p_gds_reserve_rsv_index_list")
	drop proc p_gds_reserve_rsv_index_list;
create proc p_gds_reserve_rsv_index_list
	@date			datetime,
	@types		varchar(255),
	@index		varchar(30)   -- 统计指标
as
-----------------------------------------------
--		系统客房资源数据统计指标 -- 列表
--
--		该过程需要与 p_gds_reserve_rsv_index 保持一致 
-----------------------------------------------
declare	@bdate	datetime,
			@type		char(5),
			@duin			char(1)


select @duin=value from sysoption where catalog='reserve' and item='day_use_in'

select @bdate = bdate1 from sysdata

-- 拼字符串
if @types='%' 
begin
	select @types='_'
	select @type=isnull((select min(type) from typim where type>'' and tag='K'), '')
	while @type <> ''
	begin
		select @types = @types+substring(@type+space(5), 1, 5)+'_'
		select @type=isnull((select min(type) from typim where type>@type and tag='K'), '')
	end
end

--
create table #goutput (
	accnt			char(10)						not null,
	id				int			default 0	not null,
	class			char(1)		default ''	not null,
	sta			char(1)		default ''	not null,
	name			varchar(50)	default ''	not null,
	vip			char(30)		default ''	not null,
	market		char(3)		default ''	not null,
	src			char(3)		default ''	not null,
	arr			datetime						not null,
	dep			datetime						not null,
	type			char(5)		default ''	not null,
	roomno		char(5)		default ''	not null,
	rmnum			int			default 0	not null,
	gstno			int			default 0	not null,
	rate			money			default 0	not null,
	groupno		varchar(50)	default ''	not null,
	cusno			varchar(50)	default ''	not null,
	agent			varchar(50)	default ''	not null,
	source		varchar(50)	default ''	not null,
	remark		varchar(50)	default ''	not null
)

-- -----------------------------------------------------------------
-- -- 确认预订客房 ( Include Checked/In, Not include day-use)
-- -----------------------------------------------------------------
-- else if @index = 'Definite Reservations'
-- begin
-- 	select @result = isnull((select sum(a.quantity) from rsvsaccnt a, master b
-- 		where charindex(a.type,@types)>0 and a.begin_<>a.end_ and a.begin_<=@date and a.end_>@date
-- 			and a.accnt=b.accnt and b.restype in (select code from restype where definite='T')),0)
-- end
-- 
-- -------------------------------------------
-- --	非确认预订 ( Not include day-use)
-- -------------------------------------------
-- else if @index = 'Tentative Reservation'
-- begin
-- 	select @result = isnull((select sum(a.quantity) from rsvsaccnt a, master b
-- 		where charindex(a.type,@types)>0 and a.begin_<>a.end_ and a.begin_<=@date and a.end_>@date
-- 			and a.accnt=b.accnt and b.restype not in (select code from restype where definite='T')),0)
-- end

-------------------------------------------
--	本日抵离 dayuse 
-------------------------------------------
if @index = 'Day Use'
begin
	-- 宾客、团体分开插入，主要区别是 ‘备注’
	insert #goutput(accnt,id,class,sta,name,vip,type,roomno,rmnum,market,src,arr,dep,
					gstno,rate,groupno,cusno,agent,source,remark)
		select d.accnt,d.id,a.class,a.sta,b.haccnt,c.vip,d.type,d.roomno,d.quantity,a.market,a.src,d.arr,d.dep,
				d.gstno,d.rate,b.groupno,b.cusno,b.agent,b.source,substring(a.ref,1,50)
			from master a, master_des b, guest c, rsvsrc d
			where a.accnt=b.accnt and a.haccnt=c.no and a.accnt=d.accnt and charindex(d.type, @types)>0 and a.class='F' 
				and d.begin_=d.end_ and d.begin_=@date
	insert #goutput(accnt,id,class,sta,name,vip,type,roomno,rmnum,market,src,arr,dep,
					gstno,rate,groupno,cusno,agent,source,remark)
		select d.accnt,d.id,a.class,a.sta,b.haccnt,c.vip,d.type,d.roomno,d.quantity,a.market,a.src,d.arr,d.dep,
				d.gstno,d.rate,b.groupno,b.cusno,b.agent,b.source,a.ref
			from master a, master_des b, guest c, rsvsrc d
			where a.accnt=b.accnt and a.haccnt=c.no and a.accnt=d.accnt and charindex(d.type, @types)>0 and a.class<>'F' 
				and d.begin_=d.end_ and d.begin_=@date
end

-- -------------------------------------------
-- --	总预订房 = 确认预订客房 + 非确认预订
-- -------------------------------------------
-- else if @index = 'Total Reserved'
-- begin
-- 	exec p_gds_reserve_rsv_index_list @date, @types, 'Definite Reservations', 'R', @mm1 output
-- 	exec p_gds_reserve_rsv_index_list @date, @types, 'Tentative Reservation', 'R', @mm2 output
-- 	select @result = @mm1 + @mm2
-- end
-- 

-------------------------------------------
--	当前客房
-------------------------------------------
else if @index = 'Current In House'
begin
	insert #goutput(accnt,id,class,sta,name,vip,type,roomno,rmnum,market,src,arr,dep,
					gstno,rate,groupno,cusno,agent,source,remark)
		select a.accnt,0,a.class,a.sta,b.haccnt,c.vip,a.type,a.roomno,a.rmnum,a.market,a.src,a.arr,a.dep,
				a.gstno,a.setrate,b.groupno,b.cusno,b.agent,b.source,substring(a.ref,1,50)
			from master a, master_des b, guest c
			where a.accnt=b.accnt and a.haccnt=c.no and a.sta='I' and a.class='F'
				and charindex(a.type, @types)>0
end

-------------------------------------------
--	当前 Walk-Ins
-------------------------------------------
else if @index = 'Walk-Ins'
begin
	insert #goutput(accnt,id,class,sta,name,vip,type,roomno,rmnum,market,src,arr,dep,
					gstno,rate,groupno,cusno,agent,source,remark)
		select a.accnt,0,a.class,a.sta,b.haccnt,c.vip,a.type,a.roomno,a.rmnum,a.market,a.src,a.arr,a.dep,
				a.gstno,a.setrate,b.groupno,b.cusno,b.agent,b.source,substring(a.ref,1,50)
			from master a, master_des b, guest c
			where a.accnt=b.accnt and a.haccnt=c.no and a.sta='I' and a.class='F' and datediff(dd,a.bdate,@bdate)=0 and substring(a.extra,9,1)='1'
				and charindex(a.type, @types)>0
end

-------------------------------------------
--	过夜客房
-------------------------------------------
else if @index = 'Occupied Tonight'
begin
	-- 宾客、团体分开插入，主要区别是 ‘备注’
	insert #goutput(accnt,id,class,sta,name,vip,type,roomno,rmnum,market,src,arr,dep,
					gstno,rate,groupno,cusno,agent,source,remark)
		select d.accnt,d.id,a.class,a.sta,b.haccnt,c.vip,d.type,d.roomno,d.quantity,a.market,a.src,d.arr,d.dep,
				d.gstno,d.rate,b.groupno,b.cusno,b.agent,b.source,substring(a.ref,1,50)
			from master a, master_des b, guest c, rsvsrc d
			where a.accnt=b.accnt and a.haccnt=c.no and a.accnt=d.accnt and a.class='F'
				and charindex(d.type, @types)>0 and d.begin_<=@date and d.end_>@date
	insert #goutput(accnt,id,class,sta,name,vip,type,roomno,rmnum,market,src,arr,dep,
					gstno,rate,groupno,cusno,agent,source,remark)
		select d.accnt,d.id,a.class,a.sta,b.haccnt,c.vip,d.type,d.roomno,d.quantity,a.market,a.src,d.arr,d.dep,
				d.gstno,d.rate,b.groupno,b.cusno,b.agent,b.source,a.ref
			from master a, master_des b, guest c, rsvsrc d
			where a.accnt=b.accnt and a.haccnt=c.no and a.accnt=d.accnt and a.class<>'F'
				and charindex(d.type, @types)>0 and d.begin_<=@date and d.end_>@date
	insert #goutput(accnt,id,class,sta,name,vip,type,roomno,rmnum,market,src,arr,dep,
					gstno,rate,groupno,cusno,agent,source,remark)
		select d.accnt,d.id,a.class,a.sta,a.name,'',d.type,d.roomno,d.quantity,a.market,a.src,d.arr,d.dep,
				d.gstno,d.rate,'',a.cusno,a.agent,a.source,a.ref
			from sc_master a, rsvsrc d
			where a.accnt=d.accnt and a.class<>'F'
				and charindex(d.type, @types)>0 and d.begin_=@date and d.end_>@date
end

---------------------------------------------------------------
--	Same Day Reservations 当日预订当日到达客房
---------------------------------------------------------------
else if @index = 'Same Day Reservations'
begin
	declare	@resno char(6)
	select @resno = substring(convert(char(8),@date,112),3,6)

	insert #goutput(accnt,id,class,sta,name,vip,type,roomno,rmnum,market,src,arr,dep,
					gstno,rate,groupno,cusno,agent,source,remark)
	select a.accnt,a.id,b.class,b.sta,c.name,c.vip,a.type,a.roomno,a.quantity,b.market,b.src,a.arr,a.dep,
					a.gstno,a.rate,b.groupno,b.cusno,b.agent,b.source,b.ref
		from rsvsrc a, master b, guest c
		where a.accnt=b.accnt and a.begin_=@date and (a.begin_<>end_ or @duin='T') and charindex(a.type,@types)>0 
			and b.resno like @resno+'%' and b.haccnt=c.no
end


-------------------------------------------------------------------------
--	当日到达客房	+散客/团体/会议  (未到)
-------------------------------------------------------------------------
else if @index = 'Arrival Rooms' 
begin
	-- 宾客、团体分开插入，主要区别是 ‘备注’
	insert #goutput(accnt,id,class,sta,name,vip,type,roomno,rmnum,market,src,arr,dep,
					gstno,rate,groupno,cusno,agent,source,remark)
		select d.accnt,d.id,a.class,a.sta,b.haccnt,c.vip,d.type,d.roomno,d.quantity,a.market,a.src,d.arr,d.dep,
				d.gstno,d.rate,b.groupno,b.cusno,b.agent,b.source,substring(a.ref,1,50)
			from master a, master_des b, guest c, rsvsrc d
			where a.accnt=b.accnt and a.haccnt=c.no and a.accnt=d.accnt and a.class='F' and a.sta='R'
				and charindex(d.type, @types)>0 and d.begin_=@date and (d.end_>@date or (@duin='T' and d.end_>=@date))
	insert #goutput(accnt,id,class,sta,name,vip,type,roomno,rmnum,market,src,arr,dep,
					gstno,rate,groupno,cusno,agent,source,remark)
		select d.accnt,d.id,a.class,a.sta,b.haccnt,c.vip,d.type,d.roomno,d.quantity,a.market,a.src,d.arr,d.dep,
				d.gstno,d.rate,b.groupno,b.cusno,b.agent,b.source,a.ref
			from master a, master_des b, guest c, rsvsrc d
			where a.accnt=b.accnt and a.haccnt=c.no and a.accnt=d.accnt and a.class<>'F'
				and charindex(d.type, @types)>0 and d.begin_=@date and (d.end_>@date or (@duin='T' and d.end_>=@date))
	insert #goutput(accnt,id,class,sta,name,vip,type,roomno,rmnum,market,src,arr,dep,
					gstno,rate,groupno,cusno,agent,source,remark)
		select d.accnt,d.id,a.class,a.sta,a.name,'',d.type,d.roomno,d.quantity,a.market,a.src,d.arr,d.dep,
				d.gstno,d.rate,'',a.cusno,a.agent,a.source,a.ref
			from sc_master a, rsvsrc d
			where a.accnt=d.accnt and a.class<>'F'
				and charindex(d.type, @types)>0 and d.begin_=@date and (d.end_>@date or (@duin='T' and d.end_>=@date))
end


-------------------------------------------------------------------------
--	实际到达客房/客人  -- 主要检验营业日期
-------------------------------------------------------------------------
else if @index = 'Arrival Rooms Actual'
begin
	insert #goutput(accnt,id,class,sta,name,vip,type,roomno,rmnum,market,src,arr,dep,
					gstno,rate,groupno,cusno,agent,source,remark)
	select a.accnt,0,a.class,a.sta,b.haccnt,c.vip,a.type,a.roomno,a.rmnum,a.market,a.src,a.arr,a.dep,
				a.gstno,a.setrate,b.groupno,b.cusno,b.agent,b.source,substring(a.ref,1,50)
		from master a, master_des b, guest c
			where a.accnt=b.accnt and a.haccnt=c.no and a.sta='I' and a.class='F' and a.bdate=@bdate and charindex(a.type,@types)>0
end

-------------------------------------------
--	当日离店客房 (预计)
-------------------------------------------
else if @index = 'Departure Rooms'
begin
	-- 宾客、团体分开插入，主要区别是 ‘备注’
	insert #goutput(accnt,id,class,sta,name,vip,type,roomno,rmnum,market,src,arr,dep,
					gstno,rate,groupno,cusno,agent,source,remark)
		select d.accnt,d.id,a.class,a.sta,b.haccnt,c.vip,d.type,d.roomno,d.quantity,a.market,a.src,d.arr,d.dep,
				d.gstno,d.rate,b.groupno,b.cusno,b.agent,b.source,substring(a.ref,1,50)
			from master a, master_des b, guest c, rsvsrc d
			where a.accnt=b.accnt and a.haccnt=c.no and a.accnt=d.accnt and a.class='F'
				and charindex(d.type, @types)>0 and (d.begin_<@date or (@duin='T' and d.begin_<=@date)) and d.end_=@date	-- 这里只统计离店日期相同的。前期没有续住的不考虑  
	insert #goutput(accnt,id,class,sta,name,vip,type,roomno,rmnum,market,src,arr,dep,
					gstno,rate,groupno,cusno,agent,source,remark)
		select d.accnt,d.id,a.class,a.sta,b.haccnt,c.vip,d.type,d.roomno,d.quantity,a.market,a.src,d.arr,d.dep,
				d.gstno,d.rate,b.groupno,b.cusno,b.agent,b.source,a.ref
			from master a, master_des b, guest c, rsvsrc d
			where a.accnt=b.accnt and a.haccnt=c.no and a.accnt=d.accnt and a.class<>'F'
				and charindex(d.type, @types)>0 and (d.begin_<@date or (@duin='T' and d.begin_<=@date)) and d.end_=@date
end

-------------------------------------------
--	当日实际离店客房 / 客人
-------------------------------------------
else if @index = 'Departure Rooms Actual'
begin
	insert #goutput(accnt,id,class,sta,name,vip,type,roomno,rmnum,market,src,arr,dep,
					gstno,rate,groupno,cusno,agent,source,remark)
	select a.accnt,0,a.class,a.sta,b.haccnt,c.vip,a.type,a.roomno,a.rmnum,a.market,a.src,a.arr,a.dep,
				a.gstno,a.setrate,b.groupno,b.cusno,b.agent,b.source,substring(a.ref,1,50)
		from master a, master_des b, guest c
			where a.accnt=b.accnt and a.haccnt=c.no and a.sta='O' and a.class='F' and a.ressta='I'  and charindex(a.type,@types)>0
end

-------------------------------------------
--	Extended Stays / 延房 -- 在住客人、本日延房；需要参考 master_till
-------------------------------------------
else if @index = 'Extended Stays Rooms'
begin
	insert #goutput(accnt,id,class,sta,name,vip,type,roomno,rmnum,market,src,arr,dep,
					gstno,rate,groupno,cusno,agent,source,remark)
	select a.accnt,0,a.class,a.sta,b.haccnt,c.vip,a.type,a.roomno,a.rmnum,a.market,a.src,a.arr,a.dep,
				a.gstno,a.setrate,b.groupno,b.cusno,b.agent,b.source,substring(a.ref,1,50)
		from master a, master_des b, guest c
			where a.accnt=b.accnt and a.haccnt=c.no and a.sta='I' and a.class='F' and datediff(dd,@bdate,a.dep)>0  and charindex(a.type,@types)>0
		and exists(select 1 from master_till b where a.accnt=b.accnt and b.sta='I' and datediff(dd,dep,@bdate)=0)
end

-------------------------------------------
--	Early Departures / 提前走
-------------------------------------------
else if @index = 'Early Departures Rooms'
begin
	-- 提前走 ed  -- 本日结账、本来离日<>今天；需要参考 master_till
	insert #goutput(accnt,id,class,sta,name,vip,type,roomno,rmnum,market,src,arr,dep,
					gstno,rate,groupno,cusno,agent,source,remark)
	select a.accnt,0,a.class,a.sta,b.haccnt,c.vip,a.type,a.roomno,a.rmnum,a.market,a.src,a.arr,a.dep,
				a.gstno,a.setrate,b.groupno,b.cusno,b.agent,b.source,substring(a.ref,1,50)
		from master a, master_des b, guest c
			where a.accnt=b.accnt and a.haccnt=c.no and a.sta='O' and a.class='F'  and charindex(a.type,@types)>0
				and exists(select 1 from master_till b where a.accnt=b.accnt and b.sta='I' and datediff(dd,dep,@bdate)<0)
end

-------------------------------------------
--	免费房
-------------------------------------------
else if @index = 'COM'
begin
	insert #goutput(accnt,id,class,sta,name,vip,type,roomno,rmnum,market,src,arr,dep,
					gstno,rate,groupno,cusno,agent,source,remark)
	select a.accnt,0,a.class,a.sta,b.haccnt,c.vip,a.type,a.roomno,a.rmnum,a.market,a.src,a.arr,a.dep,
				a.gstno,a.setrate,b.groupno,b.cusno,b.agent,b.source,substring(a.ref,1,50)
		from master a, master_des b, guest c, mktcode d
			where a.accnt=b.accnt and a.haccnt=c.no and a.sta='I' and a.class='F' and a.market=d.code and d.flag='COM' 
				and charindex(a.type,@types)>0 

end

-------------------------------------------
--	自用房
-------------------------------------------
else if @index = 'HSE'
begin
	insert #goutput(accnt,id,class,sta,name,vip,type,roomno,rmnum,market,src,arr,dep,
					gstno,rate,groupno,cusno,agent,source,remark)
	select a.accnt,0,a.class,a.sta,b.haccnt,c.vip,a.type,a.roomno,a.rmnum,a.market,a.src,a.arr,a.dep,
				a.gstno,a.setrate,b.groupno,b.cusno,b.agent,b.source,substring(a.ref,1,50)
		from master a, master_des b, guest c, mktcode d
			where a.accnt=b.accnt and a.haccnt=c.no and a.sta='I' and a.class='F' and a.market=d.code and d.flag='HSE' 
				and charindex(a.type,@types)>0 
end

-------------------------------------------
--	Pre-assigned Rooms
-------------------------------------------
else if @index = 'Pre-assigned Rooms'
begin
	insert #goutput(accnt,id,class,sta,name,vip,type,roomno,rmnum,market,src,arr,dep,
					gstno,rate,groupno,cusno,agent,source,remark)
	select a.accnt,0,a.class,a.sta,b.haccnt,c.vip,a.type,a.roomno,a.rmnum,a.market,a.src,a.arr,a.dep,
				a.gstno,a.setrate,b.groupno,b.cusno,b.agent,b.source,substring(a.ref,1,50)
		from master a, master_des b, guest c, rsvsrc d
			where a.accnt=b.accnt and a.haccnt=c.no and a.class='F' and a.roomno>='0' and a.sta='R'
				and a.accnt=d.accnt and charindex(d.type, @types)>0 and d.begin_<=@date and d.end_>@date
end

-- 整理
update #goutput set vip=a.descript from basecode a where #goutput.vip=a.code and a.cat='vip'
update #goutput set sta='R' where class<>'F'

-- Output
select accnt,sta,name,vip,type,roomno,rmnum,market,src,arr,dep,
					gstno,rate,groupno+'/'+cusno,agent+'/'+source,remark from #goutput order by arr

return 0
;