if exists(select * from sysobjects where name = "p_zk_business_on_book" and type ='P')
	drop proc p_zk_business_on_book
;


create proc p_zk_business_on_book
   @start  datetime,
   @end    datetime,
   @roomtype   varchar(10)
as
declare
   @date   char(12),
   @ind_r  integer,
   @blk_r   integer,
   @d_blk    integer,
   @n_blk    integer,
   @t_rms    integer,
   @ooo      integer,
   @avbl     integer,
   @occ    money,
   @ind_revenue  money,
   @ind_avgrate   money,
   @blk_revenue   money,
   @blk_avgrate   money,
   @total_revenue money,
   @total_avgrate  money,
   @cur_date   char(12)
   
 
create table #bob
(
	date   char(12) null,
   ind_r  integer null,
   blk_r   integer null,
   d_blk    integer null,
   n_blk    integer null,
   t_rms    integer null,
   ooo      integer null,
   avbl     integer null ,
   occ    money null ,
   ind_revenue  money null ,
   ind_avgrate   money null,
   blk_revenue   money null,
   blk_avgrate   money null,
   total_revenue money null,
   total_avgrate  money null
)

if datediff(dd,@start,@end)>184
   return 1
if @roomtype='' or @roomtype=null select @roomtype='%'
if @roomtype<>'' or @roomtype<>null select @roomtype='%'+@roomtype+'%'
while @start<=@end
   begin
   select @ind_r=isnull(sum(rmnum),0) from master where class='F' and convert(char,arr,12)=convert(char,@start,12) and ratecode<>'COM' and setrate<>0 and rtrim(type) like rtrim(@roomtype)
   select @blk_r=isnull(sum(rmnum),0) from master where class<>'F' and convert(char,arr,12)=convert(char,@start,12) and roomno<>'' and ratecode<>'COM' and setrate<>0 and rtrim(type) like rtrim(@roomtype)
   select @d_blk=isnull(sum(a.rmnum),0) from master a,restype b where a.class<>'F' and convert(char,a.arr,12)=convert(char,@start,12) and roomno='' and a.restype=b.code and b.definite='T' and a.ratecode<>'COM' and a.setrate<>0 and rtrim(a.type) like rtrim(@roomtype)
   select @n_blk=isnull(sum(a.rmnum),0) from master a,restype b where a.class<>'F' and convert(char,a.arr,12)=convert(char,@start,12) and roomno='' and a.restype=b.code and b.definite='F' and a.ratecode<>'COM' and a.setrate<>0 and rtrim(a.type) like rtrim(@roomtype)
   select @t_rms=isnull(sum(a.rmnum),0)+@ind_r+@blk_r+@d_blk from master a,restype b where a.class<>'F' and convert(char,a.arr,12)=convert(char,@start,12) and roomno='' and a.restype=b.code and b.definite='F' and a.ratecode<>'COM' and a.setrate<>0 and rtrim(a.type) like rtrim(@roomtype)
   select @ooo=isnull(count(1),0) from rmsta where locked='L' and convert(char,futbegin,12)<=@start and (convert(char(8),futend,12) >= @start or futend is null) and (sta='O' or futsta='O') and tag='K' 
   select @avbl=isnull(count(*),0) -@ooo -@t_rms from rmsta 
   select @occ=convert(money,@t_rms)/convert(money,@ooo+@avbl+@t_rms) *100
   select @ind_revenue=sum(setrate) from master where class='F' and convert(char,arr,12)=convert(char,@start,12) and ratecode<>'COM' and setrate<>0 and rtrim(type) like rtrim(@roomtype)
   select @ind_avgrate= @ind_revenue / convert(money,count(*)) from master where class='F' and convert(char,arr,12)=convert(char,@start,12) and ratecode<>'COM' and setrate<>0 and rtrim(type) like rtrim(@roomtype)
   select @blk_revenue=sum(b.rate) from master a,rsvsrc b where a.class<>'F' and convert(char,a.arr,12)=convert(char,@start,12) and a.ratecode<>'COM' and a.accnt=b.accnt and rtrim(a.type) like rtrim(@roomtype)
   select @blk_avgrate= @blk_revenue / convert(money,count(*)) from master where class<>'F' and convert(char,arr,12)=convert(char,@start,12) and ratecode<>'COM' and setrate<>0 and rtrim(type) like rtrim(@roomtype)
   if @ind_revenue=null select @ind_revenue=0
   if @ind_avgrate=null select @ind_avgrate=0
   if @blk_revenue=null select @blk_revenue=0
   if @blk_avgrate=null select @blk_avgrate=0
   if @total_revenue=null select @total_revenue=0
   if @total_avgrate=null select @total_avgrate=0  
   select @total_revenue=@ind_revenue+@blk_revenue
   if @ind_avgrate<>0 and @blk_avgrate<>0
      select @total_avgrate=@total_revenue/convert(money,@ind_revenue/@ind_avgrate+@blk_revenue/@blk_avgrate)
   else if @ind_avgrate<>0
      select @total_avgrate=@total_revenue/convert(money,@ind_revenue/@ind_avgrate)
   else if @blk_avgrate<>0
      select @total_avgrate=@total_revenue/convert(money,@blk_revenue/@blk_avgrate)
   if datepart(dw,@start)=1
      select @cur_date=convert(char(8),@start,10)+' Mon'
   else if datepart(dw,@start)=2
      select @cur_date=convert(char(8),@start,10)+' Tue'
   else if datepart(dw,@start)=3
      select @cur_date=convert(char(8),@start,10)+' Wed'
   else if datepart(dw,@start)=4
      select @cur_date=convert(char(8),@start,10)+' Thu'
   else if datepart(dw,@start)=5
      select @cur_date=convert(char(8),@start,10)+' Fri'
   else if datepart(dw,@start)=6
      select @cur_date=convert(char(8),@start,10)+' Sat'
   else if datepart(dw,@start)=7
      select @cur_date=convert(char(8),@start,10)+' Sun'
   insert #bob select @cur_date,@ind_r,@blk_r,@d_blk,@n_blk,@t_rms,@ooo,@avbl,@occ,@ind_revenue,@ind_avgrate,@blk_revenue,@blk_avgrate,@total_revenue,@total_avgrate
   select @start=dateadd(dd,1,@start)
   select @cur_date=convert(char,@start,12)
   select @ind_r=0,@blk_r=0,@d_blk=0,@n_blk=0,@t_rms=0,@ooo=0,@avbl=0,@occ=0,@ind_revenue=0,@ind_avgrate=0,@blk_revenue=0,@blk_avgrate=0,@total_revenue=0,@total_avgrate=0
end 
select * from #bob order by date


;