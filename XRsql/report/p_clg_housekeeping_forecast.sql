drop proc p_clg_housekeeping_forecast;
create proc p_clg_housekeeping_forecast
	@begin	datetime,
	@end		datetime
as
declare
@date	datetime,
@gst	money,
@mrm	money,
@arr	money,
@dep	money,
@erm	money,
@egst	money

create table #rslt(
	date				datetime,
	des				char(10),
	gst				money,
	morning			money,
	arr				money,
	dep				money,
	evening			money
)

select @date = bdate from sysdata
if @begin is not null and @begin > @date
	select @date=@begin

if @end is null or @end<@date
	select @end = @date

while datediff(dd,@end,@date)<=0
	begin
	select @mrm		 = isnull(sum(a.quantity),0) from rsvsaccnt a,typim b where datediff(dd,a.begin_,@date)>=1 and datediff(dd,a.end_,@date)<1 and a.type=b.type and b.tag='K'
	select @arr		 = isnull(sum(a.quantity),0) from rsvsaccnt a,typim b where datediff(dd,a.begin_,@date)=0 and a.type=b.type and b.tag='K'
	select @dep		 = isnull(sum(a.quantity),0) from rsvsaccnt a,typim b where datediff(dd,a.end_,@date)=0 and a.type=b.type and b.tag='K'

	select @erm 	 = @mrm + @arr - @dep
	select @egst	 = isnull(sum(a.quantity*a.gstno),0) from rsvsrc a,typim b where datediff(dd,a.begin_,@date)>=0 and datediff(dd,a.end_,@date)<0 and a.type=b.type and b.tag='K'

	insert into #rslt select @date,substring(datename(weekday,@date),1,3),@egst,@mrm,@arr,@dep,@erm

	select @date = dateadd(dd,1,@date)
	end

	select * from #rslt order by date
;