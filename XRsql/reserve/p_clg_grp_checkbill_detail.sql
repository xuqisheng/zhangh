if exists(select * from sysobjects where name = 'p_clg_grp_checkbill_detail')
	drop proc p_clg_grp_checkbill_detail;

create proc p_clg_grp_checkbill_detail
	@modu_id	char(2),
	@pc_id	char(4),
	@accnt 	char(10),	--团队帐号
	@begdate datetime,	--统计时间
	@enddate datetime,
	@type   	char(3),		--grp,all,mem
	@isvalid char(3),		--isi,isd,all
	@isfut	char(1)		--T包括预计帐目   注意预计帐目的isfut=T   注意最后的select语句!
as

declare
	@amount		money,	--金额
	@rooms		integer,	--记录数
	@date			datetime,
	@rmtype		char(5),
	@pccode		char(5),	--费用码
	@roomno		char(5),
	@is_fut		char(1),
	@rmtype_fut	char(5),
   @rmchgcode  char(5),	--自动房费
   @rmaddcode  char(5)	--手工房费

create table #checkbill
    (	date datetime null,
		pccode char(5)	null,
	 	rmtype char(5) null,
	 	descript char(30) null,
      descript1   char(30) null,
		rooms integer default 0 null,
	   charge money default 0 null,
		credit money default 0 null,
		amount money default 0 null,
		isfut	 char(1)	null )

select @rmchgcode=value from sysoption where catalog='audit' and item='room_charge_pccode'
select @rmaddcode=value from sysoption where catalog='audit' and item='room_charge_pccode_NP'

if @type = 'grp'
	begin
	if @isvalid = 'isi'
		declare c_guest cursor for select date,pccode,roomno,rmtype,rooms,charge-credit,isfut from grp_checkbill
		 where modu_id=@modu_id and pc_id=@pc_id and accnt=@accnt and billno='' and date>=@begdate and date<=@enddate order by date,pccode
	else if @isvalid = 'isd'
		declare c_guest cursor for select date,pccode,roomno,rmtype,rooms,charge-credit,isfut from grp_checkbill
		 where modu_id=@modu_id and pc_id=@pc_id and accnt=@accnt and billno<>'' and date>=@begdate and date<=@enddate order by date,pccode
	else
		declare c_guest cursor for select date,pccode,roomno,rmtype,rooms,charge-credit,isfut from grp_checkbill
		 where modu_id=@modu_id and pc_id=@pc_id and accnt=@accnt and date>=@begdate and date<=@enddate order by date,pccode
	end
else if @type = 'mem'
	begin
	if @isvalid = 'isi'
		declare c_guest cursor for select date,pccode,roomno,rmtype,rooms,charge-credit,isfut from grp_checkbill
		 where modu_id=@modu_id and pc_id=@pc_id and accnt<>@accnt and billno='' and date>=@begdate and date<=@enddate order by date,pccode
	else if @isvalid = 'isd'
		declare c_guest cursor for select date,pccode,roomno,rmtype,rooms,charge-credit,isfut from grp_checkbill
		 where modu_id=@modu_id and pc_id=@pc_id and accnt<>@accnt and billno<>'' and date>=@begdate and date<=@enddate order by date,pccode
	else
		declare c_guest cursor for select date,pccode,roomno,rmtype,rooms,charge-credit,isfut from grp_checkbill
		 where modu_id=@modu_id and pc_id=@pc_id and accnt<>@accnt and date>=@begdate and date<=@enddate order by date,pccode
	end
else
	begin
	if @isvalid = 'isi'
		declare c_guest cursor for select date,pccode,roomno,rmtype,rooms,charge-credit,isfut from grp_checkbill
		 where modu_id=@modu_id and pc_id=@pc_id and billno='' and date>=@begdate and date<=@enddate order by date,pccode
	else if @isvalid = 'isd'
		declare c_guest cursor for select date,pccode,roomno,rmtype,rooms,charge-credit,isfut from grp_checkbill
		 where modu_id=@modu_id and pc_id=@pc_id and billno<>'' and date>=@begdate and date<=@enddate order by date,pccode
	else
		declare c_guest cursor for select date,pccode,roomno,rmtype,rooms,charge-credit,isfut from grp_checkbill
		 where modu_id=@modu_id and pc_id=@pc_id and date>=@begdate and date<=@enddate order by date,pccode
	end

