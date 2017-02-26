IF OBJECT_ID('dbo.p_clg_report_history_forecast1') IS NOT NULL
    DROP PROCEDURE dbo.p_clg_report_history_forecast1
;
create proc p_clg_report_history_forecast1
	@begin_	datetime,
   @end_	datetime,
	@gtype	varchar(250)

as
declare
	@date		datetime,
   @quantity money,
   @amount money,
   @bdate    datetime,
	@gtype1	char(3),
    @gtype2 varchar(250),
	@type		char(5),
	@types	varchar(250),
	@pos		int,
    @pc_id  char(4)

create table #goutput(
	class		char(1)		null,
	date		datetime		null,
	occ		int			null,
	arr		int			null,
	free		int			null,
	htl		int			null,
    sold    int         null,
	d_ind		int			null,
	nd_ind	int			null,
	d_grp		int			null,
	nd_grp	int			null,
	occupancy	money		null,
    occpay      money       null,
	rm_rev		money		null,
	avr		money			null,
    avrpay  money           null,
	dep		int			null,
	ooo		int			null,
	gst		int			null)

--rsvsrc_detail
select @pc_id = substring(max(pc_id),1,3)+'0' from rmratecode_check
exec p_yjw_reserve_rsvsrc_calc '',@pc_id,1

select @gtype2 = ','+rtrim(@gtype)+','
if rtrim(@gtype) is null
	select @types = '%',@gtype2 = '%'
else
	begin
	declare c_type cursor for select type from typim where gtype = @gtype1
	select @pos = charindex(',',rtrim(@gtype)+',')
	select @gtype1 = substring(@gtype, 1, @pos - 1)
	select @types = '_'
	while rtrim(@gtype1) is not null
		begin
		open c_type
		fetch c_type into @type
		while @@sqlstatus=0
			begin
			select @types = @types + substring(@type+space(5),1,5) + '_'
			fetch c_type into @type
			end
		close c_type
		select @gtype = substring(@gtype, @pos+1, 250)
		select @pos = charindex(',',rtrim(@gtype)+',')
		select @gtype1 = substring(@gtype, 1, @pos - 1)
		end
	deallocate cursor c_type
	end

select @bdate = bdate from sysdata
--计算历史audit_impdata
select @date= @begin_
if datediff(dd,@end_,@bdate)>0
	select @bdate=dateadd(dd,1,@end_)
