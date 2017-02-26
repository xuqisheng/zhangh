--------------------------------------
-- room and guest flow report 
--------------------------------------
if exists (select 1 from sysobjects where name = 'mstflow' and type = 'U' )
	drop table mstflow;
create table mstflow
(
	order_		char(2)	default '' not null, 
	code			char(10)	default '' not null, 
	itemrela		char(26)	default '' not null, 
	descript1	char(20)	default '' not null, 
	descript2	char(34)	default '' not null, 
	quan1			integer	default 0  not null, 
	quan2			integer	default 0  not null
)
exec sp_primarykey mstflow, code
create unique index index2 on mstflow(code)
;

insert mstflow values ('1', '(1)  ', '', '------上日过夜房合计', 'Last night"s stay overs', 0, 0)
insert mstflow values ('2', '(2)  ', '3+6+7+8+9+10', '----预计本日到店', 'Anticipated arrivals', 0, 0) 
insert mstflow values ('3', '(2.1)', '4+5', 'a.实际到店', 'Actual arrivals', 0, 0) 
insert mstflow values ('4', '(2.1.1)', '', '住过夜', 'Stay over', 0, 0) 
insert mstflow values ('5', '(2.1.2)', '', '当天离店', 'Same day check out', 0, 0) 
insert mstflow values ('6', '(2.2)', '', 'b.推迟到店', 'Delayed arrivals', 0, 0)
insert mstflow values ('7', '(2.3)', '', 'c.预订取消', 'Cancellations', 0, 0) 
insert mstflow values ('8', '(2.4)', '', 'd.应到未到', 'No shows', 0, 0) 
insert mstflow values ('9', '(2.5)', '', 'e.转馆处理', 'Transfer to other hotels', 0, 0) 
insert mstflow values ('10', '(2.6)', '', 'f.其它情况', 'Miscellaneous', 0, 0) 

insert mstflow values ('11', '(3)  ', '12+13', '----预计本日离店', 'Anticipated departures', 0, 0) 
insert mstflow values ('12', '(3.1)', '', 'a.实际离店', 'Actual departures', 0, 0)
insert mstflow values ('13', '(3.2)', '', 'b.推迟离店', 'Extended stay overs', 0, 0)

insert mstflow values ('14', '(4)  ', '15+16', '----预计本日过夜', 'Anticipated Stay overs', 0, 0) 
insert mstflow values ('15', '(4.1)', '', 'a.实际过夜', 'Actual stay overs', 0, 0)
insert mstflow values ('16', '(4.2)', '', 'b.提前离店', 'Early check out', 0, 0)

insert mstflow values ('17', '(5)  ', '18+19', '----本日前应离店', 'Should-be departures before today', 0, 0)
insert mstflow values ('18', '(5.1)', '', 'a.实际离店', 'Actual departures', 0, 0)
insert mstflow values ('19', '(5.2)', '', 'b.仍住过夜', 'stay overs', 0, 0)

insert mstflow values ('20', '(6)  ', '21+22', '----提前到店预订', 'Unexpected early arrivals', 0, 0)
insert mstflow values ('21', '(6.1)', '', 'a.住过夜', 'stay overs', 0, 0)
insert mstflow values ('22', '(6.2)', '', 'b.当天离店', 'Same day check out', 0, 0)

insert mstflow values ('23', '(7)  ', '24+25', '晚到预订或挂帐重入住', 'Late arrivals', 0, 0) 
insert mstflow values ('24', '(7.1)', '', 'a.住过夜', 'stay overs', 0, 0)
insert mstflow values ('25', '(7.2)', '', 'b.当天离店', 'Same day check out', 0, 0)

insert mstflow values ('26', '(8)  ', '27+28', '----本日预订实际到店', 'Same day pickups', 0, 0)
insert mstflow values ('27', '(8.1)', '', 'a.住过夜', 'stay overs', 0, 0)
insert mstflow values ('28', '(8.2)', '', 'b.当天离店', 'Same day check out', 0, 0)

insert mstflow values ('29', '(9)  ', '30+31', '------------直接登记', 'Walk-in arrivals', 0, 0) 
insert mstflow values ('30', '(9.1)', '', 'a.住过夜', 'stay overs', 0, 0)
insert mstflow values ('31', '(9.2)', '', 'b.当天离店', 'Same day check out', 0, 0)