open c_guest
fetch c_guest into @date,@pccode,@roomno,@rmtype_fut,@rooms,@amount,@is_fut
while @@sqlstatus = 0
	begin
	select @pccode = ltrim(@pccode)
	if @pccode = @rmchgcode or @pccode = @rmaddcode
		begin
			select @rmtype = type from rmsta where roomno = @roomno
			if @is_fut='T'
				select @rmtype = @rmtype_fut
			if not exists (select 1 from #checkbill where datediff(day,date,@date) = 0 and rmtype = @rmtype and isfut=@is_fut)
				insert #checkbill values (@date,@rmchgcode,@rmtype,'','',0,0,0,0,@is_fut)
			if @pccode =@rmaddcode
				update #checkbill set rooms = rooms + @rooms,credit = credit + @amount,amount = amount + @amount
                    where datediff(day,date,@date) = 0 and pccode = @rmchgcode and rmtype = @rmtype and isfut=@is_fut
			else
				update #checkbill set rooms = rooms + @rooms,amount = amount + @rooms*@amount where datediff(day,date,@date) = 0
                     and pccode = @rmchgcode and rmtype = @rmtype and isfut=@is_fut
		end
	else
		begin
		if not exists (select 1 from #checkbill where datediff(day,date,@date) = 0 and pccode = @pccode and isfut=@is_fut)
			insert #checkbill values (@date,@pccode,'','','',0,0,0,0,@is_fut)
			update #checkbill set rooms = rooms + @rooms,amount = amount + @rooms*@amount where datediff(day,date,@date) = 0
              and pccode = @pccode and isfut=@is_fut
		end

	fetch c_guest into @date,@pccode,@roomno,@rmtype_fut,@rooms,@amount,@is_fut
	end

close c_guest
deallocate cursor c_guest

--update #checkbill set pccode = '00' where pccode='903'  --订金
--update #checkbill set pccode = '0' where pccode='901'    --结账付款,难道取所有付款码？
update #checkbill set descript = a.descript,descript1 = a.descript1 from typim a where #checkbill.rmtype = a.type and #checkbill.pccode = @rmchgcode
update #checkbill set descript = a.descript,descript1 = a.descript1 from pccode a where #checkbill.pccode = a.pccode and #checkbill.pccode <>@rmchgcode
update #checkbill set charge = a.rate from grprate a where #checkbill.rmtype = a.type and a.accnt = @accnt

if @isfut='F'
	select c.haccnt,a.credman,a.arr,a.dep,a.accnt,b.date,b.pccode,b.rmtype,b.descript,b.descript1,b.rooms,b.charge,b.credit,b.amount,b.isfut
	 from master a,#checkbill b,master_des c where a.accnt=@accnt and a.accnt=c.accnt and b.amount<>0 and b.isfut='F' 
	union
	select a.name,a.credman,a.arr,a.dep,a.accnt,b.date,b.pccode,b.rmtype,b.descript,b.descript1,b.rooms,b.charge,b.credit,b.amount,b.isfut
	 from hmaster a,#checkbill b where a.accnt=@accnt and b.amount<>0 and b.isfut='F' 
	order by b.pccode,b.descript,b.date
else
	select c.haccnt,a.credman,a.arr,a.dep,a.accnt,b.date,b.pccode,b.rmtype,b.descript,b.descript1,b.rooms,b.charge,b.credit,b.amount,b.isfut
	 from master a,#checkbill b,master_des c where a.accnt=@accnt and a.accnt=c.accnt and b.amount<>0
	union
	select a.name,a.credman,a.arr,a.dep,a.accnt,b.date,b.pccode,b.rmtype,b.descript,b.descript1,b.rooms,b.charge,b.credit,b.amount,b.isfut
	 from hmaster a,#checkbill b where a.accnt=@accnt and b.amount<>0 order by b.pccode,b.descript,b.date
	
return 0
;
//exec p_clg_grp_checkbill_detail @modu_id='02',@pc_id='0.45',@accnt='4800444',@begdate='1980-5-19 00:00:00',@enddate='2050-6-29 00:00:00',@type='all',@isvalid='isi',@isfut='F'