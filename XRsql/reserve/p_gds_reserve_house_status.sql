----------------------------------------------------------------------
--	table : house_status  & Insert data 
--	proc  : p_gds_reserve_house_status
--	trig	: t_gds_house_status_update
----------------------------------------------------------------------

-------------------------------------------------------------------------------
--	House Status Table
-------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "house_status" and type = 'U')
	drop table house_status;
create table house_status
(
	id						int						null,
	item					varchar(10)				null,
	descript				varchar(30)				null,
	descript1			varchar(30)				null,
	value1				money						null,
	value2				money						null,
	value3				money						null,
	more					int						null,	-- 是否可以穿透查询
	sequence				int						null
);
exec sp_primarykey house_status,item
create unique index index1 on house_status(id,item)
create index index2 on house_status(id, sequence)
;

-- Room Summary
insert house_status (id,item,descript,descript1,more,sequence)
	select 1, 'ttl', '总房数','Total Rooms', 0, 10;
insert house_status (id,item,descript,descript1,more,sequence)
	select 1, 'oo', '维修房','Out of Order', 1, 20;
insert house_status (id,item,descript,descript1,more,sequence)
	select 1, 'rent', '可卖房','Rooms to Rent', 0, 30;
insert house_status (id,item,descript,descript1,more,sequence)
	select 1, 'os', '锁定房','Out of Service', 1, 40;   -- 锁定房仍然计算到可卖房 
insert house_status (id,item,descript,descript1,more,sequence)
	select 1, 'com', '免费房','Complimentary', 1, 50;
insert house_status (id,item,descript,descript1,more,sequence)
	select 1, 'hse', '自用房','House Use', 1, 25;

-- Movement
insert house_status (id,item,descript,descript1,more,sequence)
	select 2, 'de', '预计离店','Departures Expected', 1, 180;
insert house_status (id,item,descript,descript1,more,sequence)
	select 2, 'da', '实际离店','Departures Actual', 1, 170;
insert house_status (id,item,descript,descript1,more,sequence)
	select 2, 'ae', '预计到达','Arrivals Expected', 1, 130;
insert house_status (id,item,descript,descript1,more,sequence)
	select 2, 'pr', '预留房','Pre-assigned Rooms', 1, 140;
insert house_status (id,item,descript,descript1,more,sequence)
	select 2, 'aa', '实际到达','Arrivals Actual', 1, 120;
insert house_status (id,item,descript,descript1,more,sequence)
	select 2, 'es', '续住','Extended Stays', 1, 190;
insert house_status (id,item,descript,descript1,more,sequence)
	select 2, 'ed', '提前离店','Early Departures', 1, 200;
insert house_status (id,item,descript,descript1,more,sequence)
	select 2, 'dr', '日租房','Day Rooms', 1, 210;
insert house_status (id,item,descript,descript1,more,sequence)
	select 2, 'sdr', '当天预订','Same Day Reservations', 1, 150;
insert house_status (id,item,descript,descript1,more,sequence)
	select 2, 'wi', '自来房','Walk Ins', 1, 160;
insert house_status (id,item,descript,descript1,more,sequence)
	select 2, 'cos', '当前占用','Current Occupancy Status', 1, 110;

-- HouseKeeping
insert house_status (id,item,descript,descript1,more,sequence)
	select 3, 'ins', '检查房','Inspected Rooms', 1, 520;
insert house_status (id,item,descript,descript1,more,sequence)
	select 3, 'cl', '干净房','Clean Rooms', 1, 510;
insert house_status (id,item,descript,descript1,more,sequence)
	select 3, 'dir', '脏房','Dirty rooms', 1, 530;
insert house_status (id,item,descript,descript1,more,sequence)
	select 3, 'oor', '维修房','Out of Order', 1, 500;
insert house_status (id,item,descript,descript1,more,sequence)
	select 3, 'osr', '锁定房','Out of Service', 1, 540;
insert house_status (id,item,descript,descript1,more,sequence)
	select 3, 'qroom', 'Q-Room','Q-Room', 1, 550;

-- End of Day Projection
insert house_status (id,item,descript,descript1,more,sequence)
	select 4, 'avlt', '本夜可用','Available Tonight', 0, 850;
