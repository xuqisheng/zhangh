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

insert mstflow values ('1', '(1)  ', '', '------���չ�ҹ���ϼ�', 'Last night"s stay overs', 0, 0)
insert mstflow values ('2', '(2)  ', '3+6+7+8+9+10', '----Ԥ�Ʊ��յ���', 'Anticipated arrivals', 0, 0) 
insert mstflow values ('3', '(2.1)', '4+5', 'a.ʵ�ʵ���', 'Actual arrivals', 0, 0) 
insert mstflow values ('4', '(2.1.1)', '', 'ס��ҹ', 'Stay over', 0, 0) 
insert mstflow values ('5', '(2.1.2)', '', '�������', 'Same day check out', 0, 0) 
insert mstflow values ('6', '(2.2)', '', 'b.�Ƴٵ���', 'Delayed arrivals', 0, 0)
insert mstflow values ('7', '(2.3)', '', 'c.Ԥ��ȡ��', 'Cancellations', 0, 0) 
insert mstflow values ('8', '(2.4)', '', 'd.Ӧ��δ��', 'No shows', 0, 0) 
insert mstflow values ('9', '(2.5)', '', 'e.ת�ݴ���', 'Transfer to other hotels', 0, 0) 
insert mstflow values ('10', '(2.6)', '', 'f.�������', 'Miscellaneous', 0, 0) 

insert mstflow values ('11', '(3)  ', '12+13', '----Ԥ�Ʊ������', 'Anticipated departures', 0, 0) 
insert mstflow values ('12', '(3.1)', '', 'a.ʵ�����', 'Actual departures', 0, 0)
insert mstflow values ('13', '(3.2)', '', 'b.�Ƴ����', 'Extended stay overs', 0, 0)

insert mstflow values ('14', '(4)  ', '15+16', '----Ԥ�Ʊ��չ�ҹ', 'Anticipated Stay overs', 0, 0) 
insert mstflow values ('15', '(4.1)', '', 'a.ʵ�ʹ�ҹ', 'Actual stay overs', 0, 0)
insert mstflow values ('16', '(4.2)', '', 'b.��ǰ���', 'Early check out', 0, 0)

insert mstflow values ('17', '(5)  ', '18+19', '----����ǰӦ���', 'Should-be departures before today', 0, 0)
insert mstflow values ('18', '(5.1)', '', 'a.ʵ�����', 'Actual departures', 0, 0)
insert mstflow values ('19', '(5.2)', '', 'b.��ס��ҹ', 'stay overs', 0, 0)

insert mstflow values ('20', '(6)  ', '21+22', '----��ǰ����Ԥ��', 'Unexpected early arrivals', 0, 0)
insert mstflow values ('21', '(6.1)', '', 'a.ס��ҹ', 'stay overs', 0, 0)
insert mstflow values ('22', '(6.2)', '', 'b.�������', 'Same day check out', 0, 0)

insert mstflow values ('23', '(7)  ', '24+25', '��Ԥ�����������ס', 'Late arrivals', 0, 0) 
insert mstflow values ('24', '(7.1)', '', 'a.ס��ҹ', 'stay overs', 0, 0)
insert mstflow values ('25', '(7.2)', '', 'b.�������', 'Same day check out', 0, 0)

insert mstflow values ('26', '(8)  ', '27+28', '----����Ԥ��ʵ�ʵ���', 'Same day pickups', 0, 0)
insert mstflow values ('27', '(8.1)', '', 'a.ס��ҹ', 'stay overs', 0, 0)
insert mstflow values ('28', '(8.2)', '', 'b.�������', 'Same day check out', 0, 0)

insert mstflow values ('29', '(9)  ', '30+31', '------------ֱ�ӵǼ�', 'Walk-in arrivals', 0, 0) 
insert mstflow values ('30', '(9.1)', '', 'a.ס��ҹ', 'stay overs', 0, 0)
insert mstflow values ('31', '(9.2)', '', 'b.�������', 'Same day check out', 0, 0)

