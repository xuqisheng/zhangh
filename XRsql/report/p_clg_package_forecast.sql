drop proc p_clg_package_forecast;
create proc p_clg_package_forecast
	@mode		char(3),
	@begin	datetime,
	@end		datetime,
	@grp		char(50), --sum有效
	@pkgs		char(50),	--dtl有效
	@type		char(50)
as
declare
@date	datetime,
@rm	money,
@aih	money,
@cih	money,
@arr	money,
@dep	money,
@pkg	char(4), --sum作为包价组，dtl作为包价
@code	char(4), --sum作为包价
@cnt	int,
@m		money,
@m1	money,
@m2	money,
@m3	money,
@m4	money,
@m5	money,
@m6	money,
@m7	money,
@m8	money,
@m9	money,
@m10	money

create table #rsv(
	saccnt	char(10),
	date_		datetime,
	quantity	int,
	gstno		int,
	child		int,
	packages	varchar(50),
	tarr		datetime,
	tdep		datetime)
create table #rslt(
	date				datetime,
	des				char(10),
	rm					money default 0,
	aih				money default 0,
	cih				money default 0,
	arr			money default 0,
	dep			money default 0,
	m1			money default 0,
	m2			money default 0,
	m3			money default 0,
	m4			money default 0,
	m5			money default 0,
	m6			money default 0,
	m7			money default 0,
	m8			money default 0,
	m9			money default 0,
	m10			money default 0
)

select @date = bdate from sysdata
if @begin is not null and @begin > @date
	select @date=@begin

if @end is null or @end<@date
	select @end = @date
--根据fidelio的样板，前半部分数据与package无关。后半部分才是package的数据。
insert into #rsv select a.saccnt,a.date_,a.quantity,a.gstno,b.children,a.packages,a.arr,a.dep from rsvsrc_detail a,master b,typim c where -- not rtrim(packages) is null and
		datediff(dd,a.date_,@end)>=0 and datediff(dd,a.date_,@date)<=0 and (charindex(rtrim(a.type),@type)>0 or rtrim(@type) is null) and a.accnt=b.accnt and a.type=c.type and c.tag='K'

if @mode='sum'
	begin
	declare c_pkg cursor for select code from basecode where cat='package_type' and (charindex(rtrim(code),@grp)>0 or rtrim(@grp) is null) order by code
	declare c_code cursor for select code from package where charindex(rtrim(type),@pkg)>0 or rtrim(@pkg) is null order by type,code
	end
else
	declare c_pkg cursor for select code from package where charindex(rtrim(code),@pkgs)>0 or rtrim(@pkgs) is null order by type,code

while datediff(dd,@end,@date)<=0
	begin
	select @rm		= isnull(count(saccnt),0) from #rsv where datediff(dd,date_,@date)=0
	select @rm		= @rm - (select isnull(count(distinct saccnt),0) from #rsv where datediff(dd,date_,@date)=0)
	select @rm		= (select isnull(sum(quantity),0) from #rsv where datediff(dd,date_,@date)=0) - @rm

	select @arr		 = isnull(sum(quantity*gstno),0) from #rsv where datediff(dd,date_,@date)=0 and datediff(dd,tarr,date_)=0
	select @dep		 = isnull(sum(a.quantity*a.gstno),0) from rsvsrc a,typim b where datediff(dd,a.end_,@date)=0 and datediff(dd,a.begin_,@date)>0 and a.type=b.type and b.tag='K'

	select @aih	 = isnull(sum(quantity*gstno),0) from #rsv where datediff(dd,date_,@date)=0
	select @cih	 = isnull(sum(quantity*child),0) from #rsv where datediff(dd,date_,@date)=0

	select @cnt=0
	open c_pkg
	fetch c_pkg into @pkg
	while @@sqlstatus=0
	begin
	if @mode='sum'
		begin
		select @m = 0
		open c_code
		fetch c_code into @code
		while @@sqlstatus = 0
			begin
			select @m = @m+isnull(sum(quantity*gstno),0) from #rsv where datediff(dd,date_,@date)=0 and charindex(rtrim(@code),packages)>0
			fetch c_code into @code
			end
		close c_code
		end
	else
		select @m = isnull(sum(quantity*gstno),0) from #rsv where datediff(dd,date_,@date)=0 and charindex(rtrim(@pkg),packages)>0
	select @cnt = @cnt + 1
	if @cnt = 1
		select @m1 = isnull(@m,0)
	else if @cnt = 2
		select @m2 = isnull(@m,0)
	else if @cnt = 3
		select @m3 = isnull(@m,0)
	else if @cnt = 4
		select @m4 = isnull(@m,0)
	else if @cnt = 5
		select @m5 = isnull(@m,0)
	else if @cnt = 6
		select @m6 = isnull(@m,0)
	else if @cnt = 7
		select @m7 = isnull(@m,0)
	else if @cnt = 8
		select @m8 = isnull(@m,0)
	else if @cnt = 9
		select @m9 = isnull(@m,0)
	else if @cnt = 10
		select @m10 = isnull(@m,0)

	fetch c_pkg into @pkg
	end
	close c_pkg
	insert into #rslt select @date,substring(datename(weekday, @date),1,3),@rm,@aih,@cih,@arr,@dep,isnull(@m1,0),isnull(@m2,0),isnull(@m3,0),isnull(@m4,0),isnull(@m5,0),isnull(@m6,0),isnull(@m7,0),isnull(@m8,0),isnull(@m9,0),isnull(@m10,0)

	select @date = dateadd(dd,1,@date)
	end

	if @mode='sum'
		deallocate cursor c_code
	deallocate cursor c_pkg
	select * from #rslt order by date
;