insert house_status (id,item,descript,descript1,more,sequence)
	select 4, 'occt', '本夜占用','Occupied Tonight', 1, 800;
insert house_status (id,item,descript,descript1,more,sequence)
	select 4, 'occt_h', '本夜占用(不含自用房)','Occupied Tonight(without HSE)', 0, 805;
insert house_status (id,item,descript,descript1,more,sequence)
	select 4, 'rate', '平均房价','Average Room Rate', 0, 840;
--insert house_status (id,item,descript,descript1,more,sequence)
--	select 4, 'allo', 'Allotments','Allotments', 1, 830;
insert house_status (id,item,descript,descript1,more,sequence)
	select 4, 'ind', '散客','Individuals', 0, 810;
insert house_status (id,item,descript,descript1,more,sequence)
	select 4, 'grp', '团体/会议','Groups', 0, 820;
insert house_status (id,item,descript,descript1,more,sequence)
	select 4, 'rev', '收入','Revenue', 0, 830;
insert house_status (id,item,descript,descript1,more,sequence)
	select 4, 'hse', '自用房','House Use', 1, 801;


if exists(select 1 from sysobjects where name = "p_gds_reserve_house_status")
	drop proc p_gds_reserve_house_status;
create proc p_gds_reserve_house_status
	@id			int,
	@types		varchar(255) = '%',
	@langid		int = 0
as

----------------------------------------------------------------------------------------------
--		House Status 
----------------------------------------------------------------------------------------------
declare	@value		money,
			@bdate		datetime,
			@tmp1			money,
			@tmp2			money,
			@type			char(5)

select @bdate = bdate1 from sysdata
if @types is null 
	select @types = '%'

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

------------------------
-- id = 1	客房总计
------------------------
if @id = 1
begin
	exec p_gds_reserve_rsv_index @bdate, @types, 'Total Rooms', 'R', @value output
	update house_status set value1 = @value where item='ttl'
	
	exec p_gds_reserve_rsv_index @bdate, @types, 'Out of Order', 'R', @value output
	update house_status set value1 = @value where item='oo'
	
	exec p_gds_reserve_rsv_index @bdate, @types, 'Room to Rent', 'R', @value output
	update house_status set value1 = @value where item='rent'
	
	exec p_gds_reserve_rsv_index @bdate, @types, 'Out of Service', 'R', @value output
	update house_status set value1 = @value where item='os'
	
	exec p_gds_reserve_rsv_index @bdate, @types, 'Q-room', 'R', @value output
	update house_status set value1 = @value where item='qroom'
	
	exec p_gds_reserve_rsv_index @bdate, @types, 'COM_IN', 'R', @value output
	update house_status set value1 = @value where item='com'
	
	exec p_gds_reserve_rsv_index @bdate, @types, 'HSE', 'R', @value output
	update house_status set value1 = @value where item='hse'
end