insert mstflow values ('32', '(a)', '3+20+23+26+29', '------���յ��귿�ϼ�', 'Total of arrivals', 0, 0)
insert mstflow values ('33', '(b)', '5+12+16+18+22+25+28+31', '------������귿�ϼ�', 'Total of departures', 0, 0)
insert mstflow values ('34', '(c)', '1+32-33', '------���չ�ҹ���ϼ�', 'This night"s stay overs', 0, 0)
insert mstflow values ('35', '(d)', '5+22+25+28+31', '------���յ��뷿�ϼ�', 'Total of same day checkout', 0, 0)
insert mstflow values ('36', '(e)', '32-35', '--���յִ��ҹ���ϼ�', 'Stay overs who arrived today', 0, 0)
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
		-- ���չ�ҹ�� 
		begin 
		if datediff(day, @bdate, @fmdep) = 0 
			-- Ԥ�Ʊ������ 
			begin
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(3)'
			if exists (select 1 from master_till where accnt = @accnt and sta = 'I')
				-- ��ҹ 
				update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(3.2)'
			else
				-- ʵ����� 
				update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(3.1)'
			end 
		else if datediff(day, @bdate, @fmdep) > 0 
			-- Ԥ�Ʊ��չ�ҹ 
			begin
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(4)'
			if exists (select 1 from master_till where accnt = @accnt and sta = 'I')
				-- ʵ�ʹ�ҹ 
				update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(4.1)'
			else
				-- ��ǰ��� 
				update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(4.2)'
			end 
		else 
			begin
			-- ����ǰӦ��� 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(5)'
			if exists (select 1 from master_till where accnt = @accnt and sta = 'I')
				-- �Թ�ҹ 
				update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(5.2)'
			else
				-- ʵ����� 
				update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(5.1)'
			end 
		end 
	else if charindex(@fmsta, 'RCG') > 0 and datediff(day, @bdate, @fmarr) = 0 
		-- Ԥ�Ʊ��յ��� 
		begin
		update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(2)'
		select @tosta = sta, @toarr=arr, @tologmark = logmark from master_till where accnt = @accnt
		if exists (select 1 from master_log where accnt = @accnt and sta ='I' and logmark >= @fmlogmark and logmark <= @tologmark)
			begin
			-- ʵ�ʵ��� 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(2.1)'
			if @tosta = 'I' 
				-- ��ҹ 
				update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(2.1.1)'
			else
				-- ������� 
				update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(2.1.2)'
			end 
		else if charindex(@tosta, 'RCG') > 0 and datediff(day, @bdate, @toarr) > 0 
			-- �Ƴٵ��� 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(2.2)'
		else if charindex(@tosta, 'RCGN') > 0 
			-- Ӧ��δ�� 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(2.4)'
		else if charindex(@tosta, 'X') > 0 
			-- Ԥ��ȡ�� 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(2.3)'
		else if charindex(@tosta, 'L') > 0 
			-- ת�� 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(2.5)'
		else
			-- ���� 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(2.6)'
		end 
	else if charindex(@fmsta, 'RCG') > 0 and datediff(day, @bdate, @fmarr) > 0 
		-- Ԥ�ƴ��ջ��Ժ󵽴� 
		begin
		select @tosta = sta, @toarr = arr, @tologmark = logmark from master_till where accnt = @accnt
		if exists (select 1 from master_log where accnt = @accnt and sta = 'I' and logmark >= @fmlogmark and logmark <= @tologmark)
			begin
			-- ��ǰ���� 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(6)'
			if @tosta = 'I' 
				-- ��ҹ 
				update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(6.1)'
			else
				-- ������� 
				update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(6.2)'
			end 
		end 
	else
		begin
		select @tosta = sta, @toarr = arr, @tologmark = logmark from master_till where accnt = @accnt
		if exists (select 1 from master_log where accnt = @accnt and sta ='I' and logmark >= @fmlogmark and logmark <= @tologmark)
			begin
			-- ��Ԥ������ʿ�������ס 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(7)'
			if @tosta = 'I' 
				-- ��ҹ 
				update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(7.1)'
			else
				-- ������� 
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
		-- ֱ�ӵǼ� 
		begin
		update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(9)'
		if @tosta = 'I' 
			-- ��ҹ 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(9.1)'
		else
			-- ������� 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(9.2)'
		end 
	else if exists (select 1 from master_log where accnt = @accnt and sta ='I' and logmark <= @tologmark)
		-- ����Ԥ��ʵ�ʵ��� 
		begin
		update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(8)'
		if @tosta = 'I' 
			-- ��ҹ 
			update mstflow set quan1 = quan1 + @quan1, quan2 = quan2 + @quan2 where code = '(8.1)'
		else
			-- ������� 
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