while datediff(dd,@date,@bdate)>0
begin
	insert into #goutput values('H',@date,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
	if @gtype2='%'
		begin
		update #goutput set occ=amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class='occ' and datediff(dd,@date,#goutput.date)=0
		update #goutput set arr=amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class='act_arr' and datediff(dd,@date,#goutput.date)=0
		update #goutput set free=amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class='free' and datediff(dd,@date,#goutput.date)=0
		update #goutput set htl=amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class='htl' and datediff(dd,@date,#goutput.date)=0
		update #goutput set occupancy=amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class='occ_o%' and datediff(dd,@date,#goutput.date)=0
		update #goutput set rm_rev=amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class='income' and datediff(dd,@date,#goutput.date)=0
		update #goutput set dep=amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class='act_dep' and datediff(dd,@date,#goutput.date)=0
		update #goutput set ooo=amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class='mnt' and datediff(dd,@date,#goutput.date)=0
		update #goutput set gst=amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class='gstih' and datediff(dd,@date,#goutput.date)=0
		update #goutput set d_ind= amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class in ('sold_fit') and datediff(dd,@date,#goutput.date)=0
		update #goutput set d_grp= amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class in ('sold_mem') and datediff(dd,@date,#goutput.date)=0
		end
	else
		begin
		select @quantity = isnull(sum(a.amount),0) from ymanager_report a
							where datediff(dd,@date,a.date)=0 and a.class='occ' and charindex(','+rtrim(a.gtype)+',',@gtype2)>0
		update #goutput set occ=@quantity where datediff(dd,@date,date)=0
		select @quantity = isnull(sum(a.amount),0) from ymanager_report a
							where datediff(dd,@date,a.date)=0 and a.class='act_arr' and charindex(','+rtrim(a.gtype)+',',@gtype2)>0
		 update #goutput set arr=@quantity where datediff(dd,@date,date)=0
		select @quantity = isnull(sum(a.amount),0) from ymanager_report a
							where datediff(dd,@date,a.date)=0 and a.class='free' and charindex(','+rtrim(a.gtype)+',',@gtype2)>0
		update #goutput set free=@quantity where datediff(dd,@date,date)=0
		select @quantity = isnull(sum(a.amount),0) from ymanager_report a
							where datediff(dd,@date,a.date)=0 and a.class='htl' and charindex(','+rtrim(a.gtype)+',',@gtype2)>0
		update #goutput set htl=@quantity where datediff(dd,@date,date)=0
		 select @amount = isnull(sum(a.amount),0) from ymanager_report a
							where datediff(dd,@date,a.date)=0 and a.class='occ_o%' and charindex(','+rtrim(a.gtype)+',',@gtype2)>0
		update #goutput set occupancy=@amount where datediff(dd,@date,date)=0
		select @amount = isnull(sum(a.amount),0) from ymanager_report a
							where datediff(dd,@date,a.date)=0 and a.class='income' and charindex(','+rtrim(a.gtype)+',',@gtype2)>0
		update #goutput set rm_rev=@amount where datediff(dd,@date,date)=0
	 --   select @amount = @quantity / a.occ from #goutput a
	--						where datediff(dd,@date,a.date)=0 and a.occ<>0
	--	update #goutput set avr=@amount where datediff(dd,@date,date)=0
		 select @quantity = isnull(sum(a.amount),0) from ymanager_report a
							where datediff(dd,@date,a.date)=0 and a.class='act_dep' and charindex(','+rtrim(a.gtype)+',',@gtype2)>0
		update #goutput set dep=@quantity where datediff(dd,@date,date)=0
		 select @quantity = isnull(sum(a.amount),0) from ymanager_report a
							where datediff(dd,@date,a.date)=0 and a.class='mnt' and charindex(','+rtrim(a.gtype)+',',@gtype2)>0
		update #goutput set ooo=@quantity where datediff(dd,@date,date)=0
		select @quantity = isnull(sum(a.amount),0) from ymanager_report a
							where datediff(dd,@date,a.date)=0 and a.class='gstih' and charindex(','+rtrim(a.gtype)+',',@gtype2)>0
		update #goutput set gst=@quantity where datediff(dd,@date,date)=0
		 select @quantity = isnull(sum(a.amount),0) from ymanager_report a
							where datediff(dd,@date,a.date)=0 and a.class='sold_fit' and charindex(','+rtrim(a.gtype)+',',@gtype2)>0
		 update #goutput set d_ind=@quantity where datediff(dd,@date,date)=0
		select @quantity = isnull(sum(a.amount),0) from ymanager_report a
							where datediff(dd,@date,a.date)=0 and a.class='sold_mem' and charindex(','+rtrim(a.gtype)+',',@gtype2)>0
		 update #goutput set d_grp=@quantity where datediff(dd,@date,date)=0
		end
   select @date=dateadd(dd,1,@date)
end

select @bdate = bdate from sysdata
--计算未来rsv_index
select @date= @end_
if datediff(dd,@begin_,@bdate)<0
   select @bdate=@begin_