------------------------
-- id = 2	业务流转
------------------------
if @id = 2
begin
	update house_status set value1=0, value2=0 where id=2
	-- 预计离店  de
	exec p_gds_reserve_rsv_index @bdate, @types, 'Departure Rooms', 'R', @value output
	update house_status set value1=@value where item='de'
	exec p_gds_reserve_rsv_index @bdate, @types, 'Departure Persons', 'R', @value output
	update house_status set value2=@value where item='de'

	-- 实际离店  da
	exec p_gds_reserve_rsv_index @bdate, @types, 'Departure Rooms Actual', 'R', @value output
	update house_status set value1=@value where item='da'
	exec p_gds_reserve_rsv_index @bdate, @types, 'Departure Persons Actual', 'R', @value output
	update house_status set value2=@value where item='da'

	-- 预计到达  ae
	exec p_gds_reserve_rsv_index @bdate, @types, 'Arrival Rooms', 'R', @value output
	update house_status set value1=@value where item='ae'
	exec p_gds_reserve_rsv_index @bdate, @types, 'Arrival Persons', 'R', @value output
	update house_status set value2=@value where item='ae'

	-- Pre-assigned Rooms  pr
	update house_status set value1=isnull((select count(distinct roomno) from master where class='F' and sta='R' and datediff(dd,arr,@bdate)=0 and roomno>'0' and charindex(type,@types)>0),0) where item='pr'
	update house_status set value2=isnull((select sum(gstno) from master where class='F' and sta='R' and datediff(dd,arr,@bdate)=0 and roomno>'0' and charindex(type,@types)>0),0) where item='pr'

	-- 实际到达 aa  -- 主要检验营业日期
	exec p_gds_reserve_rsv_index @bdate, @types, 'Arrival Rooms Actual', 'R', @value output
	update house_status set value1=@value where item='aa'
	exec p_gds_reserve_rsv_index @bdate, @types, 'Arrival Persons Actual', 'R', @value output
	update house_status set value2=@value where item='aa'

	-- 延房 es  -- 在住客人、本日延房；需要参考 master_till 
	exec p_gds_reserve_rsv_index @bdate, @types, 'Extended Stays Rooms', 'R', @value output
	update house_status set value1=@value where item='es'
	exec p_gds_reserve_rsv_index @bdate, @types, 'Extended Stays Persons', 'R', @value output
	update house_status set value2=@value where item='es'

	-- 提前走 ed  -- 本日结账、本来离日<>今天；需要参考 master_till
	exec p_gds_reserve_rsv_index @bdate, @types, 'Early Departures Rooms', 'R', @value output
	update house_status set value1=@value where item='ed'
	exec p_gds_reserve_rsv_index @bdate, @types, 'Early Departures Persons', 'R', @value output
	update house_status set value2=@value where item='ed'

	-- Day Rooms  dr
	exec p_gds_reserve_rsv_index @bdate, @types, 'Day Use', 'R', @value output
	update house_status set value1=@value where item='dr'
	exec p_gds_reserve_rsv_index @bdate, @types, 'Day Use Persons', 'R', @value output
	update house_status set value2=@value where item='dr'

	-- Same Day Reservations  sdr
	exec p_gds_reserve_rsv_index @bdate, @types, 'Same Day Reservations', 'R', @value output
	update house_status set value1=@value where item='sdr'
	exec p_gds_reserve_rsv_index @bdate, @types, 'Same Day Reservations Persons', 'R', @value output
	update house_status set value2=@value where item='sdr'

	-- Walk-Ins  wi
	update house_status set value1=isnull((select count(distinct roomno) from master where sta='I' and class='F' and datediff(dd,bdate,@bdate)=0 and substring(extra,9,1)='1' and charindex(type,@types)>0),0) where item='wi'
	update house_status set value2=isnull((select sum(gstno) from master where sta='I' and class='F' and datediff(dd,bdate,@bdate)=0 and substring(extra,9,1)='1' and charindex(type,@types)>0),0) where item='wi'

	-- 当前占用 cos
	select @tmp1 = (select count(distinct roomno) from master where sta='I' and class='F' and charindex(type,@types)>0)
	exec p_gds_reserve_rsv_index @bdate, @types, 'Room to Rent', 'R', @tmp2 output
	update house_status set value1=@tmp1 where item='cos'
	update house_status set value2=isnull((select sum(gstno) from master where sta='I' and class='F' and charindex(type,@types)>0),0) where item='cos'
	if @tmp2<>0
		update house_status set value3=round(@tmp1/@tmp2,3) where item='cos'
	else
		update house_status set value3=0 where item='cos'
end

------------------------
-- id = 3	客房中心
------------------------
if @id=3
begin
	update house_status set value1=(select count(1) from rmsta where ocsta='O' and sta='I' and charindex(type,@types)>0) where item='ins'
	update house_status set value2=(select count(1) from rmsta where ocsta='V' and sta='I' and charindex(type,@types)>0) where item='ins'
	
	update house_status set value1=(select count(1) from rmsta where ocsta='O' and sta='R' and charindex(type,@types)>0) where item='cl'
	update house_status set value2=(select count(1) from rmsta where ocsta='V' and sta='R' and charindex(type,@types)>0) where item='cl'
	
	update house_status set value1=(select count(1) from rmsta where ocsta='O' and sta='D' and charindex(type,@types)>0) where item='dir'
	update house_status set value2=(select count(1) from rmsta where ocsta='V' and sta='D' and charindex(type,@types)>0) where item='dir'
	
	update house_status set value1=(select count(1) from rmsta where ocsta='O' and sta='O' and charindex(type,@types)>0) where item='oor'
	update house_status set value2=(select count(1) from rmsta where ocsta='V' and sta='O' and charindex(type,@types)>0) where item='oor'
	
	update house_status set value1=(select count(1) from rmsta where ocsta='O' and sta='S' and charindex(type,@types)>0) where item='osr'
	update house_status set value2=(select count(1) from rmsta where ocsta='V' and sta='S' and charindex(type,@types)>0) where item='osr'
