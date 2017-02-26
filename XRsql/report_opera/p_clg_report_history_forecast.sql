--E44的过程
drop proc p_clg_report_history_forecast;
create proc p_clg_report_history_forecast
	@begin_	datetime,
   @end_	datetime

as
declare
	@date		datetime,
   @quantity money,
   @bdate    datetime


create table #goutput(
	class		char(1)		null,
	date		datetime		null,
	occ		int			null,
	arr		int			null,
	free		int			null,
	htl		int			null,
	d_ind		int			null,
	nd_ind	int			null,
	d_grp		int			null,
	nd_grp	int			null,
	occupancy	money		null,
	rm_rev		money		null,
	avr		money			null,
	dep		int			null,
	ooo		int			null,
	gst		int			null)


select @bdate = bdate from sysdata


--计算历史audit_impdata
select @date= @begin_
if datediff(dd,@end_,@bdate)>0
	select @bdate=dateadd(dd,1,@end_)
while datediff(dd,@date,@bdate)>0
begin
	insert into #goutput values('H',@date,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
	update #goutput set occ=amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class='occ' and datediff(dd,@date,#goutput.date)=0
	update #goutput set arr=amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class='act_arr' and datediff(dd,@date,#goutput.date)=0
	update #goutput set free=amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class='free' and datediff(dd,@date,#goutput.date)=0
	update #goutput set htl=amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class='htl' and datediff(dd,@date,#goutput.date)=0
	update #goutput set occupancy=amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class='occ%' and datediff(dd,@date,#goutput.date)=0
	update #goutput set rm_rev=amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class='income' and datediff(dd,@date,#goutput.date)=0
	update #goutput set avr=amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class='income%' and datediff(dd,@date,#goutput.date)=0
	update #goutput set dep=amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class='act_dep' and datediff(dd,@date,#goutput.date)=0
	update #goutput set ooo=amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class='ooo' and datediff(dd,@date,#goutput.date)=0
	update #goutput set gst=amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class='gstih' and datediff(dd,@date,#goutput.date)=0
   update #goutput set d_ind= amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class in ('soldf') and datediff(dd,@date,#goutput.date)=0
   update #goutput set d_grp= amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class in ('soldg') and datediff(dd,@date,#goutput.date)=0
   update #goutput set d_grp= d_grp+amount from yaudit_impdata where datediff(dd,@date,yaudit_impdata.date)=0 and yaudit_impdata.class in ('soldc') and datediff(dd,@date,#goutput.date)=0
	select @date=dateadd(dd,1,@date)
end

select @bdate = bdate from sysdata
--计算未来rsv_index
select @date= @end_
if datediff(dd,@begin_,@bdate)<0
   select @bdate=@begin_
while datediff(dd,@date,@bdate)<=0
begin
  insert into #goutput values('F',@date,0,0,0,0,0,0,0,0,0,0,0,0,0,0)

  exec p_gds_reserve_rsv_index @date, '%', 'Occupied Tonight', 'R', @quantity output
  update #goutput set occ=@quantity where datediff(dd,@date,#goutput.date)=0
  --出租率=占用/总房数？
  select @quantity=100*@quantity/count(1) from rmsta
  update #goutput set occupancy=@quantity where datediff(dd,@date,#goutput.date)=0
  exec p_gds_reserve_rsv_index @date, '%', 'Arrival Rooms', 'R', @quantity output
  update #goutput set arr=@quantity where datediff(dd,@date,#goutput.date)=0
  exec p_gds_reserve_rsv_index @date, '%', 'COM', 'R', @quantity output
  update #goutput set free=@quantity where datediff(dd,@date,#goutput.date)=0
  exec p_gds_reserve_rsv_index @date, '%', 'HSE', 'R', @quantity output
  update #goutput set htl=@quantity where datediff(dd,@date,#goutput.date)=0
  --总房数减自用房
  --update #goutput set occ=occ - @quantity where datediff(dd,@date,#goutput.date)=0

 -- exec p_yb_reserve_rsv_index @date, '%', 'Definite Reservations/FIT', 'R', @quantity  output
 -- update #goutput set d_ind=@quantity where datediff(dd,@date,#goutput.date)=0
 -- exec p_yb_reserve_rsv_index @date, '%', 'Tentative Reservation/FIT', 'R', @quantity  output
 -- update #goutput set nd_ind=@quantity where datediff(dd,@date,#goutput.date)=0


 -- exec p_yb_reserve_rsv_index @date, '%', 'Definite Reservations/GRP', 'R', @quantity output
 -- update #goutput set d_grp=@quantity where datediff(dd,@date,#goutput.date)=0
 -- exec p_yb_reserve_rsv_index @date, '%', 'Tentative Reservation/GRP', 'R', @quantity output
 -- update #goutput set nd_grp=@quantity where datediff(dd,@date,#goutput.date)=0

  exec p_gds_reserve_rsv_index @date, '%', 'Room Revenue', 'R', @quantity output
  update #goutput set rm_rev=@quantity where datediff(dd,@date,#goutput.date)=0
  exec p_gds_reserve_rsv_index @date, '%', 'Average Room Rate', 'R', @quantity output
  update #goutput set avr=@quantity where datediff(dd,@date,#goutput.date)=0
  exec p_gds_reserve_rsv_index @date, '%', 'Departure Rooms', 'R', @quantity output
  update #goutput set dep=@quantity where datediff(dd,@date,#goutput.date)=0
  exec p_gds_reserve_rsv_index @date, '%', 'Out of Order', 'R', @quantity output
  update #goutput set ooo=@quantity where datediff(dd,@date,#goutput.date)=0

  exec p_gds_reserve_rsv_index @date, '%', 'People In-House', 'R', @quantity output
  update #goutput set gst=@quantity where datediff(dd,@date,#goutput.date)=0
  select @date=dateadd(dd,-1,@date)