while datediff(dd,@date,@bdate)<=0
begin
  insert into #goutput values('F',@date,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)

  exec p_gds_reserve_rsv_index @date, @types, 'Occupied Tonight', 'R', @quantity output
  update #goutput set occ=@quantity where datediff(dd,@date,#goutput.date)=0
  --出租率=占用/总房数？
  select @amount=100*@quantity/count(1) from rmsta where tag='K' and sta<>'O'
  update #goutput set occupancy=@amount where datediff(dd,@date,#goutput.date)=0
  exec p_gds_reserve_rsv_index @date, @types, 'Arrival Rooms', 'R', @quantity output
  update #goutput set arr=@quantity where datediff(dd,@date,#goutput.date)=0
  exec p_gds_reserve_rsv_index @date, @types, 'COM', 'R', @quantity output
  update #goutput set free=@quantity where datediff(dd,@date,#goutput.date)=0
  exec p_gds_reserve_rsv_index @date, @types, 'HSE', 'R', @quantity output
  update #goutput set htl=@quantity where datediff(dd,@date,#goutput.date)=0
  --总房数减自用房
  --update #goutput set occ=occ - @quantity where datediff(dd,@date,#goutput.date)=0

  exec p_clg_reserve_rsv_index @date, @types, 'Definite Reservations/FIT', 'R', @quantity  output
  update #goutput set d_ind=@quantity where datediff(dd,@date,#goutput.date)=0
  exec p_clg_reserve_rsv_index @date, @types, 'Tentative Reservation/FIT', 'R', @quantity  output
  update #goutput set nd_ind=@quantity where datediff(dd,@date,#goutput.date)=0


  exec p_clg_reserve_rsv_index @date, @types, 'Definite Reservations/GRP', 'R', @quantity output
  update #goutput set d_grp=@quantity where datediff(dd,@date,#goutput.date)=0
  exec p_clg_reserve_rsv_index @date, @types, 'Tentative Reservation/GRP', 'R', @quantity output
  update #goutput set nd_grp=@quantity where datediff(dd,@date,#goutput.date)=0

  --exec p_gds_reserve_rsv_index @date, @types, 'Room Revenue Include SVC', 'R', @amount output 实际结果与描述不符，没有包含外加服务费
   select @amount = isnull(sum(a.quantity*(a.qrate+a.p_srv)),0) from rsvsrc_detail a,master b
        where a.accnt=b.accnt and a.date_ = @date and (@types='%' or charindex(a.type, @types)>0) and charindex(b.sta,'IR')>0
  update #goutput set rm_rev=@amount where datediff(dd,@date,#goutput.date)=0
  --exec p_gds_reserve_rsv_index @date, @types, 'Average Room Rate', 'R', @quantity output
  --update #goutput set avr=@quantity where datediff(dd,@date,#goutput.date)=0
  exec p_gds_reserve_rsv_index @date, @types, 'Departure Rooms', 'R', @quantity output
  update #goutput set dep=@quantity where datediff(dd,@date,#goutput.date)=0
  exec p_gds_reserve_rsv_index @date, @types, 'Out of Order', 'R', @quantity output
  update #goutput set ooo=@quantity where datediff(dd,@date,#goutput.date)=0
  exec p_gds_reserve_rsv_index @date, @types, 'Out of Service', 'R', @amount output
  update #goutput set ooo=@quantity+@amount where datediff(dd,@date,#goutput.date)=0

  exec p_gds_reserve_rsv_index @date, @types, 'People In-House', 'R', @quantity output
  update #goutput set gst=@quantity where datediff(dd,@date,#goutput.date)=0
  select @date=dateadd(dd,-1,@date)
end

--计算当天到达离开要特殊计算包括已退房
select @date = bdate from sysdata
if datediff(dd,@begin_,@date)>=0 and datediff(dd,@end_,@date)<=0
begin
	select @quantity=isnull(sum(a.rmnum),0) from master a where a.class='F' and a.sta in ('I','R','O','S') and datediff(dd,a.arr,@date)=0
		 and (charindex('_'+a.type+'_',@types)>0 or @types='%') and a.roomno=''
	select @quantity=@quantity+count(distinct a.roomno) from master a where a.class='F' and a.sta in ('I','R','O','S') and datediff(dd,a.arr,@date)=0
		 and (charindex('_'+a.type+'_',@types)>0 or @types='%') and a.roomno<>''

//	select @quantity=count(distinct a.saccnt) from master a where a.class='F' and a.sta in ('I','R','O','S') and datediff(dd,a.arr,@date)=0
//		 and (charindex('_'+a.type+'_',@types)>0 or @types='%')
  update #goutput set arr= 0 + @quantity where datediff(dd,@date,#goutput.date)=0













	select @quantity=count(distinct a.roomno) from master a where a.class='F' and a.sta in ('I','R','O','S') and datediff(dd,a.dep,@date)=0
		 and (charindex('_'+a.type+'_',@types)>0 or @types='%')
  update #goutput set dep= 0 + @quantity where datediff(dd,@date,#goutput.date)=0
end

--sofit 要求ARR=Rm_rev/(occ-free)
update #goutput set sold = (occ - free - htl)
update #goutput set avr=rm_rev/occ,avrpay =rm_rev/sold  where sold<>0
select @quantity = count(1) from rmsta where tag='K' and sta<>'O'
update #goutput set occpay = 100.00*sold/@quantity

 select #goutput.class, #goutput.date, #goutput.occ, #goutput.arr, #goutput.free, #goutput.htl, #goutput.sold, #goutput.d_ind, #goutput.nd_ind, #goutput.d_grp, #goutput.nd_grp, #goutput.occupancy, #goutput.occpay, #goutput.rm_rev, #goutput.avr, #goutput.avrpay, #goutput.dep, #goutput.ooo, #goutput.gst from #goutput order  by date
;