end

------------------------
-- id = 4	预计本夜
------------------------
if @id=4
begin
	exec p_gds_reserve_rsv_index @bdate, @types, 'Available Rooms', 'R', @value output
	update house_status set value1 = @value where item='avlt'
	
	exec p_gds_reserve_rsv_index @bdate, @types, 'Occupied Tonight', 'R', @value output
	update house_status set value1 = @value where item='occt'

	--occt_h本夜占用不含自用房
	exec p_gds_reserve_rsv_index @bdate, @types, 'Occupied Tonight', 'R', @value output
	exec p_gds_reserve_rsv_index @bdate, @types, 'HSE', 'R', @tmp1 output 
	update house_status set value1 = @value - @tmp1 where item='occt_h'
	exec p_gds_reserve_rsv_index @bdate, @types, 'People In-House', 'R', @value output
	exec p_gds_reserve_rsv_index @bdate, @types, 'PN_HSE', 'R', @tmp1 output   
	update house_status set value2 = @value - @tmp1 where item='occt_h'
	exec p_gds_reserve_rsv_index @bdate, @types, 'Room to Rent', 'R', @value output
	update house_status set value3 = value1 / @value  where item='occt_h' and @value <> 0

	exec p_gds_reserve_rsv_index @bdate, @types, 'Occupied Tonight', 'R', @value output
	select @tmp1 = @value
	exec p_gds_reserve_rsv_index @bdate, @types, 'People In-House', 'R', @value output
	update house_status set value2 = @value where item='occt'
	exec p_gds_reserve_rsv_index @bdate, @types, 'Room to Rent', 'R', @tmp2 output
	if @tmp2<>0
		update house_status set value3=@tmp1 / @tmp2 where item='occt'
	else
		update house_status set value3=0 where item='occt'

	exec p_gds_reserve_rsv_index @bdate, @types, 'Average Room Rate', 'R', @value output
	update house_status set value1 = @value where item='rate'
	 
	-- Allotments  -- ?
	update house_status set value1 = 0 where item='allo'
	
	exec p_gds_reserve_rsv_index @bdate, @types, 'Occupied Tonight/FIT', 'R', @value output
	update house_status set value1 = @value where item='ind'
	exec p_gds_reserve_rsv_index @bdate, @types, 'People In-House/FIT', 'R', @value output
	update house_status set value2 = @value where item='ind'
	
	exec p_gds_reserve_rsv_index @bdate, @types, 'Occupied Tonight/GRP', 'R', @tmp1 output
	exec p_gds_reserve_rsv_index @bdate, @types, 'Occupied Tonight/MET', 'R', @tmp2 output
	update house_status set value1 = @tmp1+@tmp2 where item='grp'
	exec p_gds_reserve_rsv_index @bdate, @types, 'People In-House/GRP', 'R', @tmp1 output
	exec p_gds_reserve_rsv_index @bdate, @types, 'People In-House/MET', 'R', @tmp2 output
	update house_status set value2 = @tmp1+@tmp2 where item='grp'

	exec p_gds_reserve_rsv_index @bdate, @types, 'Room Revenue', 'R', @value output
	update house_status set value1 = @value where item='rev'
end

if @langid = 0
	select item, descript, value1, value2, value3, more, id from house_status where id=@id order by id, sequence
else
	select item, descript1, value1, value2, value3, more, id from house_status where id=@id order by id, sequence

return 0;


----------------------------------------------------------------------
--	update trigger 
--
--	跟踪 house_status 更新情况，用于 house status 的自动更新
----------------------------------------------------------------------
if exists (select * from sysobjects where name = 't_gds_house_status_update' and type = 'TR')
   drop trigger t_gds_house_status_update;
create trigger t_gds_house_status_update
   on house_status
   for update as
begin
if not exists(select 1 from table_update where tbname = 'house_status')
	insert table_update select 'house_status', getdate()
else
	update table_update set update_date = getdate() where tbname = 'house_status'

end
;

