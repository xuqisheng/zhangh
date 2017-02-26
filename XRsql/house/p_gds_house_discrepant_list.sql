
if  exists(select * from sysobjects where name = "p_gds_house_discrepant_list")
	 drop proc p_gds_house_discrepant_list;
create proc p_gds_house_discrepant_list
	@mode			char(10)	= 'disc',	-- 显示模式 skip, sleep, disc, all
	@brmno		char(5)	= ''   		-- 起始房号
as
-----------------------------------------------------------------------------------------------
--	p_gds_house_discrepant_list 矛盾房 显示
--
--每次显示的时候自动处理? 不行，可以放在 rmsta update trigger 
----------------------------------------------------------------------------------------------- 

create table #goutput(
	roomno		char(5)						not null,
	hs_sta		char(3)						not null,
	fo_sta		char(3)						not null,
	rmsta			char(1)						not null,
	discrepancy	char(10)						null,
	remark		varchar(50)					null,
	cby			char(10)						null,
	changed		datetime						null,
	id				int							null
)

declare	@print	char(1)   -- 打印模式

select @print = '0'
select @brmno = rtrim(@brmno)
if @brmno is null
	select @brmno = ''
else if @brmno = 'print'
	select @print = '1', @brmno=''

if @mode = 'skip' 
	insert #goutput select a.roomno, a.hs_sta, a.fo_sta, b.sta, '', a.remark, a.cby, a.changed, a.id
		 from discrepant_room a, rmsta b where a.roomno=b.roomno and a.sta='I' and a.hs_sta='V' and a.roomno>=@brmno
else if @mode = 'sleep' 
	insert #goutput select a.roomno, a.hs_sta, a.fo_sta, b.sta, '', a.remark, a.cby, a.changed, a.id
		 from discrepant_room a, rmsta b where a.roomno=b.roomno and a.sta='I' and a.hs_sta='O' and a.roomno>=@brmno
else if @mode = 'disc' 
	insert #goutput select a.roomno, a.hs_sta, a.fo_sta, b.sta, '', a.remark, a.cby, a.changed, a.id
		 from discrepant_room a, rmsta b where a.roomno=b.roomno and a.sta='I' and a.roomno>=@brmno
else
begin
	insert #goutput select a.roomno, a.hs_sta, a.fo_sta, b.sta, '', a.remark, a.cby, a.changed, a.id
		 from discrepant_room a, rmsta b where a.roomno=b.roomno and a.sta='I' and a.roomno>=@brmno
	insert #goutput select roomno, ocsta, ocsta, sta, '', '', '', null, -1
		from rmsta where roomno not in (select roomno from #goutput) and roomno>=@brmno
end

update #goutput set discrepancy = 'SLEEP' where hs_sta='O' and fo_sta='V'
update #goutput set discrepancy = 'SKIP' where hs_sta='V' and fo_sta='O'

-- 
if @print = '1'
begin
	update #goutput set hs_sta='VAC' where hs_sta='V'
	update #goutput set hs_sta='OCC' where hs_sta='O'
	update #goutput set fo_sta='VAC' where fo_sta='V'
	update #goutput set fo_sta='OCC' where fo_sta='O'
end

select * from #goutput order by roomno

return 0
;