end

--计算当天到达离开要特殊计算包括已退房
select @bdate = bdate from sysdata
if datediff(dd,@begin_,@bdate)>=0 and datediff(dd,@end_,@bdate)<=0
begin
	select @quantity=count(distinct a.roomno) from master a where a.class='F' and a.sta in ('O','S') and datediff(dd,a.arr,@bdate)=0
--  exec p_gds_reserve_rsv_index @date, '%', 'Arrival Rooms', 'R', @quantity output
  update #goutput set arr=arr+@quantity where datediff(dd,@bdate,#goutput.date)=0
  --总房数减自用房
 -- update #goutput set occ=occ - @quantity where datediff(dd,@date,#goutput.date)=0

  --exec p_yb_reserve_rsv_index @date, '%', 'Definite Reservations/FIT', 'R', @quantity  output
	select @quantity=count(distinct a.roomno) from master a,restype b where a.class='F' and a.sta in ('O','S') and datediff(dd,a.arr,@bdate)=0 and a.restype=b.code and b.definite='T' and a.groupno=''
  update #goutput set d_ind=d_ind+@quantity where datediff(dd,@date,#goutput.date)=0
  --exec p_yb_reserve_rsv_index @date, '%', 'Tentative Reservation/FIT', 'R', @quantity  output
	select @quantity=count(distinct a.roomno) from master a,restype b where a.class='F' and a.sta in ('O','S') and datediff(dd,a.arr,@bdate)=0 and a.restype=b.code and b.definite<>'T' and a.groupno=''
  update #goutput set nd_ind=nd_ind+@quantity where datediff(dd,@date,#goutput.date)=0


  --exec p_yb_reserve_rsv_index @date, '%', 'Definite Reservations/GRP', 'R', @quantity output
	select @quantity=count(distinct a.roomno) from master a,restype b where a.class='F' and a.sta in ('O','S') and datediff(dd,a.arr,@bdate)=0 and a.restype=b.code and b.definite='T' and a.groupno<>''
  update #goutput set d_grp=d_grp+@quantity where datediff(dd,@date,#goutput.date)=0
 -- exec p_yb_reserve_rsv_index @date, '%', 'Tentative Reservation/GRP', 'R', @quantity output
	select @quantity=count(distinct a.roomno) from master a,restype b where a.class='F' and a.sta in ('O','S') and datediff(dd,a.arr,@bdate)=0 and a.restype=b.code and b.definite<>'T' and a.groupno<>''
  update #goutput set nd_grp=nd_grp+@quantity where datediff(dd,@date,#goutput.date)=0
--  exec p_gds_reserve_rsv_index @date, '%', 'Departure Rooms', 'R', @quantity output
	select @quantity=count(distinct a.roomno) from master a where a.class='F' and a.sta in ('O','S') and datediff(dd,a.dep,@bdate)=0
  update #goutput set dep=dep+@quantity where datediff(dd,@bdate,#goutput.date)=0
end
select * from #goutput order  by date
;



