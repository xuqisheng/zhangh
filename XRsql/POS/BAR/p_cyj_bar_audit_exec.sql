
if exists(select 1 from sysobjects where name = 'p_cyj_bar_audit_exec' and type = 'P') 
	drop proc p_cyj_bar_audit_exec;

create proc p_cyj_bar_audit_exec
as
--------------------------------------------------------------------------------
--
--		��̨�����ת, ��ҹ���ת, ��sysoption�趨
--		insert into sysoption   select 'pos', 'bar_month_mode' ,'day', '��̨��תģʽ, day:����; month:����'
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

-- �����̨�Ѿ���ת
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