insert mstflow values ('32', '(a)', '3+20+23+26+29', '------本日到店房合计', 'Total of arrivals', 0, 0)
insert mstflow values ('33', '(b)', '5+12+16+18+22+25+28+31', '------本日离店房合计', 'Total of departures', 0, 0)
insert mstflow values ('34', '(c)', '1+32-33', '------本日过夜房合计', 'This night"s stay overs', 0, 0)
insert mstflow values ('35', '(d)', '5+22+25+28+31', '------当日抵离房合计', 'Total of same day checkout', 0, 0)
insert mstflow values ('36', '(e)', '32-35', '--当日抵达过夜房合计', 'Stay overs who arrived today', 0, 0)
;


--------------------------------------
--	p_gds_audit_mstflow
--------------------------------------
if exists (select 1 from sysobjects where name = 'p_gds_audit_mstflow' and type = 'P' )
	drop proc p_gds_audit_mstflow;
create proc p_gds_audit_mstflow
as
	
declare 
	@accnt		char(7), 
	@fmsta		char(1), 
	@fmarr		datetime, 
	@fmdep		datetime, 
	@fmgroupno	char(7), 
	@fmlogmark	integer, 
	@tosta		char(1), 
	@toarr		datetime, 
	@todep		datetime, 
	@togroupno	char(7), 
	@tologmark	integer, 
	@quan1		integer, 
	@quan2		integer, 
	@quan11		integer, 
	@quan22		integer, 
	@quan111		integer, 
	@quan222		integer, 
	@bdate		datetime
	

-- init 
select @bdate = dateadd(day, -1, bdate1) from sysdata 
update mstflow set quan1 = 0 , quan2 = 0 

-- last night data 
update mstflow set
	quan1 = (select count(1) from master_last where sta = 'I' and substring(accnt, 2, 2) < '80' and rtrim(groupno) is null ), 
	quan2 = (select count(1) from master_last where sta = 'I' and substring(accnt, 2, 2) < '80' and rtrim(groupno) is not null )
	where code ='(1)'

-- scan master_last 
declare c_master_last cursor for select accnt, sta, arr, dep, groupno, logmark
	from master_last where substring(accnt, 2, 2) < '80'
	order by sta
open  c_master_last
fetch c_master_last into @accnt, @fmsta, @fmarr, @fmdep, @fmgroupno, @fmlogmark
while @@sqlstatus = 0
	begin
	if rtrim(@fmgroupno) is null
		select @quan1 = 1, @quan2 = 0
	else
		select @quan1 = 0, @quan2 = 1
	if @fmsta = 'I'
		-- 上日过夜房 
		begin 
		if datediff(day, @bdate, @fmdep) = 0 
			-- 预计本日离店 
			begin
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(3)'
			if exists (select 1 from master_till where accnt = @accnt and sta = 'I')
				-- 过夜 
				update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(3.2)'
			else
				-- 实际离店 
				update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(3.1)'
			end 
		else if datediff(day, @bdate, @fmdep) > 0 
			-- 预计本日过夜 
			begin
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(4)'
			if exists (select 1 from master_till where accnt = @accnt and sta = 'I')
				-- 实际过夜 
				update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(4.1)'
			else
				-- 提前离店 
				update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(4.2)'
			end 
		else 
			begin
			-- 本日前应离店 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(5)'
			if exists (select 1 from master_till where accnt = @accnt and sta = 'I')
				-- 仍过夜 
				update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(5.2)'
			else
				-- 实际离店 
				update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(5.1)'
			end 
		end 
	else if charindex(@fmsta, 'RCG') > 0 and datediff(day, @bdate, @fmarr) = 0 
		-- 预计本日到店 
		begin
		update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(2)'
		select @tosta = sta, @toarr=arr, @tologmark = logmark from master_till where accnt = @accnt
		if exists (select 1 from master_log where accnt = @accnt and sta ='I' and logmark >= @fmlogmark and logmark <= @tologmark)
			begin
			-- 实际到店 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(2.1)'
			if @tosta = 'I' 
				-- 过夜 
				update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(2.1.1)'
			else
				-- 当天离店 
				update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(2.1.2)'
			end 
		else if charindex(@tosta, 'RCG') > 0 and datediff(day, @bdate, @toarr) > 0 
			-- 推迟到店 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(2.2)'
		else if charindex(@tosta, 'RCGN') > 0 
			-- 应到未到 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(2.4)'
		else if charindex(@tosta, 'X') > 0 
			-- 预订取消 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(2.3)'
		else if charindex(@tosta, 'L') > 0 
			-- 转馆 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(2.5)'
		else
			-- 其它 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(2.6)'
		end 
	else if charindex(@fmsta, 'RCG') > 0 and datediff(day, @bdate, @fmarr) > 0 
		-- 预计次日或以后到达 
		begin
		select @tosta = sta, @toarr = arr, @tologmark = logmark from master_till where accnt = @accnt
		if exists (select 1 from master_log where accnt = @accnt and sta = 'I' and logmark >= @fmlogmark and logmark <= @tologmark)
			begin
			-- 提前到店 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(6)'
			if @tosta = 'I' 
				-- 过夜 
				update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(6.1)'
			else
				-- 当天离店 
				update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(6.2)'
			end 
		end 
	else
		begin
		select @tosta = sta, @toarr = arr, @tologmark = logmark from master_till where accnt = @accnt
		if exists (select 1 from master_log where accnt = @accnt and sta ='I' and logmark >= @fmlogmark and logmark <= @tologmark)
			begin
			-- 晚到预订或挂帐客人重入住 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(7)'
			if @tosta = 'I' 
				-- 过夜 
				update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(7.1)'
			else
				-- 当天离店 
				update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(7.2)'
			end 
		end 
	fetch c_master_last into @accnt, @fmsta, @fmarr, @fmdep, @fmgroupno, @fmlogmark
	end 
