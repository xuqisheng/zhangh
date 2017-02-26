
if exists(select 1 from sysobjects where name = 'p_cyj_bar_audit_exec' and type = 'P') 
	drop proc p_cyj_bar_audit_exec;

create proc p_cyj_bar_audit_exec
as
--------------------------------------------------------------------------------
--
--		吧台按天结转, 由夜审结转, 由sysoption设定
--		insert into sysoption   select 'pos', 'bar_month_mode' ,'day', '吧台结转模式, day:按天; month:按月'
--
--------------------------------------------------------------------------------
declare	
	@bdate		datetime,
	@storecode		char(3),
	@storeid		int,
	@name			char(30),
	@number		money

if not exists(select 1 from sysoption where catalog = 'pos' and item = 'bar_month_mode' and value = 'day')
	return

select @bdate = bdate1 from sysdata

-- 当天吧台已经结转
if exists(select 1 from pos_store_month where month = @bdate)
	return

begin tran 
save  tran t_bar_audit
declare c_bar cursor for select storecode,condid,descript,number from pos_store_store
open c_bar
fetch c_bar into @storecode,@storeid,@name,@number
while @@sqlstatus = 0 
	begin
	exec p_cyj_bar_month_sfc @bdate,@storeid,@name,@storecode,@bdate
	fetch c_bar into @storecode,@storeid,@name,@number
	end
close c_bar
deallocate cursor c_bar

exec p_cyj_bar_month_end @bdate, @bdate, @bdate, 'Audit'
commit tran
;




