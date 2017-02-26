--E43
drop proc p_clg_report_house_status;
create proc p_clg_report_house_status
	@bdate	datetime
as
declare 
	@type 		char(5),
	@quantity	int
create table #goutput(
	class	char(15),
	code	char(14),
	type	char(5),
	value	int,
	sort	int)

declare c_type cursor for select type from typim
open c_type
fetch c_type into @type
while @@sqlstatus=0
begin
--class=V
	insert into #goutput select '2Vacant Rooms','Clean',@type,count(1),2 from rmsta where type=@type and sta='R' and ocsta='V'
	insert into #goutput select '2Vacant Rooms','Dirty',@type,count(1),1 from rmsta where type=@type and sta='D' and ocsta='V'
	insert into #goutput select '2Vacant Rooms','Out of Order',@type,count(1),3 from rmsta where type=@type and sta='O' and ocsta='V'
	insert into #goutput select '2Vacant Rooms','Out of Service',@type,count(1),4 from rmsta where type=@type and sta='S' and ocsta='V'
--class=O
	insert into #goutput select '4Occupied Rooms','Clean',@type,count(1),2 from rmsta where type=@type and sta='R' and ocsta='O'
	insert into #goutput select '4Occupied Rooms','Dirty',@type,count(1),1 from rmsta where type=@type and sta='D' and ocsta='O'
	insert into #goutput select '4Occupied Rooms','Out of Order',@type,count(1),3 from rmsta where type=@type and sta='O' and ocsta='O'
	insert into #goutput select '4Occupied Rooms','Out of Service',@type,count(1),4 from rmsta where type=@type and sta='S' and ocsta='O'
--class=ARR
	exec p_gds_reserve_rsv_index @bdate, @type, 'Arrival Rooms', 'R', @quantity output
	insert into #goutput values('1Arrival','Total',@type,@quantity,1)
	exec p_gds_reserve_rsv_index @bdate, @type, 'Arrival Rooms Actual', 'R', @quantity output
	insert into #goutput values('1Arrival','Expcted',@type,@quantity,2)
--class=DEP
	exec p_gds_reserve_rsv_index @bdate, @type, 'Departure Rooms', 'R', @quantity output
	insert into #goutput values('3Departure','Total',@type,@quantity,1)
	exec p_gds_reserve_rsv_index @bdate, @type, 'Departure Rooms Actual', 'R', @quantity output
	insert into #goutput values('3Departure','Expcted',@type,@quantity,2)

	fetch c_type into @type
end
select * from #goutput;