close c_master_last
deallocate cursor c_master_last
-- scan master_till 
declare c_master_till cursor for select accnt, sta, arr, dep, groupno, logmark
	from master_till where substring(accnt, 2, 2)<'80'
	and not exists (select 1 from master_last where master_last.accnt = master_till.accnt)
open  c_master_till
fetch c_master_till into @accnt, @tosta, @toarr, @todep, @togroupno, @tologmark
while @@sqlstatus = 0
	begin
	if rtrim(@togroupno) is null
		select @quan1=1, @quan2=0
	else
		select @quan1=0, @quan2=1
	if exists (select 1 from master_log where accnt = @accnt and sta ='I' and logmark <= @tologmark) and not exists (select 1 from master_log where accnt = @accnt and charindex(sta, 'RCG') > 0 and logmark <= @tologmark)
		-- 直接登记 
		begin
		update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(9)'
		if @tosta = 'I' 
			-- 过夜 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(9.1)'
		else
			-- 当天离店 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(9.2)'
		end 
	else if exists (select 1 from master_log where accnt = @accnt and sta ='I' and logmark <= @tologmark)
		-- 本日预订实际到店 
		begin
		update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(8)'
		if @tosta = 'I' 
			-- 过夜 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(8.1)'
		else
			-- 当天离店 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(8.2)'
		end 
	fetch c_master_till into @accnt, @tosta, @toarr, @todep, @togroupno, @tologmark
	end 
close c_master_till
deallocate cursor c_master_till
select @quan1 = isnull(sum(quan1), 0), @quan2 = isnull(sum(quan2), 0) from mstflow where code in ('(2.1)', '(6)', '(7)', '(8)', '(9)')
update mstflow set quan1 = @quan1 , quan2 = @quan2 where code ='(a)'
select @quan11 = isnull(sum(quan1), 0), @quan22 = isnull(sum(quan2), 0) from mstflow where code in ('(2.1.2)', '(3.1)', '(4.2)', '(5.1)', '(6.2)', '(7.2)', '(8.2)', '(9.2)')
update mstflow set quan1 = @quan11 , quan2 = @quan22 where code ='(b)'
select @quan111 = isnull(sum(quan1), 0), @quan222 = isnull(sum(quan2), 0) from mstflow where code = '(1)'
update mstflow set quan1 = @quan111 + @quan1 - @quan11, quan2 = @quan222 + @quan2 - @quan22 where code ='(c)'
select @quan111 = isnull(sum(quan1), 0), @quan222 = isnull(sum(quan2), 0) from mstflow where code in ('(2.1.2)', '(6.2)', '(7.2)', '(8.2)', '(9.2)')
update mstflow set quan1 = @quan111, quan2 = @quan222 where code ='(d)'
select @quan111 = isnull(sum(quan1), 0), @quan222 = isnull(sum(quan2), 0) from mstflow where code in ('(a)')
select @quan11  = isnull(sum(quan1), 0), @quan22  = isnull(sum(quan2), 0) from mstflow where code in ('(d)')
update mstflow set quan1 = @quan111 - @quan11, quan2 = @quan222 - @quan22 where code ='(e)'
return 0
;
