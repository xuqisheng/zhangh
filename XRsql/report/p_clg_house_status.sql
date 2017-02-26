drop proc p_clg_house_status;
create proc p_clg_house_status
	@lang	int
as
declare
	@date	datetime,
	@type	varchar(7),
	@typedes	char(30),
	@arr	money,
	@arrf	money,
	@di	money,
	@cl	money,
	@oo	money,
	@os	money,
	@dep	money,
	@depf money,
	@od	money,
	@oc	money
create table #rslt(
	type	char(30),
	arr	money,
	arrfut		money,
	di		money,
	cl		money,
	oo		money,
	os		money,
	dep	money,
	depfut	money,
	od		money,
	oc		money
)
select @date = bdate from sysdata
declare c_type cursor for select ','+substring(type+space(5),1,5)+',' from typim order by gtype,type

open c_type
fetch c_type into @type
while @@sqlstatus = 0
	begin
	exec p_gds_reserve_rsv_index @date, @type, 'Out of Order', 'R', @oo output
	exec p_gds_reserve_rsv_index @date, @type, 'Out of Service', 'R', @os output
	exec p_gds_reserve_rsv_index @date, @type, 'Arrival Rooms', 'R', @arrf output
	exec p_gds_reserve_rsv_index @date, @type, 'Arrival Rooms Actual', 'R', @arr output
	exec p_gds_reserve_rsv_index @date, @type, 'Departure Rooms', 'R', @depf output
	exec p_gds_reserve_rsv_index @date, @type, 'Departure Rooms Actual', 'R', @dep output
	select @di = count(1) from rmsta where ocsta='V' and charindex(sta,'DT')>0 and charindex(type,@type)>0
	select @cl = count(1) from rmsta where ocsta='V' and charindex(sta,'RI')>0 and charindex(type,@type)>0
	select @od = count(1) from rmsta where ocsta='O' and charindex(sta,'DT')>0 and charindex(type,@type)>0
	select @oc = count(1) from rmsta where ocsta='O' and charindex(sta,'RI')>0 and charindex(type,@type)>0
	if @lang=0
		select @typedes = descript from typim where charindex(type,@type)>0
	else
		select @typedes = descript1 from typim where charindex(type,@type)>0
	insert into #rslt select @typedes,@arr,@arrf,@di,@cl,@oo,@os,@dep,@depf,@od,@oc
	fetch c_type into @type
	end
close c_type
deallocate cursor c_type

select *	 from #rslt
;