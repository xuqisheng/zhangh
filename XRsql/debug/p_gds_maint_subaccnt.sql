// ------------------------------------------------------------------------
// Rebuld All Subaccnt
// ------------------------------------------------------------------------
if exists(select * from sysobjects where name='p_gds_maint_subaccnt' and type ='P')
   drop proc p_gds_maint_subaccnt;
create proc p_gds_maint_subaccnt
as

declare	@bdate		datetime,
			@accnt		char(10),
			@groupno		char(10),
			@class		char(1),
			@id			int,
			@extra		char(30),
			@lock			char(10)

declare c_maint cursor for select accnt,class,groupno,extra from master // order by accnt desc
open c_maint
fetch c_maint into @accnt,@class,@groupno,@extra
while @@sqlstatus = 0
begin
	-- 允许记账 (注意散客和成员的区别)
	if not exists(select 1 from subaccnt where accnt=@accnt and subaccnt=1 and type='0' and tag='0')
	begin
--		if @groupno=''	
			insert subaccnt select a.roomno, '', a.accnt, 1, '', '', '允许记账费用', '*', '2000.1.1', '2030.1.1', a.cby, a.changed, '0', '0', '', '', 1
				from master a, guest b where a.accnt=@accnt and a.haccnt = b.no
--		else
--			insert subaccnt select a.roomno, '', a.accnt, 1, '', '', '允许记账费用', '.', '2000.1.1', '2030.1.1', a.cby, a.changed, '0', '0', '', '', 1
--				from master a, guest b where a.accnt=@accnt and a.haccnt = b.no
	end

	-- 分账户
	if not exists(select 1 from subaccnt where accnt=@accnt and subaccnt=1 and type='5' and tag='0')
		insert subaccnt select a.roomno, '', a.accnt, 1, '', '', b.name, '*', '2000.1.1', '2030.1.1', a.cby, a.changed, '5', '0', '', '', 1
			from master a, guest b where a.accnt=@accnt and a.haccnt = b.no
	
	-- 团体为成员付费 (just group & meet= 所有费用)
	if @class in ('G', 'M') 
		and not exists(select 1 from subaccnt where accnt=@accnt and subaccnt=1 and type='2' and tag='0')
		insert subaccnt select a.roomno, '', a.accnt, 1, '', '', '团体为成员付费', '.', '2000.1.1', '2030.1.1', a.cby, a.changed, '2', '0', '', '', 1
			from master a, guest b where a.accnt=@accnt and a.haccnt = b.no

	-- 成员 : 团体付费
	if @groupno<>'' and @class='F' and not exists(select 1 from subaccnt where accnt=@accnt and to_accnt=@groupno and type='5' and tag='0')
	begin
		select @id = max(subaccnt) from subaccnt where accnt=@accnt and type='5'
		select @id = isnull(@id, 1) + 1
		insert subaccnt select a.roomno, '', a.accnt, @id, '', a.groupno, '团体付费', b.pccodes, '2000.1.1', '2030.1.1', a.cby, a.changed, '5', '0', '', '', 1
			from master a, subaccnt b where a.accnt=@accnt and a.groupno = b.accnt and b.type = '2'
	end

	fetch c_maint into @accnt,@class,@groupno
end
close c_maint
deallocate cursor c_maint
;



//select * from master where groupno<>'' 
//	and accnt not in (select accnt from subaccnt where type='5' and subaccnt>1);

//select * from master where class='G' 
//and not exists(select 1 from subaccnt where accnt=master.accnt and subaccnt=1 and type='2' and tag='0');
