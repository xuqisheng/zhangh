drop  procedure p_cq_sp_guest_count;
create procedure p_cq_sp_guest_count
			@begin_			datetime,
			@end_				datetime
			
as
declare
			@guest1			integer,
			@guest2			integer,
			@guest3			integer,
			@guest4			integer,
			@bdate			datetime,
			@code				char(2),
			@descript		char(20),
			@sort				char(2)
	

create table #count
(
	class		char(10),
	name		char(20),
	number	money
)

select @bdate = bdate1 from sysdata

declare c_sort cursor for 
	select sort,name from sp_place_sort order by sort
open c_sort
fetch c_sort into @code,@descript
while	@@sqlstatus = 0
	begin
	select @guest1 = isnull(sum(a.guest),0) from sp_hmenu a,sp_hpay b where a.menu in (
		select menu from sp_hplaav where placecode in (select placecode from sp_place where sort = @sort))
		and datediff(dd,@begin_,a.bdate) >= 0 and datediff(dd,@end_,a.bdate) <=0 
		and a.menu = b.menu and b.paycode = 'GL' and a.sta = '3'
	insert #count select '住店客人',@descript,@guest1
	select @guest2 = isnull(sum(a.guest),0) from sp_hmenu a,sp_hpay b where a.menu in (
		select menu from sp_hplaav where placecode in (select placecode from sp_place where sort = @sort))
		and datediff(dd,@begin_,a.bdate) >= 0 and datediff(dd,@end_,a.bdate) <=0 
		and a.menu = b.menu and a.cardno <> '' and a.sta = '3'
	select @guest3 = isnull(count(1),0) from sp_pla_use a where a.placecode in (select placecode from sp_place where sort = @sort)
		and datediff(dd,@begin_,a.bdate) >= 0 and datediff(dd,@end_,a.bdate) <=0 
	insert #count select '会员客人',@descript,@guest2+@guest3
	select @guest4 = isnull(sum(a.guest),0) from sp_hmenu a,sp_hpay b where a.menu in (
		select menu from sp_hplaav where placecode in (select placecode from sp_place where sort = @sort))
		and datediff(dd,@begin_,a.bdate) >= 0 and datediff(dd,@end_,a.bdate) <=0 
		and a.menu = b.menu and b.paycode <> 'GL' and a.sta = '3' and a.cardno = ''
	insert #count select '其他客人',@descript,@guest4
	
	fetch c_sort into @code,@descript
	end
close c_sort
deallocate cursor c_sort

select class,name,number from #count

;