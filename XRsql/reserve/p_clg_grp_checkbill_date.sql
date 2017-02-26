//按日期分组的框架
if exists(select * from sysobjects where name = 'p_clg_grp_checkbill_date')
	drop proc p_clg_grp_checkbill_date;

create proc p_clg_grp_checkbill_date
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
	@amount		money,	--金额
	@date			datetime,
	@pccode		char(5),--费用码
    @rm_pccodes char(50),  --房费费用码集
	@narr			int,
	@ndep			int,
	@ncom			int

create table #sum
	 ( date		datetime		null,
		amount0	money	default 0 null,	--房费
		amount1	money	default 0 null,	--餐费
		amount2	money	default 0 null,	--其他
       amount3 money   default 0 null,
		amount4	money	default 0 null,	--到达
		amount5	money	default 0 null,	--离开
      amount6 money   default 0 null )--免费

create table #master
	 ( accnt		char(10)		null,
		roomno	char(5) null,
		market	char(3) null,	
		setrate	money	default 0 null,
		arr		datetime null,
		dep		datetime null)

insert into #master(accnt,roomno,market,setrate,arr,dep) select accnt,roomno,market,setrate,arr,dep from master where groupno=@accnt and sta in ('I','R','S','O')
insert into #master(accnt,roomno,market,setrate,arr,dep) select accnt,roomno,market,setrate,arr,dep from hmaster where groupno=@accnt and sta ='O'

--调整日期 ylee 09.11.12
if exists(select 1 from master where accnt = @accnt and datediff(month,@begdate,arr) > 2)
	select @begdate = dateadd(day, -2, arr), @enddate = dateadd(day, 2, dep) from master where accnt = @accnt
if exists(select 1 from hmaster where accnt = @accnt and datediff(month,@begdate,arr) > 2)
	select @begdate = dateadd(day, -2, arr), @enddate = dateadd(day, 2, dep) from hmaster where accnt = @accnt

select @rm_pccodes=value from sysoption where catalog='audit' and item='room_charge_pccodes'
if @type='grp'
	begin
	if @isvalid='isi'
		declare c_guest cursor for select date,pccode,rooms*(charge-credit) from grp_checkbill
			where modu_id=@modu_id and pc_id=@pc_id and accnt=@accnt and billno='' and date>=@begdate and date<=@enddate and (@isfut='T' or isfut='F') order by date,pccode
	else if @isvalid='isd'
		declare c_guest cursor for select date,pccode,rooms*(charge-credit) from grp_checkbill
			where modu_id=@modu_id and pc_id=@pc_id and accnt=@accnt and billno<>'' and date>=@begdate and date<=@enddate and (@isfut='T' or isfut='F') order by date,pccode
	else
		declare c_guest cursor for select date,pccode,rooms*(charge-credit) from grp_checkbill
			where modu_id=@modu_id and pc_id=@pc_id and accnt=@accnt and date>=@begdate and date<=@enddate and (@isfut='T' or isfut='F') order by date,pccode
	end
else if @type='mem'
	begin
	if @isvalid='isi'
		declare c_guest cursor for select date,pccode,rooms*(charge-credit) from grp_checkbill
			where modu_id=@modu_id and pc_id=@pc_id and accnt<>@accnt and billno='' and date>=@begdate and date<=@enddate and (@isfut='T' or isfut='F') order by date,pccode
	else if @isvalid='isd'
		declare c_guest cursor for select date,pccode,rooms*(charge-credit) from grp_checkbill
			where modu_id=@modu_id and pc_id=@pc_id and accnt<>@accnt and billno<>'' and date>=@begdate and date<=@enddate and (@isfut='T' or isfut='F') order by date,pccode
	else
		declare c_guest cursor for select date,pccode,rooms*(charge-credit) from grp_checkbill
			where modu_id=@modu_id and pc_id=@pc_id and accnt<>@accnt and date>=@begdate and date<=@enddate and (@isfut='T' or isfut='F') order by date,pccode
	end
else
	begin
	if @isvalid='isi'
		declare c_guest cursor for select date,pccode,rooms*(charge-credit) from grp_checkbill
			where modu_id=@modu_id and pc_id=@pc_id and billno='' and date>=@begdate and date<=@enddate and (@isfut='T' or isfut='F') order by date,pccode
	else if @isvalid='isd'
		declare c_guest cursor for select date,pccode,rooms*(charge-credit) from grp_checkbill
			where modu_id=@modu_id and pc_id=@pc_id and billno<>'' and date>=@begdate and date<=@enddate and (@isfut='T' or isfut='F') order by date,pccode
	else
		declare c_guest cursor for select date,pccode,rooms*(charge-credit) from grp_checkbill
			where modu_id=@modu_id and pc_id=@pc_id and date>=@begdate and date<=@enddate and (@isfut='T' or isfut='F') order by date,pccode
	end

open c_guest
fetch c_guest into @date,@pccode,@amount
while @@sqlstatus = 0
	begin
	if not exists (select 1 from #sum where datediff(day,date,@date) = 0)
		insert #sum(date,amount0,amount1,amount2,amount3) values (@date,0,0,0,0)
	if exists(select 1 from pccode where pccode=@pccode and deptno7='rm')
		update #sum set amount0 = amount0 + @amount where datediff(day,date,@date) = 0
	else if exists(select 1 from pccode where pccode=@pccode and deptno7='fb')
		update #sum set amount1 = amount1 + @amount where datediff(day,date,@date) = 0
	else if exists(select 1 from pccode where pccode=@pccode and argcode<'98')
		update #sum set amount2 = amount2 + @amount where datediff(day,date,@date) = 0
    else
    	update #sum set amount3 = amount3 + @amount where datediff(day,date,@date) = 0
	fetch c_guest into @date,@pccode,@amount
	end
close c_guest
deallocate cursor c_guest


select @date = min(date),@enddate = max(date) from #sum
while datediff(dd,@date,@enddate)>=0
	begin
	select @narr=count(distinct roomno) from #master where datediff(dd,arr,@date)=0
	select @ndep=count(distinct roomno) from #master where datediff(dd,dep,@date)=0
	select @ncom=count(distinct roomno) from #master a,mktcode b where datediff(dd,@date,arr)<=0 and datediff(dd,@date,dep)>=0 and a.market=b.code and b.flag='COM'
	update #sum set amount4=@narr,amount5=@ndep, amount6=@ncom where datediff(dd,date,@date)=0
	select @date = dateadd(dd,1,@date)
	end

select c.haccnt,a.credman,a.arr,a.dep,a.accnt,b.date,b.amount0,b.amount1,b.amount2,b.amount3,b.amount4,b.amount5,b.amount6
	 from master a,#sum b, master_des c where a.accnt=@accnt and a.accnt=c.accnt
union 
select a.name,a.credman,a.arr,a.dep,a.accnt,b.date,b.amount0,b.amount1,b.amount2,b.amount3,b.amount4,b.amount5,b.amount6
	 from hmaster a,#sum b where a.accnt=@accnt
 order by date

return 0
;