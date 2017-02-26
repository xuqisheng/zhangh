if exists(select * from sysobjects where name = 'p_clg_grp_checkbill_roomno')
	drop proc p_clg_grp_checkbill_roomno;

create proc p_clg_grp_checkbill_roomno
	@modu_id	char(2),
	@pc_id	char(4),
	@accnt 	char(10),	--团队帐号
	@begdate datetime,	--统计时间
	@enddate datetime,
	@type   	char(3),		--grp,all,mem
	@isvalid char(3),		--isi,isd,all
	@isfut	char(1)		--T包括预计帐目
as

declare
	@amount		money,
	@pccode		char(5),
	@roomno		char(5)

create table #temp
    (	roomno char(5) null,
	 	amount0 money default 0 null,
		amount1 money default 0 null,
		amount2 money default 0 null,
		amount3 money default 0 null,
		amount4 money default 0 null,
        amount5 money default 0 null)

if @type='grp'
	begin
	if @isvalid='isi'
		declare c_guest cursor for select roomno,pccode,rooms*(charge-credit) from grp_checkbill
 		 where modu_id=@modu_id and pc_id=@pc_id and accnt=@accnt and billno='' and date>=@begdate and date<=@enddate and (@isfut='T' or isfut='F') order by pccode
	else if @isvalid='isd'
		declare c_guest cursor for select roomno,pccode,rooms*(charge-credit) from grp_checkbill
 		 where modu_id=@modu_id and pc_id=@pc_id and accnt=@accnt and billno<>'' and date>=@begdate and date<=@enddate and (@isfut='T' or isfut='F') order by pccode
	else
		declare c_guest cursor for select roomno,pccode,rooms*(charge-credit) from grp_checkbill
 		 where modu_id=@modu_id and pc_id=@pc_id and accnt=@accnt and date>=@begdate and date<=@enddate and (@isfut='T' or isfut='F') order by pccode
	end
else if @type='mem'
	begin
	if @isvalid='isi'
		declare c_guest cursor for select roomno,pccode,rooms*(charge-credit) from grp_checkbill
 		 where modu_id=@modu_id and pc_id=@pc_id and accnt<>@accnt and billno='' and date>=@begdate and date<=@enddate and (@isfut='T' or isfut='F') order by pccode
	else if @isvalid='isd'
		declare c_guest cursor for select roomno,pccode,rooms*(charge-credit) from grp_checkbill
 		 where modu_id=@modu_id and pc_id=@pc_id and accnt<>@accnt and billno<>'' and date>=@begdate and date<=@enddate and (@isfut='T' or isfut='F') order by pccode
	else
		declare c_guest cursor for select roomno,pccode,rooms*(charge-credit) from grp_checkbill
 		 where modu_id=@modu_id and pc_id=@pc_id and accnt<>@accnt and date>=@begdate and date<=@enddate and (@isfut='T' or isfut='F') order by pccode
	end
else
	begin
	if @isvalid='isi'
		declare c_guest cursor for select roomno,pccode,rooms*(charge-credit) from grp_checkbill
 		 where modu_id=@modu_id and pc_id=@pc_id and billno='' and date>=@begdate and date<=@enddate and (@isfut='T' or isfut='F') order by pccode
	else if @isvalid='isd'
		declare c_guest cursor for select roomno,pccode,rooms*(charge-credit) from grp_checkbill
 		 where modu_id=@modu_id and pc_id=@pc_id and billno<>'' and date>=@begdate and date<=@enddate and (@isfut='T' or isfut='F') order by pccode
	else
		declare c_guest cursor for select roomno,pccode,rooms*(charge-credit) from grp_checkbill
 		 where modu_id=@modu_id and pc_id=@pc_id and date>=@begdate and date<=@enddate and (@isfut='T' or isfut='F') order by pccode
	end
open c_guest
fetch c_guest into @roomno,@pccode,@amount
while @@sqlstatus=0
	begin


	if not exists(select 1 from #temp where roomno=@roomno)
		insert into #temp values(@roomno,0,0,0,0,0,0)
	if exists(select 1 from pccode where pccode=@pccode and deptno7='rm')
		update #temp set amount0 = amount0 + @amount where roomno=@roomno
	else if exists(select 1 from pccode where pccode=@pccode and deptno7='fb')
		update #temp set amount1 = amount1 + @amount where roomno=@roomno
	else if exists(select 1 from pccode where pccode=@pccode and modu='05')
		update #temp set amount2 = amount2 + @amount where roomno=@roomno
	else if exists(select 1 from pccode where pccode=@pccode and argcode<'98')
		update #temp set amount3 = amount3 + @amount where roomno=@roomno
	else
		update #temp set amount4 = amount4 + @amount where roomno=@roomno

	fetch c_guest into @roomno,@pccode,@amount
	end

close c_guest
deallocate cursor c_guest

update #temp set amount5 = amount0 + amount1 + amount2 + amount3 + amount4

select * from #temp
;
//exec p_clg_grp_checkbill_roomno @modu_id='02',@pc_id='0.45',@accnt='4800444',@begdate='1980-5-19 00:00:00',@enddate='2050-6-29 00:00:00',@type='all',@isvalid='isi',@isfut='F'