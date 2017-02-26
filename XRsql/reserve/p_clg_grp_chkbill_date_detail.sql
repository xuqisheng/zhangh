if exists(select * from sysobjects where name = 'p_clg_grp_chkbill_date_detail')
	drop proc p_clg_grp_chkbill_date_detail;

create proc p_clg_grp_chkbill_date_detail
	@modu_id	char(2),
	@pc_id	char(4),
	@accnt 	char(10),	--团队帐号
	@begdate datetime,	--统计时间
	@enddate datetime,	--这个日期不使用
	@type   	char(3),		--grp,all,mem
	@isvalid char(3),		--isi,isd,all
	@isfut	char(1)		--T包括预计帐目 注意预计帐目的isfut=T
as

declare
	@amount		money,
	@rooms		integer,
	@date			datetime,
	@rmtype		char(5),
	@pccode		char(5),
	@roomno		char(5),
	@is_fut		char(1),
    @rmchgcode  char(5)
--	date日
--		rmtype(rooms间,amount元/间):descript
--		date日消费小计：pccode: sum(amount)

create table #checkbill
    (	pccode 	char(5)		null,
	 	rmtype 	char(5)		null,
	 	rlist		varchar(255) null,
		rlist1	varchar(255) null,
		rlist2	varchar(255) null,
		rlist3	varchar(255) null,
		rlist4	varchar(255) null,
		rlist5	varchar(255) null,
		rooms 	integer	default 0 null,
		rmrate	money		default 0 null,
		isfut	 	char(1)	null )

select @rmchgcode=value from sysoption where catalog='audit' and item='room_charge_pccode'
declare c_guest cursor for select pccode,rmtype,rooms,charge-credit,isfut from grp_checkbill
	where modu_id=@modu_id and pc_id=@pc_id and datediff(day,date,@begdate) = 0 and pccode=@rmchgcode order by date,rmtype
open c_guest
fetch c_guest into @pccode,@rmtype,@rooms,@amount,@is_fut
while @@sqlstatus = 0
	begin
	if not exists (select 1 from #checkbill where rmtype = @rmtype and rmrate=@amount and pccode=@pccode)
		insert #checkbill values (@rmchgcode,@rmtype,'','','','','','',0,@amount,@is_fut)
	update #checkbill set rooms = rooms + @rooms where rmtype = @rmtype and rmrate=@amount and pccode=@pccode

	fetch c_guest into @pccode,@rmtype,@rooms,@amount,@is_fut
	end
close c_guest
deallocate cursor c_guest

declare c_guest1 cursor for select distinct roomno,rmtype,charge-credit from grp_checkbill
	where modu_id=@modu_id and pc_id=@pc_id and datediff(day,date,@begdate) = 0 and pccode=@rmchgcode order by date,rmtype
open c_guest1
fetch c_guest1 into @roomno,@rmtype,@amount
while @@sqlstatus = 0
	begin
	if @roomno is not null
		begin
		update #checkbill set rlist5 = rlist5+' '+@roomno  where rmtype = @rmtype and rmrate=@amount and datalength(rlist4)>=250 and datalength(rlist5)<250
		update #checkbill set rlist4 = rlist4+' '+@roomno where rmtype = @rmtype and rmrate=@amount and datalength(rlist3)>=250 and datalength(rlist4)<250
		update #checkbill set rlist3 = rlist3+' '+@roomno where rmtype = @rmtype and rmrate=@amount and datalength(rlist2)>=250 and datalength(rlist3)<250
		update #checkbill set rlist2 = rlist2+' '+@roomno where rmtype = @rmtype and rmrate=@amount and datalength(rlist1)>=250 and datalength(rlist2)<250
		update #checkbill set rlist1 = rlist1+' '+@roomno where rmtype = @rmtype and rmrate=@amount and datalength(rlist)>=250 and datalength(rlist1)<250 
		update #checkbill set rlist =  rlist+' '+@roomno where rmtype = @rmtype and rmrate=@amount and datalength(rlist)<250
		end
	fetch c_guest1 into @roomno,@rmtype,@amount
	end
close c_guest1
deallocate cursor c_guest1

--update #checkbill set rooms = datalength(descript) / 5 where descript<>''

select b.descript,b.descript1,a.rlist,a.rlist1,a.rlist2,a.rlist3,a.rlist4,a.rlist5,a.rooms,a.rmrate,a.isfut
	 from #checkbill a,typim b where a.rmtype=b.type order by a.rmtype

return 0
;